;; ggg: guile glyph generator
;;
;; Spdx-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (ggg prelude)
  #:declarative? #t
  #:use-module (ice-9 ftw)
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
  #:export (log-message log
                        log-info
                        log-error
                        fail
                        guard-errors
                        error-detail
                        serialize-style
                        assoc-ref-or
                        get-setting
                        syscall
                        ensure-directory
                        delete-directory-tree
                        suggest-similar
                        safe-filename?
                        lookup))

(define preferred-strftime-format
  (make-parameter "%Y-%m-%d %H:%M:%S%z"))

(define (log-message msg . maybe-port)
  (let ((port (if (null? maybe-port)
                  (current-output-port)
                  (car maybe-port))))
    (display (format #f "\n\x1b[1m~a\x1b[0m" msg) port)))

(define (log msg . args)
  (log-message (apply format
                      (append (list #f msg) args))))

(define (log-info msg . args)
  (log-message (format #f "[INFO][~a] ~a"
                       (strftime (preferred-strftime-format)
                                 (localtime (current-time)))
                       (apply format
                              (append (list #f msg) args)))))

(define (log-error msg . args)
  (log-message (format #f "[ERROR][~a] ~a\n"
                       (strftime (preferred-strftime-format)
                                 (localtime (current-time)))
                       (apply format
                              (append (list #f msg) args)))
               (current-error-port)))

(define* (fail message
               #:key
               hint
               (details '())
               (exit-code 1))
  "Report an actionable error message on stderr and exit with EXIT-CODE.
Unlike a raw Guile backtrace this points the user at what to change."
  (log-error "~a" message)
  (for-each (lambda (detail)
              (display (format #f "         - ~a\n" detail)
                       (current-error-port)))
            details)
  (when hint
    (display (format #f "\n         Hint: ~a\n" hint)
             (current-error-port)))
  (exit exit-code))

(define (error-detail key args)
  "A short, human-readable description of a caught exception."
  (cond
    ((eq? key 'system-error)
     (let* ((data (find list? args))
            (errno (and (list? data) (car (reverse data)))))
       (format #f "~a~a"
               (if (and (list? data) (string? (car data)))
                   (format #f "~a: " (car data))
                   "")
               (if (and (integer? errno) (not (zero? errno)))
                   (strerror errno)
                   "system error"))))
    (else
     (let ((template (find (lambda (arg)
                             (and (string? arg)
                                  (string-contains arg "~")))
                           args))
           (irritants (find list? args)))
       (cond
         ((and template irritants)
          (catch #t
            (lambda () (apply format #f template irritants))
            (lambda (k . a) template)))
         (template template)
         (else (or (find string? args)
                   (format #f "~a" key))))))))

(define* (guard-errors thunk
                       #:key
                       (label "unexpected error")
                       hint)
  "Run THUNK, turning any exception into a clean, actionable error message.
Exits (quit) requests are passed through so ggg can shut down normally."
  (catch #t
    thunk
    (lambda (key . args)
      (if (eq? key 'quit)
          (apply throw key args)
          (fail (format #f "~a: ~a" label (error-detail key args))
                #:hint hint)))))

(define (serialize-style alist)
  (string-join (map (lambda (p)
                      (format #f "~a: ~a"
                              (car p)
                              (cdr p))) alist) ";"))

(define (assoc-ref-or alist key default)
  (let ((x (assoc-ref alist key)))
    (if (not x) default x)))

(define (lookup alist key)
  "Like assoc-ref, but never throws on malformed entries."
  (if (not (list? alist))
      #f
      (let ((entry (find (lambda (e)
                           (and (pair? e) (eq? (car e) key)))
                         alist)))
        (and entry (cdr entry)))))

(define (syscall cmd)
  (let* ((process (open-input-pipe cmd))
         (process-output (get-string-all process)))
    (close-pipe process) process-output))

(define (ensure-directory path)
  "Create PATH and any missing parents, like mkdir -p."
  (unless (file-exists? path)
    (let ((parent (dirname path)))
      (unless (or (string=? parent path)
                  (string=? parent "."))
        (ensure-directory parent)))
    (catch 'system-error
      (lambda () (mkdir path))
      (lambda (key proc errno args)
        (unless (file-exists? path)
          (fail (format #f "could not create directory '~a'" path)
                #:hint "Check that you have write permission for the parent directory."))))))

(define (delete-directory-tree path)
  "Recursively delete PATH without invoking a shell."
  (when (file-exists? path)
    (if (file-is-directory? path)
        (begin
          (for-each (lambda (child)
                      (delete-directory-tree
                       (string-append path "/" child)))
                    (scandir path
                             (lambda (name)
                               (not (member name '("." ".."))))))
          (rmdir path))
        (delete-file path))))

(define (safe-filename? value)
  "True when VALUE can be used as a badge id and therefore as a file name."
  (and (string? value)
       (not (string-null? value))
       (not (string=? value "."))
       (not (string=? value ".."))
       (string-every (lambda (c)
                       (or (char-alphabetic? c)
                           (char-numeric? c)
                           (memv c '(#\- #\_ #\. #\+))))
                     value)))

(define (edit-distance a b)
  "Levenshtein distance between strings A and B."
  (let* ((la (string-length a))
         (lb (string-length b))
         (previous (list->vector (iota (+ lb 1))))
         (current (make-vector (+ lb 1) 0)))
    (do ((i 1 (+ i 1)))
        ((> i la) (vector-ref previous lb))
      (vector-set! current 0 i)
      (do ((j 1 (+ j 1)))
          ((> j lb))
        (let ((cost (if (char=? (string-ref a (- i 1))
                                (string-ref b (- j 1)))
                        0 1)))
          (vector-set! current j
                       (min (+ (vector-ref previous j) 1)
                            (+ (vector-ref current (- j 1)) 1)
                            (+ (vector-ref previous (- j 1)) cost)))))
      (let ((swap previous))
        (set! previous current)
        (set! current swap)))))

(define* (suggest-similar needle candidates #:key (max-distance 2))
  "Return the candidate closest to NEEDLE within MAX-DISTANCE, or #f."
  (let* ((needle (string-downcase (format #f "~a" needle)))
         (scored (filter (lambda (candidate)
                           (<= (cdr candidate) max-distance))
                         (map (lambda (candidate)
                                (cons candidate
                                      (edit-distance
                                       needle
                                       (string-downcase
                                        (format #f "~a" candidate)))))
                              candidates))))
    (and (pair? scored)
         (car (car (sort scored
                         (lambda (a b) (< (cdr a) (cdr b)))))))))

(define-syntax-rule (get-setting setting)
  "Get a setting for ggg, from glyph file."
  (let* ((val (module-variable (resolve-module '(ggg config)) setting)))
    (catch #t
           (lambda ()
             (variable-ref val))
           (lambda (key . args)
             #f))))
