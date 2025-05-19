;; ggg: guile glyph generator

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; ggg is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ggg is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ggg.  If not, see <https://www.gnu.org/licenses/>.

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
  #:use-module (sxml ssax input-parse)
  #:use-module (sxml ssax)
  #:use-module (sxml transform)
  #:use-module (srfi srfi-13)
  #:use-module (srfi srfi-64))

;; ====== Serialize (SXML) ======

(define check-name
  (let ((*good-cache* (make-hash-table)))
    (lambda (name)
      (if (not (hashq-ref *good-cache* name))
          (let* ((str (symbol->string name))
                 (i (string-index str #\:))
                 (head (or (and i
                                (substring str 0 i)) str))
                 (tail (and i
                            (substring str
                                       (1+ i)))))
            (and i
                 (string-index (substring str
                                          (1+ i)) #\:)
                 (error "Invalid QName: more than one colon" name))
            (for-each (lambda (s)
                        (and s
                             (or (char-alphabetic? (string-ref s 0))
                                 (eq? (string-ref s 0) #\_)
                                 (error "Invalid name starting character" s
                                        name))
                             (string-for-each (lambda (c)
                                                (or (char-alphabetic? c)
                                                    (string-index
                                                     "0123456789.-_" c)
                                                    (error
                                                     "Invalid name character"
                                                     c s name))) s)))
                      (list head tail))
            (hashq-set! *good-cache* name #t))))))

;; The following two functions serialize tags and attributes. They are
;; being used in the node handlers for the post-order function, see
;; below.

(define (attribute-value->xml value port)
  (cond
    ((pair? value)
     (attribute-value->xml (car value) port)
     (attribute-value->xml (cdr value) port))
    ((null? value)
     *unspecified*)
    ((string? value)
     (string->escaped-xml value port))
    ((procedure? value)
     (with-output-to-port port value))
    (else (string->escaped-xml (call-with-output-string (lambda (port)
                                                          (display value port)))
                               port))))

(define (attribute->xml attr value port)
  (check-name attr)
  (display attr port)
  (display "=\"" port)
  (attribute-value->xml value port)
  (display #\" port))

(define (element->xml tag attrs body port)
  (check-name tag)
  (display #\< port)
  (display tag port)
  (if attrs
      (let lp
        ((attrs attrs))
        (if (pair? attrs)
            (let ((attr (car attrs)))
              (display #\space port)
              (if (pair? attr)
                  (attribute->xml (car attr)
                                  (cdr attr) port)
                  (error "bad attribute" tag attr))
              (lp (cdr attrs)))
            (if (not (null? attrs))
                (error "bad attributes" tag attrs)))))
  (if (pair? body)
      (begin
        (display #\> port)
        (let lp
          ((body body))
          (cond
            ((pair? body)
             (sxml->xml (car body) port)
             (lp (cdr body)))
            ((null? body)
             (display "</" port)
             (display tag port)
             (display ">" port))
            (else (error "bad element body" tag body)))))
      (display " />" port)))

;; FIXME: ensure name is valid
(define (entity->xml name port)
  (display #\& port)
  (display name port)
  (display #\; port))

;; FIXME: ensure tag and str are valid
(define (pi->xml tag str port)
  (display "<?" port)
  (display tag port)
  (display #\space port)
  (display str port)
  (display "?>" port))

(define* (sxml->xml tree
                    #:optional (port (current-output-port))
                    (escape? #f))
  "Serialize the sxml tree @var{tree} as XML. The output will be written
to the current output port, unless the optional argument @var{port} is
present."
  (cond
    ((pair? tree)
     (if (symbol? (car tree))
         ;; An element.
         (let ((tag (car tree)))
           (case tag
             ((*TOP*)
              (sxml->xml (cdr tree) port escape?))
             ((*ENTITY*)
              (if (and (list? (cdr tree))
                       (= (length (cdr tree)) 1))
                  (entity->xml (cadr tree) port)
                  (error "bad *ENTITY* args"
                         (cdr tree))))
             ((*PI*)
              (if (and (list? (cdr tree))
                       (= (length (cdr tree)) 2))
                  (pi->xml (cadr tree)
                           (caddr tree) port)
                  (error "bad *PI* args"
                         (cdr tree))))
             (else (let* ((elems (cdr tree))
                          (attrs (and (pair? elems)
                                      (pair? (car elems))
                                      (eq? '@
                                           (caar elems))
                                      (cdar elems))))
                     (element->xml tag attrs
                                   (if attrs
                                       (cdr elems) elems) port)))))
         ;; A nodelist.
         (for-each (lambda (x)
                     (sxml->xml x port)) tree)))
    ((string? tree)
     (if escape?
         (string->escaped-xml tree port)
         (display tree port)))
    ((null? tree)
     *unspecified*)
    ((not tree)
     *unspecified*)
    ((eqv? tree #t)
     *unspecified*)
    ((procedure? tree)
     (with-output-to-port port tree))
    (else (when escape?
            (string->escaped-xml (call-with-output-string (lambda (port)
                                                            (display tree port)))
                                 port)))))

(define (sxml->string sxml)
  "Detag an sxml tree @var{sxml} into a string. Does not perform any
formatting."
  (string-concatenate-reverse (foldts (lambda (seed tree)
                                        ;; fdown
                                        '())
                                      (lambda (seed kid-seed tree)
                                        ;; fup
                                        (append! kid-seed seed))
                                      (lambda (seed tree)
                                        ;; fhere
                                        (if (string? tree)
                                            (cons tree seed) seed))
                                      '() sxml)))

(define (make-char-quotator char-encoding)
  (let ((bad-chars (list->char-set (map car char-encoding))))
    
    ;; Check to see if str contains one of the characters in charset,
    ;; from the position i onward. If so, return that character's index.
    ;; otherwise, return #f
    (define (index-cset str i charset)
      (string-index str charset i))

    ;; The body of the function
    (lambda (str port)
      (let ((bad-pos (index-cset str 0 bad-chars)))
        (if (not bad-pos)
            (display str port) ;str had all good chars
            (let loop
              ((from 0)
               (to bad-pos))
              (cond
                ((>= from
                     (string-length str))
                 *unspecified*)
                ((not to)
                 (display (substring str from
                                     (string-length str)) port))
                (else (let ((quoted-char (cdr (assv (string-ref str to)
                                                    char-encoding)))
                            (new-to (index-cset str
                                                (+ 1 to) bad-chars)))
                        (if (< from to)
                            (display (substring str from to) port))
                        (display quoted-char port)
                        (loop (1+ to) new-to))))))))))

;; Given a string, check to make sure it does not contain characters
;; such as '<' or '&' that require encoding. Return either the original
;; string, or a list of string fragments with special characters
;; replaced by appropriate character entities.

(define string->escaped-xml
  (make-char-quotator '((#\< . "&lt;") (#\> . "&gt;")
                        (#\& . "&amp;")
                        (#\" . "&quot;"))))

;; ====== GGG ======

(define (assoc-ref-or alist key default)
  (let ((x (assoc-ref alist key)))
    (if (not x) default x)))

(define (syscall cmd)
  (let* ((process (open-input-pipe cmd))
         (process-output (get-string-all process)))
    (close-pipe process) process-output))

(define (get-short-commit-sha)
  (syscall "git log --pretty=format:'%h' -n 1"))

(define* (length-for-text text-length)
  (cond
    ((< text-length 4)
     (round (* 17 text-length)))
    ((< text-length 5)
     (round (* 15 text-length)))
    ((< text-length 6)
     (round (* 13 text-length)))
    ((< text-length 7)
     (round (* 12 text-length)))
    ((< text-length 8)
     (round (* 10 text-length)))
    ((< text-length 10)
     (round (* 10 text-length)))
    (else (round (* 9 text-length)))))

(define (mk-readme-vector-image x)
  (let* ((left-length (string-length (assoc-ref x
                                                'left-text)))
         (left-width (length-for-text left-length))
         (left-background (assoc-ref x
                                     'left-background))
         (right-length (string-length (assoc-ref x
                                                 'right-text)))
         (right-width (length-for-text right-length))
         (right-background (assoc-ref x
                                      'right-background))
         (part-separator-width 20)
         (total-width (+ left-width right-width part-separator-width))
         (text-y 17)
         (part-separator-background (assoc-ref x
                                               'right-background))
         (part-separator-x (- left-width 8))
         (right-x left-width)
         (left-font-family (assoc-ref-or x
                                         'left-font-family "sans-serif"))
         (right-font-family (assoc-ref-or x
                                          'right-font-family "sans-serif"))
         (left-font-size (assoc-ref-or x
                                       'left-font-size 12))
         (right-font-size (assoc-ref-or x
                                        'right-font-size 12))
         (height (assoc-ref-or x
                               'height 26))
         (border-radius (assoc-ref-or x
                                      'border-radius 10))
         (left-logo (if (not (assoc-ref x
                                        'left-logo)) ""
                                        (get-string-all (open-input-file (assoc-ref x
                                                                                    'left-logo))))))
    `((svg (@ (id ,(assoc-ref x
                              'id))
              (xmlns "http://www.w3.org/2000/svg")
              (width ,total-width)
              (height ,height)
              (viewBox ,(format #f "0 0 ~a ~a" total-width height)))
           (g
            ,left-logo)
           (g (@ (shape-rendering geometricPrecision))
              (rect (@ (x 0)
                       (width ,left-width)
                       (height ,height)
                       (fill ,left-background)
                       (rx ,border-radius)
                       (ry ,border-radius)) "")
              (rect (@ (x ,part-separator-x)
                       (width ,part-separator-width)
                       (height ,height)
                       (fill ,part-separator-background)
                       (rx 0)
                       (ry 0)) "")
              (rect (@ (x ,right-x)
                       (width ,right-width)
                       (height ,height)
                       (fill ,right-background)
                       (rx ,border-radius)
                       (ry ,border-radius)) ""))
           (g (@ (text-anchor middle))
              (text (@ (fill ,(assoc-ref x
                                         'left-color))
                       (font-size ,left-font-size)
                       (font-family ,left-font-family)
                       (x ,(round (- (/ left-width 2)
                                     (/ left-width 14))))
                       (y ,text-y))
                    ,(assoc-ref x
                                'left-text))
              (text (@ (fill ,(assoc-ref x
                                         'right-color))
                       (font-size ,right-font-size)
                       (font-family ,right-font-family)
                       (x ,(round (+ left-width
                                     (/ left-width 2)
                                     (/ left-width 14))))
                       (y ,text-y))
                    ,(assoc-ref x
                                'right-text)))))))

(define vector-images
  `(((id . pipeline-succeeded) (left-background . "#555")
     (left-text . "pipeline")
     (left-color . "#fff")
     (right-background . "#407430")
     (right-text . "succeeded")
     (right-color . "#fff"))
    ((id . scheme-guile) (left-background . "#555")
     (left-text . "Scheme")
     (left-color . "#fff")
     (left-logo . "resources/svg/gnu-svgrepo-com.svg")
     (right-background . "#deb07a")
     (right-text . "Guile")
     (right-color . "#000"))
    ((id . haskell-ghc910) (left-background "#555")
     (left-text . "Haskell")
     (left-color . "#fff")
     (right-background . "#7851A9")
     (right-text . "GHC 9.10")
     (right-color . "#fff"))
    ((id . gnu-make) (left-background . "#555")
     (left-text . "GNU")
     (left-color . "#fff")
     (right-background . "#bbbbbb")
     (right-text . "Make")
     (right-color . "#000"))
    ((id . gnu-emacs) (left-background . "#555")
     (left-text . "GNU")
     (left-color . "#fff")
     (right-background . "#885997")
     (right-text . "Emacs")
     (right-color . "#fff"))))

(define (main args)
  (display "
>>= starting ggg: guile glyph generator
")
  (display args)
  (newline)
  (map (lambda (vector-image)
         (display (format #f "\n>>= producing dist/~a.svg\n"
                          (assoc-ref vector-image
                                     'id)))
         (with-output-to-file (format #f "dist/~a.svg"
                                      (assoc-ref vector-image
                                                 'id))
           (lambda ()
             (sxml->xml (mk-readme-vector-image vector-image)))))
       vector-images)

  (map (lambda (vector-image)
         (display (format #f "\n>>= producing dist/~a.png\n"
                          (assoc-ref vector-image
                                     'id)))
         (syscall (format #f
                   "convert -quality 100 -density 10000 -background none -resize 1% dist/~a.svg dist/~a.png"
                   (assoc-ref vector-image
                              'id)
                   (assoc-ref vector-image
                              'id)))) vector-images)

  (display "\n>>= ggg is done generating images\n"))

(main (command-line))


