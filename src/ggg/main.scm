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

(define* (render-glyphs #:key file
                        resources-dir
                        destination-dir
                        with-stdin?
                        with-convert?
                        with-stdout?)
  (let* ((clean-dist-cmd (format #f "rm -rfv ~a" destination-dir))
         (mkdir-dist-cmd (format #f "mkdir -p ~a" destination-dir)))
    (if with-stdin?
        ;; Read from stdin
        (begin
          (log-info "\tloading glyphs from stdin")
          (eval-string (get-string-all (current-input-port))))
        ;; Read from file
        (begin
          (log-info "\tloading glyphs file: ~a" file)
          (load file)))

    ;; Prepare dist
    (log-info "\texecuting: ~a" clean-dist-cmd)
    (syscall clean-dist-cmd)
    (log-info "\texecuting: ~a" mkdir-dist-cmd)
    (syscall mkdir-dist-cmd)

    (log-info "+-----------------------------------------------+")
    (log-info "Start producing SVG images")
    (define produce-svg-to-file
      (lambda (vector-image)
        (log-info "\tproducing ~a/~a.svg" destination-dir
                  (assoc-ref vector-image
                             'id))

        (with-output-to-file (format #f "~a/~a.svg" destination-dir
                                     (assoc-ref vector-image
                                                'id))
          (lambda ()
            (sxml->xml (mk-glyph vector-image
                                 #:resources-dir resources-dir))))))

    (define produce-svg-to-stdout
      (lambda (vector-image)
        (newline)
        (newline)
        (sxml->xml (mk-glyph vector-image
                                      #:resources-dir resources-dir)
                   (current-output-port))
        (newline)
        (newline)))

    (if with-stdout?
        (for-each produce-svg-to-stdout
                  (get-setting 'ggg-glyphs))
        (for-each produce-svg-to-file
                  (get-setting 'ggg-glyphs)))

    (when with-convert?
      (log-info "+-----------------------------------------------+")
      (log-info "Start producing PNG images")
      (map (lambda (vector-image)
             (log-info "\tproducing ~a/~a.png" destination-dir
                       (assoc-ref vector-image
                                  'id))
             (syscall (format #f
                       "convert -quality 100 -density 1000 -background none -resize 10% ~a/~a.svg ~a/~a.png"
                       destination-dir
                       (assoc-ref vector-image
                                  'id)
                       destination-dir
                       (assoc-ref vector-image
                                  'id))))
           (get-setting 'ggg-glyphs)))

    (log-info "+-----------------------------------------------+")
    (log-info "GGG is done generating images\n")))

(define* (main #:key (args (command-line)))
  
  (let* ((option-spec '((destination (single-char #\d)
                                     (value #t)
                                     (required? #f))
                        (resources-dir (single-char #\r)
                                       (value #t))
                        (stdin (single-char #\i)
                               (value #f)
                               (required? #f))
                        (stdout (single-char #\o)
                                (value #f)
                                (required? #f))
                        (convert (single-char #\c)
                                 (value #f)
                                 (required? #f))
                        (file (single-char #\f)
                              (value #t)
                              (required? #f))))
         (options (getopt-long args option-spec))
         (file (option-ref options
                           'file #f))
         (resources-dir (option-ref options
                                    'resources-dir #f))
         (destination-dir (option-ref options
                                      'destination "./dist")))
    (log-info "GGG: Guile Glyph Generator")
    (render-glyphs #:file file
                   #:with-stdin? (option-ref options
                                             'stdin #f)
                   #:with-stdout? (option-ref options
                                              'stdout #f)
                   #:with-convert? (option-ref options
                                               'convert #f)
                   #:resources-dir resources-dir
                   #:destination-dir destination-dir)))

