
(define-module (sigilcraft main)
  #:declarative? #f
  #:use-module (ice-9 getopt-long)
  #:use-module (sxml simple))

(define (mk-badges)
  `((div
     (h1 "SigilCraft"))))

(define (main args)
  (display args)
  (newline)
  (with-output-to-file "dist/index.html"
    (lambda ()
      (sxml->xml (mk-badges)))))

(main (command-line))
