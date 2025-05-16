
(define-module (sigilcraft main)
  #:declarative? #f
  #:use-module (ice-9 getopt-long))

(define (mk-badges)
  `((div
     (h1 "SigilCraft"))))

(define (main args)
  (display args)
  (newline)
  (with-output-to-file "dist/index.html"
    (lambda ()
      (display (mk-badges)))))

(main (command-line))
