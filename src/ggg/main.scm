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

(load "./sxml.scm")

(define-module (ggg main)
  #:declarative? #f
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:use-module (ggg sxml)
  #:use-module (srfi srfi-13)
  #:use-module (srfi srfi-64))

;; ====== GGG ======

(define (get-path-for-svg name)
  (get-string-all (open-input-file (format #f "resources/svg-paths/~a" name))))

(define* (white-svg id
                    #:key (width 18)
                    (height 18)
                    (view-box "0 0 18 20")
                    (fill "#ffffff")
                    (fill-rule 'nonzero)
                    (clip-rule 'nonzero)
                    (x 6)
                    (y 5))
  `((svg (@ (width ,width)
            (height ,height)
            (viewBox ,view-box)
            (x ,x)
            (y ,y)
            (xmlns "http://www.w3.org/2000/svg")
            (fill none))
         (path (@ (fill ,fill)
                  (fill-rule ,fill-rule)
                  (clip-rule ,clip-rule)
                  (d ,(get-path-for-svg id))) ""))))

(define ggg-logos
  `((emacs unquote
           (white-svg 'emacs
                      #:view-box "0 0 24 26"))
    (lambda unquote
      (white-svg 'lambda))
    (gnu unquote
         (white-svg 'gnu
                    #:view-box "0 0 24 26"))
    (scala unquote
           (white-svg 'scala
                      #:view-box "0 0 36 26"
                      #:y 3))
    (scales unquote
            (white-svg 'scales
                       #:view-box "0 0 20 20"))
    (paint unquote
           (white-svg 'paint
                      #:view-box "0 0 42 42"
                      #:y 7))
    (hashtag unquote
             (white-svg 'hashtag
                        #:fill-rule "evenodd"
                        #:clip-rule "evenodd"
                        #:view-box "0 0 30 30"
                        #:y 6))
    (fish unquote
          (white-svg 'fish
                     #:view-box "0 0 250 100"))))

(define (assoc-ref-or alist key default)
  (let ((x (assoc-ref alist key)))
    (if (not x) default x)))

(define (syscall cmd)
  (let* ((process (open-input-pipe cmd))
         (process-output (get-string-all process)))
    (close-pipe process) process-output))

(define (get-short-commit-sha)
  (syscall "git log --pretty=format:'%h' -n 1"))

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

(define (mk-readme-vector-image x)
  (let* ((first-logo (assoc-ref ggg-logos
                                (assoc-ref x
                                           'first-logo)))
         (first-text (assoc-ref x
                                'first-text))
         (second-text (assoc-ref x
                                 'second-text))
         (first-background (assoc-ref x
                                      'first-background))
         (second-background (assoc-ref x
                                       'second-background))
         (first-color (assoc-ref x
                                 'first-color))
         (second-color (assoc-ref x
                                  'second-color))
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
         (first-font-size (assoc-ref-or x
                                        'first-font-size 12))
         (second-font-size (assoc-ref-or x
                                         'second-font-size 12))

         ;; --- Layout Constants ---
         (default-logo-width 16)
         (text-padding 4)
         (separator-width 8)
         (text-vertical-center 17)
         (default-first-padding 2)
         (separator-x-offset 6)

         ;; --- Calculated Dimensions ---
         (has-first-logo? (not (nil? first-logo)))
         (first-logo-effective-width (if has-first-logo? default-logo-width 0))
         (first-text-length (string-length first-text))
         (second-text-length (string-length second-text))

         (first-text-width (length-for-text first-text-length))
         (second-text-width (length-for-text second-text-length))

         (first-area-width (+ first-logo-effective-width default-first-padding
                              first-text-width))

         (total-badge-width (+ first-area-width second-text-width))

         (first-separator-x (- first-area-width separator-x-offset))
         (second-separator-x first-area-width)
         (second-x first-area-width)
         (first-text-x (round (+ first-logo-effective-width
                                 (/ first-text-width 2)))) ;Center text in first area
         (second-text-x (round (+ second-x
                                  (/ second-text-width 2)))) ;Center text in second area
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
              (rect (@ (x ,second-x)
                       (width ,second-text-width)
                       (height ,height)
                       (fill ,second-background)
                       (rx ,border-radius)
                       (ry ,border-radius)) "")
              (rect (@ (x ,first-separator-x)
                       (width ,separator-width)
                       (height ,height)
                       (fill ,first-background)
                       (rx 0)
                       (ry 0)) "")
              (rect (@ (x ,second-separator-x)
                       (width ,separator-width)
                       (height ,height)
                       (fill ,second-background)
                       (rx 0)
                       (ry 0)) ""))
           (g (@ (text-anchor middle)
                 (shape-rendering geometricPrecision))
              (text (@ (fill ,first-color)
                       (font-size ,first-font-size)
                       (font-family ,first-font-family)
                       (x ,first-text-x)
                       (y ,text-vertical-center))
                    ,first-text)
              (text (@ (fill ,second-color)
                       (font-size ,second-font-size)
                       (font-family ,second-font-family)
                       (x ,second-text-x)
                       (y ,text-vertical-center))
                    ,second-text))
           ,(if first-logo
                `(g (shape-rendering geometricPrecision)
                    ,first-logo)
                '())))))

(define (main args)
  (display "
>>= starting ggg: guile glyph generator
")
  (display (format #f "\n>>= loading glyphs: ~a\n\n"
                   (cadr args)))
  (load (cadr args))
  (map (lambda (vector-image)
         (display (format #f "\n>>= producing dist/~a.svg\n"
                          (assoc-ref vector-image
                                     'id)))
         (with-output-to-file (format #f "dist/~a.svg"
                                      (assoc-ref vector-image
                                                 'id))
           (lambda ()
             (sxml->xml (mk-readme-vector-image vector-image)))))
       ggg-readme-vector-images)

  (map (lambda (vector-image)
         (display (format #f "\n>>= producing dist/~a.png\n"
                          (assoc-ref vector-image
                                     'id)))
         (syscall (format #f
                   "convert -quality 100 -density 1000 -background none -resize 10% dist/~a.svg dist/~a.png"
                   (assoc-ref vector-image
                              'id)
                   (assoc-ref vector-image
                              'id)))) ggg-readme-vector-images)

  (display "\n>>= ggg is done generating images\n"))

(main (command-line))

