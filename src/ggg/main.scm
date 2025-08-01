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

(define-module (ggg main)
  #:declarative? #f
  #:use-module (ice-9 format)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 match)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 getopt-long)
  #:use-module (ggg sxml)
  #:use-module (ggg prelude)
  #:use-module (ggg glyph)
  #:export (main render-glyphs))

(define* (render-glyphs #:key glyph-file resources-dir output-dir)
  (let* ((clean-dist-cmd (format #f "rm -rfv ~a" output-dir))
         (mkdir-dist-cmd (format #f "mkdir -p ~a" output-dir)))
    (log-info "executing: ~a" clean-dist-cmd)
    (syscall clean-dist-cmd)

    (log-info "executing: ~a" mkdir-dist-cmd)
    (syscall mkdir-dist-cmd)

    (log-info "Start rendering glyphs")
    (log-info "\tglyph-file: ~a" glyph-file)

    ;; load user-supplied Scheme file
    (load glyph-file)
    (use-modules (ggg config))

    (log-info "+-----------------------------------------+")
    (log-info "Start producing SVG images")
    (map (lambda (vector-image)
           (log-info "\tproducing ~a/~a.svg" output-dir
                     (assoc-ref vector-image
                                'id))

           (with-output-to-file (format #f "~a/~a.svg" output-dir
                                        (assoc-ref vector-image
                                                   'id))
             (lambda ()
               (sxml->xml (mk-glyph vector-image
                                    #:resources-dir resources-dir)))))
         (get-setting 'ggg-readme-vector-images))

    (log-info "+-----------------------------------------+")
    (log-info "Start producing PNG images")
    (map (lambda (vector-image)
           (log-info "\tproducing ~a/~a.png" output-dir
                     (assoc-ref vector-image
                                'id))
           (syscall (format #f
                     "convert -quality 100 -density 1000 -background none -resize 10% ~a/~a.svg ~a/~a.png"
                     output-dir
                     (assoc-ref vector-image
                                'id)
                     output-dir
                     (assoc-ref vector-image
                                'id))))
         (get-setting 'ggg-readme-vector-images))

    (log-info "+-----------------------------------------+")
    (log-info "GGG is done generating images\n")))

(define* (main #:key (args (command-line)))
  
  (let* ((option-spec '((output-dir (single-char #\o)
                                    (value #t))
                        (resources-dir (single-char #\r)
                                       (value #t))
                        (glyph-file (single-char #\g)
                                    (value #t)
                                    (required? #t))))
         (options (getopt-long args option-spec))
         (glyph-file (option-ref options
                                 'glyph-file #f))
         (resources-dir (option-ref options
                                    'resources-dir #f))
         (output-dir (option-ref options
                                 'output-dir "./dist")))
    (log-info "GGG: Guile Glyph Generator")
    (render-glyphs #:glyph-file glyph-file
                   #:resources-dir resources-dir
                   #:output-dir output-dir)))

