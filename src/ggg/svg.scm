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
  #:export (length-for-text))

(define* (length-for-text text-length
                          #:key (font-size 12))
  "Estimates text container widths in pixels. It looks up a rough width per character based on the font size.
Then, it multiplies this by the number of characters and adds some padding.
Finally, it slightly adjusts the width based on whether the text is very short, short,
medium, or long to make the badge look better. It rounds the final width to a whole number."
  (let* ((base-char-width (case font-size
                            ((10)
                             8)
                            ((11)
                             9)
                            ((12)
                             9.5)
                            ((14)
                             10.5)
                            ((16)
                             11.5)
                            (else 7)))
         (horizontal-padding 16)
         (scaling-factor (cond
                           ((> text-length 7)
                            0.8)
                           ((> text-length 6)
                            0.9)
                           ((> text-length 5)
                            1.0)
                           ((< text-length 5)
                            1.3)
                           (else 1.0)))
         (calculated-width (+ horizontal-padding
                              (* base-char-width text-length scaling-factor))))
    (round calculated-width)))
