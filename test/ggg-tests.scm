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

(use-modules (ice-9 regex)
             (ice-9 textual-ports)
             (srfi srfi-1)
             (srfi srfi-13)
             (srfi srfi-64)
             (ggg colors)
             (ggg gallery)
             (ggg glyph)
             (ggg logo)
             (ggg main)
             (ggg prelude)
             (ggg sxml)
             (ggg svg)
             (ggg version))

(define project-root
  (canonicalize-path
   (string-append (dirname (current-filename)) "/..")))

(define resources
  (string-append project-root "/resources"))

(define fixtures
  (string-append project-root "/test/fixtures"))

(define (temp-directory)
  "The system temporary directory, never #f. Falling back keeps tests from
creating a literal #f/ directory in the project root when TMPDIR is unset."
  (let ((tmpdir (getenv "TMPDIR")))
    (if (and tmpdir (not (string-null? tmpdir)))
        tmpdir
        "/tmp")))

(define (sxml->string* tree)
  (call-with-output-string
   (lambda (port)
     (sxml->xml tree port))))

(define (count-substring needle haystack)
  (let loop ((start 0) (count 0))
    (let ((found (string-contains haystack needle start)))
      (if found
          (loop (+ found (string-length needle)) (+ count 1))
          count))))

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
  (test-equal "catppuccin colors resolve to their hex values"
    "#f38ba8"
    (resolve-color 'catppuccin-mocha-red))
  (test-equal "every theme family is available"
    '(catppuccin-mocha catppuccin-macchiato catppuccin-frappe catppuccin-latte
      doom-one doom-one-light dracula dracula-alucard
      solarized-dark solarized-light modus-operandi modus-vivendi)
    (theme-names))
  (test-equal "doom colors resolve to their hex values"
    "#51afef"
    (resolve-color 'doom-one-blue))
  (test-equal "dracula colors resolve to their hex values"
    "#bd93f9"
    (resolve-color 'dracula-purple))
  (test-equal "solarized colors resolve to their hex values"
    "#fdf6e3"
    (resolve-color 'solarized-light-base3))
  (test-equal "modus colors resolve to their hex values"
    "#44bc44"
    (resolve-color 'modus-vivendi-green))
  (test-assert "every color is named after its theme"
    (every (lambda (theme)
             (every (lambda (name)
                      (string-prefix? (string-append (symbol->string theme) "-")
                                      (symbol->string name)))
                    (theme-color-names theme)))
           (theme-names)))
  (test-equal "no two themes share a color name"
    (length named-colors)
    (length (delete-duplicates (map car named-colors))))
  (test-assert "every palette color is a valid color"
    (every (lambda (entry) (not (color-error (cdr entry))))
           named-colors))
  (test-equal "colors are grouped by theme for display"
    (map symbol->string (theme-names))
    (map car (colors-by-theme)))
  (test-equal "hex strings pass through"
    "#abcdef"
    (resolve-color "#abcdef"))
  (test-assert "short hex strings are valid"
    (not (color-error "#fff")))
  (test-assert "invalid hex colors are reported"
    (color-error "#12345"))
  (test-assert "unknown color names are reported"
    (color-error 'not-a-color))
  (test-assert "colors without a theme are not accepted"
    (color-error 'red))
  (test-assert "unknown color names get a suggestion"
    (string-contains (color-error 'catppuccin-mocha-surfce2)
                     "catppuccin-mocha-surface2"))
  (test-assert "error messages can carry a context"
    (string-contains (color-error 'nope #:context "glyph 'x', section 1")
                     "glyph 'x', section 1")))

;; ====== Geometry ======

(test-group "geometry"
  (test-assert "the badge scale is 9.18% (6%, then a further 3%)"
    (< (abs (- badge-scale 1.0918)) 1e-9))
  (test-equal "the default geometry is scaled and kept to two decimals"
    '(21.84 15.29 6.55 15.29 3.28 3.28 12.01)
    (list (scaled 20) (scaled 14) (scaled 6) (scaled 14)
          (scaled 3) (scaled 3) (scaled 11)))
  (test-equal "coordinates built from scaled dimensions stay short"
    67.74
    (rounded (- 71.02 (scaled 3))))
  (test-equal "text is measured at the unscaled font size, then scaled"
  ;; "Scheme" is 39.9px of glyphs at 11px, plus 5px of padding each side.
    54
    (length-for-text "Scheme" #:font-size 11)))

;; ====== Version ======

(test-group "version"
  (test-assert "the version is a three-part version number"
    (string-match "^[0-9]+\\.[0-9]+\\.[0-9]+$" ggg-version))
  (test-equal "the version banner names ggg and the version"
    (string-append "ggg " ggg-version)
    (ggg-version-string))
  (test-assert "`ggg --version' prints the version, license and homepage"
    (let ((printed (call-with-output-string print-version)))
      (and (string-contains printed (ggg-version-string))
           (string-contains printed (string-append "License: " ggg-license))
           (string-contains printed (string-append "Homepage: " ggg-homepage)))))
  (test-assert "the version source is what `maak release' rewrites"
    (file-exists? (string-append project-root "/src/ggg/version.scm"))))

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
        15.29
        (svg-attribute logo 'width))
      (test-equal "a stray x/y in the logo document is ignored"
        '(3.28 3.28)
        (list (svg-attribute logo 'x) (svg-attribute logo 'y)))
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
  `((sections ((background . catppuccin-mocha-surface2)
               (text . "Scheme")
               (color . catppuccin-mocha-text)
               (logo . lambda))
              ((background . catppuccin-mocha-peach) (text . "Guile") (color . catppuccin-mocha-text)))
    (id . scheme-guile-test)))

(define broken-glyph
  `((sections ((background . not-a-color)
               (text . "Broken")
               (color . catppuccin-mocha-text)
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
                                      (color . catppuccin-mocha-text)))
                           (id . malformed))
                         #:resources resources)))

  (test-equal "badges may have more than three sections"
    '()
    (validate-glyph `((sections ((background . catppuccin-mocha-surface2) (text . "1") (color . catppuccin-mocha-text))
                                ((background . catppuccin-mocha-surface2) (text . "2") (color . catppuccin-mocha-text))
                                ((background . catppuccin-mocha-surface2) (text . "3") (color . catppuccin-mocha-text))
                                ((background . catppuccin-mocha-surface2) (text . "4") (color . catppuccin-mocha-text))
                                ((background . catppuccin-mocha-surface2) (text . "5") (color . catppuccin-mocha-text)))
                      (id . five))
                    #:resources resources))

  (test-assert "a glyph without sections is reported"
    (any (lambda (problem) (string-contains problem "has no sections"))
         (validate-glyph '((id . empty)) #:resources resources)))

  (test-assert "missing text labels are reported"
    (any (lambda (problem) (string-contains problem "missing a text label"))
         (validate-glyph `((sections ((background . catppuccin-mocha-surface2) (color . catppuccin-mocha-text)))
                           (id . no-text))
                         #:resources resources)))

  (test-assert "ids that cannot be file names are reported"
    (any (lambda (problem) (string-contains problem "cannot be used as a file name"))
         (validate-glyph `((sections ((background . catppuccin-mocha-surface2)
                                      (text . "x")
                                      (color . catppuccin-mocha-text)))
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
    ;; The badge is rendered from the glyph defined above, using named theme
    ;; colors, a named logo and defaults for every other setting.
    (test-assert "theme colors are resolved to hex values"
      (and (string-contains xml "fill=\"#585b70\"")
           (string-contains xml "fill=\"#fab387\"")
           (string-contains xml "fill=\"#cdd6f4\"")))
    (test-assert "badge text is rendered"
      (and (string-contains xml ">Scheme<")
           (string-contains xml ">Guile<")))
    ;; Compare against the logo file itself: the inlined logo keeps whatever
    ;; viewBox the file declares, so tuning a logo never breaks this check.
    (test-assert "logos are inlined into the badge"
      (let* ((path (logo-file-path 'lambda #:resources resources))
             (svg (call-with-input-file path get-string-all))
             (start (string-contains svg "viewBox=\""))
             (box (and start
                       (let ((end (string-index svg #\" (+ start 9))))
                         (and end (substring svg (+ start 9) end))))))
        (and box (not (string-null? box))
             (string-contains xml (format #f "viewBox=\"~a\"" box)))))
    (test-assert "the badge id becomes the svg id"
      (string-contains xml "id=\"scheme-guile-test\""))
    ;; Badges follow the compact shields.io geometry -- 20px high, 11px text,
    ;; 5px of padding per side and 3px rounded corners -- drawn 9.18% larger.
    (test-assert "badges are 21.84px high with 3.28px corners"
      (and (string-contains xml "height=\"21.84\"")
           (string-contains xml "rx=\"3.28\"")))
    (test-assert "badge text sits at y=15.29 for a 12.01px font"
      (and (string-contains xml "font-size=\"12.01\"")
           (string-contains xml "y=\"15.29\"")))
    (test-assert "text width is tight like shields.io, scaled up"
      ;; 18.57px logo area, then 10px of padding plus the measured text per
      ;; section, all scaled by the badge scale.
      (string-contains xml "width=\"111.57\" height=\"21.84\""))
    (test-assert "the first label is centered after the logo gap"
      (string-contains xml "x=\"46.0\" y=\"15.29\">Scheme<")))

  (let* ((glyph `((sections ((background . catppuccin-mocha-surface2)
                             (text . "Complex")
                             (color . catppuccin-mocha-text)
                             (logo . sparkle)))
                  (id . complex-logo-test)))
         (xml (sxml->string* (mk-glyph glyph #:resources resources))))
    (test-assert "a badge can use a gradient logo"
      (and (string-contains xml "linearGradient")
           (string-contains xml "url(#sparkle-shine)"))))

  (let* ((glyph `((sections ((background . catppuccin-mocha-surface2) (text . "one") (color . catppuccin-mocha-text))
                            ((background . catppuccin-mocha-red) (text . "two") (color . catppuccin-mocha-text))
                            ((background . catppuccin-mocha-surface2) (text . "three") (color . catppuccin-mocha-text))
                            ((background . catppuccin-mocha-red) (text . "four") (color . catppuccin-mocha-text))
                            ((background . catppuccin-mocha-surface2) (text . "five") (color . catppuccin-mocha-text)))
                  (id . five-parts)))
         (xml (sxml->string* (mk-glyph glyph #:resources resources))))
    (test-assert "every part of a five-part badge is rendered"
      (every (lambda (text) (string-contains xml (format #f ">~a<" text)))
             '("one" "two" "three" "four" "five")))
    (test-assert "a five-part badge has a background and a seam per part"
      (= 13 (count-substring "<rect " xml))))

  (let* ((glyph `((sections ((background . catppuccin-mocha-surface2)
                             (text . "Complex")
                             (color . catppuccin-mocha-text)
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

  (let* ((groups (list (cons "test.scm" (list valid-glyph))))
         (html (gallery-html #:resources resources #:glyph-groups groups))
         (names (logo-names #:resources resources))
         (tiles (filter (lambda (line)
                          (string-contains line "class=\"tile\""))
                        (string-split html #\newline)))
         (badges (filter (lambda (line)
                           (string-contains line "class=\"badge-tile\""))
                         (string-split html #\newline))))
    (test-assert "every logo gets a tile"
      (= (length names) (length tiles)))
    (test-assert "every glyph gets a badge tile"
      (= 1 (length badges)))
    (test-assert "badge tiles show the glyph id"
      (and (string-contains html "(id . scheme-guile-test)")
           (string-contains html "<span class=\"name\">scheme-guile-test</span>")))
    (test-assert "badge tiles can be filtered by their text"
      (string-contains html "data-name=\"scheme-guile-test Scheme Guile\""))
    (test-assert "badge ids are namespaced by glyph group"
      (string-contains html "id=\"badge-testscm-scheme-guile-test\""))
    (test-assert "the gallery renders real badges, not just logos"
      (string-contains html ">Scheme<"))
    (test-assert "tiles show the glyph snippet"
      (string-contains html "(logo . sparkle)"))
    (test-assert "logo snippets can be copied"
      (string-contains html "data-copy=\"(logo . sparkle)\""))
    (test-assert "badge tiles copy a complete glyph definition"
      (and (string-contains html "data-copy=\"(define scheme-guile-test '((sections")
           (string-contains html "class=\"toast\" role=\"status\"")))
    (test-assert "the gallery script copies to the clipboard and shows a toast"
      (and (string-contains html "navigator.clipboard.writeText")
           (string-contains html "classList.add('show')")))
    (test-assert "logos are inlined instead of linked"
      (string-contains html "<svg"))
    (test-assert "logo ids are namespaced so they cannot clash"
      (and (string-contains html "id=\"logo-sparkle-sparkle-shine\"")
           (string-contains html "url(#logo-sparkle-sparkle-shine)")
           (not (string-contains html "url(#sparkle-shine)")))))

  (let ((groups ((@@ (ggg main) load-glyph-groups)
                 (string-append project-root "/glyphs")
                 #:resources resources)))
    (test-equal "glyph files are grouped by file name"
      '("jjba23.scm" "showcase.scm")
      (map car groups))
    (test-equal "every glyph of every file is in the gallery"
      237
      (apply + (map (lambda (group) (length (cdr group))) groups))))

  (let* ((path (format #f "~a/ggg-gallery-test-~a.html"
                       (temp-directory) (getpid)))
         (groups (list (cons "test.scm" (list valid-glyph))))
         (counts (call-with-values
                     (lambda ()
                       (write-gallery-page path
                                           #:resources resources
                                           #:glyph-groups groups))
                   list)))
    (test-equal "the gallery reports its badge and logo counts"
      (list 1 (length (logo-names #:resources resources)))
      counts)
    (test-assert "the gallery page is written to disk"
      (and (> (apply + counts) 0) (file-exists? path)))
    (test-assert "the written page is self contained"
      (string-contains (call-with-input-file path get-string-all) "<svg"))
    (test-assert "the gallery test writes inside the temporary directory"
      (string-prefix? (temp-directory) path))
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

    (test-assert "the jjba23 project badges are in the main glyph file"
      (every (lambda (id)
               (member id (map glyph-id main-glyphs)))
             '("byggsteg" "lucidplan" "maak" "bewaking"
               "hygguile" "veritas" "symbanta"
               "lang-python" "build-cmake" "test-jest"
               "db-postgresql" "ci-buildkite" "docs-markdown")))

    (test-assert "showcase ids do not collide with the main glyph file"
      (null? (lset-intersection string=? (map glyph-id main-glyphs)
                                showcase-ids)))

    (test-assert "showcase ids are unique"
      (= (length showcase-ids) (length (delete-duplicates showcase-ids))))

    (test-assert "showcase badges render"
      (string-contains (sxml->string* (mk-glyph (car showcase-glyphs)
                                                #:resources resources))
                       "<svg"))

    (test-equal "showcase badges color their accent section with catppuccin"
      'catppuccin-mocha-base
      (cdr (assq 'color
                 (cadr (lookup (car (filter (lambda (glyph)
                                              (string=? (glyph-id glyph)
                                                        "javascript"))
                                            showcase-glyphs))
                               'sections)))))

    (test-assert "every showcase badge labels itself with catppuccin mocha"
      (every (lambda (glyph)
               (let ((label (car (lookup glyph 'sections))))
                 (every (lambda (key)
                          (let ((name (lookup label key)))
                            (and (symbol? name)
                                 (string-prefix? "catppuccin-mocha-"
                                                 (symbol->string name)))))
                        '(background color))))
             showcase-glyphs))

    (test-assert "every showcase accent is a real theme color"
      (every (lambda (glyph)
               (let ((accent (cadr (lookup glyph 'sections))))
                 (every (lambda (key)
                          (not (color-error (lookup accent key))))
                        '(background color))))
             showcase-glyphs))

    (test-assert "the showcase second sections mix the theme families"
      (let* ((accent-name (lambda (glyph)
                            (symbol->string
                             (lookup (cadr (lookup glyph 'sections)) 'background))))
             (families (delete-duplicates
                        (filter identity
                                (map (lambda (name)
                                       (find (lambda (family)
                                               (string-prefix? family name))
                                             '("catppuccin-" "doom-" "dracula-"
                                               "solarized-" "modus-")))
                                     (map accent-name showcase-glyphs))))))
        (equal? (sort families string<?)
                '("catppuccin-" "doom-" "dracula-" "modus-" "solarized-"))))

    (test-assert "every theme has a variant badge"
      (let ((accents (map (lambda (glyph)
                            (lookup (cadr (lookup glyph 'sections)) 'background))
                          showcase-glyphs)))
        (every (lambda (accent) (member accent accents))
               '(catppuccin-mocha-mauve
                 catppuccin-macchiato-teal
                 catppuccin-frappe-peach
                 catppuccin-latte-blue
                 doom-one-blue
                 doom-one-light-magenta
                 dracula-purple
                 dracula-alucard-pink
                 solarized-dark-cyan
                 solarized-light-violet
                 modus-operandi-red
                 modus-vivendi-green))))))

;; ====== Destination directory ======

(test-group "destination"
  (let* ((dir (string-append (temp-directory) "/ggg-keep-test"))
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
