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

(define-module (ggg glyph)
  #:declarative? #f
  #:use-module (ice-9 format)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 match)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 getopt-long)
  #:use-module (ggg svg)
  #:use-module (ggg prelude)
  #:export (mk-glyph))

(define* (mk-glyph x
                   #:key resources-dir)
  (let* ((first-logo (assoc-ref (ggg-logos #:resources-dir resources-dir)
                                (assoc-ref x
                                           'first-logo)))
         (first-text (assoc-ref x
                                'first-text))
         (second-text (assoc-ref x
                                 'second-text))
         (third-text (assoc-ref x
                                'third-text))
         (first-background (assoc-ref x
                                      'first-background))
         (second-background (assoc-ref x
                                       'second-background))
         (third-background (assoc-ref x
                                      'third-background))
         (first-color (assoc-ref x
                                 'first-color))
         (second-color (assoc-ref x
                                  'second-color))
         (third-color (assoc-ref x
                                 'third-color))
         (badge-id (assoc-ref x
                              'id))
         (height (assoc-ref-or x
                               'height 26))
         (border-radius (assoc-ref-or x
                                      'border-radius 6))
         (first-font-family (assoc-ref-or x
                                          'first-font-family "sans-serif"))
         (second-font-family (assoc-ref-or x
                                           'second-font-family "sans-serif"))
         (third-font-family (assoc-ref-or x
                                          'third-font-family "sans-serif"))
         (first-font-size (assoc-ref-or x
                                        'first-font-size 12))
         (second-font-size (assoc-ref-or x
                                         'second-font-size 12))
         (third-font-size (assoc-ref-or x
                                        'third-font-size 12))

         (first-font-weight (assoc-ref-or x
                                          'first-font-weight 500))
         (second-font-weight (assoc-ref-or x
                                           'second-font-weight 500))
         (third-font-weight (assoc-ref-or x
                                          'third-font-weight 500))

         ;; --- Layout Constants ---
         (default-logo-width 18)
         (text-padding 4)
         (separator-width 8)
         (text-vertical-center 17)
         (default-first-padding 2)
         (separator-x-offset 6)

         ;; --- Calculated Dimensions ---
         (has-first-logo? (not (nil? first-logo)))
         (first-logo-effective-width (if has-first-logo? default-logo-width 0))

         (first-text-width (length-for-text (string-length first-text)))
         (second-text-width (if (not second-text) 0
                                (length-for-text (string-length second-text))))
         (third-text-width (if (not third-text) 0
                               (length-for-text (string-length third-text))))

         (first-area-width (+ first-logo-effective-width default-first-padding
                              first-text-width))

         (total-badge-width (+ first-area-width
                               (if (not second-text-width) 0 second-text-width)
                               (if (not third-text-width) 0 third-text-width)))

         (first-separator-x (- first-area-width separator-x-offset))
         (second-separator-x first-area-width)

         (third-separator-x (- (+ first-area-width second-text-width)
                               separator-x-offset))
         (fourth-separator-x (+ first-area-width second-text-width))

         (second-x first-area-width)
         (third-x (+ first-area-width second-text-width))
         (first-text-x (round (+ first-logo-effective-width
                                 (/ first-text-width 2)))) ;Center text in first area
         (second-text-x (round (+ second-x
                                  (/ second-text-width 2)))) ;Center text in second area
         (third-text-x (round (+ third-x
                                 (/ third-text-width 2)))) ;Center text in third area
         )
    `((svg (@ (id ,badge-id)
              (xmlns "http://www.w3.org/2000/svg")
              (width ,total-badge-width)
              (height ,height)
              (viewBox ,(format #f "0 0 ~a ~a" total-badge-width height)))
           (g (@ (shape-rendering geometricPrecision))
              (rect (@ (x 0)
                       (width ,first-area-width)
                       (height ,height)
                       (fill ,first-background)
                       (rx ,border-radius)
                       (ry ,border-radius)) "")
              ,(if (not second-text)
                   '()
                   `(rect (@ (x ,second-x)
                             (width ,second-text-width)
                             (height ,height)
                             (fill ,second-background)
                             (rx ,border-radius)
                             (ry ,border-radius)) ""))
              ,(if (not third-text)
                   '()
                   `(rect (@ (x ,third-x)
                             (width ,third-text-width)
                             (height ,height)
                             (fill ,third-background)
                             (rx ,border-radius)
                             (ry ,border-radius)) ""))
              ,(if (not second-text)
                   '()
                   `(rect (@ (x ,first-separator-x)
                             (width ,separator-width)
                             (height ,height)
                             (fill ,first-background)
                             (rx 0)
                             (ry 0)) ""))
              ,(if (not second-text)
                   '()
                   `(rect (@ (x ,second-separator-x)
                             (width ,separator-width)
                             (height ,height)
                             (fill ,second-background)
                             (rx 0)
                             (ry 0)) ""))
              ,(if (not third-text)
                   '()
                   `(rect (@ (x ,third-separator-x)
                             (width ,separator-width)
                             (height ,height)
                             (fill ,second-background)
                             (rx 0)
                             (ry 0)) ""))
              ,(if (not third-text)
                   '()
                   `(rect (@ (x ,fourth-separator-x)
                             (width ,separator-width)
                             (height ,height)
                             (fill ,third-background)
                             (rx 0)
                             (ry 0)) "")))
           (g (@ (text-anchor middle)
                 (shape-rendering geometricPrecision))
              (text (@ (fill ,first-color)
                       (font-size ,first-font-size)
                       (font-family ,first-font-family)
                       (style ,(serialize-style `((font-weight unquote
                                                   first-font-weight))))
                       (x ,first-text-x)
                       (y ,text-vertical-center))
                    ,first-text)
              ,(if (not second-text)
                   '()
                   `(text (@ (fill ,second-color)
                             (font-size ,second-font-size)
                             (font-family ,second-font-family)
                             (style ,(serialize-style `((font-weight unquote
                                                         second-font-weight))))
                             (x ,second-text-x)
                             (y ,text-vertical-center))
                          ,second-text))
              ,(if (not third-text)
                   '()
                   `(text (@ (fill ,third-color)
                             (font-size ,third-font-size)
                             (font-family ,third-font-family)
                             (style ,(serialize-style `((font-weight unquote
                                                         third-font-weight))))
                             (x ,third-text-x)
                             (y ,text-vertical-center))
                          ,third-text)))
           ,(if first-logo
                `(g (shape-rendering geometricPrecision)
                    ,first-logo)
                '())))))
