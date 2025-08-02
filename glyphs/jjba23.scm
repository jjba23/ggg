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

(define-module (ggg config)
  #:export (ggg-glyphs))

(define glyph-pipeline-succeeded
  `((sections ((background . "#555") (text . "pipeline")
               (color . "#fff"))
              ((background . "#407430") (text . "succeeded")
               (color . "#fff")))
    (id . pipeline-succeeded)))

(define glyph-gnu-guix
  `((sections ((background . "#555") (text . "GNU")
               (color . "#fff")
               (logo . gnu))
              ((background . "#FFBF01") (text . "Guix")
               (color . "#000")))
    (id . gnu-guix)))

(define glyph-scheme-guile
  `((sections ((background . "#555") (text . "Scheme")
               (color . "#fff")
               (logo . lambda))
              ((background . "#d0730f") (text . "Guile")
               (color . "#fff")))
    (id . scheme-guile)))

;; (define glyph-haskell-ghc910
;;   `((id . haskell-ghc910) (first-background "#555")
;;     (first-text . "Haskell")
;;     (first-color . "#fff")
;;     (first-logo . lambda)
;;     (second-background . "#7851A9")
;;     (second-text . "GHC 9.10")
;;     (second-color . "#fff")))

;; (define glyph-gnu-make
;;   `((id . gnu-make) (first-background . "#555")
;;     (first-text . "GNU")
;;     (first-color . "#fff")
;;     (first-logo . gnu)
;;     (second-background . "#a32d2a")
;;     (second-text . "Make")
;;     (second-color . "#fff")))

;; (define glyph-i18n-gnu-gettext
;;   `((id . i18n-gnu-gettext) (first-background . "#555")
;;     (first-text . "i18n")
;;     (first-color . "#fff")
;;     (first-logo . language)
;;     (second-background . "#a32d2a")
;;     (second-text . "GNU gettext")
;;     (second-color . "#fff")))

;; (define glyph-gnu-emacs
;;   `((id . gnu-emacs) (first-background . "#555")
;;     (first-text . "GNU")
;;     (first-color . "#fff")
;;     (first-logo . emacs)
;;     (second-background . "#c4609e")
;;     (second-text . "Emacs")
;;     (second-color . "#fff")))

;; (define glyph-gnu-emacs-single
;;   `((id . gnu-emacs-single) (first-background . "#555")
;;     (first-text . "GNU Emacs")
;;     (first-color . "#fff")
;;     (first-logo . emacs)))

;; (define glyph-emacs-lisp
;;   `((id . emacs-lisp) (first-background . "#555")
;;     (first-text . "Emacs")
;;     (first-color . "#fff")
;;     (first-logo . emacs)
;;     (second-background . "#c4609e")
;;     (second-text . "Lisp")
;;     (second-color . "#fff")))

;; (define glyph-license-gpl3+
;;   `((id . license-gpl3+) (first-background . "#555")
;;     (first-text . "license")
;;     (first-color . "#fff")
;;     (first-logo . scales)
;;     (second-background . "#4f677f")
;;     (second-text . "GPL v3+")
;;     (second-color . "#fff")))

;; (define glyph-license-lgpl3+
;;   `((id . license-lgpl3+) (first-background . "#555")
;;     (first-text . "license")
;;     (first-color . "#fff")
;;     (first-logo . scales)
;;     (second-background . "#4f677f")
;;     (second-text . "LGPL v3+")
;;     (second-color . "#fff")))

;; (define glyph-license-agpl3+
;;   `((id . license-agpl3+) (first-background . "#555")
;;     (first-text . "license")
;;     (first-color . "#fff")
;;     (first-logo . scales)
;;     (second-background . "#4f677f")
;;     (second-text . "AGPL v3+")
;;     (second-color . "#fff")))

;; (define glyph-license-fdl13+
;;   `((id . license-fdl13+) (first-background . "#555")
;;     (first-text . "license")
;;     (first-color . "#fff")
;;     (first-logo . scales)
;;     (second-background . "#4f677f")
;;     (second-text . "GFDL v1.3+")
;;     (second-color . "#fff")))

;; (define glyph-shell-fish
;;   `((id . shell-fish) (first-background . "#555")
;;     (first-text . "Shell")
;;     (first-color . "#fff")
;;     (first-logo . hashtag)
;;     (second-background . "#407430")
;;     (second-text . "Fish")
;;     (second-color . "#fff")))

;; (define glyph-shell-bash
;;   `((id . shell-bash) (first-background . "#555")
;;     (first-text . "Shell")
;;     (first-color . "#fff")
;;     (first-logo . hashtag)
;;     (second-background . "#407430")
;;     (second-text . "Bash")
;;     (second-color . "#fff")))

;; (define glyph-shell-eshell
;;   `((id . shell-eshell) (first-background . "#555")
;;     (first-text . "Shell")
;;     (first-color . "#fff")
;;     (first-logo . hashtag)
;;     (second-background . "#c4609e")
;;     (second-text . "EShell")
;;     (second-color . "#fff")))

;; (define glyph-gnu-artanis
;;   `((id . gnu-artanis) (first-background . "#555")
;;     (first-text . "GNU")
;;     (first-color . "#fff")
;;     (first-logo . lambda)
;;     (second-background . "#5a3142")
;;     (second-text . "Artanis")
;;     (second-color . "#fff")))

(define glyph-gnu-artanis-122
  `((sections ((background . "#555") (text . "GNU")
               (color . "#fff")
               (logo . lambda)
               (font-weight . 900))
              ((background . "#5a3142") (text . "Artanis")
               (color . "#fff")
               (font-weight . 900))
              ((background . "#555") (text . "v1.2.2")
               (color . "#fff")
               (font-weight . 900)))
    (id . gnu-artanis-122)))

;; (define glyph-css-tailwind4
;;   `((id . css-tailwind4) (first-background . "#555")
;;     (first-text . "CSS")
;;     (first-color . "#fff")
;;     (first-logo . paint)
;;     (second-background . "#80aadf")
;;     (second-text . "Tailwind v4")
;;     (second-color . "#111")))

;; (define glyph-scala-213
;;   `((id . scala-213) (sections ((background . "#555") (text . "Scala")
;;                                 (color . "#fff")
;;                                 (logo . scala))
;;                                ((background . "#A50021") (text . "v2.13")
;;                                 (color . "#fff")))))

(define glyph-jointhefreeworld-org
  `((sections ((background . "#555") (text . "jointhefreeworld.org")
               (color . "#fff")
               (logo . gear)))
    (id . jointhefreeworld-org)))

(define ggg-glyphs
  (list glyph-pipeline-succeeded
        glyph-gnu-guix
        glyph-scheme-guile
        ;; glyph-haskell-ghc910
        ;; glyph-gnu-make
        ;; glyph-gnu-emacs
        ;; glyph-gnu-emacs-single
        ;; glyph-emacs-lisp
        ;; glyph-i18n-gnu-gettext
        ;; glyph-license-gpl3+
        ;; glyph-license-lgpl3+
        ;; glyph-license-agpl3+
        ;; glyph-license-fdl13+
        ;; glyph-shell-fish
        ;; glyph-shell-bash
        ;; glyph-shell-eshell
        ;; glyph-gnu-artanis
        glyph-gnu-artanis-122
        ;; glyph-css-tailwind4
        glyph-jointhefreeworld-org
        ;; glyph-scala-213
        ))

