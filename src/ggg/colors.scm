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

(define-module (ggg colors)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ggg prelude)
  #:export (named-colors
            color-names
            color-error
            resolve-color
            theme-palettes
            theme-names
            theme-color-names
            colors-by-theme))

;; ====== Theme palettes ======

;; ggg borrows the colors of the themes people already live in: Catppuccin,
;; Doom, Dracula, Solarized and Modus.
;;
;; Every color of every palette below becomes a named color of the form
;; "<theme>-<color>", so `catppuccin-mocha-red`, `doom-one-blue`,
;; `dracula-purple`, `solarized-light-base3` and `modus-vivendi-green` all mean
;; exactly one thing. Qualified names keep glyph files readable, unambiguous
;; and easy to re-theme: switching a badge from mocha to latte is a matter of
;; changing the theme prefix, not of remembering hex codes.
;;
;; Raw hex strings (e.g. "#555") keep working for one-off colors, and are
;; validated so a typo is reported instead of producing a broken badge.

;; ---- Catppuccin: https://github.com/catppuccin/catppuccin ----

(define catppuccin-mocha
  '((rosewater . "#f5e0dc")
    (flamingo . "#f2cdcd")
    (pink . "#f5c2e7")
    (mauve . "#cba6f7")
    (red . "#f38ba8")
    (maroon . "#eba0ac")
    (peach . "#fab387")
    (yellow . "#f9e2af")
    (green . "#a6e3a1")
    (teal . "#94e2d5")
    (sky . "#89dceb")
    (sapphire . "#74c7ec")
    (blue . "#89b4fa")
    (lavender . "#b4befe")
    (text . "#cdd6f4")
    (subtext1 . "#bac2de")
    (subtext0 . "#a6adc8")
    (overlay2 . "#9399b2")
    (overlay1 . "#7f849c")
    (overlay0 . "#6c7086")
    (surface2 . "#585b70")
    (surface1 . "#45475a")
    (surface0 . "#313244")
    (base . "#1e1e2e")
    (mantle . "#181825")
    (crust . "#11111b")))

(define catppuccin-macchiato
  '((rosewater . "#f4dbd6")
    (flamingo . "#f0c6c6")
    (pink . "#f5bde6")
    (mauve . "#c6a0f6")
    (red . "#ed8796")
    (maroon . "#ee99a0")
    (peach . "#f5a97f")
    (yellow . "#eed49f")
    (green . "#a6da95")
    (teal . "#8bd5ca")
    (sky . "#91d7e3")
    (sapphire . "#7dc4e4")
    (blue . "#8aadf4")
    (lavender . "#b7bdf8")
    (text . "#cad3f5")
    (subtext1 . "#b8c0e0")
    (subtext0 . "#a5adcb")
    (overlay2 . "#939ab7")
    (overlay1 . "#8087a2")
    (overlay0 . "#6e738d")
    (surface2 . "#5b6078")
    (surface1 . "#494d64")
    (surface0 . "#363a4f")
    (base . "#24273a")
    (mantle . "#1e2030")
    (crust . "#181926")))

(define catppuccin-frappe
  '((rosewater . "#f2d5cf")
    (flamingo . "#eebebe")
    (pink . "#f4b8e4")
    (mauve . "#ca9ee6")
    (red . "#e78284")
    (maroon . "#ea999c")
    (peach . "#ef9f76")
    (yellow . "#e5c890")
    (green . "#a6d189")
    (teal . "#81c8be")
    (sky . "#99d1db")
    (sapphire . "#85c1dc")
    (blue . "#8caaee")
    (lavender . "#babbf1")
    (text . "#c6d0f5")
    (subtext1 . "#b5bfe2")
    (subtext0 . "#a5adce")
    (overlay2 . "#949cbb")
    (overlay1 . "#838ba7")
    (overlay0 . "#737994")
    (surface2 . "#626880")
    (surface1 . "#51576d")
    (surface0 . "#414559")
    (base . "#303446")
    (mantle . "#292c3c")
    (crust . "#232634")))

(define catppuccin-latte
  '((rosewater . "#dc8a78")
    (flamingo . "#dd7878")
    (pink . "#ea76cb")
    (mauve . "#8839ef")
    (red . "#d20f39")
    (maroon . "#e64553")
    (peach . "#fe640b")
    (yellow . "#df8e1d")
    (green . "#40a02b")
    (teal . "#179299")
    (sky . "#04a5e5")
    (sapphire . "#209fb5")
    (blue . "#1e66f5")
    (lavender . "#7287fd")
    (text . "#4c4f69")
    (subtext1 . "#5c5f77")
    (subtext0 . "#6c6f85")
    (overlay2 . "#7c7f93")
    (overlay1 . "#8c8fa1")
    (overlay0 . "#9ca0b0")
    (surface2 . "#acb0be")
    (surface1 . "#bcc0cc")
    (surface0 . "#ccd0da")
    (base . "#eff1f5")
    (mantle . "#e6e9ef")
    (crust . "#dce0e8")))

;; ---- Doom Emacs: https://github.com/doomemacs/themes ----
;;
;; The doom palettes name their shades base0..base8, from the darkest to the
;; lightest, plus bg/fg for the editor background and foreground.

(define doom-one
  '((bg . "#282c34")
    (bg-alt . "#21242b")
    (base0 . "#1b1f24")
    (base1 . "#21242b")
    (base2 . "#282c34")
    (base3 . "#2d3138")
    (base4 . "#353a42")
    (base5 . "#3c4149")
    (base6 . "#484d55")
    (base7 . "#525860")
    (base8 . "#5b6268")
    (fg . "#bbc2cf")
    (fg-alt . "#5b6268")
    (grey . "#3f444a")
    (red . "#ff6c6b")
    (orange . "#da8548")
    (green . "#98be65")
    (teal . "#1abc9c")
    (yellow . "#ecbe7b")
    (blue . "#51afef")
    (dark-blue . "#2257a0")
    (magenta . "#c678dd")
    (violet . "#a9a1e1")
    (cyan . "#46d9ff")
    (dark-cyan . "#5699af")))

(define doom-one-light
  '((bg . "#fafafa")
    (bg-alt . "#efefef")
    (base0 . "#f0f0f0")
    (base1 . "#e7e7e7")
    (base2 . "#dfdfdf")
    (base3 . "#c6c7c7")
    (base4 . "#b9b9b9")
    (base5 . "#b2b2b2")
    (base6 . "#939395")
    (base7 . "#696969")
    (base8 . "#383a42")
    (fg . "#383a42")
    (fg-alt . "#a0a1a7")
    (grey . "#b9b9b9")
    (red . "#e45649")
    (orange . "#da8548")
    (green . "#50a14f")
    (teal . "#1abc9c")
    (yellow . "#c18401")
    (blue . "#4078f2")
    (dark-blue . "#2257a0")
    (magenta . "#a626a4")
    (violet . "#a9a1e1")
    (cyan . "#0184bc")
    (dark-cyan . "#5699af")))

;; ---- Dracula: https://github.com/dracula/dracula-theme ----
;;
;; `dracula-alucard` is Dracula's light counterpart.

(define dracula
  '((background . "#282a36")
    (current-line . "#44475a")
    (foreground . "#f8f8f2")
    (comment . "#6272a4")
    (cyan . "#8be9fd")
    (green . "#50fa7b")
    (orange . "#ffb86c")
    (pink . "#ff79c6")
    (purple . "#bd93f9")
    (red . "#ff5555")
    (yellow . "#f1fa8c")))

(define dracula-alucard
  '((background . "#fffbeb")
    (current-line . "#cfcfde")
    (foreground . "#1f1f1f")
    (comment . "#6c664b")
    (cyan . "#036a96")
    (green . "#14710a")
    (orange . "#a34d14")
    (pink . "#a3144d")
    (purple . "#644ac9")
    (red . "#cb3a2a")
    (yellow . "#846e15")))

;; ---- Solarized: https://ethanschoonover.com/solarized ----
;;
;; Solarized defines one set of sixteen colors; the dark and the light variant
;; differ in which of them carry the background and the foreground.

(define solarized-dark
  '((base03 . "#002b36")
    (base02 . "#073642")
    (base01 . "#586e75")
    (base00 . "#657b83")
    (base0 . "#839496")
    (base1 . "#93a1a1")
    (base2 . "#eee8d5")
    (base3 . "#fdf6e3")
    (yellow . "#b58900")
    (orange . "#cb4b16")
    (red . "#dc322f")
    (magenta . "#d33682")
    (violet . "#6c71c4")
    (blue . "#268bd2")
    (cyan . "#2aa198")
    (green . "#859900")))

(define solarized-light
  '((base03 . "#002b36")
    (base02 . "#073642")
    (base01 . "#586e75")
    (base00 . "#657b83")
    (base0 . "#839496")
    (base1 . "#93a1a1")
    (base2 . "#eee8d5")
    (base3 . "#fdf6e3")
    (yellow . "#b58900")
    (orange . "#cb4b16")
    (red . "#dc322f")
    (magenta . "#d33682")
    (violet . "#6c71c4")
    (blue . "#268bd2")
    (cyan . "#2aa198")
    (green . "#859900")))

;; ---- Modus: https://protesilaos.com/emacs/modus-themes ----
;;
;; Modus names the background and foreground shades bg-main, bg-dim, bg-active,
;; bg-inactive, fg-main, fg-dim, fg-active and fg-alt, and keeps one accent per
;; hue.

(define modus-operandi
  '((bg-main . "#ffffff")
    (bg-dim . "#f0f0f0")
    (bg-active . "#c4c4c4")
    (bg-inactive . "#e0e0e0")
    (fg-main . "#000000")
    (fg-dim . "#595959")
    (fg-active . "#000000")
    (fg-alt . "#a6a6a6")
    (red . "#a60000")
    (green . "#006800")
    (yellow . "#6f5500")
    (blue . "#0031a9")
    (magenta . "#721045")
    (cyan . "#00538b")))

(define modus-vivendi
  '((bg-main . "#000000")
    (bg-dim . "#1e1e1e")
    (bg-active . "#535353")
    (bg-inactive . "#303030")
    (fg-main . "#ffffff")
    (fg-dim . "#989898")
    (fg-active . "#ffffff")
    (fg-alt . "#c6c6c6")
    (red . "#ff5f59")
    (green . "#44bc44")
    (yellow . "#d0bc00")
    (blue . "#2fafff")
    (magenta . "#feacd0")
    (cyan . "#00d3d0")))

;; ====== Named colors ======

;; Every supported theme, in the order ggg lists them, as
;; (theme-name . ((color-name . hex) ...)) pairs.
(define theme-palettes
  (list (cons 'catppuccin-mocha catppuccin-mocha)
        (cons 'catppuccin-macchiato catppuccin-macchiato)
        (cons 'catppuccin-frappe catppuccin-frappe)
        (cons 'catppuccin-latte catppuccin-latte)
        (cons 'doom-one doom-one)
        (cons 'doom-one-light doom-one-light)
        (cons 'dracula dracula)
        (cons 'dracula-alucard dracula-alucard)
        (cons 'solarized-dark solarized-dark)
        (cons 'solarized-light solarized-light)
        (cons 'modus-operandi modus-operandi)
        (cons 'modus-vivendi modus-vivendi)))

(define (theme-qualified-name theme color)
  "The name of COLOR in THEME, e.g. the symbol catppuccin-mocha-red."
  (string->symbol (format #f "~a-~a" theme color)))

;; Every color of every supported theme, as (name . hex) pairs, where NAME is
;; the qualified "<theme>-<color>" form, e.g. (catppuccin-mocha-red . "#f38ba8").
(define named-colors
  (append-map (lambda (theme-palette)
                (let ((theme (car theme-palette)))
                  (map (lambda (color)
                         (cons (theme-qualified-name theme (car color))
                               (cdr color)))
                       (cdr theme-palette))))
              theme-palettes))

(define (theme-names)
  "The supported theme names, in the order ggg lists them."
  (map car theme-palettes))

(define (theme-color-names theme)
  "The qualified names of every color in THEME, in the palette's order."
  (let ((palette (assoc-ref theme-palettes theme)))
    (if palette
        (map (lambda (color) (theme-qualified-name theme (car color)))
             palette)
        '())))

(define (colors-by-theme)
  "Every palette grouped by theme, ready to display: a list of
(theme-name (color-name . hex) ...) pairs, with both names as strings."
  (map (lambda (theme-palette)
         (let ((theme (car theme-palette)))
           (cons (symbol->string theme)
                 (map (lambda (color)
                        (cons (symbol->string
                               (theme-qualified-name theme (car color)))
                              (cdr color)))
                      (cdr theme-palette)))))
       theme-palettes))

(define (color-names)
  "The names accepted in glyph files, sorted alphabetically."
  (sort (map (lambda (entry) (symbol->string (car entry))) named-colors)
        string<?))

(define (hex-color-string? value)
  (and (string-prefix? "#" value)
       (let ((digits (substring value 1)))
         (and (member (string-length digits) '(3 4 6 8))
              (string-every (lambda (c)
                              (or (char-numeric? c)
                                  (char<=? #\a c #\f)
                                  (char<=? #\A c #\F)))
                            digits)))))

(define* (color-error value #:key context)
  "Return a human-readable problem with VALUE, or #f when it is a valid color.
CONTEXT (for example \"glyph 'foo', section 1\") is prepended to the message."
  (define (with-context message)
    (if context
        (format #f "~a: ~a" context message)
        message))
  (cond
    ((symbol? value)
     (if (assoc-ref named-colors value)
         #f
         (with-context
          (let ((suggestion (suggest-similar value (map car named-colors))))
            (format #f "unknown color name '~a'~a"
                    value
                    (if suggestion
                        (format #f "; did you mean '~a'?" suggestion)
                        ""))))))
    ((string? value)
     (let ((trimmed (string-trim-both value)))
       (cond
         ((string-null? trimmed)
          (with-context "empty color value"))
         ((and (string-prefix? "#" trimmed)
               (not (hex-color-string? trimmed)))
          (with-context
           (format #f "invalid hex color ~s (expected #rgb, #rgba, #rrggbb or #rrggbbaa)"
                   value)))
         (else #f))))
    (else
     (with-context
      (format #f "expected a color name (symbol) or a hex string, got ~s"
              value)))))

(define* (resolve-color value #:key context)
  "Resolve VALUE (a theme color name or a hex/CSS color string) to a string.
Exits with a helpful error message when VALUE is not a valid color."
  (let ((problem (color-error value #:context context)))
    (when problem
      (fail problem
            #:hint (format #f "Use a theme color name such as catppuccin-mocha-red (run `ggg --list-colors` for all ~a of them), or a hex string."
                           (length named-colors)))))
  (cond
    ((symbol? value) (assoc-ref named-colors value))
    ((string? value) (string-trim-both value))
    (else value)))
