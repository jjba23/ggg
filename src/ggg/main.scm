
(define-module (ggg main)
  #:declarative? #f
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 textual-ports)
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

(define* (mk-badge #:key left-background
                   left-color
                   left-text
                   right-background
                   right-color
                   right-text
                   id
                   (font-family "sans-serif")
                   (font-size 11)
                   (border-radius 6)
                   (height 24))
  (let* ((left-length (string-length left-text))
         (left-width (round (* 10 left-length)))
         (right-length (string-length right-text))
         (right-width (round (* 10 right-length)))
         (total-width (+ left-width right-width)))
    `((svg (@ (id ,id)
              (xmlns "http://www.w3.org/2000/svg")
              (width ,total-width)
              (height ,height)
              (viewBox ,(format #f "0 0 ~a ~a" total-width height)))
           (g (@ (shape-rendering geometricPrecision))
              (rect (@ (width ,left-width)
                       (height ,height)
                       (fill ,left-background)
                       (rx ,border-radius)
                       (ry ,border-radius)) "")
              (rect (@ (x 56)
                       (width 10)
                       (height ,height)
                       (fill ,right-background)
                       (rx 0)
                       (ry 0)) "")
              (rect (@ (x 60)
                       (width ,right-width)
                       (height ,height)
                       (fill ,right-background)
                       (rx ,border-radius)
                       (ry ,border-radius)) ""))
           (g (@ (text-anchor middle)
                 (font-family ,font-family)
                 (font-size ,font-size))
              (text (@ (fill ,left-color)
                       (x ,(round (- (/ left-width 2)
                                     (/ left-width 10))))
                       (y 16))
                    ,left-text)
              (text (@ (fill ,right-color)
                       (x 92)
                       (y 16))
                    ,right-text)))
      (img (@ (id ,(format #f "~a-img" id))) ""))))

(define (mk-vector-image xs)
  (mk-badge #:id (assoc-ref xs
                            'id)
            #:left-background (assoc-ref xs
                                         'left-background)
            #:left-text (assoc-ref xs
                                   'left-text)
            #:left-color (assoc-ref xs
                                    'left-color)
            #:right-background (assoc-ref xs
                                          'right-background)
            #:right-text (assoc-ref xs
                                    'right-text)
            #:right-color (assoc-ref xs
                                     'right-color)))

(define vector-images
  `(((id . pipeline-success) (left-background . "#444")
     (left-text . "pipeline")
     (left-color . "#fff")
     (right-background . "#407430")
     (right-text . "succeeded")
     (right-color . "#fff"))
    ((id . scheme-guile) (left-background . "#444")
     (left-text . "Scheme")
     (left-color . "#fff")
     (right-background . "#deb07a")
     (right-text . "Guile")
     (right-color . "#000"))

    ))

;;     (gnu-make .
;;               (lambda(id ) (mk-badge
;;                        #:id id
;;                        #:left-background "#444"
;;                        #:left-text "GNU"
;;                        #:left-color "#fff"
;;                        #:right-background "#bbbbbb"
;;                        #:right-text "Make"
;;                        #:right-color "#000")))

;;     (gnu-emacs .
;;                (lambda(id) (mk-badge
;;                        #:id id
;;                        #:left-background "#444"
;;                        #:left-text "GNU"
;;                        #:left-color "#fff"
;;                        #:right-background "#885997"
;;                        #:right-text "Emacs"
;;                        #:right-color "#fff")))
;;     )
;;   )

(define (badges-page)
  `("<!DOCTYPE html>" (div (h1 "GGG: Guile Glyph Generator")
                           (em
                            "Generate SVG images for handy useful glyphs, org/markdown badges and more, from Lisp (Guile Scheme), leveraging web development as well.")
                           (div (@ (style "padding: 1rem;")) "")

                           (script (@ (src "/index.js")) "")
                           (script ,(format #f
                                     "
const vectorImages = [~a]
document.addEventListener('DOMContentLoaded', () => {

  vectorImages.forEach(v => renderSvgToImage(v, false))
})
"
                                     (string-join (map (lambda (x)
                                                         (format #f "'~a'"
                                                                 (symbol->string
                                                                  (assoc-ref x
                                                                   'id))))
                                                       vector-images) ",")))
                           (div ""))))

(define (main args)
  (display args)
  (newline)
  (with-output-to-file "dist/index.html"
    (lambda ()
      (sxml->xml (badges-page)))))

(main (command-line))

