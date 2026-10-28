;; ggg: guile glyph generator
;;
;; Spdx-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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
  "MIT")

(define (ggg-version-string)
  "Return the one-line version banner printed by `ggg --version'."
  (format #f "ggg ~a" ggg-version))

(define* (print-version #:optional (port (current-output-port)))
  "Print the version banner, license and homepage of ggg to PORT."
  (format port "~a\n~a\n~a\n"
          (ggg-version-string)
          (format #f "License: ~a" ggg-license)
          (format #f "Homepage: ~a" ggg-homepage)))
