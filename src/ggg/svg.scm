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

(define-module (ggg svg)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:export (badge-scale scaled rounded length-for-text))

;; Every badge is drawn larger than the shields.io and GitHub geometry the
;; numbers in this library are calibrated against: 6% larger at first, and then
;; a further 3%, so 9.18% in total.  A slightly larger badge reads better in a
;; README while keeping the compact look, and applying the scale in one place
;; means the boxes, the text and the logo grow together.
(define badge-scale
  (* 1.06 1.03))

(define (scaled value)
  "VALUE scaled by BADGE-SCALE, rounded to two decimals so that coordinates stay
short in the SVG."
  (/ (round (* value badge-scale 100)) 100))

(define (rounded value)
  "VALUE rounded to two decimals, so that a coordinate built by adding or
subtracting scaled dimensions stays short in the SVG."
  (/ (round (* value 100)) 100))

;; Average character widths for the sans-serif stack at each font size. They
;; are calibrated against the badges shields.io and GitHub render, which are
;; 11px text with 5px of padding on each side.
(define (average-character-width font-size)
  (case font-size
    ((9) 5.1)
    ((10) 5.6)
    ((11) 6.0)
    ((12) 6.5)
    ((13) 7.1)
    ((14) 7.6)
    ((16) 8.7)
    (else 6.0)))

(define (character-width character font-size)
  "The estimated width of CHARACTER at FONT-SIZE. Capitals, digits and wide
letters take more room than the average lowercase letter."
  (let ((average (average-character-width font-size)))
    (* average
       (cond
         ((char-whitespace? character) 0.55)
         ((char-upper-case? character) 1.3)
         ((char-numeric? character) 1.12)
         ((memv character '(#\i #\l #\I #\. #\, #\: #\; #\' #\! #\| #\( #\)
                            #\[ #\] #\{ #\})) 0.5)
         ((memv character '(#\m #\w #\M #\W #\@)) 1.35)
         (else 1.0)))))

(define* (length-for-text text
                          #:key (font-size 11) (padding 5))
  "Estimate the width of a badge section in pixels: TEXT at FONT-SIZE plus
PADDING on both sides, drawn at BADGE-SCALE. The per-character widths are
averages for the sans-serif stack badges use, so a badge stays as compact as
the ones shields.io and GitHub render. The result is rounded to a whole pixel."
  (let ((text (if (string? text) text (format #f "~a" text))))
    (inexact->exact
     (round (* badge-scale
               (+ (* 2 padding)
                  (fold (lambda (character total)
                          (+ total (character-width character font-size)))
                        0
                        (string->list text))))))))
