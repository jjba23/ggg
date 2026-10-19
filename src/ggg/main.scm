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
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ggg sxml)
  #:use-module (ggg prelude)
  #:use-module (ggg glyph)
  #:use-module (ggg colors)
  #:use-module (ggg gallery)
  #:use-module (ggg logo)
  #:export (main render-glyphs))

;; The ImageMagick program used for PNG output. The Guix package replaces this
;; definition with an absolute store path.
(define imagemagick-convert
  "convert")

;; Some distributions ship ImageMagick with its SVG delegate disabled by a
;; security policy. Inkscape can rasterize the same files, so it is used as a
;; fallback instead of failing the whole run.
(define inkscape-program
  "inkscape")

;; ====== Resources and configuration ======

(define (find-resources explicit)
  "Return a usable resources directory, or #f."
  (let ((directory (or (and explicit
                            (not (string-null? explicit))
                            explicit)
                       (and (file-exists? "resources") "resources"))))
    (and directory
         (file-exists? directory)
         (canonicalize-path directory))))

(define* (require-resources explicit)
  (let ((resources (find-resources explicit)))
    (unless resources
      (fail "no resources directory found"
            #:hint "Pass --resources PATH (ggg's resources directory), or run ggg from the project root."))
    ;; ggg used to read single-path logos from svg-paths/. Report that clearly
    ;; instead of silently ignoring the files someone still keeps there.
    (let ((legacy (legacy-svg-paths #:resources resources)))
      (unless (null? legacy)
        (fail (format #f "'~a' contains a svg-paths/ directory, which ggg no longer supports"
                      resources)
              #:details (map (lambda (name) (format #f "svg-paths/~a" name)) legacy)
              #:hint "That directory held only the data of a path's \"d\" attribute. Wrap each file in an SVG document at logos/<name>.svg, e.g. <svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path fill=\"#ffffff\" d=\"...\"/></svg>.")))
    (unless (file-exists? (format #f "~a/logos" resources))
      (fail (format #f "'~a' does not look like a ggg resources directory" resources)
            #:hint "It should contain a logos/ directory with one <name>.svg document per logo."))
    resources))

(define* (load-glyphs #:key file with-stdin?)
  "Load the user's glyph configuration, with pointers to what went wrong."
  (if with-stdin?
      (let ((source (get-string-all (current-input-port))))
        (when (string-null? (string-trim-both source))
          (fail "no glyph configuration received on standard input"
                #:hint "Pipe a Scheme configuration into ggg, e.g. cat glyphs.scm | ggg -i -d ./dist."))
        (guard-errors (lambda () (eval-string source))
                      #:label "could not read the glyph configuration from standard input"
                      #:hint "The configuration must be valid Scheme. See glyphs/jjba23.scm for an example."))
      (begin
        (unless file
          (fail "no glyph configuration given"
                #:hint "Use -f/--file PATH, or -i/--stdin to read the configuration from standard input."))
        (unless (file-exists? file)
          (fail (format #f "glyph file not found: ~a" file)
                #:hint "Check the path passed to -f/--file."))
        (let ((path (canonicalize-path file)))
          (guard-errors (lambda () (load path))
                        #:label (format #f "could not load glyph file '~a'" file)
                        #:hint "The file must be valid Scheme and define ggg-glyphs. See glyphs/jjba23.scm for an example."))))
  (let ((glyphs (get-setting 'ggg-glyphs)))
    (unless glyphs
      (fail "the glyph configuration does not define ggg-glyphs"
            #:hint "Start the file with (define-module (ggg config)) and finish it with (define ggg-glyphs (list your-glyph ...))."))
    glyphs))

(define (glyph-files path)
  "The glyph files named by PATH: the file itself, or every *.scm file in it."
  (guard-errors
   (lambda ()
     (unless (file-exists? path)
       (fail (format #f "glyphs path not found: ~a" path)
             #:hint "Pass a glyph file (Scheme) or a directory containing .scm files."))
     (let ((files (if (file-is-directory? path)
                      (map (lambda (name) (format #f "~a/~a" path name))
                           (sort (filter (lambda (name)
                                           (string-suffix? ".scm" name))
                                         (scandir path
                                                  (lambda (name)
                                                    (not (member name '("." ".."))))))
                                 string<?))
                      (list path))))
       (when (null? files)
         (fail (format #f "no .scm glyph files found in '~a'" path)
               #:hint "Pass a file, or a directory that contains at least one .scm file."))
       files))
   #:label (format #f "could not read the glyphs in '~a'" path)
   #:hint "Pass a glyph file (Scheme) or a directory containing .scm files."))

(define* (load-glyph-groups path #:key resources)
  "Load every glyph file named by PATH for the gallery, as (label . glyphs)
pairs. The badges are validated exactly like a normal render."
  (map (lambda (file)
         (let ((glyphs (load-glyphs #:file file #:with-stdin? #f)))
           (let ((problems (validate-glyphs glyphs #:resources resources)))
             (when (pair? problems)
               (report-problems problems)))
           (cons (basename file) glyphs)))
       (glyph-files path)))

(define (report-problems problems)
  (let ((count (length problems)))
    (log-error "the glyph configuration has ~a problem~a"
               count (if (= count 1) "" "s"))
    (for-each (lambda (problem)
                (display (format #f "         - ~a\n" problem)
                         (current-error-port)))
              problems)
    (display "\n         Hint: fix the settings above, then run ggg again.\n         Use `ggg --list-colors` and `ggg --list-logos` to see valid names.\n"
             (current-error-port))
    (exit 1)))

;; ====== Rendering ======

(define* (prepare-destination destination #:key keep?)
  (if keep?
      (begin
        (log-info "\tkeeping the files already in: ~a" destination)
        (guard-errors (lambda () (ensure-directory destination))
                      #:label (format #f "could not create destination directory '~a'" destination)
                      #:hint "Check that the path is a directory you can write to."))
      (begin
        (when (file-exists? destination)
          (log-info "\tclearing destination directory: ~a" destination)
          (guard-errors (lambda () (delete-directory-tree destination))
                        #:label (format #f "could not clear destination directory '~a'" destination)
                        #:hint "Check that you have write permission for it."))
        (log-info "\tcreating destination directory: ~a" destination)
        (guard-errors (lambda () (ensure-directory destination))
                      #:label (format #f "could not create destination directory '~a'" destination)
                      #:hint "Check that the path is a directory you can write to."))))

(define* (write-svg glyph #:key resources destination)
  (let* ((id (glyph-id glyph))
         (path (format #f "~a/~a.svg" destination id))
         (image (mk-glyph glyph #:resources resources)))
    (log-info "\tproducing ~a" path)
    (guard-errors (lambda ()
                    (with-output-to-file path
                      (lambda ()
                        (sxml->xml image))))
                  #:label (format #f "could not write '~a'" path)
                  #:hint "Check that the destination directory is writable.")))

(define* (print-svg glyph #:key resources)
  (newline)
  (newline)
  (sxml->xml (mk-glyph glyph #:resources resources)
             (current-output-port))
  (newline)
  (newline))

(define (run-program program arguments)
  "Run PROGRAM with ARGUMENTS, returning its wait status, or #f when it is
missing or cannot be executed."
  (catch 'system-error
    (lambda () (apply system* program arguments))
    (lambda (key . rest) #f)))

(define* (rasterize svg png)
  "Write PNG from SVG. Return the name of the renderer that did it, or #f."
  (define (attempt program arguments renderer)
    (let ((status (run-program program arguments)))
      (and status (zero? status) renderer)))
  (or (attempt imagemagick-convert
               (list "-quality" "100"
                     "-density" "1000"
                     "-background" "none"
                     "-resize" "10%"
                     svg png)
               'ImageMagick)
      (attempt inkscape-program
               (list "--export-type=png"
                     ;; Inkscape works in 96 DPI, so 100 DPI matches the
                     ;; 1000-density/10%-resize ImageMagick pipeline above.
                     "--export-dpi=100"
                     (format #f "--export-filename=~a" png)
                     svg)
               'Inkscape)))

(define* (convert-svg-to-png glyph #:key destination)
  (let* ((id (glyph-id glyph))
         (svg (format #f "~a/~a.svg" destination id))
         (png (format #f "~a/~a.png" destination id))
         (renderer (guard-errors (lambda () (rasterize svg png))
                                 #:label (format #f "could not rasterize '~a'" svg)
                                 #:hint "Re-run without -c/--convert to generate only SVGs.")))
    (unless renderer
      ;; Do not leave a half-written PNG behind when both programs failed.
      (when (file-exists? png)
        (delete-file png))
      (fail (format #f "could not convert '~a' to PNG" svg)
            #:hint "Neither ImageMagick (convert) nor Inkscape could render it. ImageMagick's security policy may block SVG input; install Inkscape or enable the SVG delegate. Re-run without -c/--convert to generate only SVGs."))
    (log-info "\tproducing ~a (~a)" png renderer)))

(define* (render-glyphs #:key
                        file
                        resources
                        destination
                        with-stdin?
                        with-convert?
                        with-stdout?
                        with-keep?)
  (set! resources (require-resources resources))

  (if with-stdin?
      (unless with-stdout?
        (log-info "\tloading glyphs from stdin"))
      (unless with-stdout?
        (log-info "\tloading glyphs file: ~a" file)))

  (let* ((glyphs (load-glyphs #:file file #:with-stdin? with-stdin?))
         (problems (validate-glyphs glyphs #:resources resources)))
    ;; Validate everything before touching the destination directory, so a typo
    ;; never leaves a half-generated dist/ behind.
    (when (pair? problems)
      (report-problems problems))

    (unless with-stdout?
      (prepare-destination destination #:keep? with-keep?)
      (log-info "+-----------------------------------------------+")
      (log-info "Start producing SVG images"))

    (if with-stdout?
        (for-each (lambda (glyph)
                    (print-svg glyph #:resources resources))
                  glyphs)
        (for-each (lambda (glyph)
                    (write-svg glyph
                               #:resources resources
                               #:destination destination))
                  glyphs))

    (when with-convert?
      (log-info "+-----------------------------------------------+")
      (log-info "Start producing PNG images")
      (for-each (lambda (glyph)
                  (convert-svg-to-png glyph #:destination destination))
                glyphs))

    (unless with-stdout?
      (log-info "+-----------------------------------------------+")
      (log-info "GGG is done generating images\n"))))

;; ====== Command line ======

(define short-help
  "GGG: Guile Glyph Generator

USAGE: ggg [OPTIONS]

    -f, --file FILE          glyph configuration (Scheme file)
    -i, --stdin              read the glyph configuration from stdin
    -d, --destination DIR    output directory (default: ./dist)
    -o, --stdout             write SVGs to stdout
    -c, --convert            also write PNGs (ImageMagick or Inkscape)
    -k, --keep               keep the files already in the destination
    -r, --resources DIR      directory containing the logos/ directory
        --list-colors        show every named color, grouped by theme
        --list-logos         show the available logos
        --gallery FILE       write an HTML gallery of every logo
        --glyphs PATH        glyph file or directory to show in --gallery
    -h, --help               show this help

See resources/help.txt or the README for details.\n")

(define (show-help resources)
  (let ((help-file (and resources
                        (format #f "~a/help.txt" resources))))
    (if (and help-file (file-exists? help-file))
        (display (call-with-input-file help-file get-string-all))
        (display short-help))))

(define (print-colors)
  (display "Theme colors, grouped by theme:\n")
  (for-each
   (lambda (theme-colors)
     (let* ((theme (car theme-colors))
            (entries (cdr theme-colors))
            (width (apply max (map (lambda (entry)
                                     (string-length (car entry)))
                                   entries))))
       (newline)
       (display (format #f "~a (~a colors):\n" theme (length entries)))
       (for-each (lambda (entry)
                   (display (format #f "  ~a  ~a\n"
                                    (string-pad-right (car entry) width)
                                    (cdr entry))))
                 entries)))
   (colors-by-theme)))

(define* (print-logos #:key resources)
  (let ((names (logo-names #:resources resources)))
    (if (null? names)
        (display "No logos found in the resources directory.\n")
        (begin
          (display "Available logos:\n")
          (for-each (lambda (name)
                      (display (format #f "  ~a\n" name)))
                    names)))))

(define* (main #:key (args (command-line)))
  (let* ((option-spec '((destination (single-char #\d)
                                     (value #t)
                                     (required? #f))
                        (resources (single-char #\r)
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
                        (keep (single-char #\k)
                              (value #f)
                              (required? #f))
                        (file (single-char #\f)
                              (value #t)
                              (required? #f))
                        (help (single-char #\h)
                              (value #f)
                              (required? #f))
                        (list-colors (value #f)
                                     (required? #f))
                        (list-logos (value #f)
                                    (required? #f))
                        (gallery (value #t)
                                 (required? #f))
                        (glyphs (value #t)
                                (required? #f))))
         (options (catch 'getopt-long
                    (lambda () (getopt-long args option-spec))
                    (lambda (key . args)
                      (fail (format #f "invalid command line: ~a"
                                    (error-detail key args))
                            #:hint "Try 'ggg --help' for usage."))))
         (file (option-ref options 'file #f))
         (resources-option (option-ref options 'resources #f))
         (destination (option-ref options 'destination "./dist"))
         (with-convert? (option-ref options 'convert #f))
         (with-keep? (option-ref options 'keep #f))
         (with-stdout? (option-ref options 'stdout #f))
         (with-stdin? (option-ref options 'stdin #f))
         (with-help? (option-ref options 'help #f))
         (list-colors? (option-ref options 'list-colors #f))
         (list-logos? (option-ref options 'list-logos #f))
         (gallery-file (option-ref options 'gallery #f))
         (glyphs-path (option-ref options 'glyphs #f))
         (resources (find-resources resources-option)))

    (when with-help?
      (show-help resources)
      (exit 0))

    (when list-colors?
      (print-colors)
      (exit 0))

    (when list-logos?
      (print-logos #:resources (require-resources resources-option))
      (exit 0))

    (when (and glyphs-path (not gallery-file))
      (fail "--glyphs only makes sense together with --gallery"
            #:hint "Use --gallery FILE --glyphs ./glyphs to include every badge in the gallery."))

    (when gallery-file
      (let* ((resource-directory (require-resources resources-option))
             (glyph-groups (if glyphs-path
                               (load-glyph-groups glyphs-path
                                                  #:resources resource-directory)
                               '())))
        (call-with-values
            (lambda ()
              (write-gallery-page gallery-file
                                  #:resources resource-directory
                                  #:glyph-groups glyph-groups))
          (lambda (badges logos)
            (display (format #f "Wrote a gallery of ~a badge~a and ~a logo~a to ~a\n"
                             badges (if (= badges 1) "" "s")
                             logos (if (= logos 1) "" "s")
                             (canonicalize-path gallery-file))))))
      (exit 0))

    (when (and file with-stdin?)
      (fail "cannot combine --file and --stdin"
            #:hint "Use -f/--file to read a file, or -i/--stdin to read the configuration from a pipe."))

    (unless (or file with-stdin?)
      (fail "no glyph configuration given"
            #:hint "Use -f/--file PATH, or -i/--stdin to read the configuration from standard input."))

    (when (and with-stdout? with-convert?)
      (fail "cannot combine --stdout and --convert"
            #:hint "PNG conversion needs an output directory, so it cannot run with --stdout. Use either -o or -c."))

    (when (and (not with-stdout?)
               (string-null? destination))
      (fail "the destination directory is empty"
            #:hint "Pass a directory with -d/--destination, or use -o/--stdout."))

    (unless with-stdout?
      (log-info "GGG: Guile Glyph Generator"))

    (render-glyphs #:file file
                   #:with-stdin? with-stdin?
                   #:with-stdout? with-stdout?
                   #:with-convert? with-convert?
                   #:with-keep? with-keep?
                   #:resources (require-resources resources-option)
                   #:destination destination)))
