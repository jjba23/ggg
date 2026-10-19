;; ggg: guile glyph generator

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; ggg is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ggg is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Affero General Public License for more details.

;; You should have received a copy of the GNU Affero General Public License
;; along with ggg.  If not, see <https://www.gnu.org/licenses/>.

(define-module (ggg gallery)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ggg colors)
  #:use-module (ggg glyph)
  #:use-module (ggg logo)
  #:use-module (ggg prelude)
  #:use-module (ggg sxml)
  #:export (gallery-html write-gallery-page logo-display-name logo-markup
                        gallery-badge-tile badge-markup badge-search-text))

;; ====== Logo helpers ======

(define* (logo-display-name name #:key resources)
  "The human-readable title of a logo, falling back to its file name."
  (let* ((name (logo-name->string name))
         (path (logo-file-path name #:resources resources))
         (contents (and path (call-with-input-file path get-string-all)))
         (match (and contents
                     (string-match "<title>([^<]*)</title>" contents))))
    (let ((title (and match (string-trim-both (match:substring match 1)))))
      (if (and title (not (string-null? title)))
          title
          name))))

(define (element-attribute-names node)
  (let ((body (cdr node)))
    (if (and (pair? body) (pair? (car body)) (eq? '@ (caar body)))
        (cdar body)
        '())))

(define (element-ids node)
  "Every id attribute used anywhere in NODE."
  (cond
    ((string? node) '())
    ((not (pair? node)) '())
    ((eq? '@ (car node))
     (filter-map (lambda (attribute)
                   (and (pair? attribute) (eq? 'id (car attribute)) (cadr attribute)))
                 (cdr node)))
    (else (append-map element-ids node))))

(define (prefix-svg-ids node prefix)
  "Namespace every id in NODE (and the references to it) with PREFIX, so several
logos can live in the same document without clashing on gradient names."
  (let ((ids (sort (delete-duplicates (element-ids node))
                   (lambda (a b) (> (string-length a) (string-length b))))))
    (define (rewrite value)
      (if (not (string? value))
          value
          (fold (lambda (id acc)
                  (string-replace-substring acc
                                            (string-append "#" id)
                                            (string-append "#" prefix id)))
                value
                ids)))
    (define (walk node)
      (cond
        ((string? node) (rewrite node))
        ((not (pair? node)) node)
        ((eq? '@ (car node))
         (cons '@ (map (lambda (attribute)
                         (cond
                           ((not (pair? attribute)) attribute)
                           ((eq? 'id (car attribute))
                            (list 'id (string-append prefix (cadr attribute))))
                           (else (list (car attribute) (rewrite (cadr attribute))))))
                       (cdr node))))
        (else (cons (walk (car node)) (map walk (cdr node))))))
    (walk node)))

(define (serialize-sxml tree)
  (call-with-output-string
   (lambda (port)
     (sxml->xml tree port))))

(define* (logo-markup name #:key resources)
  "The logo as inline SVG markup, with its ids namespaced."
  (let ((sxml (get-logo-sxml name #:resources resources)))
    (and sxml
         (serialize-sxml
          (prefix-svg-ids sxml
                          (format #f "logo-~a-" (logo-name->string name)))))))

;; ====== Badge helpers ======

(define (glyph-section-texts glyph)
  "Every text label of GLYPH, as strings."
  (let ((sections (lookup glyph 'sections)))
    (if (not (list? sections))
        '()
        (filter-map (lambda (section)
                      (let ((text (lookup section 'text)))
                        (and text (format #f "~a" text))))
                    sections))))

(define (badge-search-text glyph)
  "What a badge can be filtered by: its id and the text of every section."
  (string-join (cons (or (glyph-id glyph) "")
                     (glyph-section-texts glyph))
               " "))

(define (id-safe text)
  "TEXT reduced to characters that are safe inside an SVG id."
  (list->string (filter (lambda (character)
                          (or (char-alphabetic? character)
                              (char-numeric? character)
                              (eqv? character #\-)))
                        (string->list text))))

(define (scheme-source value)
  "VALUE as Scheme source, so a copied snippet can be pasted into a glyph file."
  (call-with-output-string
   (lambda (port) (write value port))))

(define (glyph-definition glyph)
  "The Scheme form that recreates GLYPH."
  (format #f "(define ~a '~a)"
          (or (glyph-id glyph) "glyph")
          (scheme-source glyph)))

(define* (badge-markup glyph #:key resources (group ""))
  "The badge as inline SVG markup, with its ids namespaced per group."
  (let ((prefix (format #f "badge-~a-" (id-safe group))))
    (serialize-sxml
     (prefix-svg-ids (mk-glyph glyph #:resources resources) prefix))))

(define* (gallery-badge-tile glyph #:key resources (group ""))
  (let* ((id (or (glyph-id glyph) "badge"))
         (definition (glyph-definition glyph))
         (markup (badge-markup glyph #:resources resources #:group group)))
    (format #f "\
      <figure class=\"badge-tile\" data-name=\"~a\">
        <div class=\"badge-preview\">~a</div>
        <figcaption>
          <span class=\"name\">~a</span>
          <button type=\"button\" class=\"snippet\" data-copy=\"~a\" title=\"Copy the ~a glyph definition\">(id . ~a)</button>
        </figcaption>
      </figure>"
            (html-escape (badge-search-text glyph))
            markup
            (html-escape id)
            (html-attribute-escape definition)
            (html-escape id)
            (html-escape id))))

(define (gallery-badge-group label glyphs resources)
  (let ((count (length glyphs)))
    (format #f "\
    <section class=\"badge-group\">
      <h2>~a <span class=\"meta\">~a badge~a</span></h2>
      <div class=\"badge-grid\">
~a
      </div>
    </section>"
            (html-escape label)
            count
            (if (= count 1) "" "s")
            (string-join (map (lambda (glyph)
                                (gallery-badge-tile glyph
                                                    #:resources resources
                                                    #:group label))
                              glyphs)
                         "\n"))))

(define (gallery-badge-groups glyph-groups resources)
  "The HTML of every glyph group, or an empty string when there are none."
  (if (or (not glyph-groups) (null? glyph-groups))
      ""
      (string-join (map (lambda (group)
                          (gallery-badge-group (car group) (cdr group) resources))
                        glyph-groups)
                   "\n")))

(define (gallery-badge-count glyph-groups)
  (fold (lambda (group total) (+ total (length (cdr group))))
        0
        (or glyph-groups '())))

;; ====== HTML ======

(define (html-escape text)
  (string-concatenate
   (map (lambda (character)
          (case character
            ((#\&) "&amp;")
            ((#\<) "&lt;")
            ((#\>) "&gt;")
            ((#\") "&quot;")
            ((#\') "&#39;")
            (else (string character))))
        (string->list (format #f "~a" text)))))

(define (html-attribute-escape text)
  "Like HTML-ESCAPE, but leaves apostrophes alone so copied Scheme keeps its
quotes readable in a double-quoted attribute."
  (string-concatenate
   (map (lambda (character)
          (case character
            ((#\&) "&amp;")
            ((#\<) "&lt;")
            ((#\>) "&gt;")
            ((#\") "&quot;")
            (else (string character))))
        (string->list (format #f "~a" text)))))

(define (palette-css template)
  "TEMPLATE with each @name@ replaced by that Catppuccin mocha color, so the
gallery is painted with the same palette as the badges."
  (regexp-substitute/global
   #f "@([a-z0-9]+)@"
   template
   'pre
   (lambda (match)
     (resolve-color
      (string->symbol
       (format #f "catppuccin-mocha-~a" (match:substring match 1)))))
   'post))

(define (gallery-style)
  "The gallery stylesheet, colored from the Catppuccin mocha palette."
  (palette-css "
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  body {
    margin: 0; padding: 2rem 1.5rem 4rem;
    font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
    background: @base@; color: @text@;
  }
  header { max-width: 76rem; margin: 0 auto 1.5rem; }
  h1 { margin: 0 0 .4rem; font-size: 1.7rem; }
  p.lede { margin: 0 0 1rem; color: @subtext0@; max-width: 48rem; line-height: 1.5; }
  .toolbar { display: flex; gap: .8rem; flex-wrap: wrap; align-items: center; }
  input[type=search] {
    padding: .5rem .7rem; min-width: 16rem; border-radius: .4rem;
    border: 1px solid @surface1@; background: @mantle@; color: inherit; font-size: .95rem;
  }
  .count { color: @subtext0@; font-size: .9rem; }

  .badge-group { max-width: 76rem; margin: 2rem auto 0; }
  .badge-group h2, h2.section-heading { font-size: 1.1rem; margin: 0 0 .9rem; }
  h2.section-heading { max-width: 76rem; margin: 2.6rem auto .9rem; }
  .meta { font-weight: 400; color: @overlay1@; font-size: .85rem; margin-left: .35rem; }
  .badge-grid {
    display: grid; gap: .8rem; align-items: start;
    grid-template-columns: repeat(auto-fill, minmax(15rem, 1fr));
  }
  figure.badge-tile {
    margin: 0; padding: .85rem .7rem .65rem; border-radius: .6rem;
    background: @mantle@; border: 1px solid @surface0@;
    display: flex; flex-direction: column; gap: .55rem; align-items: center;
    min-width: 0;
  }
  figure.badge-tile[hidden] { display: none; }
  .badge-preview {
    width: 100%; min-height: 2.3rem;
    display: flex; align-items: center; justify-content: center;
  }
  .badge-preview svg { display: block; max-width: 100%; height: auto; }

  .grid {
    max-width: 76rem; margin: 0 auto;
    display: grid; gap: .9rem;
    grid-template-columns: repeat(auto-fill, minmax(11rem, 1fr));
  }
  figure.tile {
    margin: 0; padding: .9rem .7rem .7rem; border-radius: .6rem;
    background: @mantle@; border: 1px solid @surface0@;
    display: flex; flex-direction: column; gap: .6rem; align-items: center;
  }
  figure.tile[hidden] { display: none; }
  .preview {
    width: 4.5rem; height: 4.5rem; border-radius: .5rem;
    background: @surface2@; display: flex; align-items: center; justify-content: center;
  }
  .preview svg { width: 3rem; height: 3rem; }
  figcaption { text-align: center; width: 100%; }
  .name {
    display: block; font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: .85rem; color: @text@; overflow-wrap: anywhere;
  }
  .title { display: block; font-size: .74rem; color: @overlay1@; margin-top: .15rem; }
  button.snippet {
    display: block; margin: .4rem auto 0; padding: .16rem .4rem;
    font-size: .68rem; color: @overlay1@; cursor: pointer;
    background: transparent; border: 1px solid transparent; border-radius: .3rem;
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  }
  button.snippet:hover { color: @lavender@; border-color: @surface1@; background: @surface0@; }
  button.snippet:focus-visible { outline: 2px solid @lavender@; outline-offset: 1px; }
  .toast {
    position: fixed; left: 50%; bottom: 1.4rem; z-index: 10;
    transform: translate(-50%, .8rem); opacity: 0; pointer-events: none;
    padding: .55rem .9rem; border-radius: .45rem; font-size: .85rem;
    background: @surface0@; color: @text@; border: 1px solid @surface1@;
    box-shadow: 0 6px 24px rgba(0, 0, 0, .35);
    transition: opacity .18s ease, transform .18s ease;
  }
  .toast.show { opacity: 1; transform: translate(-50%, 0); }
  footer { max-width: 76rem; margin: 2.5rem auto 0; color: @overlay1@; font-size: .85rem; }
  a { color: @sapphire@; }
"))

(define gallery-script "
  const input = document.querySelector('input[type=search]');
  const tiles = Array.from(document.querySelectorAll('figure.tile, figure.badge-tile'));
  const count = document.querySelector('.count');
  const badges = document.querySelectorAll('figure.badge-tile').length;
  const logos = document.querySelectorAll('figure.tile').length;
  const noun = (n, word) => n + ' ' + word + (n === 1 ? '' : 's');
  const summary = () => [badges ? noun(badges, 'badge') : '',
                         logos ? noun(logos, 'logo') : '']
                          .filter(Boolean).join(' · ');
  const filter = () => {
    const query = input.value.trim().toLowerCase();
    let shown = 0;
    tiles.forEach((tile) => {
      const matches = !query || tile.dataset.name.toLowerCase().includes(query);
      tile.hidden = !matches;
      if (matches) shown += 1;
    });
    count.textContent = query
      ? shown + ' of ' + tiles.length + ' shown'
      : summary();
  };
  input.addEventListener('input', filter);
  filter();

  const toast = document.querySelector('.toast');
  let toastTimer;
  const notify = (message) => {
    toast.textContent = message;
    toast.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove('show'), 1800);
  };
  const copyText = async (text) => {
    try {
      await navigator.clipboard.writeText(text);
      return true;
    } catch (error) {
      // file:// pages and older browsers have no clipboard API.
      const area = document.createElement('textarea');
      area.value = text;
      area.setAttribute('readonly', '');
      area.style.position = 'fixed';
      area.style.opacity = '0';
      document.body.appendChild(area);
      area.select();
      let copied = false;
      try { copied = document.execCommand('copy'); } catch (ignored) { copied = false; }
      area.remove();
      return copied;
    }
  };
  document.querySelectorAll('button.snippet').forEach((button) => {
    button.addEventListener('click', async () => {
      const name = button.closest('figure').querySelector('.name').textContent;
      const copied = await copyText(button.dataset.copy);
      notify(copied ? 'Copied ' + name : 'Could not copy ' + name);
    });
  });
")

(define* (gallery-tile name #:key resources)
  (let* ((display (logo-display-name name #:resources resources))
         (markup (logo-markup name #:resources resources)))
    (format #f "\
    <figure class=\"tile\" data-name=\"~a ~a\">
      <div class=\"preview\">~a</div>
      <figcaption>
        <span class=\"name\">~a</span>
        <span class=\"title\">~a</span>
        <button type=\"button\" class=\"snippet\" data-copy=\"~a\" title=\"Copy the ~a logo snippet\">(logo . ~a)</button>
      </figcaption>
    </figure>"
            (html-escape name)
            (html-escape display)
            markup
            (html-escape name)
            (html-escape display)
            (html-attribute-escape (format #f "(logo . ~a)" name))
            (html-escape name)
            (html-escape name))))

(define (gallery-lede badge-count glyph-file-count logo-count)
  (if (zero? badge-count)
      (string-append
       "Every logo that ggg ships, inlined from its "
       "<code>resources/logos/&lt;name&gt;.svg</code> file. Logos are drawn white "
       "on the same gray a badge uses. Use one in a glyph file with "
       "<code>(logo . name)</code>. See <code>CREDITS.org</code> "
       "for where each logo comes from.")
      (format #f
              "Every badge from ~a glyph file~a, rendered at its real size with the \
theme colors it asks for, followed by all ~a logos that ggg ships. Use a logo in a \
glyph file with <code>(logo . name)</code>. See \
<code>CREDITS.org</code> for where each logo comes from."
              glyph-file-count
              (if (= glyph-file-count 1) "" "s")
              logo-count)))

(define* (gallery-html #:key resources (glyph-groups '()) (title "GGG badge gallery"))
  "A self-contained HTML page showing every badge in GLYPH-GROUPS and every
logo in RESOURCES with its name."
  (let* ((names (logo-names #:resources resources))
         (badge-count (gallery-badge-count glyph-groups))
         (logo-count (length names))
         (summary (string-join
                   (filter-map (lambda (part) part)
                               (list (if (> badge-count 0)
                                         (format #f "~a badge~a"
                                                 badge-count
                                                 (if (= badge-count 1) "" "s"))
                                         #f)
                                     (format #f "~a logo~a"
                                             logo-count
                                             (if (= logo-count 1) "" "s"))))
                   " · ")))
    (format #f "\
<!DOCTYPE html>
<html lang=\"en\">
  <head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>~a</title>
    <style>~a  </style>
  </head>
  <body>
    <header>
      <h1>~a</h1>
      <p class=\"lede\">
        ~a
      </p>
      <div class=\"toolbar\">
        <input type=\"search\" placeholder=\"Filter badges and logos…\" aria-label=\"Filter badges and logos\">
        <span class=\"count\">~a</span>
      </div>
    </header>
~a
    <main>
      <h2 class=\"section-heading\">Logo library <span class=\"meta\">~a</span></h2>
      <div class=\"grid\">
~a
      </div>
    </main>
    <footer>
      Generated by <code>ggg --gallery</code>.
    </footer>
    <div class=\"toast\" role=\"status\" aria-live=\"polite\"></div>
    <script>~a</script>
  </body>
</html>
"
            (html-escape title)
            (gallery-style)
            (html-escape title)
            (gallery-lede badge-count (length glyph-groups) logo-count)
            summary
            (gallery-badge-groups glyph-groups resources)
            (format #f "~a logo~a" logo-count (if (= logo-count 1) "" "s"))
            (string-join (map (lambda (name)
                                (gallery-tile name #:resources resources))
                              names)
                         "\n")
            gallery-script)))

(define* (write-gallery-page path #:key resources (glyph-groups '()))
  "Write the gallery to PATH. Return two values: the number of badges and the
number of logos it shows."
  (let* ((names (logo-names #:resources resources))
         (html (gallery-html #:resources resources #:glyph-groups glyph-groups)))
    (guard-errors (lambda ()
                    (ensure-directory (dirname path))
                    (with-output-to-file path
                      (lambda ()
                        (display html))))
                  #:label (format #f "could not write gallery page '~a'" path)
                  #:hint "Check that the directory you are writing to exists and is writable.")
    (values (gallery-badge-count glyph-groups) (length names))))
