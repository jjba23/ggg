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

;; Commentary:
;;
;; A glyph can ask for a visual style with (style . name).  A style is a
;; "skin": it does not know how a badge is laid out, it only decorates the
;; geometry it is handed.  `style-skin' answers with an alist that (ggg glyph)
;; applies:
;;
;;   radius             the corner radius the badge should use
;;   defs               SVG <defs> (gradients, clip paths, filters)
;;   background-fill    a procedure (section -> color) replacing the section
;;                      backgrounds, for styles that paint their own plate
;;   overlays           shapes drawn above the backgrounds, below the text
;;   border             shapes drawn above the overlays, below the text
;;   text-fill          a procedure (section -> color) replacing the text color
;;   text-filter        a filter applied to the group of text labels
;;
;; Every style keeps the compact shields.io geometry of the flat default -- same
;; width, same height, same canvas -- so a row of badges of mixed styles always
;; lines up. Decorations are drawn inside the badge, never around it.

(define-module (ggg style)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ggg prelude)
  #:use-module (ggg svg)
  #:export (style-names style-name style-descriptions style-id-prefix style-skin
                        tint shade))

;; ====== Style names ======

(define style-names
  '(flat square shadow plastic frosted-glass material frutiger neon))

;; Friendly spellings that resolve to the canonical names above, so a glyph
;; file can say (style . "frosted glass") or (style . glass) and still work.
(define style-aliases
  '((default . flat)
    (plain . flat)
    (none . flat)
    (frostedglass . frosted-glass)
    (frosted . frosted-glass)
    (glass . frosted-glass)
    (neo . neon)
    (frutiger-aero . frutiger)))

(define style-descriptions
  '((flat . "flat colors with the usual rounded corners (the default)")
    (square . "sharp, square corners")
    (shadow . "a subtle shadow just under the content, in the same box as every other style")
    (plastic . "a glossy highlight and a bright inner bevel")
    (frosted-glass . "a translucent frost sheen behind a light hairline border")
    (material . "a Material-style sheen with a soft elevation shade")
    (frutiger . "glossy Frutiger Aero glass with a sky tint and a bright reflection")
    (neon . "a dark plate with crisp glowing outlines and bright text")))

(define (style-name value)
  "The canonical style symbol for VALUE, or #f when it names no style.
Spaces and underscores become dashes, so \"frosted glass\" and frosted_glass
both mean frosted-glass."
  (let* ((text (cond
                 ((symbol? value) (symbol->string value))
                 ((string? value) value)
                 (else (format #f "~a" value))))
         (text (string-trim-both text))
         (normalized
          (list->string
           (map (lambda (character)
                  (cond
                    ((or (char=? character #\space)
                         (char=? character #\_))
                     #\-)
                    (else (char-downcase character))))
                (string->list text))))
         (name (string->symbol normalized))
         (alias (assoc-ref style-aliases name)))
    (cond
      (alias alias)
      ((memq name style-names) name)
      (else #f))))

(define (style-id-prefix badge-id)
  "A prefix for the SVG ids a style generates for BADGE-ID. Ids have to be
valid XML names, so characters such as '+' in a glyph id are replaced."
  (string-append "ggg-"
                 (list->string
                  (map (lambda (character)
                         (if (or (char-alphabetic? character)
                                 (char-numeric? character)
                                 (memv character '(#\- #\_ #\.)))
                             character
                             #\-))
                       (string->list (format #f "~a" badge-id))))
                 "-"))

;; ====== Color math ======

;; Styles need to lighten and darken the colors the glyph asked for, so a
;; gloss is a lighter tint of the background and a neon plate is a much darker
;; one.  Only hex colors can be mixed; anything else (a CSS color name) is
;; returned untouched so a style never breaks a valid glyph.

(define (hex-digits color)
  "The six hex digits of COLOR without the leading #, or #f."
  (and (string? color)
       (string-prefix? "#" color)
       (let ((digits (substring color 1)))
         (case (string-length digits)
           ((3) (list->string
                 (append-map (lambda (character) (list character character))
                             (string->list digits))))
           ((4) (substring digits 0 3))
           ((6) digits)
           ((8) (substring digits 0 6))
           (else #f)))))

(define (hex->rgb color)
  "The (red green blue) components of COLOR, each 0-255, or #f."
  (let ((digits (hex-digits color)))
    (and digits
         (list (string->number (substring digits 0 2) 16)
               (string->number (substring digits 2 4) 16)
               (string->number (substring digits 4 6) 16)))))

(define (rgb->hex components)
  "COMPONENTS, each 0-255, as a #rrggbb string."
  (string-append
   "#"
   (string-concatenate
    (map (lambda (component)
           (let ((digits (number->string
                          (max 0 (min 255 (inexact->exact (round component))))
                          16)))
             (if (= 1 (string-length digits))
                 (string-append "0" digits)
                 digits)))
         components))))

(define* (mix-color color other amount)
  "COLOR mixed with OTHER by AMOUNT (0 keeps COLOR, 1 becomes OTHER)."
  (let ((a (hex->rgb color))
        (b (hex->rgb other)))
    (if (and a b)
        (rgb->hex (map (lambda (x y)
                         (+ (* x (- 1 amount)) (* y amount)))
                       a b))
        color)))

(define* (tint color #:optional (amount 0.25))
  "COLOR lightened towards white by AMOUNT."
  (mix-color color "#ffffff" amount))

(define* (shade color #:optional (amount 0.25))
  "COLOR darkened towards black by AMOUNT."
  (mix-color color "#000000" amount))

;; ====== SVG helpers ======

(define (ctx-value ctx key)
  "The value of KEY in the style context CTX."
  (let ((entry (assq key ctx)))
    (and entry (cdr entry))))

(define (ctx-id ctx suffix)
  (string-append (ctx-value ctx 'prefix) suffix))

(define (gradient-stops stops)
  "SXML <stop> elements from STOPS, each (offset color [opacity])."
  (map (lambda (stop)
         (let ((offset (list-ref stop 0))
               (color (list-ref stop 1))
               (opacity (if (>= (length stop) 3) (list-ref stop 2) 1)))
           `(stop (@ (offset ,offset)
                     (stop-color ,color)
                     (stop-opacity ,opacity)))))
       stops))

(define* (linear-gradient id stops
                          #:key (x1 "0%") (y1 "0%") (x2 "0%") (y2 "100%"))
  "A vertical (by default) linear gradient called ID that paints STOPS."
  `(linearGradient (@ (id ,id) (x1 ,x1) (y1 ,y1) (x2 ,x2) (y2 ,y2))
                   ,@(gradient-stops stops)))

(define* (radial-gradient id stops
                          #:key (cx "50%") (cy "50%") (r "70%"))
  "A radial gradient called ID that paints STOPS."
  `(radialGradient (@ (id ,id) (cx ,cx) (cy ,cy) (r ,r))
                   ,@(gradient-stops stops)))

(define (clip-rect id width height radius)
  "A clip path called ID for a WIDTH by HEIGHT rectangle with RADIUS corners,
so overlays never spill over the rounded edge of the badge."
  `(clipPath (@ (id ,id))
             (rect (@ (x 0) (y 0)
                      (width ,width) (height ,height)
                      (rx ,radius) (ry ,radius)))))

(define* (drop-shadow-filter id
                             #:key (dx 0) (dy 1.4) (blur 1)
                             (color "#000000") (opacity 0.45))
  "A drop shadow filter called ID, built from the classic filter primitives so
that every renderer (and ImageMagick's SVG delegate) understands it."
  `(filter (@ (id ,id)
              (x "-50%") (y "-50%")
              (width "200%") (height "200%"))
           (feGaussianBlur (@ (in "SourceAlpha") (stdDeviation ,blur)))
           (feOffset (@ (dx ,dx) (dy ,dy) (result "offset")))
           (feFlood (@ (flood-color ,color) (flood-opacity ,opacity)))
           (feComposite (@ (in2 "offset") (operator "in")))
           (feMerge (@)
                    (feMergeNode (@))
                    (feMergeNode (@ (in "SourceGraphic"))))))

(define* (glow-filter id #:key (blur 1.8) (strength 2))
  "A neon glow filter called ID: the input is blurred STRENGTH times and then
drawn under a crisp copy of itself."
  `(filter (@ (id ,id)
              (x "-70%") (y "-70%")
              (width "240%") (height "240%"))
           (feGaussianBlur (@ (in "SourceGraphic")
                              (stdDeviation ,blur)
                              (result "glow")))
           (feMerge (@)
                    ,@(map (lambda (ignored)
                             `(feMergeNode (@ (in "glow"))))
                           (iota strength))
                    (feMergeNode (@ (in "SourceGraphic"))))))

(define (section-rects ctx attributes)
  "One rectangle per section, at its position and size, with ATTRIBUTES."
  (map (lambda (section x width)
         `(rect (@ (x ,x)
                   (y 0)
                   (width ,width)
                   (height ,(ctx-value ctx 'height))
                   ,@attributes)
                ""))
       (ctx-value ctx 'sections)
       (ctx-value ctx 'positions)
       (ctx-value ctx 'widths)))

(define (section-outlines ctx attributes)
  "One unfilled, stroked rectangle per section, with ATTRIBUTES."
  (map (lambda (section x width)
         `(rect (@ (x ,x)
                   (y 0)
                   (width ,width)
                   (height ,(ctx-value ctx 'height))
                   (fill "none")
                   (stroke ,(lookup section 'background))
                   (rx ,(ctx-value ctx 'radius))
                   (ry ,(ctx-value ctx 'radius))
                   ,@attributes)
                ""))
       (ctx-value ctx 'sections)
       (ctx-value ctx 'positions)
       (ctx-value ctx 'widths)))

(define (full-badge-rect ctx fill)
  "One rectangle covering the whole badge, filled with FILL."
  `(rect (@ (x 0) (y 0)
            (width ,(ctx-value ctx 'width))
            (height ,(ctx-value ctx 'height))
            (rx ,(ctx-value ctx 'radius))
            (ry ,(ctx-value ctx 'radius))
            (fill ,fill))
         ""))

;; ====== Skins ======

(define (flat-skin ctx)
  "The default: nothing is drawn on top of the badge."
  '())

(define (square-skin ctx)
  "The badge with sharp corners."
  `((radius . 0)))

(define (shadow-skin ctx)
  "A subtle shadow just under the badge's content, drawn inside the badge so
that every badge keeps the exact flat size and stays aligned in a row."
  (let ((clip (ctx-id ctx "clip"))
        (shade (ctx-id ctx "shade"))
        (highlight (ctx-id ctx "highlight"))
        (width (ctx-value ctx 'width))
        (height (ctx-value ctx 'height))
        (radius (ctx-value ctx 'radius)))
    `((defs . (,(clip-rect clip width height radius)
               ,(linear-gradient shade
                                 '(("0%" "#000000" 0)
                                   ("74%" "#000000" 0)
                                   ("90%" "#000000" 0.12)
                                   ("100%" "#000000" 0.32)))
               ,(linear-gradient highlight
                                 '(("0%" "#ffffff" 0.12)
                                   ("35%" "#ffffff" 0.01)
                                   ("100%" "#ffffff" 0)))))
      (overlays . ((g (@ (clip-path ,(format #f "url(#~a)" clip)))
                      ,(full-badge-rect ctx (format #f "url(#~a)" shade))
                      ,(full-badge-rect ctx (format #f "url(#~a)" highlight))))))))

(define (material-skin ctx)
  "A Material-style badge: a smooth sheen that is lighter at the top and
settles into a soft elevation shade at the bottom, plus a faint inner edge."
  (let ((clip (ctx-id ctx "clip"))
        (sheen (ctx-id ctx "sheen"))
        (width (ctx-value ctx 'width))
        (height (ctx-value ctx 'height))
        (radius (ctx-value ctx 'radius)))
    `((defs . (,(clip-rect clip width height radius)
               ,(linear-gradient sheen
                                 '(("0%" "#ffffff" 0.16)
                                   ("50%" "#ffffff" 0.04)
                                   ("86%" "#000000" 0.02)
                                   ("100%" "#000000" 0.24)))))
      (overlays . ((g (@ (clip-path ,(format #f "url(#~a)" clip)))
                      ,(full-badge-rect ctx (format #f "url(#~a)" sheen)))))
      (border . ((rect (@ (x 0.3) (y 0.3)
                          (width ,(rounded (- width 0.6)))
                          (height ,(rounded (- height 0.6)))
                          (rx ,(rounded (max 0 (- radius 0.3))))
                          (ry ,(rounded (max 0 (- radius 0.3))))
                          (fill "none")
                          (stroke "#ffffff")
                          (stroke-opacity 0.14)
                          (stroke-width 0.6)) ""))))))

(define (plastic-skin ctx)
  "A plastic badge: the top half catches a strong gloss while the bottom half
darkens, with a bright inner bevel and a soft text shadow."
  (let ((clip (ctx-id ctx "clip"))
        (gloss (ctx-id ctx "gloss"))
        (text-shadow (ctx-id ctx "text-shadow"))
        (width (ctx-value ctx 'width))
        (height (ctx-value ctx 'height))
        (radius (ctx-value ctx 'radius)))
    `((defs . (,(clip-rect clip width height radius)
               ,(linear-gradient gloss
                                 '(("0%" "#ffffff" 0.55)
                                   ("44%" "#ffffff" 0.10)
                                   ("50%" "#000000" 0.02)
                                   ("100%" "#000000" 0.14)))
               ,(drop-shadow-filter text-shadow
                                    #:dy 0.6 #:blur 0.5 #:opacity 0.35)))
      (text-filter . ,(format #f "url(#~a)" text-shadow))
      (overlays . ((g (@ (clip-path ,(format #f "url(#~a)" clip)))
                      ,(full-badge-rect ctx (format #f "url(#~a)" gloss)))))
      (border . ((rect (@ (x 0.35) (y 0.35)
                          (width ,(rounded (- width 0.7)))
                          (height ,(rounded (- height 0.7)))
                          (rx ,(rounded (max 0 (- radius 0.35))))
                          (ry ,(rounded (max 0 (- radius 0.35))))
                          (fill "none")
                          (stroke "#ffffff")
                          (stroke-opacity 0.3)
                          (stroke-width 0.7)) ""))))))

(define (frosted-glass-skin ctx)
  "A frosted glass badge: a translucent white frost and a soft reflection
behind a light hairline border."
  (let ((clip (ctx-id ctx "clip"))
        (frost (ctx-id ctx "frost"))
        (shine (ctx-id ctx "shine"))
        (width (ctx-value ctx 'width))
        (height (ctx-value ctx 'height))
        (radius (ctx-value ctx 'radius)))
    `((defs . (,(clip-rect clip width height radius)
               ,(linear-gradient frost
                                 '(("0%" "#ffffff" 0.20)
                                   ("55%" "#ffffff" 0.07)
                                   ("100%" "#ffffff" 0.03)))
               ,(radial-gradient shine
                                 '(("0%" "#ffffff" 0.35)
                                   ("100%" "#ffffff" 0))
                                 #:cx "30%" #:cy "18%" #:r "75%")))
      (overlays . ((g (@ (clip-path ,(format #f "url(#~a)" clip)))
                      ,(full-badge-rect ctx (format #f "url(#~a)" frost))
                      (ellipse (@ (cx ,(rounded (* width 0.28)))
                                  (cy ,(rounded (* height 0.22)))
                                  (rx ,(rounded (* width 0.34)))
                                  (ry ,(rounded (* height 0.5)))
                                  (fill ,(format #f "url(#~a)" shine))) ""))))
      (border . ((rect (@ (x 0.5) (y 0.5)
                          (width ,(rounded (- width 1)))
                          (height ,(rounded (- height 1)))
                          (rx ,(rounded (max 0 (- radius 0.5))))
                          (ry ,(rounded (max 0 (- radius 0.5))))
                          (fill "none")
                          (stroke "#ffffff")
                          (stroke-opacity 0.45)
                          (stroke-width 1)) ""))))))

(define (frutiger-skin ctx)
  "A Frutiger Aero badge: a sky-tinted gloss, a hard specular highlight and a
brighter, rounder border, the look of late-2000s glass."
  (let* ((clip (ctx-id ctx "clip"))
         (sky (ctx-id ctx "sky"))
         (gloss (ctx-id ctx "gloss"))
         (shine (ctx-id ctx "shine"))
         (text-shadow (ctx-id ctx "text-shadow"))
         (width (ctx-value ctx 'width))
         (height (ctx-value ctx 'height))
         (radius (max (ctx-value ctx 'radius) (scaled 5.5))))
    `((radius . ,radius)
      (defs . (,(clip-rect clip width height radius)
               ,(linear-gradient sky
                                 '(("0%" "#9fe4ff" 0.28)
                                   ("48%" "#a9f5e1" 0.10)
                                   ("100%" "#ffffff" 0.02)))
               ,(linear-gradient gloss
                                  '(("0%" "#ffffff" 0.55)
                                    ("34%" "#ffffff" 0.18)
                                    ("50%" "#ffffff" 0.02)
                                    ("100%" "#ffffff" 0)))
               ,(radial-gradient shine
                                 '(("0%" "#ffffff" 0.55)
                                   ("100%" "#ffffff" 0))
                                 #:cx "26%" #:cy "16%" #:r "62%")
               ,(drop-shadow-filter text-shadow
                                    #:dy 0.7 #:blur 0.6 #:opacity 0.35)))
      (text-filter . ,(format #f "url(#~a)" text-shadow))
      (overlays . ((g (@ (clip-path ,(format #f "url(#~a)" clip)))
                      ,(full-badge-rect ctx (format #f "url(#~a)" sky))
                      ,(full-badge-rect ctx (format #f "url(#~a)" gloss))
                      (ellipse (@ (cx ,(rounded (* width 0.24)))
                                  (cy ,(rounded (* height 0.2)))
                                  (rx ,(rounded (* width 0.3)))
                                  (ry ,(rounded (* height 0.42)))
                                  (fill ,(format #f "url(#~a)" shine))) ""))))
      (border . ((rect (@ (x 0.45) (y 0.45)
                          (width ,(rounded (- width 0.9)))
                          (height ,(rounded (- height 0.9)))
                          (rx ,(rounded (max 0 (- radius 0.45))))
                          (ry ,(rounded (max 0 (- radius 0.45))))
                          (fill "none")
                          (stroke "#ffffff")
                          (stroke-opacity 0.55)
                          (stroke-width 0.9)) ""))))))

(define (neon-skin ctx)
  "A neon badge: every section becomes a dark plate with a crisp glowing
outline in its own color, and the text is brightened for legibility without a
blur that would soften it."
  (let ((glow (ctx-id ctx "glow")))
    `((defs . (,(glow-filter glow #:blur 0.8 #:strength 1)))
      (background-fill . ,(lambda (section)
                            (shade (lookup section 'background) 0.82)))
      (text-fill . ,(lambda (section)
                      (tint (lookup section 'background) 0.35)))
      (border . ((g (@ (shape-rendering "geometricPrecision")
                       (filter ,(format #f "url(#~a)" glow)))
                    ,@(section-outlines ctx '((stroke-width 1.8)
                                              (stroke-opacity 0.6))))
                 (g (@ (shape-rendering "geometricPrecision"))
                    ,@(section-outlines ctx '((stroke-width 1)
                                              (stroke-opacity 1)))))))))

(define (style-skin style ctx)
  "The skin of STYLE (a symbol from STYLE-NAMES) for the geometry in CTX."
  (case style
    ((flat) (flat-skin ctx))
    ((square) (square-skin ctx))
    ((shadow) (shadow-skin ctx))
    ((plastic) (plastic-skin ctx))
    ((frosted-glass) (frosted-glass-skin ctx))
    ((material) (material-skin ctx))
    ((frutiger) (frutiger-skin ctx))
    ((neon) (neon-skin ctx))
    (else (flat-skin ctx))))
