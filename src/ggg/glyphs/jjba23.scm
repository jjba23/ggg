;; ggg: guile glyph generator

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; ggg is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ggg is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ggg.  If not, see <https://www.gnu.org/licenses/>.

(define ggg-readme-vector-images
  `(((id . pipeline-succeeded) (left-background . "#555")
     (left-text . "pipeline")
     (left-color . "#fff")
     (right-background . "#407430")
     (right-text . "succeeded")
     (right-color . "#fff"))
    ((id . scheme-guile) (left-background . "#555")
     (left-text . "Scheme")
     (left-color . "#fff")
     (left-logo unquote lambda-svg)
     (right-background . "#deb07a")
     (right-text . "Guile")
     (right-color . "#000"))
    ((id . haskell-ghc910) (left-background "#555")
     (left-text . "Haskell")
     (left-color . "#fff")
     (left-logo unquote lambda-svg)
     (right-background . "#7851A9")
     (right-text . "GHC 9.10")
     (right-color . "#fff"))
    ((id . gnu-make) (left-background . "#555")
     (left-text . "GNU")
     (left-color . "#fff")
     (left-logo unquote gnu-svg)
     (right-background . "#bbbbbb")
     (right-text . "Make")
     (right-color . "#000"))
    ((id . gnu-emacs) (left-background . "#555")
     (left-text . "GNU")
     (left-color . "#fff")
     (left-logo unquote emacs-svg)
     (right-background . "#885997")
     (right-text . "Emacs")
     (right-color . "#fff"))
    ((id . scala-213) (left-background . "#555")
     (left-text . "Scala")
     (left-color . "#fff")
     (left-logo unquote scala-svg)
     (right-background . "#A50021")
     (right-text . "v2.13")
     (right-color . "#fff"))))
