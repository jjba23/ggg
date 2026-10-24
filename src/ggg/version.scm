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

(define-module (ggg version)
  ;; Deliberately not declarative.  A declarative module lets Guile inline its
  ;; bindings into the modules that use them, and the version is the one value
  ;; here that changes between builds: inlined, it would be baked into a
  ;; consumer's compiled file while that file's source stayed the same, and a
  ;; bump would leave `ggg --version' answering with the version the consumer
  ;; was compiled against.  Compiled from source in a store the two agree, but
  ;; a warm cache should not decide what a release is called.
  #:declarative? #f
  #:use-module (ice-9 format)
  #:export (ggg-version ggg-homepage ggg-license ggg-version-string
                        print-version))

;; The version is written by hand here and nowhere else: `ggg --version' prints
;; it, default.nix reads it while it evaluates the derivation, and `maak
;; release' copies it into guix.scm.  A release therefore starts by editing the
;; line below, and `maak release' does the rest.
(define ggg-version
  "0.16.4")

(define ggg-homepage
  "https://codeberg.org/jjba23/ggg")

(define ggg-license
  "AGPL-3.0-or-later")

(define (ggg-version-string)
  "Return the one-line version banner printed by `ggg --version'."
  (format #f "ggg ~a" ggg-version))

(define* (print-version #:optional (port (current-output-port)))
  "Print the version banner, license and homepage of ggg to PORT."
  (format port "~a\n~a\n~a\n"
          (ggg-version-string)
          (format #f "License: ~a" ggg-license)
          (format #f "Homepage: ~a" ggg-homepage)))
