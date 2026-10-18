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

;; Commentary:
;;
;; Test suite for ggg, run it with:
;;
;;   guile -L ./src ./test/ggg-tests.scm
;;
;; or through Maak:
;;
;;   maak test

(use-modules (ice-9 textual-ports)
             (srfi srfi-1)
             (srfi srfi-13)
             (srfi srfi-64)
             (ggg colors)
             (ggg gallery)
             (ggg glyph)
             (ggg logo)
             (ggg main)
             (ggg prelude)
             (ggg sxml))

(define project-root
  (canonicalize-path
   (string-append (dirname (current-filename)) "/..")))

(define resources
  (string-append project-root "/resources"))

(define fixtures
  (string-append project-root "/test/fixtures"))

(define (sxml->string* tree)
  (call-with-output-string
   (lambda (port)
     (sxml->xml tree port))))

(define (svg-attribute logo name)
  "Read an attribute of a logo's outer svg element."
  (let* ((attribute-group (assoc '@ (cdr logo)))
         (attribute (and attribute-group
                         (assoc name (cdr attribute-group)))))
    (and attribute (cadr attribute))))

(test-begin "ggg")
(define runner (test-runner-current))

;; ====== Named colors ======

(test-group "colors"
  (test-equal "palette names resolve to hex values"
    "#555"
    (resolve-color 'badge-gray))
  (test-equal "hex strings pass through"
    "#abcdef"
    (resolve-color "#abcdef"))
  (test-assert "short hex strings are valid"
    (not (color-error "#fff")))
  (test-assert "invalid hex colors are reported"
    (color-error "#12345"))
  (test-assert "unknown color names are reported"
    (color-error 'not-a-color))
  (test-assert "unknown color names get a suggestion"
    (string-contains (color-error 'guix-yelow) "guix-yellow"))
  (test-assert "error messages can carry a context"
    (string-contains (color-error 'nope #:context "glyph 'x', section 1")
                     "glyph 'x', section 1")))

;; ====== Logos ======

(test-group "logos"
  (test-assert "unknown logos return #f"
    (not (get-logo-sxml 'no-such-logo #:resources resources)))
  (test-assert "the shipped logos are listed"
    (every (lambda (name)
             (member (symbol->string name) (logo-names #:resources resources)))
           '(emacs gear guix rust scala)))

  (test-group "logo discovery"
    (test-equal "only .svg files count as logos"
      '()
      (logo-names #:resources (string-append fixtures "/raw-paths")))

    (test-assert "every listed logo has an svg file on disk"
      (every (lambda (name)
               (string-suffix? ".svg"
                               (or (logo-file-path name #:resources resources)
                                   "")))
             (logo-names #:resources resources)))

    (test-assert "files that are not svg documents are not logos"
      (not (logo-file-path 'legacy-path
                           #:resources (string-append fixtures "/raw-paths"))))

    (test-equal "leftover svg-paths files are detected"
      '("gear" "rust")
      (legacy-svg-paths #:resources (string-append fixtures "/legacy-paths")))

    (test-equal "a resources directory without svg-paths has none"
      '()
      (legacy-svg-paths #:resources (string-append fixtures "/raw-paths"))))


  (test-group "full svg documents"
    (let* ((logo (get-logo-sxml 'multi-part #:resources fixtures))
           (xml (sxml->string* logo)))
      (test-equal "the logo viewBox is kept"
        "0 0 32 32"
        (svg-attribute logo 'viewBox))
      (test-equal "the badge decides the logo size"
        18
        (svg-attribute logo 'width))
      (test-assert "the svg namespace is declared"
        (string-contains xml "xmlns=\"http://www.w3.org/2000/svg\""))
      (test-assert "every shape of the logo is kept"
        (and (string-contains xml "<path")
             (string-contains xml "<circle")
             (string-contains xml "<use")))
      (test-assert "gradients and defs survive"
        (and (string-contains xml "linearGradient")
             (string-contains xml "url(#multi-part-gradient)")))
      (test-assert "groups with transforms survive"
        (string-contains xml "translate(0 2)"))
      (test-assert "xlink attributes keep their prefix"
        (string-contains xml "xlink:href"))
      (test-assert "the xlink namespace is declared"
        (string-contains xml "xmlns:xlink"))
      (test-assert "foreign namespace metadata is dropped"
        (not (string-contains xml "inkscape"))))))

;; ====== Glyph validation ======

(define valid-glyph
  `((sections ((background . badge-gray)
               (text . "Scheme")
               (color . white)
               (logo . lambda))
              ((background . guix-orange) (text . "Guile") (color . white)))
    (id . scheme-guile-test)))

(define broken-glyph
  `((sections ((background . not-a-color)
               (text . "Broken")
               (color . white)
               (logo . no-such-logo)))
    (id . broken-test)
    (height . tall)))

(test-group "validation"
  (test-equal "a valid glyph has no problems"
    '()
    (validate-glyph valid-glyph #:resources resources))

  (test-assert "unknown colors are reported"
    (any (lambda (problem) (string-contains problem "not-a-color"))
         (validate-glyph broken-glyph #:resources resources)))

  (test-assert "unknown logos are reported"
    (any (lambda (problem) (string-contains problem "unknown logo 'no-such-logo'"))
         (validate-glyph broken-glyph #:resources resources)))

  (test-assert "non-numeric settings are reported"
    (any (lambda (problem) (string-contains problem "must be a number"))
         (validate-glyph broken-glyph #:resources resources)))

  (test-assert "malformed settings suggest the dotted pair syntax"
    (any (lambda (problem) (string-contains problem "(background . value)"))
         (validate-glyph `((sections ((background "#555")
                                      (text . "x")
                                      (color . white)))
                           (id . malformed))
                         #:resources resources)))

  (test-assert "too many sections are reported"
    (any (lambda (problem) (string-contains problem "at most 3"))
         (validate-glyph `((sections ((background . badge-gray) (text . "1") (color . white))
                                     ((background . badge-gray) (text . "2") (color . white))
                                     ((background . badge-gray) (text . "3") (color . white))
                                     ((background . badge-gray) (text . "4") (color . white)))
                           (id . four))
                         #:resources resources)))

  (test-assert "missing text labels are reported"
    (any (lambda (problem) (string-contains problem "missing a text label"))
         (validate-glyph `((sections ((background . badge-gray) (color . white)))
                           (id . no-text))
                         #:resources resources)))

  (test-assert "ids that cannot be file names are reported"
    (any (lambda (problem) (string-contains problem "cannot be used as a file name"))
         (validate-glyph `((sections ((background . badge-gray)
                                      (text . "x")
                                      (color . white)))
                           (id . "../escape"))
                         #:resources resources)))

  (test-assert "duplicate ids are reported"
    (any (lambda (problem) (string-contains problem "reuses the id"))
         (validate-glyphs (list valid-glyph valid-glyph) #:resources resources)))

  (test-assert "an empty configuration is reported"
    (pair? (validate-glyphs '() #:resources resources))))

;; ====== Rendering ======

(test-group "rendering"
  (let* ((xml (sxml->string* (mk-glyph valid-glyph #:resources resources))))
    ;; The badge is rendered from the glyph defined above, using named colors,
    ;; a named logo and defaults for every other setting.
    (test-assert "named colors are resolved to hex values"
      (and (string-contains xml "fill=\"#555\"")
           (string-contains xml "fill=\"#d0730f\"")
           (string-contains xml "fill=\"#fff\"")))
    (test-assert "badge text is rendered"
      (and (string-contains xml ">Scheme<")
           (string-contains xml ">Guile<")))
    (test-assert "logos are inlined into the badge"
      (string-contains xml "viewBox=\"0 0 18 20\""))
    (test-assert "the badge id becomes the svg id"
      (string-contains xml "id=\"scheme-guile-test\"")))

  (let* ((glyph `((sections ((background . badge-gray)
                             (text . "Complex")
                             (color . white)
                             (logo . sparkle)))
                  (id . complex-logo-test)))
         (xml (sxml->string* (mk-glyph glyph #:resources resources))))
    (test-assert "a badge can use a gradient logo"
      (and (string-contains xml "linearGradient")
           (string-contains xml "url(#sparkle-shine)")))))

;; ====== Gallery ======

(test-group "gallery"
  (test-equal "logo display names come from the logo title"
    "Sparkle"
    (logo-display-name 'sparkle #:resources resources))

  (test-equal "display names fall back to the file name"
    "rust"
    (logo-display-name 'rust #:resources resources))

  (let* ((html (gallery-html #:resources resources))
         (names (logo-names #:resources resources))
         (tiles (filter (lambda (line)
                          (string-contains line "class=\"tile\""))
                        (string-split html #\newline))))
    (test-assert "every logo gets a tile"
      (= (length names) (length tiles)))
    (test-assert "tiles show the glyph snippet"
      (string-contains html "(logo . sparkle)"))
    (test-assert "logos are inlined instead of linked"
      (string-contains html "<svg"))
    (test-assert "logo ids are namespaced so they cannot clash"
      (and (string-contains html "id=\"logo-sparkle-sparkle-shine\"")
           (string-contains html "url(#logo-sparkle-sparkle-shine)")
           (not (string-contains html "url(#sparkle-shine)")))))

  (let* ((path (format #f "~a/ggg-gallery-test.html" (getenv "TMPDIR")))
         (count (write-gallery-page path #:resources resources)))
    (test-assert "the gallery page is written to disk"
      (and (> count 0) (file-exists? path)))
    (test-assert "the written page is self contained"
      (string-contains (call-with-input-file path get-string-all) "<svg"))
    (delete-file path)))

;; ====== Showcase ======

(define (load-glyph-file name)
  "Load glyphs/NAME in a throw-away module, returning its ggg-glyphs."
  (save-module-excursion
   (lambda ()
     (load (string-append project-root "/glyphs/" name))))
  (get-setting 'ggg-glyphs))

(test-group "showcase"
  (let* ((main-glyphs (load-glyph-file "jjba23.scm"))
         (showcase-glyphs (load-glyph-file "showcase.scm"))
         (showcase-ids (map glyph-id showcase-glyphs)))
    (test-assert "the showcase covers plenty of logos"
      (>= (length showcase-glyphs) 100))

    (test-assert "every showcase badge uses a logo"
      (every (lambda (glyph)
               (lookup (car (lookup glyph 'sections)) 'logo))
             showcase-glyphs))

    (test-equal "the showcase configuration is valid"
      '()
      (validate-glyphs showcase-glyphs #:resources resources))

    (test-assert "showcase ids do not collide with the main glyph file"
      (null? (lset-intersection string=? (map glyph-id main-glyphs)
                                showcase-ids)))

    (test-assert "showcase ids are unique"
      (= (length showcase-ids) (length (delete-duplicates showcase-ids))))

    (test-assert "showcase badges render"
      (string-contains (sxml->string* (mk-glyph (car showcase-glyphs)
                                                #:resources resources))
                       "<svg"))

    (test-equal "light brand colors get dark text"
      'black
      (cdr (assq 'color
                 (cadr (lookup (car (filter (lambda (glyph)
                                              (string=? (glyph-id glyph)
                                                        "javascript"))
                                            showcase-glyphs))
                               'sections)))))))

;; ====== Destination directory ======

(test-group "destination"
  (let* ((dir (string-append (or (getenv "TMPDIR") "/tmp") "/ggg-keep-test"))
         (kept (string-append dir "/kept.svg"))
         (prepare (@@ (ggg main) prepare-destination)))
    (ensure-directory dir)
    (call-with-output-file kept
      (lambda (port) (display "kept" port)))

    (with-output-to-string (lambda () (prepare dir #:keep? #t)))
    (test-assert "--keep leaves existing files alone"
      (file-exists? kept))

    (with-output-to-string (lambda () (prepare dir)))
    (test-assert "the destination is cleared by default"
      (and (file-exists? dir)
           (not (file-exists? kept))))

    (delete-directory-tree dir)))

(test-end "ggg")

(let ((passed (test-runner-pass-count runner))
      (failed (test-runner-fail-count runner))
      (skipped (test-runner-skip-count runner)))
  (display (format #f "\n~a checks: ~a passed, ~a failed, ~a skipped\n"
                   (+ passed failed skipped) passed failed skipped))
  (exit (if (zero? failed) 0 1)))
