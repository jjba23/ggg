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
  #:use-module (ggg logo)
  #:use-module (ggg prelude)
  #:use-module (ggg sxml)
  #:export (gallery-html write-gallery-page logo-display-name logo-markup))

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

(define gallery-style "
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  body {
    margin: 0; padding: 2rem 1.5rem 4rem;
    font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
    background: #14181d; color: #e9edf2;
  }
  header { max-width: 76rem; margin: 0 auto 1.5rem; }
  h1 { margin: 0 0 .4rem; font-size: 1.7rem; }
  p.lede { margin: 0 0 1rem; color: #a9b3bf; max-width: 48rem; line-height: 1.5; }
  .toolbar { display: flex; gap: .8rem; flex-wrap: wrap; align-items: center; }
  input[type=search] {
    padding: .5rem .7rem; min-width: 16rem; border-radius: .4rem;
    border: 1px solid #39414b; background: #1b2128; color: inherit; font-size: .95rem;
  }
  .count { color: #a9b3bf; font-size: .9rem; }
  .grid {
    max-width: 76rem; margin: 1.5rem auto 0;
    display: grid; gap: .9rem;
    grid-template-columns: repeat(auto-fill, minmax(11rem, 1fr));
  }
  figure.tile {
    margin: 0; padding: .9rem .7rem .7rem; border-radius: .6rem;
    background: #1b2128; border: 1px solid #262d36;
    display: flex; flex-direction: column; gap: .6rem; align-items: center;
  }
  figure.tile[hidden] { display: none; }
  .preview {
    width: 4.5rem; height: 4.5rem; border-radius: .5rem;
    background: #555555; display: flex; align-items: center; justify-content: center;
  }
  .preview svg { width: 3rem; height: 3rem; }
  figcaption { text-align: center; width: 100%; }
  .name {
    display: block; font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: .85rem; color: #ffffff; overflow-wrap: anywhere;
  }
  .title { display: block; font-size: .74rem; color: #97a2ae; margin-top: .15rem; }
  code.snippet {
    display: block; margin-top: .4rem; font-size: .68rem; color: #7f8b98;
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  }
  footer { max-width: 76rem; margin: 2.5rem auto 0; color: #7f8b98; font-size: .85rem; }
  a { color: #80aadf; }
")

(define gallery-script "
  const input = document.querySelector('input[type=search]');
  const tiles = Array.from(document.querySelectorAll('figure.tile'));
  const count = document.querySelector('.count');
  const label = (n) => n + ' logo' + (n === 1 ? '' : 's');
  const filter = () => {
    const query = input.value.trim().toLowerCase();
    let shown = 0;
    tiles.forEach((tile) => {
      const matches = !query || tile.dataset.name.toLowerCase().includes(query);
      tile.hidden = !matches;
      if (matches) shown += 1;
    });
    count.textContent = query ? shown + ' of ' + label(tiles.length) : label(tiles.length);
  };
  input.addEventListener('input', filter);
  filter();
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
        <code class=\"snippet\">(logo . ~a)</code>
      </figcaption>
    </figure>"
            (html-escape name)
            (html-escape display)
            markup
            (html-escape name)
            (html-escape display)
            (html-escape name))))

(define* (gallery-html #:key resources (title "GGG logo gallery"))
  "A self-contained HTML page showing every logo in RESOURCES with its name."
  (let ((names (logo-names #:resources resources)))
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
        Every logo that ggg ships, inlined from its
        <code>resources/logos/&lt;name&gt;.svg</code> file. Logos are drawn white
        on the same gray a badge uses, so they look just like they will inside
        a badge. Use one in a glyph file with <code>(logo . name)</code>.
        See <code>resources/logos/CREDITS.md</code> for where each logo comes from.
      </p>
      <div class=\"toolbar\">
        <input type=\"search\" placeholder=\"Filter logos…\" aria-label=\"Filter logos\">
        <span class=\"count\">~a logos</span>
      </div>
    </header>
    <main class=\"grid\">
~a
    </main>
    <footer>
      Generated by <code>ggg --gallery</code> from ~a.
    </footer>
    <script>~a</script>
  </body>
</html>
"
            (html-escape title)
            gallery-style
            (html-escape title)
            (length names)
            (string-join (map (lambda (name)
                                (gallery-tile name #:resources resources))
                              names)
                         "\n")
            (html-escape resources)
            gallery-script)))

(define* (write-gallery-page path #:key resources)
  "Write the logo gallery to PATH and return how many logos it shows."
  (let* ((names (logo-names #:resources resources))
         (html (gallery-html #:resources resources)))
    (guard-errors (lambda ()
                    (ensure-directory (dirname path))
                    (with-output-to-file path
                      (lambda ()
                        (display html))))
                  #:label (format #f "could not write gallery page '~a'" path)
                  #:hint "Check that the directory you are writing to exists and is writable.")
    (length names)))
