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
  #:export (ggg-readme-vector-images))

(define ggg-badge-pipeline-succeeded
  `((id . pipeline-succeeded) (first-background . "#555")
    (first-text . "pipeline")
    (first-color . "#fff")
    (second-background . "#407430")
    (second-text . "succeeded")
    (second-color . "#fff")))

(define ggg-badge-gnu-guix
  `((id . gnu-guix) (first-background . "#555")
    (first-text . "GNU")
    (first-color . "#fff")
    (first-logo . gnu)
    (second-background . "#FFBF01")
    (second-text . "Guix")
    (second-color . "#000")))

(define ggg-badge-scheme-guile
  `((id . scheme-guile) (first-background . "#555")
    (first-text . "Scheme")
    (first-color . "#fff")
    (first-logo . lambda)
    (second-background . "#d0730f")
    (second-text . "Guile")
    (second-color . "#fff")))

(define ggg-badge-haskell-ghc910
  `((id . haskell-ghc910) (first-background "#555")
    (first-text . "Haskell")
    (first-color . "#fff")
    (first-logo . lambda)
    (second-background . "#7851A9")
    (second-text . "GHC 9.10")
    (second-color . "#fff")))

(define ggg-badge-gnu-make
  `((id . gnu-make) (first-background . "#555")
    (first-text . "GNU")
    (first-color . "#fff")
    (first-logo . gnu)
    (second-background . "#a32d2a")
    (second-text . "Make")
    (second-color . "#fff")))

(define ggg-badge-i18n-gnu-gettext
  `((id . i18n-gnu-gettext) (first-background . "#555")
    (first-text . "i18n")
    (first-color . "#fff")
    (first-logo . language)
    (second-background . "#a32d2a")
    (second-text . "GNU gettext")
    (second-color . "#fff")))

(define ggg-badge-gnu-emacs
  `((id . gnu-emacs) (first-background . "#555")
    (first-text . "GNU")
    (first-color . "#fff")
    (first-logo . emacs)
    (second-background . "#c4609e")
    (second-text . "Emacs")
    (second-color . "#fff")))

(define ggg-badge-gnu-emacs-single
  `((id . gnu-emacs-single) (first-background . "#555")
    (first-text . "GNU Emacs")
    (first-color . "#fff")
    (first-logo . emacs)))

(define ggg-badge-emacs-lisp
  `((id . emacs-lisp) (first-background . "#555")
    (first-text . "Emacs")
    (first-color . "#fff")
    (first-logo . emacs)
    (second-background . "#c4609e")
    (second-text . "Lisp")
    (second-color . "#fff")))

(define ggg-badge-license-gpl3+
  `((id . license-gpl3+) (first-background . "#555")
    (first-text . "license")
    (first-color . "#fff")
    (first-logo . scales)
    (second-background . "#4f677f")
    (second-text . "GPL v3+")
    (second-color . "#fff")))

(define ggg-badge-license-lgpl3+
  `((id . license-lgpl3+) (first-background . "#555")
    (first-text . "license")
    (first-color . "#fff")
    (first-logo . scales)
    (second-background . "#4f677f")
    (second-text . "LGPL v3+")
    (second-color . "#fff")))

(define ggg-badge-license-agpl3+
  `((id . license-agpl3+) (first-background . "#555")
    (first-text . "license")
    (first-color . "#fff")
    (first-logo . scales)
    (second-background . "#4f677f")
    (second-text . "AGPL v3+")
    (second-color . "#fff")))

(define ggg-badge-license-fdl13+
  `((id . license-fdl13+) (first-background . "#555")
    (first-text . "license")
    (first-color . "#fff")
    (first-logo . scales)
    (second-background . "#4f677f")
    (second-text . "GFDL v1.3+")
    (second-color . "#fff")))

(define ggg-badge-shell-fish
  `((id . shell-fish) (first-background . "#555")
    (first-text . "Shell")
    (first-color . "#fff")
    (first-logo . hashtag)
    (second-background . "#407430")
    (second-text . "Fish")
    (second-color . "#fff")))

(define ggg-badge-shell-bash
  `((id . shell-bash) (first-background . "#555")
    (first-text . "Shell")
    (first-color . "#fff")
    (first-logo . hashtag)
    (second-background . "#407430")
    (second-text . "Bash")
    (second-color . "#fff")))

(define ggg-badge-shell-eshell
  `((id . shell-eshell) (first-background . "#555")
    (first-text . "Shell")
    (first-color . "#fff")
    (first-logo . hashtag)
    (second-background . "#c4609e")
    (second-text . "EShell")
    (second-color . "#fff")))

(define ggg-badge-gnu-artanis
  `((id . gnu-artanis) (first-background . "#555")
    (first-text . "GNU")
    (first-color . "#fff")
    (first-logo . lambda)
    (second-background . "#5a3142")
    (second-text . "Artanis")
    (second-color . "#fff")))

(define ggg-badge-gnu-artanis-122
  `((id . gnu-artanis-122) (first-background . "#555")
    (first-text . "GNU")
    (first-color . "#fff")
    (first-logo . lambda)
    (first-font-weight . 900)
    (second-background . "#5a3142")
    (second-text . "Artanis")
    (second-color . "#fff")
    (second-font-weight . 900)
    (third-background . "#555")
    (third-text . "v1.2.2")
    (third-color . "#fff")
    (third-font-weight . 900)))

(define ggg-badge-css-tailwind4
  `((id . css-tailwind4) (first-background . "#555")
    (first-text . "CSS")
    (first-color . "#fff")
    (first-logo . paint)
    (second-background . "#80aadf")
    (second-text . "Tailwind v4")
    (second-color . "#111")))

(define ggg-badge-scala-213
  `((id . scala-213) (first-background . "#555")
    (first-text . "Scala")
    (first-color . "#fff")
    (first-logo . scala)
    (second-background . "#A50021")
    (second-text . "v2.13")
    (second-color . "#fff")))

(define ggg-badge-jointhefreeworld-org
  `((id . jointhefreeworld-org) (first-background . "#555")
    (first-text . "jointhefreeworld.org")
    (first-color . "#fff")
    (first-logo . gear)))

(define ggg-readme-vector-images
  (list ggg-badge-pipeline-succeeded
        ggg-badge-gnu-guix
        ggg-badge-scheme-guile
        ggg-badge-haskell-ghc910
        ggg-badge-gnu-make
        ggg-badge-gnu-emacs
        ggg-badge-gnu-emacs-single
        ggg-badge-emacs-lisp
        ggg-badge-i18n-gnu-gettext
        ggg-badge-license-gpl3+
        ggg-badge-license-lgpl3+
        ggg-badge-license-agpl3+
        ggg-badge-license-fdl13+
        ggg-badge-shell-fish
        ggg-badge-shell-bash
        ggg-badge-shell-eshell
        ggg-badge-gnu-artanis
        ggg-badge-gnu-artanis-122
        ggg-badge-css-tailwind4
        ggg-badge-jointhefreeworld-org
        ggg-badge-scala-213))

