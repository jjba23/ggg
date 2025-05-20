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

(define ggg-readme-vector-images
  `( ;Pipeline succeeded
    ((id . pipeline-succeeded) (left-background . "#555")
     (left-text . "pipeline")
     (left-color . "#fff")
     (right-background . "#407430")
     (right-text . "succeeded")
     (right-color . "#fff"))
    ;; GNU Guix
    ((id . gnu-guix) (left-background . "#555")
     (left-text . "GNU")
     (left-color . "#fff")
     (left-logo . gnu)
     (right-background . "#FFBF01")
     (right-text . "Guix")
     (right-color . "#000"))
    ;; Scheme Guile
    ((id . scheme-guile) (left-background . "#555")
     (left-text . "Scheme")
     (left-color . "#fff")
     (left-logo . lambda)
     (right-background . "#d0730f")
     (right-text . "Guile")
     (right-color . "#fff"))
    ;; Haskell GHC 9.10
    ((id . haskell-ghc910) (left-background "#555")
     (left-text . "Haskell")
     (left-color . "#fff")
     (left-logo . lambda)
     (right-background . "#7851A9")
     (right-text . "GHC 9.10")
     (right-color . "#fff"))
    ;; GNU Make
    ((id . gnu-make) (left-background . "#555")
     (left-text . "GNU")
     (left-color . "#fff")
     (left-logo . gnu)
     (right-background . "#a32d2a")
     (right-text . "Make")
     (right-color . "#fff"))
    ;; GNU Emacs
    ((id . gnu-emacs) (left-background . "#555")
     (left-text . "GNU")
     (left-color . "#fff")
     (left-logo . emacs)
     (right-background . "#c4609e")
     (right-text . "Emacs")
     (right-color . "#fff"))
    ;; Emacs Lisp
    ((id . emacs-lisp) (left-background . "#555")
     (left-text . "Emacs")
     (left-color . "#fff")
     (left-logo . emacs)
     (right-background . "#c4609e")
     (right-text . "Lisp")
     (right-color . "#fff"))
    ;; License GNU GPL v3+
    ((id . license-gpl3+) (left-background . "#555")
     (left-text . "license")
     (left-color . "#fff")
     (left-logo . scales)
     (right-background . "#4f677f")
     (right-text . "GPL v3+")
     (right-color . "#fff"))
    ;; License GNU LGPL v3+
    ((id . license-lgpl3+) (left-background . "#555")
     (left-text . "license")
     (left-color . "#fff")
     (left-logo . scales)
     (right-background . "#4f677f")
     (right-text . "LGPL v3+")
     (right-color . "#fff"))
    ;; License GNU AGPL v3+
    ((id . license-agpl3+) (left-background . "#555")
     (left-text . "license")
     (left-color . "#fff")
     (left-logo . scales)
     (right-background . "#4f677f")
     (right-text . "AGPL v3+")
     (right-color . "#fff"))
    ;; License GNU FDL v1.3+
    ((id . license-fdl13+) (left-background . "#555")
     (left-text . "license")
     (left-color . "#fff")
     (left-logo . scales)
     (right-background . "#4f677f")
     (right-text . "FDL v1.3+")
     (right-color . "#fff"))
    ;; Shell Fish
    ((id . shell-fish) (left-background . "#555")
     (left-text . "Shell")
     (left-color . "#fff")
     (left-logo . hashtag)
     (right-background . "#407430")
     (right-text . "Fish")
     (right-color . "#fff"))
    ;; Shell EShell
    ((id . shell-eshell) (left-background . "#555")
     (left-text . "Shell")
     (left-color . "#fff")
     (left-logo . hashtag)
     (right-background . "#c4609e")
     (right-text . "EShell")
     (right-color . "#fff"))
    ;; Scala 2.13
    ((id . scala-213) (left-background . "#555")
     (left-text . "Scala")
     (left-color . "#fff")
     (left-logo . scala)
     (right-background . "#A50021")
     (right-text . "v2.13")
     (right-color . "#fff"))))

