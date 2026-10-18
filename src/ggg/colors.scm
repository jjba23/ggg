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

(define-module (ggg colors)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ggg prelude)
  #:export (named-colors color-names color-error resolve-color))

;; ====== Named badge colors ======

;; A small palette with stable, human-readable names. Glyph files may use
;; either one of these names (as a symbol) or a raw hex string.
(define named-colors
  ;; Neutrals
  '((white . "#fff")
    (black . "#000")
    (badge-gray . "#555")
    (graphite . "#111")
    ;; Status / licenses
    (success-green . "#407430")
    (gnu-red . "#a32d2a")
    (license-steel . "#4f677f")
    ;; Project brand colors
    (guix-yellow . "#FFBF01")
    (guix-orange . "#d0730f")
    (emacs-magenta . "#c4609e")
    (haskell-purple . "#7851A9")
    (artanis-plum . "#5a3142")
    (tailwind-blue . "#80aadf")
    (scala-red . "#A50021")
    (scala3-red . "#DE3423")
    (rust-orange . "#e89444")
    (java-red . "#ea2d2e")
    (kotlin-purple . "#7F52FF")
    (gcc-blue . "#00599C")
    (gradle-teal . "#02303a")
    (maven-red . "#c71a36")
    (racket-blue . "#3c5c99")
    (sbcl-orange . "#e15639")
    (clojure-green . "#63b132")
    (org-green . "#77aa99")
    (magit-red . "#aa2233")
    (docker-blue . "#2496ed")
    (nix-blue . "#5277c3")
    (gtk-blue . "#3584e4")
    (meson-teal . "#008080")))

(define (color-names)
  "The names accepted in glyph files, sorted alphabetically."
  (sort (map car named-colors) string<?))

(define (hex-color-string? value)
  (and (string-prefix? "#" value)
       (let ((digits (substring value 1)))
         (and (member (string-length digits) '(3 4 6 8))
              (string-every (lambda (c)
                              (or (char-numeric? c)
                                  (char<=? #\a c #\f)
                                  (char<=? #\A c #\F)))
                            digits)))))

(define* (color-error value #:key context)
  "Return a human-readable problem with VALUE, or #f when it is a valid color.
CONTEXT (for example \"glyph 'foo', section 1\") is prepended to the message."
  (define (with-context message)
    (if context
        (format #f "~a: ~a" context message)
        message))
  (cond
    ((symbol? value)
     (if (assoc-ref named-colors value)
         #f
         (with-context
          (let ((suggestion (suggest-similar value (map car named-colors))))
            (format #f "unknown color name '~a'~a"
                    value
                    (if suggestion
                        (format #f "; did you mean '~a'?" suggestion)
                        ""))))))
    ((string? value)
     (let ((trimmed (string-trim-both value)))
       (cond
         ((string-null? trimmed)
          (with-context "empty color value"))
         ((and (string-prefix? "#" trimmed)
               (not (hex-color-string? trimmed)))
          (with-context
           (format #f "invalid hex color ~s (expected #rgb, #rgba, #rrggbb or #rrggbbaa)"
                   value)))
         (else #f))))
    (else
     (with-context
      (format #f "expected a color name (symbol) or a hex string, got ~s"
              value)))))

(define* (resolve-color value #:key context)
  "Resolve VALUE (a palette symbol or a hex/CSS color string) to a string.
Exits with a helpful error message when VALUE is not a valid color."
  (let ((problem (color-error value #:context context)))
    (when problem
      (fail problem
            #:hint (format #f "Use a named color or a hex string. Known names: ~a."
                           (string-join (color-names) ", ")))))
  (cond
    ((symbol? value) (assoc-ref named-colors value))
    ((string? value) (string-trim-both value))
    (else value)))
