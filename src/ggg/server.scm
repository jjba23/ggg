;; ggg: guile glyph generator
;;
;; Spdx-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; Commentary:
;;
;; `ggg --serve' answers GET /badge.svg?text=... with a badge, so a README can
;; link to a badge that a query string describes instead of to a rendered file.
;; The root path serves the badge builder: a live preview, autocompletion over
;; the logo library and every theme color, a preview per finish, starting
;; points, and a footer that names the version, the build and the licenses.
;; GET /logo.svg serves the project's own mark, and GET /logo.svg?name=... serves
;; one logo from the library, so the page can show the mark in its header and a
;; thumbnail beside each suggestion without inlining hundreds of files.
;; A request only builds an ordinary glyph, which (ggg glyph) renders with the
;; same code the command line uses, and one that describes no valid badge is
;; answered with 400 and the reasons, never with a broken image.

(define-module (ggg server)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
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
  #:use-module (ggg version)
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

(define (js-string value)
  "VALUE as a JavaScript string literal."
  (format #f "~s" (format #f "~a" value)))

(define (js-color-pairs)
  "Every named color as a JavaScript [name, hex] pair, for autocompletion."
  (format #f "[~a]"
          (string-join
           (map (lambda (entry)
                  (format #f "[~a,~a]"
                          (js-string (car entry))
                          (js-string (cdr entry))))
                named-colors)
           ",")))

(define (js-logos names)
  "NAMES as a JavaScript array of strings, for autocompletion."
  (format #f "[~a]" (string-join (map js-string names) ",")))

(define revision-pattern "^[0-9a-f]{7,40}$")

(define (git-revision)
  "The short revision of the checkout the server runs in, or #f when there is
no git, no checkout, or no subprocess to ask."
  (catch #t
    (lambda ()
      (let* ((port (open-pipe* OPEN_READ "git" "rev-parse" "--short" "HEAD"))
             (revision (read-line port))
             (status (close-pipe port)))
        (and (zero? status)
             (string? revision)
             (string-match revision-pattern revision)
             revision)))
    (lambda arguments #f)))

(define (build-revision)
  "The revision the page names: GGG_COMMIT when a build set it, the checkout's
revision, or 'unknown' when ggg runs from an installed copy."
  (let ((recorded (getenv "GGG_COMMIT")))
    (or (and recorded (string-match revision-pattern recorded) recorded)
        (git-revision)
        "unknown")))

(define builder-style "
  :root { color-scheme: dark;
    --crust:#11111b; --surface0:#313244; --surface1:#45475a;
    --text:#cdd6f4; --subtext0:#a6adc8; --overlay0:#6c7086;
    --mauve:#cba6f7; --sapphire:#74c7ec; --green:#a6e3a1; --red:#f38ba8; }
  * { box-sizing: border-box; }
  body { margin: 0; padding: 1.6rem 1.25rem 3rem; min-height: 100vh;
         font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
         color: var(--text);
         background:
           radial-gradient(1100px 520px at 12% -12%, rgba(203,166,247,.24), transparent 62%),
           radial-gradient(900px 480px at 104% 2%, rgba(137,220,235,.20), transparent 58%),
           var(--crust); }
  .aurora { position: fixed; inset: -25%; z-index: -1; opacity: .32; filter: blur(90px);
            background: conic-gradient(from 90deg, rgba(203,166,247,.5), rgba(148,226,213,.25),
              rgba(137,180,250,.4), rgba(245,194,231,.3), rgba(203,166,247,.5));
            animation: drift 28s linear infinite; }
  @keyframes drift { to { transform: rotate(1turn); } }
  @media (prefers-reduced-motion: reduce) {
    * { animation: none !important; transition: none !important; }
  }
  main { max-width: 74rem; margin: 0 auto; }
  h1 { margin: 0; font-size: clamp(1.7rem, 3.4vw, 2.4rem); letter-spacing: -.02em; }
  h2 { margin: 0 0 .85rem; font-size: .95rem; color: var(--subtext0);
       text-transform: uppercase; letter-spacing: .08em; }
  h3 { margin: 1.2rem 0 .6rem; font-size: .85rem; color: var(--subtext0);
       text-transform: uppercase; letter-spacing: .08em; }
  .hero { display: flex; align-items: center; gap: 1.1rem; padding: 1rem 0 1.1rem; }
  .hero img { height: 4.4rem; width: auto;
              filter: drop-shadow(0 14px 30px rgba(203,166,247,.45)); }
  .hero p { margin: .35rem 0 0; color: var(--subtext0); max-width: 44rem; line-height: 1.55; }
  .chips { display: flex; gap: .4rem; flex-wrap: wrap; margin-top: .55rem; }
  .chips span, .chips a { font-size: .72rem; padding: .2rem .55rem; border-radius: 999px;
                border: 1px solid var(--surface1); color: var(--subtext0);
                background: rgba(49,50,68,.5); }
  .chips a { color: var(--mauve); text-decoration: none; }
  .chips a:hover { border-color: var(--mauve); background: rgba(203,166,247,.14); }
  .presets { display: flex; gap: .5rem; flex-wrap: wrap; margin: 0 0 1.1rem; }
  .preset { border-radius: 999px; }
  .layout { display: grid; grid-template-columns: minmax(0, 1.12fr) minmax(0, .88fr);
            gap: 1.1rem; align-items: start; }
  .column { display: flex; flex-direction: column; gap: 1.1rem; }
  .card { background: rgba(24,24,37,.88); border: 1px solid rgba(88,91,112,.45);
          border-radius: .9rem; padding: 1.05rem 1.1rem;
          box-shadow: 0 24px 50px -40px #000; backdrop-filter: blur(10px); }
  .preview-card { position: sticky; top: 1rem; }
  .grid { display: grid; gap: .75rem; grid-template-columns: repeat(auto-fit, minmax(11rem, 1fr)); }
  label { display: flex; flex-direction: column; gap: .3rem; font-size: .78rem;
          color: var(--subtext0); }
  input, select { width: 100%; padding: .45rem .55rem; border-radius: .4rem;
                  border: 1px solid var(--surface1); background: var(--crust);
                  color: inherit; font: inherit; font-size: .88rem; min-width: 0; }
  input:focus-visible, button:focus-visible, summary:focus-visible, a:focus-visible {
    outline: 2px solid var(--mauve); outline-offset: 1px; }
  button { padding: .42rem .8rem; border-radius: .4rem; border: 1px solid var(--surface1);
           background: var(--surface0); color: var(--text); font: inherit;
           font-size: .82rem; cursor: pointer; }
  button:hover { background: var(--surface1); }
  .section-row { display: grid; gap: .5rem; align-items: end; margin-bottom: .55rem;
                 grid-template-columns: 1.25fr 1fr 1fr auto; }
  .section-row .remove { padding: .42rem .55rem; color: var(--red); }
  .hint { font-size: .76rem; color: var(--overlay0); line-height: 1.5; margin: .5rem 0 0; }
  .meta { text-transform: none; letter-spacing: 0; color: var(--overlay0); font-weight: 400; }
  .styles { display: grid; gap: .5rem; grid-template-columns: repeat(auto-fit, minmax(7.6rem, 1fr)); }
  .style-card { display: flex; flex-direction: column; gap: .35rem; align-items: center;
                padding: .55rem .4rem; background: rgba(49,50,68,.45); }
  .style-card img { max-width: 100%; height: auto; }
  .style-card .style-name { font-size: .72rem; color: var(--subtext0); }
  .style-card.is-active { border-color: var(--mauve); background: rgba(203,166,247,.12);
                          box-shadow: inset 0 0 0 1px var(--mauve); }
  .preview-stage { display: grid; place-items: center; min-height: 8.5rem;
                   border-radius: .65rem; background-color: rgba(17,17,27,.7);
                   background-image:
                     linear-gradient(45deg, rgba(255,255,255,.045) 25%, transparent 25%, transparent 75%, rgba(255,255,255,.045) 75%),
                     linear-gradient(45deg, rgba(255,255,255,.045) 25%, transparent 25%, transparent 75%, rgba(255,255,255,.045) 75%);
                   background-size: 20px 20px; background-position: 0 0, 10px 10px; }
  .preview-stage img { max-width: 92%; filter: drop-shadow(0 10px 22px rgba(0,0,0,.55)); }
  .preview-stage img.pop { animation: pop .3s cubic-bezier(.34,1.56,.64,1); }
  @keyframes pop { from { transform: scale(.92); } to { transform: scale(1); } }
  .snippet { margin-top: .7rem; }
  .snippet-row { display: flex; gap: .4rem; }
  .snippet-row input { font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
                       font-size: .72rem; }
  .preview-actions { display: flex; align-items: center; gap: .7rem; margin-top: .8rem; }
  .preview-actions .button { text-decoration: none; color: var(--text);
                             border: 1px solid var(--surface1); border-radius: .4rem;
                             padding: .42rem .8rem; font-size: .82rem;
                             background: rgba(49,50,68,.5); }
  .preview-actions .button:hover { background: var(--surface1); }
  .status { font-size: .76rem; color: var(--green); min-height: 1em; }
  .combo { position: relative; }
  .combo-list { position: absolute; z-index: 40; top: calc(100% + .25rem); left: 0; right: 0;
                margin: 0; padding: .25rem; list-style: none; background: var(--crust);
                border: 1px solid var(--surface1); border-radius: .5rem; max-height: 15rem;
                overflow: auto; box-shadow: 0 18px 40px -22px #000; }
  .combo-list li { display: flex; align-items: center; gap: .5rem; padding: .32rem .45rem;
                   border-radius: .35rem; font-size: .8rem; cursor: pointer; }
  .combo-list li.is-active, .combo-list li:hover { background: var(--surface0); }
  .combo-list img { width: 1.15rem; height: 1.15rem; object-fit: contain; }
  .chip { display: inline-block; width: 1.1rem; height: 1.1rem; border-radius: .28rem;
          border: 1px solid rgba(255,255,255,.35); background: var(--chip, transparent);
          flex: none; }
  .color-input.is-target { border-color: var(--mauve); }
  .palette-card summary { cursor: pointer; font-size: .9rem; color: var(--subtext0); }
  .palettes { display: grid; gap: .9rem; margin-top: .8rem;
              grid-template-columns: repeat(auto-fit, minmax(15rem, 1fr)); }
  .palette-group h3 { margin: .1rem 0 .45rem; }
  .swatches { display: flex; flex-wrap: wrap; gap: .3rem; }
  .swatch { display: flex; align-items: center; gap: .35rem; font-size: .7rem;
            padding: .22rem .45rem .22rem .25rem; border-radius: 999px;
            border: 1px solid rgba(88,91,112,.5); background: rgba(17,17,27,.5); }
  .swatch:hover { border-color: var(--mauve); }
  .swatch-name { color: var(--subtext0); }
  .footer { margin-top: 2.4rem; border-top: 1px solid var(--surface0); padding-top: 1.2rem;
            display: flex; flex-wrap: wrap; gap: 1rem 1.6rem; align-items: center;
            justify-content: space-between; color: var(--subtext0); font-size: .8rem; }
  .footer .brand { display: flex; align-items: center; gap: .6rem; }
  .footer .brand img { height: 1.8rem; width: auto; }
  .footer nav { display: flex; gap: .9rem; flex-wrap: wrap; }
  .footer a { color: var(--sapphire); text-decoration: none; }
  .footer a:hover { text-decoration: underline; }
  .footer .colophon { flex-basis: 100%; margin: 0; color: var(--overlay0); }
  code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; color: #f5c2e7; }
  @media (max-width: 60rem) {
    .layout { grid-template-columns: minmax(0, 1fr); }
    .preview-card { position: static; }
  }
")

(define builder-script "
      const DEFAULT_BG = 'catppuccin-mocha-surface2';
      const DEFAULT_FG = 'catppuccin-mocha-text';
      const colorItems = COLORS.map(([value, hex]) => ({ value, hex }));
      const logoItems = LOGOS.map((value) => ({ value }));
      const PRESETS = [
        { name: 'CI build', label: 'ci', text: 'passing', bg: 'catppuccin-mocha-green',
          fg: 'catppuccin-mocha-base', logo: 'githubactions', style: 'flat' },
        { name: 'License', label: 'license', text: 'MIT', bg: 'catppuccin-mocha-blue',
          fg: 'catppuccin-mocha-base', logo: 'scales', style: 'shadow' },
        { name: 'Coverage', label: 'coverage', text: '98%', bg: 'catppuccin-mocha-teal',
          fg: 'catppuccin-mocha-base', logo: 'sparkle', style: 'plastic' },
        { name: 'Docs', label: 'docs', text: 'passing', bg: 'catppuccin-mocha-sapphire',
          fg: 'catppuccin-mocha-base', logo: 'readthedocs', style: 'material' },
        { name: 'Frutiger Aero', label: 'aero', text: 'frutiger', bg: 'catppuccin-mocha-sky',
          fg: 'catppuccin-mocha-base', logo: 'leaf', style: 'frutiger' },
        { name: 'Neon', label: 'glow', text: 'neon', bg: 'catppuccin-mocha-mauve',
          fg: 'catppuccin-mocha-base', logo: 'atom-orbit', style: 'neon' }
      ];

      const preview = document.getElementById('preview');
      const urlField = document.getElementById('url');
      const markdownField = document.getElementById('markdown');
      const htmlField = document.getElementById('html');
      const download = document.getElementById('download');
      const status = document.getElementById('status');
      const rows = document.getElementById('sections');
      const styleInput = document.getElementById('style');
      let activeColor = null;

      function hexFor(name) {
        const found = COLORS.find(([value]) => value === name);
        return found ? found[1] : name;
      }

      function attachCombo(input, items) {
        const wrap = input.parentElement;
        wrap.classList.add('combo');
        const list = document.createElement('ul');
        list.className = 'combo-list';
        list.setAttribute('role', 'listbox');
        list.hidden = true;
        wrap.appendChild(list);
        let matches = [];
        let cursor = -1;

        function close() {
          list.hidden = true;
          input.setAttribute('aria-expanded', 'false');
        }

        function choose(value) {
          input.value = value;
          close();
          input.dispatchEvent(new Event('input', { bubbles: true }));
        }

        function paint() {
          list.innerHTML = matches.map((item, index) => {
            const visual = item.hex
              ? '<span class=\"chip\" style=\"background:' + hexFor(item.value) + '\"></span>'
              : '<img src=\"/logo.svg?name=' + encodeURIComponent(item.value) + '\" alt=\"\" loading=\"lazy\">';
            return '<li role=\"option\" data-value=\"' + item.value + '\" aria-selected=\"' +
                   (index === cursor) + '\" class=\"' + (index === cursor ? 'is-active' : '') + '\">' +
                   visual + '<span>' + item.value + '</span></li>';
          }).join('');
          list.hidden = matches.length === 0;
          input.setAttribute('aria-expanded', String(matches.length > 0));
        }

        function refresh() {
          const query = input.value.trim().toLowerCase();
          const pool = query
            ? items.filter((item) => item.value.toLowerCase().includes(query))
            : items.slice(0, 8);
          matches = pool.slice(0, 8);
          cursor = matches.length ? 0 : -1;
          paint();
        }

        input.setAttribute('autocomplete', 'off');
        input.setAttribute('aria-expanded', 'false');
        input.addEventListener('focus', refresh);
        input.addEventListener('input', refresh);
        input.addEventListener('keydown', (event) => {
          if (list.hidden) return;
          if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
            event.preventDefault();
            cursor = (cursor + (event.key === 'ArrowDown' ? 1 : -1) + matches.length) % matches.length;
            paint();
          } else if (event.key === 'Enter') {
            if (cursor >= 0) {
              event.preventDefault();
              choose(matches[cursor].value);
            }
          } else if (event.key === 'Escape') {
            close();
          }
        });
        input.addEventListener('blur', () => setTimeout(close, 120));
        list.addEventListener('mousedown', (event) => {
          const item = event.target.closest('[data-value]');
          if (item) {
            event.preventDefault();
            choose(item.dataset.value);
          }
        });
      }

      function addSection(text, background, ink) {
        const row = document.createElement('div');
        row.className = 'section-row';
        row.innerHTML =
          '<label>Text <input class=\"text\" placeholder=\"passing\" autocomplete=\"off\"></label>' +
          '<label>Background <input class=\"bg color-input\" placeholder=\"' + DEFAULT_BG + '\" autocomplete=\"off\"></label>' +
          '<label>Text color <input class=\"fg color-input\" placeholder=\"' + DEFAULT_FG + '\" autocomplete=\"off\"></label>' +
          '<button type=\"button\" class=\"remove\" aria-label=\"Remove this section\">x</button>';
        row.querySelector('.text').value = text || '';
        row.querySelector('.bg').value = background || '';
        row.querySelector('.fg').value = ink || '';
        row.querySelector('.remove').addEventListener('click', () => {
          row.remove();
          update();
        });
        row.querySelectorAll('input').forEach((input) => input.addEventListener('input', update));
        attachCombo(row.querySelector('.bg'), colorItems);
        attachCombo(row.querySelector('.fg'), colorItems);
        rows.appendChild(row);
      }

      function value(id) {
        return document.getElementById(id).value.trim();
      }

      function setStyle(style) {
        styleInput.value = style;
        document.querySelectorAll('.style-card').forEach((card) =>
          card.classList.toggle('is-active', card.dataset.style === style));
      }

      function update() {
        const params = new URLSearchParams();
        ['label', 'label-bg', 'label-fg', 'logo'].forEach((id) => {
          const field = document.getElementById(id).value.trim();
          if (field) params.append(id, field);
        });
        if (styleInput.value) params.append('style', styleInput.value);
        rows.querySelectorAll('.section-row').forEach((row) => {
          const text = row.querySelector('.text').value.trim();
          if (!text) return;
          params.append('text', text);
          params.append('bg', row.querySelector('.bg').value.trim() || DEFAULT_BG);
          params.append('fg', row.querySelector('.fg').value.trim() || DEFAULT_FG);
        });
        if (!params.has('text')) {
          preview.removeAttribute('src');
          urlField.value = '';
          markdownField.value = '';
          htmlField.value = '';
          download.removeAttribute('href');
          status.textContent = 'Add a section to see the badge.';
          return;
        }
        const url = new URL('/badge.svg?' + params.toString(), location.href);
        const href = url.pathname + url.search;
        preview.src = href;
        preview.classList.remove('pop');
        void preview.offsetWidth;
        preview.classList.add('pop');
        urlField.value = url.href;
        markdownField.value = '![badge](' + url.href + ')';
        htmlField.value = '<img src=\"' + url.href + '\" alt=\"badge\">';
        download.href = href;
        download.setAttribute('download', 'badge.svg');
        status.textContent = '';
      }

      document.getElementById('add').addEventListener('click', () => addSection());
      document.getElementById('presets').addEventListener('click', (event) => {
        const button = event.target.closest('[data-preset]');
        if (!button) return;
        const preset = PRESETS[Number(button.dataset.preset)];
        rows.innerHTML = '';
        document.getElementById('label').value = preset.label || '';
        document.getElementById('label-bg').value = '';
        document.getElementById('label-fg').value = '';
        document.getElementById('logo').value = preset.logo || '';
        setStyle(preset.style || 'flat');
        addSection(preset.text, preset.bg, preset.fg);
        update();
      });
      document.getElementById('styles').addEventListener('click', (event) => {
        const card = event.target.closest('[data-style]');
        if (!card) return;
        setStyle(card.dataset.style);
        update();
      });
      document.getElementById('palette').addEventListener('click', (event) => {
        const swatch = event.target.closest('[data-color]');
        if (!swatch) return;
        const target = activeColor || document.querySelector('.section-row .bg');
        if (!target) return;
        target.value = swatch.dataset.color;
        target.classList.add('is-target');
        target.dispatchEvent(new Event('input', { bubbles: true }));
        status.textContent = 'Set ' + swatch.dataset.color;
        setTimeout(() => { status.textContent = ''; }, 1400);
      });
      document.addEventListener('focusin', (event) => {
        if (!event.target.classList || !event.target.classList.contains('color-input')) return;
        activeColor = event.target;
        document.querySelectorAll('.color-input').forEach((input) =>
          input.classList.toggle('is-target', input === event.target));
      });
      document.querySelectorAll('[data-copy]').forEach((button) => {
        button.addEventListener('click', async () => {
          const field = document.getElementById(button.dataset.copy);
          if (!field || !field.value) return;
          try {
            await navigator.clipboard.writeText(field.value);
            status.textContent = 'Copied.';
          } catch (error) {
            field.select();
            status.textContent = 'Press Ctrl+C to copy.';
          }
          setTimeout(() => { status.textContent = ''; }, 1600);
        });
      });
      ['label', 'label-bg', 'label-fg', 'logo'].forEach((id) =>
        document.getElementById(id).addEventListener('input', update));
      attachCombo(document.getElementById('logo'), logoItems);
      attachCombo(document.getElementById('label-bg'), colorItems);
      attachCombo(document.getElementById('label-fg'), colorItems);
      addSection('passing');
      document.getElementById('label').value = 'build';
      update();
")

(define builder-hero "\
      <header class=\"hero\">
        <img src=\"/logo.svg\" alt=\"ggg logo\">
        <div>
          <h1>ggg badge builder</h1>
          <p>Describe a badge here and copy its URL. Every setting is a plain GET
          query, so the badge drops into a README as <code>![badge](URL)</code>.</p>
          <div class=\"chips\">
            <span>Guile Scheme</span><span>SVG</span>
            <span>any number of sections</span><span>MIT License</span>
            <a href=\"https://jointhefreeworld.org/ggg/dist/gallery.html\">Browse the gallery &rarr;</a>
          </div>
        </div>
      </header>")

(define builder-presets "\
      <div class=\"presets\" id=\"presets\" aria-label=\"Starting points\">
        <button type=\"button\" class=\"preset\" data-preset=\"0\">CI build</button>
        <button type=\"button\" class=\"preset\" data-preset=\"1\">License</button>
        <button type=\"button\" class=\"preset\" data-preset=\"2\">Coverage</button>
        <button type=\"button\" class=\"preset\" data-preset=\"3\">Docs</button>
        <button type=\"button\" class=\"preset\" data-preset=\"4\">Frutiger Aero</button>
        <button type=\"button\" class=\"preset\" data-preset=\"5\">Neon</button>
      </div>")

(define builder-sections-card "\
        <section class=\"card\">
          <h2>Sections</h2>
          <div id=\"sections\"></div>
          <button type=\"button\" id=\"add\">Add section</button>
          <p class=\"hint\">The Nth <code>bg</code>/<code>fg</code> belongs to the Nth
          <code>text</code>; empty fields use the defaults. Up to 10 sections, 100
          characters each. Focus a color field, then click a swatch below.</p>
        </section>")

(define builder-preview-card "\
        <section class=\"card preview-card\">
          <h2>Preview</h2>
          <div class=\"preview-stage\"><img id=\"preview\" alt=\"badge preview\"></div>
          <label class=\"snippet\">URL
            <span class=\"snippet-row\">
              <input id=\"url\" readonly aria-label=\"Badge URL\">
              <button type=\"button\" data-copy=\"url\">Copy</button>
            </span>
          </label>
          <label class=\"snippet\">Markdown
            <span class=\"snippet-row\">
              <input id=\"markdown\" readonly aria-label=\"Markdown snippet\">
              <button type=\"button\" data-copy=\"markdown\">Copy</button>
            </span>
          </label>
          <label class=\"snippet\">HTML
            <span class=\"snippet-row\">
              <input id=\"html\" readonly aria-label=\"HTML snippet\">
              <button type=\"button\" data-copy=\"html\">Copy</button>
            </span>
          </label>
          <div class=\"preview-actions\">
            <a id=\"download\" class=\"button\" href=\"#\" download=\"badge.svg\">Download SVG</a>
            <span class=\"status\" id=\"status\" role=\"status\" aria-live=\"polite\"></span>
          </div>
          <p class=\"hint\">The URL works anywhere an image does, and the server caches
          a successful badge for five minutes.</p>
        </section>")

(define (palette-name theme qualified)
  "QUALIFIED without its THEME prefix, e.g. 'red' for catppuccin-mocha-red."
  (let ((prefix (string-append theme "-")))
    (if (string-prefix? prefix qualified)
        (substring qualified (string-length prefix))
        qualified)))

(define (palette-swatch theme entry)
  "One clickable swatch for a color of THEME. ENTRY is a (name . hex) pair."
  (format #f "\
              <button type=\"button\" class=\"swatch\" data-color=\"~a\" title=\"~a (~a)\" style=\"--chip: ~a\">
                <span class=\"chip\"></span><span class=\"swatch-name\">~a</span>
              </button>"
          (html-escape (car entry))
          (html-escape (car entry))
          (html-escape (cdr entry))
          (html-escape (cdr entry))
          (html-escape (palette-name theme (car entry)))))

(define (builder-palette)
  "The collapsible palette of every named color, grouped by theme."
  (format #f "\
        <details class=\"card palette-card\" id=\"palette\">
          <summary>Color palette <span class=\"meta\">~a colors &middot; click one to fill the last color field</span></summary>
          <p class=\"hint\">Colors take theme names or hex strings such as <code>#ff8800</code>.</p>
          <div class=\"palettes\">
~a
          </div>
        </details>"
          (length named-colors)
          (string-join
           (map (lambda (theme)
                  (format #f "\
            <section class=\"palette-group\">
              <h3>~a</h3>
              <div class=\"swatches\">~a</div>
            </section>"
                          (html-escape (car theme))
                          (string-join (map (lambda (entry)
                                              (palette-swatch (car theme) entry))
                                            (cdr theme))
                                       "")))
                (colors-by-theme))
           "\n")))

(define (style-card style)
  "One clickable finish, previewed by a badge rendered in that style."
  (let ((name (symbol->string style))
        (description (or (assoc-ref style-descriptions style) "")))
    (format #f "\
            <button type=\"button\" class=\"style-card~a\" data-style=\"~a\" title=\"~a\">
              <img src=\"/badge.svg?label=Style&amp;text=~a&amp;style=~a&amp;bg=catppuccin-mocha-mauve&amp;fg=catppuccin-mocha-base\" alt=\"\" loading=\"lazy\">
              <span class=\"style-name\">~a</span>
            </button>"
            (if (eq? style 'flat) " is-active" "")
            name
            (html-escape description)
            name name name)))

(define (builder-label-card)
  "The label, logo and finish card."
  (format #f "\
        <section class=\"card\">
          <h2>Label and finish</h2>
          <div class=\"grid\">
            <label>Label <input id=\"label\" placeholder=\"build\"></label>
            <label>Logo <input id=\"logo\" placeholder=\"guix\"></label>
            <label>Label background <input id=\"label-bg\" class=\"color-input\" placeholder=\"catppuccin-mocha-surface2\"></label>
            <label>Label text color <input id=\"label-fg\" class=\"color-input\" placeholder=\"catppuccin-mocha-text\"></label>
          </div>
          <input type=\"hidden\" id=\"style\" value=\"flat\">
          <h3>Finish</h3>
          <div class=\"styles\" id=\"styles\">~a
          </div>
        </section>"
          (string-join (map style-card style-names) "\n")))

(define (builder-footer revision)
  "The footer: logo, version, build revision, license, source and documentation."
  (let ((build (if (string=? revision "unknown")
                   "<span id=\"build-sha\">development build</span>"
                   (format #f "\
<a id=\"build-sha\" href=\"https://github.com/jjba23/ggg/commit/~a\">commit ~a</a>"
                           (html-escape revision)
                           (html-escape revision)))))
    (format #f "\
      <footer class=\"footer\">
        <div class=\"brand\">
          <img src=\"/logo.svg\" alt=\"ggg logo\" loading=\"lazy\">
          <span><strong>ggg</strong> ~a &middot; ~a</span>
        </div>
        <nav aria-label=\"Project links\">
          <a href=\"https://github.com/jjba23/ggg\">Source code</a>
          <a href=\"https://github.com/jjba23/ggg/blob/trunk/README.org\">README</a>
          <a href=\"https://jointhefreeworld.org/api-docs/ggg/API.html\">API docs</a>
          <a href=\"https://jointhefreeworld.org/ggg/dist/gallery.html\">Gallery</a>
          <a href=\"https://github.com/jjba23/ggg/blob/trunk/CREDITS.org\">Logo credits</a>
          <a href=\"https://opensource.org/license/mit\">MIT License</a>
        </nav>
        <p class=\"colophon\">Free software under the MIT License; the logos keep the
        licenses listed in CREDITS.org. Built with GNU Guile.</p>
      </footer>"
            (html-escape ggg-version)
            build)))

(define* (builder-html resources)
  "The self-contained badge builder page for the logo library in RESOURCES."
  (let ((logos (logo-names #:resources resources)))
    (string-append
     "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n"
     "    <meta charset=\"UTF-8\">\n"
     "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
     "    <title>ggg badge builder</title>\n"
     "    <style>" builder-style "</style>\n"
     "  </head>\n  <body>\n"
     "    <div class=\"aurora\" aria-hidden=\"true\"></div>\n"
     "    <main>\n"
     builder-hero
     builder-presets
     "      <div class=\"layout\">\n        <div class=\"column\">\n"
     (builder-label-card)
     builder-sections-card
     (builder-palette)
     "        </div>\n"
     builder-preview-card
     "      </div>\n"
     (builder-footer (build-revision))
     "    </main>\n    <script>"
     (format #f "const COLORS = ~a;~%      const LOGOS = ~a;~%"
             (js-color-pairs)
             (js-logos logos))
     builder-script
     "</script>\n  </body>\n</html>\n")))

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

(define* (project-logo-path #:optional (resources "."))
  "The ggg mark the builder wears: the shipped copy, or the checkout's logo.svg."
  (let ((shipped (in-vicinity resources "logo.svg"))
        (checkout (in-vicinity (dirname resources) "logo.svg")))
    (cond ((file-exists? shipped) shipped)
          ((file-exists? checkout) checkout)
          (else #f))))

(define* (logo-response params #:key resources)
  "The project mark without a name, or the logo the request names."
  (let ((name (param params "name")))
    (cond
      ((or (not name) (string-null? name))
       (let ((path (project-logo-path resources)))
         (if path
             (values (build-response
                      #:code 200
                      #:headers '((content-type . (image/svg+xml))
                                  (cache-control . (public (max-age . 300)))))
                     (call-with-input-file path get-string-all))
             (plain-response 500 "the project logo is missing from the resources\n"))))
      ((not (logo-name-valid? name))
       (plain-response 400
                       (format #f "invalid logo name '~a'; use a plain file name\n"
                               name)))
      ((logo-file-path name #:resources resources)
       => (lambda (path)
            (values (build-response
                     #:code 200
                     #:headers '((content-type . (image/svg+xml))
                                 (cache-control . (public (max-age . 300)))))
                    (call-with-input-file path get-string-all))))
      (else
       (plain-response 404
                       (format #f "no logo named '~a'; see / for the library\n"
                               name))))))

(define (builder-response resources)
  (values (build-response #:code 200
                          #:headers '((content-type . (text/html))))
          (builder-html resources)))

(define badge-paths '("/badge.svg" "/badge"))
(define logo-paths '("/logo.svg" "/logo"))
(define builder-paths '("/" "/index.html"))

(define* (badge-handler request body #:key resources)
  "Answer REQUEST with a badge, a logo or the builder page, or explain why it has
none.  BODY goes unread: a badge is an enquiry, not an upload."
  (let ((path (uri-path (request-uri request))))
    (cond
      ((not (eq? 'GET (request-method request)))
       (plain-response 405 "Only GET requests are served.\n"))
      ((member path builder-paths)
       (builder-response resources))
      ((member path badge-paths)
       (badge-response (query-params (uri-query (request-uri request)))
                       #:resources resources))
      ((member path logo-paths)
       (logo-response (query-params (uri-query (request-uri request)))
                      #:resources resources))
      (else
       (plain-response 404
                       (format #f "Not found: ~a~%Try / for the badge builder, /badge.svg?text=passing or /logo.svg?name=guix~%"
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
