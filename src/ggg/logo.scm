;; ggg: guile glyph generator
;;
;; Spdx-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (ggg logo)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (sxml ssax)
  #:use-module (ggg prelude)
  #:use-module (ggg svg)
  #:export (logo-names logo-file-path logo-name->string
                      logo-name-valid? legacy-svg-paths get-logo-sxml))

;; ====== Logo files ======

;; A logo is a full SVG document in <resources>/logos/<name>.svg. The whole
;; <svg> element is inlined as a nested element, so a logo may contain several
;; paths, groups, gradients, transforms or filters.

(define svg-namespace "http://www.w3.org/2000/svg")
(define xlink-namespace "http://www.w3.org/1999/xlink")

(define (logo-name->string name)
  "Normalize a logo name (symbol or string, optionally ending in .svg)."
  (let ((name (cond
                ((symbol? name) (symbol->string name))
                ((string? name) name)
                (else (format #f "~a" name)))))
    (if (string-suffix? ".svg" name)
        (string-drop-right name 4)
        name)))

(define (logo-name-valid? name)
  "True when NAME is a plain logo name that is safe to look up on disk."
  (safe-filename? (logo-name->string name)))

(define* (legacy-svg-paths #:key resources)
  "The files left in the removed <resources>/svg-paths/ directory, sorted.
Only used to point people at the full SVG format when they upgrade."
  (let ((directory (and resources (format #f "~a/svg-paths" resources))))
    (if (and directory (file-exists? directory))
        (sort (scandir directory
                       (lambda (name) (not (member name '("." "..")))))
              string<?)
        '())))

(define* (logo-file-path name #:key resources)
  "Return the SVG file backing logo NAME, or #f when it does not exist."
  (let* ((name (logo-name->string name))
         (svg-file (and resources (format #f "~a/logos/~a.svg" resources name))))
    (and svg-file (file-exists? svg-file) svg-file)))

(define* (logo-names #:key resources)
  "All logo names available in RESOURCES, sorted alphabetically."
  (if (not resources)
      '()
      (let ((logos-dir (format #f "~a/logos" resources)))
        (if (not (file-exists? logos-dir))
            '()
            (sort (map (lambda (name) (string-drop-right name 4))
                       (filter (lambda (name) (string-suffix? ".svg" name))
                               (scandir logos-dir
                                        (lambda (name)
                                          (not (member name '("." "..")))))))
                  string<?)))))

;; ====== SVG documents ======

(define (element-namespace name)
  (let* ((name (symbol->string name))
         (colon (string-rindex name #\:)))
    (and colon (substring name 0 colon))))

(define (element-local-name name)
  (let* ((name (symbol->string name))
         (colon (string-rindex name #\:)))
    (if colon
        (substring name (+ colon 1))
        name)))

(define (svg-element? node)
  (and (pair? node)
       (symbol? (car node))
       (string=? "svg" (element-local-name (car node)))))

(define (attribute->sxml attribute)
  "Turn a (name . value) pair into SXML's (name value) list form."
  (list (car attribute) (cdr attribute)))

(define (svg-attributes node)
  "Attribute alist of an SXML element, or '()."
  (let ((body (cdr node)))
    (if (and (pair? body)
             (pair? (car body))
             (eq? '@ (caar body)))
        (map (lambda (attribute)
               (cons (car attribute)
                     (if (pair? (cdr attribute))
                         (cadr attribute)
                         (cdr attribute))))
             (cdar body))
        '())))

(define (svg-children node)
  (let ((body (cdr node)))
    (if (and (pair? body)
             (pair? (car body))
             (eq? '@ (caar body)))
        (cdr body)
        body)))

(define (view-box-from-size attrs)
  (let ((width (assoc-ref attrs 'width))
        (height (assoc-ref attrs 'height)))
    (and width height
         (string->number (format #f "~a" width))
         (string->number (format #f "~a" height))
         (format #f "0 0 ~a ~a" width height))))

(define (xlink-name? name)
  (and (symbol? name)
       (let ((name (symbol->string name)))
         (or (string-prefix? (string-append xlink-namespace ":") name)
             (string-prefix? "xlink:" name)))))

(define (any-xlink-attribute? node)
  (cond
    ((string? node) #f)
    ((not (pair? node)) #f)
    ((eq? '@ (car node))
     (any (lambda (attribute)
            (and (pair? attribute) (xlink-name? (car attribute))))
          (cdr node)))
    (else (any any-xlink-attribute? node))))

(define (clean-attribute attribute)
  "Strip namespace prefixes from an attribute, dropping foreign ones.
Returns a standard SXML (name value) list, or #f when the attribute is dropped."
  (let* ((name (car attribute))
         (value (if (pair? (cdr attribute))
                    (cadr attribute)
                    (cdr attribute)))
         (namespace (element-namespace name)))
    (cond
      ((not namespace) (list name value))
      ((string=? namespace svg-namespace)
       (list (string->symbol (element-local-name name)) value))
      ((string=? namespace xlink-namespace)
       (list (string->symbol
              (string-append "xlink:" (element-local-name name)))
             value))
      (else #f))))

(define (clean-svg-node node)
  "Turn a parsed XML node into a list of plain SXML nodes, dropping editor
metadata and foreign namespaces."
  (cond
    ((string? node)
     (if (string-every char-whitespace? node) '() (list node)))
    ((not (and (pair? node) (symbol? (car node))))
     '())
    (else
     (let ((namespace (element-namespace (car node))))
       (if (and namespace (not (string=? namespace svg-namespace)))
           '()
           (let* ((tag (string->symbol (element-local-name (car node))))
                  (body (cdr node))
                  (has-attributes? (and (pair? body)
                                        (pair? (car body))
                                        (eq? '@ (caar body))))
                  (attributes (if has-attributes?
                                  (filter-map clean-attribute (cdar body))
                                  '()))
                  (children (append-map clean-svg-node
                                        (if has-attributes?
                                            (cdr body)
                                            body))))
             (list `(,tag (@ ,@attributes) ,@children))))))))

(define (find-svg-element nodes)
  (find svg-element?
        (if (and (pair? nodes) (eq? '*TOP* (car nodes)))
            (cdr nodes)
            nodes)))

(define (parse-svg-document contents path)
  (catch #t
    (lambda ()
      (ssax:xml->sxml (open-input-string contents)
                      (list (cons #f svg-namespace))))
    (lambda (key . args)
      (fail (format #f "could not parse logo SVG '~a'" path)
            #:hint (format #f "~a. Make sure it is a well-formed XML document."
                           (if (pair? args) (car args) key))))))

(define* (full-svg-logo path #:key (width (scaled 14)) (height (scaled 14))
                             (x (scaled 3)) (y (scaled 3)))
  (let* ((contents (call-with-input-file path get-string-all))
         (trimmed (string-trim-both contents)))
    (unless (string-contains trimmed "<svg")
      (fail (format #f "logo '~a' does not look like an SVG document" path)
            #:hint "A logo must be an SVG document with an <svg> root element, e.g. <svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\">...</svg>."))
    (let* ((tree (parse-svg-document contents path))
           (svg (find-svg-element tree)))
      (unless svg
        (fail (format #f "logo '~a' has no <svg> root element" path)
              #:hint "Wrap the logo drawing in a single <svg>...</svg> element."))
      (let* ((attributes (svg-attributes svg))
             (view-box (or (assoc-ref attributes 'viewBox)
                           (view-box-from-size attributes)))
             ;; The badge decides where the logo sits; a stray x/y left on a
             ;; logo document must not push it out of the badge's padding.
             (extra-attributes
              (map attribute->sxml
                   (remove (lambda (attribute)
                             (memq (car attribute)
                                   '(width height x y viewBox xmlns)))
                           attributes)))
             (children (append-map clean-svg-node (svg-children svg))))
        (unless view-box
          (fail (format #f "logo '~a' has no viewBox or numeric width/height" path)
                #:hint "Add viewBox=\"0 0 24 24\" to the <svg> element so ggg can scale the logo to badge height."))
        `(svg (@ (width ,width)
                 (height ,height)
                 (viewBox ,view-box)
                 (x ,x)
                 (y ,y)
                 (xmlns ,svg-namespace)
                 ,@(if (any-xlink-attribute? svg)
                       `((xmlns:xlink ,xlink-namespace))
                       '())
                 ,@extra-attributes)
              ,@children)))))

(define* (get-logo-sxml name #:key resources (width (scaled 14)) (height (scaled 14)))
  "Return the SXML for logo NAME ready to be nested inside a badge, or #f."
  (let* ((name (logo-name->string name))
         (path (logo-file-path name #:resources resources)))
    (and path (full-svg-logo path #:width width #:height height))))
