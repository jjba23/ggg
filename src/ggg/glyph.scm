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
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ggg svg)
  #:use-module (ggg logo)
  #:use-module (ggg colors)
  #:use-module (ggg prelude)
  #:export (mk-glyph validate-glyph validate-glyphs glyph-id
                     logo-width separator-width text-vertical-center
                     first-padding separator-x-offset))

;; Badge geometry follows the compact 20px-high look of shields.io badges:
;; a 14px logo inset by 3px, 11px text, 5px of padding on each side of a text
;; run and 3px rounded corners.
(define logo-width
  (make-parameter 14))

(define separator-width
  (make-parameter 6))

(define text-vertical-center
  (make-parameter 14))

(define first-padding
  (make-parameter 3))

(define separator-x-offset
  (make-parameter 3))

;; ====== Reading a glyph definition ======

(define (glyph-id glyph)
  "The id of GLYPH as a string, or #f when it is missing or not a name."
  (let ((id (and (list? glyph) (lookup glyph 'id))))
    (cond
      ((symbol? id) (symbol->string id))
      ((string? id) id)
      (else #f))))

(define (section-label glyph-id index)
  (format #f "glyph '~a', section ~a" glyph-id index))

(define* (section-text section glyph-id index)
  (let ((label (section-label glyph-id index))
        (value (lookup section 'text)))
    (unless (or (string? value) (symbol? value) (number? value))
      (fail (format #f "~a is missing a text label" label)
            #:hint "Add (text . \"My badge\") to that section."))
    (let ((text (format #f "~a" value)))
      (when (string-null? text)
        (fail (format #f "~a has an empty text label" label)
              #:hint "Give the section a non-empty (text . \"...\") value."))
      text)))

(define* (section-color section key glyph-id index)
  (let ((label (section-label glyph-id index))
        (value (lookup section key)))
    (unless value
      (fail (format #f "~a is missing a ~a color" label key)
            #:hint (format #f "Add (~a . badge-gray) or a hex string such as \"#555\"." key)))
    (resolve-color value #:context label)))

(define* (section-font-family section glyph-id index)
  (let ((value (lookup section 'font-family)))
    (cond
      ((not value) "sans-serif")
      ((string? value) value)
      ((symbol? value) (symbol->string value))
      (else (fail (format #f "~a: font-family must be a string, got ~s"
                          (section-label glyph-id index) value))))))

(define* (section-number section key default glyph-id index)
  (let ((value (lookup section key)))
    (cond
      ((not value) default)
      ((number? value) value)
      (else (fail (format #f "~a: ~a must be a number, got ~s"
                          (section-label glyph-id index) key value))))))

(define* (glyph-number glyph key default)
  (let ((value (lookup glyph key)))
    (cond
      ((not value) default)
      ((number? value) value)
      (else (fail (format #f "glyph '~a': ~a must be a number, got ~s"
                          (or (glyph-id glyph) "unknown") key value))))))

(define* (section-logo section glyph-id index #:key resources)
  (let ((name (lookup section 'logo)))
    (and name
         (let ((path (and (logo-name-valid? name)
                          (logo-file-path name #:resources resources))))
           (unless path
             (fail (format #f "~a uses unknown logo '~a'"
                           (section-label glyph-id index) name)
                   #:hint (format #f "Available logos: ~a. Add ~a/logos/~a.svg to use a new one."
                                  (string-join (logo-names #:resources resources) ", ")
                                  resources
                                  (logo-name->string name))))
           (get-logo-sxml name
                          #:resources resources
                          #:width (logo-width)
                          #:height (logo-width))))))

;; ====== Rendering ======

(define* (resolve-section section index glyph-id #:key resources)
  "Resolve SECTION into the values the renderer needs, including its width."
  (let* ((text (section-text section glyph-id index))
         (font-size (section-number section 'font-size 11 glyph-id index))
         (logo (and (= index 1)
                    (section-logo section glyph-id index #:resources resources))))
    `((text . ,text)
      (background . ,(section-color section 'background glyph-id index))
      (color . ,(section-color section 'color glyph-id index))
      (font-family . ,(section-font-family section glyph-id index))
      (font-size . ,font-size)
      (font-weight . ,(section-number section 'font-weight 500 glyph-id index))
      (logo . ,logo)
      ;; The first text area starts after the logo box and the gap that keeps
      ;; the label from touching the logo. Other sections have no logo.
      (text-area-start . ,(if logo (+ (logo-width) (first-padding)) 0))
      (text-width . ,(length-for-text text #:font-size font-size)))))

(define (section-full-width section)
  (+ (lookup section 'text-area-start) (lookup section 'text-width)))

(define* (mk-glyph x
                   #:key resources)
  (let* ((badge-id (or (glyph-id x)
                       (fail "refusing to render a glyph without an (id . name) setting"
                             #:hint "Give each glyph a unique id, e.g. (id . scheme-guile).")))
         (sections (or (lookup x 'sections) '()))
         (section-count (if (list? sections) (length sections) 0)))
    (when (zero? section-count)
      (fail (format #f "glyph '~a' has no sections" badge-id)
            #:hint "Add at least one section with a text label and colors."))
    (let* ((height (glyph-number x 'height 20))
           (border-radius (glyph-number x 'border-radius 3))
           (resolved (map (lambda (section index)
                            (resolve-section section index badge-id
                                             #:resources resources))
                          sections
                          (iota section-count 1)))
           (widths (map section-full-width resolved))
           ;; Where each section starts. The next section's start is also the
           ;; boundary between the two of them.
           (positions (let loop ((rest widths) (x 0) (acc '()))
                        (if (null? rest)
                            (reverse acc)
                            (loop (cdr rest) (+ x (car rest)) (cons x acc)))))
           (total-badge-width (fold + 0 widths))
           (first-section (car resolved))
           (first-logo (lookup first-section 'logo)))
      `((svg (@ (id ,badge-id)
                (xmlns "http://www.w3.org/2000/svg")
                (width ,total-badge-width)
                (height ,height)
                (viewBox ,(format #f "0 0 ~a ~a" total-badge-width height)))
             (g (@ (shape-rendering "geometricPrecision"))
                ,@(map (lambda (section x width)
                         `(rect (@ (x ,x)
                                   (width ,width)
                                   (height ,height)
                                   (fill ,(lookup section 'background))
                                   (rx ,border-radius)
                                   (ry ,border-radius)) ""))
                       resolved positions widths)
                ;; Square off the rounded corners where two sections meet, with
                ;; one strip of each background color around every boundary.
                ,@(append-map (lambda (previous next boundary)
                                (list
                                 `(rect (@ (x ,(- boundary (separator-x-offset)))
                                           (width ,(separator-width))
                                           (height ,height)
                                           (fill ,(lookup previous 'background))
                                           (rx 0)
                                           (ry 0)) "")
                                 `(rect (@ (x ,boundary)
                                           (width ,(separator-width))
                                           (height ,height)
                                           (fill ,(lookup next 'background))
                                           (rx 0)
                                           (ry 0)) "")))
                              resolved (cdr resolved) (cdr positions)))
             (g (@ (text-anchor "middle")
                   (shape-rendering "geometricPrecision"))
                ,@(map (lambda (section x)
                         `(text (@ (fill ,(lookup section 'color))
                                   (font-size ,(lookup section 'font-size))
                                   (font-family ,(lookup section 'font-family))
                                   (style ,(serialize-style
                                            (list (cons 'font-weight
                                                        (lookup section 'font-weight)))))
                                   (x ,(round (+ x
                                                 (lookup section 'text-area-start)
                                                 (/ (lookup section 'text-width) 2))))
                                   (y ,(text-vertical-center)))
                                ,(lookup section 'text)))
                       resolved positions))
             ,@(if first-logo
                   `((g (@ (shape-rendering "geometricPrecision"))
                        ,first-logo))
                   '()))))))

;; ====== Validation ======

(define glyph-settings '(id sections height border-radius))

(define section-settings '(text background color logo
                                font-family font-size font-weight))

(define (setting-entry alist key)
  "The (key . value) entry for KEY, or #f. Malformed entries are ignored."
  (and (list? alist)
       (find (lambda (entry) (and (pair? entry) (eq? (car entry) key)))
             alist)))

(define (setting-value alist key)
  "The value for KEY when it is written as a proper (key . value) pair."
  (let ((entry (setting-entry alist key)))
    (and entry (not (list? entry)) (cdr entry))))

(define (unknown-settings-problems alist valid label)
  "Problems for keys in ALIST that are not part of VALID."
  (filter-map (lambda (entry)
                (and (pair? entry)
                     (symbol? (car entry))
                     (not (memq (car entry) valid))
                     (format #f "~a: unknown setting '~a' (valid settings: ~a)"
                             label (car entry)
                             (string-join (map symbol->string valid) ", "))))
              (if (list? alist) alist '())))

(define (number-problems alist keys label)
  "Problems for non-numeric values of KEYS in ALIST."
  (filter-map (lambda (key)
                (let ((value (setting-value alist key)))
                  (and value
                       (not (number? value))
                       (format #f "~a: ~a must be a number, got ~s"
                               label key value))))
              keys))

(define (non-pair-problems alist label)
  "Problems for entries that are not written as (key . value) pairs."
  (filter-map (lambda (entry)
                (if (and (pair? entry) (not (list? entry)))
                    #f
                    (format #f "~a: ~s is not a key/value pair; write (~a . value) instead"
                            label entry
                            (if (pair? entry) (car entry) 'key))))
              (if (list? alist) alist '())))

(define (color-problems section label)
  (filter-map (lambda (key)
                (let ((entry (setting-entry section key)))
                  (cond
                    ((not entry)
                     (format #f "~a is missing a ~a color; add (~a . badge-gray) or a hex string"
                             label key key))
                    ;; Entries that are not (key . value) pairs are reported by
                    ;; non-pair-problems, so do not complain twice.
                    ((list? entry) #f)
                    (else (color-error (cdr entry) #:context label)))))
              '(background color)))

(define (logo-problems section section-index label resources)
  (let ((logo (setting-value section 'logo)))
    (cond
      ((not logo) '())
      ((> section-index 1)
       (list (format #f "~a has a logo, but logos are only supported in the first section"
                     label)))
      ((not (logo-name-valid? logo))
       (list (format #f "~a: logo name '~a' may only contain letters, digits, '-', '_', '.' or '+'"
                     label logo)))
      ((not (logo-file-path logo #:resources resources))
       (let ((suggestion (suggest-similar (logo-name->string logo)
                                          (logo-names #:resources resources))))
         (list (format #f "~a uses unknown logo '~a'~a"
                       label logo
                       (if suggestion
                           (format #f " (did you mean '~a'?)" suggestion)
                           "")))))
      (else '()))))

(define* (validate-section section section-index glyph-label resources)
  "Return a list of problems for one section of a glyph."
  (let ((label (format #f "~a, section ~a" glyph-label section-index)))
    (if (not (list? section))
        (list (format #f "~a is not a proper list of settings" label))
        (append
         (non-pair-problems section label)
         (unknown-settings-problems section section-settings label)
         (let ((text (setting-value section 'text)))
           (if (or (string? text) (symbol? text) (number? text))
               '()
               (list (format #f "~a is missing a text label; add (text . \"...\")"
                             label))))
         (color-problems section label)
         (number-problems section '(font-size font-weight) label)
         (logo-problems section section-index label resources)))))

(define* (validate-glyph glyph #:key (index 1) resources)
  "Return a list of human-readable configuration problems for GLYPH."
  (if (not (list? glyph))
      (list (format #f "glyph ~a is not a proper list of settings" index))
      (let* ((id (glyph-id glyph))
             (label (format #f "glyph '~a'" (or id (format #f "#~a" index))))
             (sections (or (lookup glyph 'sections) '())))
        (append
         (if id
             (if (safe-filename? id)
                 '()
                 (list (format #f "~a: the id '~a' cannot be used as a file name (use letters, digits, '-', '_', '.' or '+')"
                               label id)))
             (list (format #f "~a is missing an (id . name) setting" label)))
         (unknown-settings-problems glyph glyph-settings label)
         (number-problems glyph '(height border-radius) label)
         (cond
           ((not (list? sections))
            (list (format #f "~a: sections must be a list of section definitions" label)))
           ((null? sections)
            (list (format #f "~a has no sections; add at least one section with text and colors"
                          label)))
           (else
            (append-map (lambda (section section-index)
                          (validate-section section section-index label resources))
                        sections
                        (iota (length sections) 1))))))))

(define* (validate-glyphs glyphs #:key resources)
  "Return every problem found in GLYPHS, so users can fix them in one pass."
  (cond
    ((not (list? glyphs))
     (list "ggg-glyphs must be a list of glyph definitions, e.g. (list glyph-one glyph-two)"))
    ((null? glyphs)
     (list "ggg-glyphs is empty; define at least one glyph and add it to the list"))
    (else
     (let loop ((rest glyphs)
                (index 1)
                (seen '())
                (problems '()))
       (if (null? rest)
           (reverse problems)
           (let* ((glyph (car rest))
                  (id (glyph-id glyph))
                  (duplicate (and id (member id seen)))
                  (duplicate-problems
                   (if duplicate
                       (list (format #f "glyph '~a' (#~a) reuses the id '~a'; ids must be unique because they name the output files"
                                     id index id))
                       '())))
             (loop (cdr rest)
                   (+ index 1)
                   (if id (cons id seen) seen)
                   (append problems
                           duplicate-problems
                           (validate-glyph glyph
                                           #:index index
                                           #:resources resources)))))))))
