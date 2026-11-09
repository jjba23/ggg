;; ggg: guile glyph generator
;;
;; Spdx-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; Commentary:
;;
;; `ggg --serve' answers GET /badge.svg?text=... with a badge, so a README can
;; link to a badge that a query string describes instead of to a rendered file.
;; The root path serves a small builder page with a live preview.  A request
;; only builds an ordinary glyph, which (ggg glyph) renders with the same code
;; the command line uses, and one that describes no valid badge is answered
;; with 400 and the reasons, never with a broken image.

(define-module (ggg server)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (web request)
  #:use-module (web response)
  #:use-module (web server)
  #:use-module (web uri)
  #:use-module (ggg colors)
  #:use-module (ggg glyph)
  #:use-module (ggg logo)
  #:use-module (ggg prelude)
  #:use-module (ggg sxml)
  #:use-module (ggg style)
  #:export (query-params badge-glyph badge-handler serve))

;; A badge in a README is short; the caps keep a hand-typed URL from turning
;; into a megabyte-wide image, or into a request that renders for a minute.
(define max-text-length 100)
(define max-sections 10)

(define default-background "catppuccin-mocha-surface2")
(define default-ink "catppuccin-mocha-text")

;; ====== Reading the request ======

(define (param params name)
  "The first value of NAME in the (name . value) PARAMS, or #f."
  (let ((entry (assoc name params)))
    (and entry (cdr entry))))

(define (param-values params name)
  "Every value of NAME in PARAMS, in the order the URL gives them."
  (filter-map (lambda (entry)
                (and (string=? (car entry) name) (cdr entry)))
              params))

(define (param-or params name default)
  (or (param params name) default))

(define (nth-or items index default)
  (if (< index (length items))
      (list-ref items index)
      default))

(define (badge-color text)
  "TEXT as a glyph color: a theme color name becomes a symbol, so a misspelt
one is reported like it is in a glyph file, and any other string (a hex code
or a CSS color) is left for the renderer to resolve."
  (if (or (assoc-ref named-colors (string->symbol text))
          (any (lambda (theme)
                 (string-prefix? (string-append (symbol->string theme) "-")
                                 text))
               (theme-names)))
      (string->symbol text)
      text))

(define (xml-text text)
  "TEXT escaped for XML character data. (ggg sxml) does not escape the strings
it is handed, and this text comes from a URL."
  (string-concatenate
   (map (lambda (character)
          (case character
            ((#\&) "&amp;")
            ((#\<) "&lt;")
            ((#\>) "&gt;")
            (else (string character))))
        (string->list text))))

(define (query-params query)
  "The (name . value) pairs of a URL query string, percent-decoded."
  (if (or (not query) (string-null? query))
      '()
      (filter-map (lambda (part)
                    (let ((equals (string-index part #\=)))
                      (and equals
                           (cons (uri-decode (substring part 0 equals))
                                 (uri-decode (substring part (1+ equals)))))))
                  (string-split query #\&))))

(define (text-problems texts)
  "Problems with the TEXT values of a request, before the glyph is validated."
  (cond
    ((null? texts)
     (list "missing the 'text' parameter; add ?text=passing"))
    ((> (length texts) max-sections)
     (list (format #f "~a 'text' sections is more than the ~a a badge can hold"
                   (length texts) max-sections)))
    (else
     (append-map (lambda (text index)
                   (let ((section (format #f "the 'text' parameter #~a" index)))
                     (cond
                       ((string-null? text)
                        (list (format #f "~a is empty" section)))
                       ((> (string-length text) max-text-length)
                        (list (format #f "~a is longer than ~a characters"
                                      section max-text-length)))
                       (else '()))))
                 texts
                 (iota (length texts) 1)))))

(define (parameter-problems params)
  "The problems with the parameters themselves, before the glyph is validated."
  (let ((label (param params "label")))
    (append
     (text-problems (param-values params "text"))
     (if (and label (> (string-length label) max-text-length))
         (list (format #f "the 'label' parameter is longer than ~a characters"
                       max-text-length))
         '()))))

(define (text-section text background ink)
  `((text . ,(xml-text text))
    (background . ,(badge-color background))
    (color . ,(badge-color ink))))

(define* (badge-glyph params #:key (id "badge"))
  "The glyph that the (name . value) PARAMS describe: an optional label
section, then one section per 'text' parameter.  The Nth bg/fg pair belongs to
the Nth text section, and a logo belongs to the first section, as it does in a
glyph file."
  (let* ((label (param params "label"))
         (label (and label (not (string-null? label)) label))
         (logo (param params "logo"))
         (style (param params "style"))
         (texts (param-values params "text"))
         (backgrounds (param-values params "bg"))
         (inks (param-values params "fg"))
         (text-sections
          (map (lambda (text index)
                 (text-section text
                               (nth-or backgrounds index default-background)
                               (nth-or inks index default-ink)))
               texts
               (iota (length texts))))
         (label-section
          (and label
               `((text . ,(xml-text label))
                 (background . ,(badge-color (param-or params "label-bg"
                                                       default-background)))
                 (color . ,(badge-color (param-or params "label-fg"
                                                  default-ink)))
                 ,@(if logo `((logo . ,logo)) '()))))
         (sections
          (cond
            (label-section (cons label-section text-sections))
            ((and logo (pair? text-sections))
             (cons (append (car text-sections) `((logo . ,logo)))
                   (cdr text-sections)))
            (else text-sections))))
    `((sections ,@sections)
      (id . ,id)
      ,@(if style `((style . ,style)) '()))))

;; ====== The builder page ======

(define (html-escape text)
  "TEXT escaped for HTML character data and attribute values."
  (string-concatenate
   (map (lambda (character)
          (case character
            ((#\&) "&amp;")
            ((#\<) "&lt;")
            ((#\>) "&gt;")
            ((#\") "&quot;")
            (else (string character))))
        (string->list (format #f "~a" text)))))

(define builder-style "
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  body { margin: 0; padding: 2rem 1.25rem 4rem; background: #1e1e2e; color: #cdd6f4;
         font-family: system-ui, -apple-system, 'Segoe UI', sans-serif; }
  main { max-width: 62rem; margin: 0 auto; }
  h1 { margin: 0 0 .35rem; font-size: 1.55rem; }
  p.lede { margin: 0 0 1.5rem; color: #a6adc8; line-height: 1.5; }
  section { background: #181825; border: 1px solid #313244; border-radius: .6rem;
            padding: 1rem; margin-bottom: 1rem; }
  h2 { margin: 0 0 .8rem; font-size: .95rem; color: #bac2de; }
  label { display: flex; flex-direction: column; gap: .28rem; font-size: .8rem;
          color: #a6adc8; }
  input, select { padding: .45rem .55rem; border-radius: .35rem; border: 1px solid #45475a;
                  background: #11111b; color: inherit; font: inherit; font-size: .9rem;
                  min-width: 0; }
  input:focus-visible, select:focus-visible, button:focus-visible {
    outline: 2px solid #b4befe; outline-offset: 1px; }
  .grid { display: grid; gap: .8rem; grid-template-columns: repeat(auto-fit, minmax(12rem, 1fr)); }
  .section-row { display: grid; gap: .5rem; grid-template-columns: 1.2fr 1fr 1fr auto;
                 align-items: end; margin-bottom: .5rem; }
  .section-row:last-child { margin-bottom: 0; }
  button { padding: .45rem .8rem; border-radius: .35rem; border: 1px solid #45475a;
           background: #313244; color: inherit; font: inherit; font-size: .85rem;
           cursor: pointer; }
  button:hover { background: #45475a; }
  button.remove { padding: .45rem .6rem; }
  .preview { display: flex; flex-direction: column; gap: .7rem; align-items: flex-start;
             width: 100%; }
  .preview img { min-height: 2.4rem; max-width: 100%; }
  .url-row { display: flex; gap: .5rem; width: 100%; }
  .url-row input { flex: 1; font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
                   font-size: .78rem; }
  .status { font-size: .78rem; color: #a6e3a1; min-height: 1em; }
  .hint { font-size: .8rem; color: #7f849c; line-height: 1.5; }
  code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; color: #f5c2e7; }
")

(define builder-script "
  const defaultBackground = 'catppuccin-mocha-surface2';
  const defaultInk = 'catppuccin-mocha-text';
  const preview = document.getElementById('preview');
  const urlField = document.getElementById('url');
  const status = document.getElementById('status');
  const rows = document.getElementById('sections');

  function addSection(text, background, ink) {
    const row = document.createElement('div');
    row.className = 'section-row';
    row.innerHTML = '<label>Text <input class=\"text\" placeholder=\"passing\"></label>' +
                    '<label>Background <input class=\"bg\" placeholder=\"catppuccin-mocha-surface2\"></label>' +
                    '<label>Text color <input class=\"fg\" placeholder=\"catppuccin-mocha-text\"></label>' +
                    '<button type=\"button\" class=\"remove\" aria-label=\"Remove this section\">x</button>';
    row.querySelector('.text').value = text || '';
    row.querySelector('.bg').value = background || '';
    row.querySelector('.fg').value = ink || '';
    row.querySelector('.remove').addEventListener('click', () => { row.remove(); update(); });
    row.querySelectorAll('input').forEach((input) => input.addEventListener('input', update));
    rows.appendChild(row);
  }

  function value(id) { return document.getElementById(id).value.trim(); }

  function update() {
    const params = new URLSearchParams();
    if (value('label')) params.append('label', value('label'));
    if (value('label-bg')) params.append('label-bg', value('label-bg'));
    if (value('label-fg')) params.append('label-fg', value('label-fg'));
    if (value('logo')) params.append('logo', value('logo'));
    if (value('style')) params.append('style', value('style'));
    rows.querySelectorAll('.section-row').forEach((row) => {
      const text = row.querySelector('.text').value.trim();
      if (!text) return;
      params.append('text', text);
      params.append('bg', row.querySelector('.bg').value.trim() || defaultBackground);
      params.append('fg', row.querySelector('.fg').value.trim() || defaultInk);
    });
    if (!params.has('text')) {
      preview.removeAttribute('src');
      urlField.value = '';
      status.textContent = 'Add a section to see the badge.';
      return;
    }
    const url = new URL('/badge.svg?' + params.toString(), location.href);
    preview.src = url.pathname + url.search;
    urlField.value = url.href;
    status.textContent = '';
  }

  document.getElementById('add').addEventListener('click', () => addSection());
  document.getElementById('copy').addEventListener('click', async () => {
    if (!urlField.value) return;
    try {
      await navigator.clipboard.writeText(urlField.value);
      status.textContent = 'Copied.';
    } catch (error) {
      urlField.select();
      status.textContent = 'Press Ctrl+C to copy.';
    }
  });
  ['label', 'label-bg', 'label-fg', 'logo', 'style'].forEach((id) =>
    document.getElementById(id).addEventListener('input', update));
  addSection('passing');
  document.getElementById('label').value = 'build';
  update();
")

(define (option-tag value label)
  (format #f "<option value=\"~a\">~a</option>"
          (html-escape value) (html-escape label)))

(define (builder-html resources)
  "The self-contained badge builder page for the logo library in RESOURCES."
  (let ((logos (logo-names #:resources resources))
        (styles (map symbol->string style-names)))
    (format #f "\
<!DOCTYPE html>
<html lang=\"en\">
  <head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>ggg badge builder</title>
    <style>~a</style>
  </head>
  <body>
    <main>
      <header>
        <h1>ggg badge builder</h1>
        <p class=\"lede\">Describe a badge here and copy its URL. Every setting is a
        plain GET query, so the badge can be embedded in a README with
        <code>![badge](URL)</code>.</p>
      </header>

      <section>
        <h2>Label and finish</h2>
        <div class=\"grid\">
          <label>Label <input id=\"label\" placeholder=\"build\"></label>
          <label>Logo <input id=\"logo\" list=\"logos\" placeholder=\"guix\"></label>
          <label>Style <select id=\"style\">~a</select></label>
          <label>Label background <input id=\"label-bg\" placeholder=\"catppuccin-mocha-surface2\"></label>
          <label>Label text color <input id=\"label-fg\" placeholder=\"catppuccin-mocha-text\"></label>
        </div>
      </section>

      <section>
        <h2>Sections</h2>
        <div id=\"sections\"></div>
        <button type=\"button\" id=\"add\">Add section</button>
        <p class=\"hint\">The Nth <code>bg</code>/<code>fg</code> belongs to the Nth
        <code>text</code>; empty fields use the defaults. Up to 10 sections, 100
        characters each.</p>
      </section>

      <section>
        <h2>Preview</h2>
        <div class=\"preview\">
          <img id=\"preview\" alt=\"badge preview\">
          <div class=\"url-row\">
            <input id=\"url\" readonly aria-label=\"Badge URL\">
            <button type=\"button\" id=\"copy\">Copy URL</button>
          </div>
          <span class=\"status\" id=\"status\" role=\"status\" aria-live=\"polite\"></span>
        </div>
      </section>

      <p class=\"hint\">Colors take theme names such as
      <code>catppuccin-mocha-green</code> or hex strings such as
      <code>%23ff8800</code>. The logo and style names are the ones from
      <code>ggg --list-logos</code> and <code>ggg --list-styles</code>.</p>
    </main>
    <datalist id=\"logos\">~a</datalist>
    <script>~a</script>
  </body>
</html>
"
            builder-style
            (string-join (map (lambda (name) (option-tag name name)) styles) "\n")
            (string-join (map (lambda (name) (option-tag name name)) logos) "\n")
            builder-script)))

;; ====== Answering the request ======

(define (glyph-svg glyph resources)
  "GLYPH as an SVG document, as a string."
  (call-with-output-string
   (lambda (port)
     (sxml->xml (mk-glyph glyph #:resources resources) port))))

(define (plain-response code message)
  (values (build-response #:code code
                          #:headers '((content-type . (text/plain))))
          message))

(define* (badge-response params #:key resources)
  (let* ((glyph (badge-glyph params))
         (problems (append (parameter-problems params)
                           (validate-glyph glyph #:resources resources))))
    (if (pair? problems)
        (plain-response 400 (format #f "~a~%" (string-join problems "\n")))
        (values (build-response
                 #:code 200
                 #:headers '((content-type . (image/svg+xml))
                             (cache-control . (public (max-age . 300)))))
                (glyph-svg glyph resources)))))

(define (builder-response resources)
  (values (build-response #:code 200
                          #:headers '((content-type . (text/html))))
          (builder-html resources)))

(define badge-paths '("/badge.svg" "/badge"))
(define builder-paths '("/" "/index.html"))

(define* (badge-handler request body #:key resources)
  "Answer REQUEST with a badge or with the builder page, or explain why it has
neither.  BODY goes unread: a badge is an enquiry, not an upload."
  (let ((path (uri-path (request-uri request))))
    (cond
      ((not (eq? 'GET (request-method request)))
       (plain-response 405 "Only GET requests are served.\n"))
      ((member path builder-paths)
       (builder-response resources))
      ((member path badge-paths)
       (badge-response (query-params (uri-query (request-uri request)))
                       #:resources resources))
      (else
       (plain-response 404
                       (format #f "Not found: ~a~%Try / for the badge builder, or /badge.svg?text=passing~%"
                               path))))))

(define* (serve #:key resources (host "127.0.0.1") (port 8080))
  "Serve badges and the builder at http://HOST:PORT until interrupted.

The address defaults to the loopback interface, so the server answers only the
machine it runs on; pass 0.0.0.0 as HOST to answer other machines."
  (log-info "serving badges on http://~a:~a/ (and /badge.svg?text=passing)" host port)
  (guard-errors (lambda ()
                  (run-server (lambda (request body)
                                (badge-handler request body #:resources resources))
                              'http
                              (list #:host host #:port port)))
                #:label (format #f "could not serve badges on ~a:~a" host port)
                #:hint "Check that the port is free and that the address belongs to this machine."))
