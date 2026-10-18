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

;; Commentary:
;;
;; A showcase of the logo library: one badge for each of the most popular
;; logos in resources/logos/, grouped by what the project is.
;;
;;   ggg --file ./glyphs/showcase.scm --destination ./dist --keep
;;
;; --keep is needed because ggg clears the destination directory by default,
;; which would remove the badges produced from glyphs/jjba23.scm. `maak run`
;; renders both files into ./dist, and `maak showcase` renders only this one.

(define-module (ggg config)
  #:declarative? #t)

;; ====== Helpers ======

(define (hex-channel digits start)
  (string->number (substring digits start (+ start 2)) 16))

(define (expand-hex hex)
  "The digits of HEX as six characters, so #fff and #ffffff read alike."
  (let ((digits (substring hex 1)))
    (if (= (string-length digits) 3)
        (string-join (map (lambda (digit)
                            (string digit digit))
                          (string->list digits))
                     "")
        digits)))

(define (channel-luminance value)
  (let ((scaled (/ value 255.0)))
    (if (<= scaled 0.03928)
        (/ scaled 12.92)
        (expt (/ (+ scaled 0.055) 1.055) 2.4))))

(define (relative-luminance hex)
  "The WCAG relative luminance of HEX, between 0 and 1."
  (let ((digits (expand-hex hex)))
    (+ (* 0.2126 (channel-luminance (hex-channel digits 0)))
       (* 0.7152 (channel-luminance (hex-channel digits 2)))
       (* 0.0722 (channel-luminance (hex-channel digits 4))))))

(define (ink hex)
  "Black or white, whichever contrasts more with HEX.
0.179 is the luminance at which both have the same contrast ratio."
  (if (> (relative-luminance hex) 0.179) 'black 'white))

(define (badge id label logo category background)
  "A two-section badge: the logo with LABEL, then CATEGORY on BACKGROUND."
  `((sections ((background . badge-gray)
               (text . ,label)
               (color . white)
               (logo . ,logo))
              ((background . ,background)
               (text . ,category)
               (color . ,(ink background))))
    (id . ,id)))

;; ====== Languages ======

(define glyph-python
  (badge 'python "Python" 'python "language" "#3776AB"))

(define glyph-javascript
  (badge 'javascript "JavaScript" 'javascript "language" "#F7DF1E"))

(define glyph-typescript
  (badge 'typescript "TypeScript" 'typescript "language" "#3178C6"))

(define glyph-go
  (badge 'go "Go" 'go "language" "#00ADD8"))

(define glyph-swift
  (badge 'swift "Swift" 'swift "language" "#F05138"))

(define glyph-cplusplus
  (badge 'cplusplus "C++" 'cplusplus "language" "#00599C"))

(define glyph-dart
  (badge 'dart "Dart" 'dart "language" "#0175C2"))

(define glyph-elixir
  (badge 'elixir "Elixir" 'elixir "language" "#4B275F"))

(define glyph-erlang
  (badge 'erlang "Erlang" 'erlang "language" "#A90533"))

(define glyph-lua
  (badge 'lua "Lua" 'lua "language" "#2C2D72"))

(define glyph-julia
  (badge 'julia "Julia" 'julia "language" "#9558B2"))

(define glyph-perl
  (badge 'perl "Perl" 'perl "language" "#39457E"))

(define glyph-ocaml
  (badge 'ocaml "OCaml" 'ocaml "language" "#EC6A00"))

(define glyph-crystal
  (badge 'crystal "Crystal" 'crystal "language" "#000000"))

(define glyph-nim
  (badge 'nim "Nim" 'nim "language" "#FFE953"))

;; ====== Web frameworks and tools ======

(define glyph-react
  (badge 'react "React" 'react "framework" "#61DAFB"))

(define glyph-svelte
  (badge 'svelte "Svelte" 'svelte "framework" "#FF3E00"))

(define glyph-astro
  (badge 'astro "Astro" 'astro "framework" "#FF5D01"))

(define glyph-nextjs
  (badge 'nextjs "Next.js" 'nextdotjs "framework" "#000000"))

(define glyph-nuxt
  (badge 'nuxt "Nuxt" 'nuxt "framework" "#00DC82"))

(define glyph-vite
  (badge 'vite "Vite" 'vite "bundler" "#646CFF"))

(define glyph-tailwindcss
  (badge 'tailwindcss "Tailwind CSS" 'tailwindcss "css" "#06B6D4"))

(define glyph-bootstrap
  (badge 'bootstrap "Bootstrap" 'bootstrap "css" "#7952B3"))

(define glyph-html5
  (badge 'html5 "HTML5" 'html5 "web" "#E34F26"))

(define glyph-markdown
  (badge 'markdown "Markdown" 'markdown "docs" "#000000"))

(define glyph-graphql
  (badge 'graphql "GraphQL" 'graphql "api" "#E10098"))

(define glyph-htmx
  (badge 'htmx "htmx" 'htmx "web" "#3366CC"))

(define glyph-django
  (badge 'django "Django" 'django "framework" "#092E20"))

(define glyph-fastapi
  (badge 'fastapi "FastAPI" 'fastapi "framework" "#009688"))

(define glyph-flask
  (badge 'flask "Flask" 'flask "framework" "#000000"))

(define glyph-laravel
  (badge 'laravel "Laravel" 'laravel "framework" "#FF2D20"))

(define glyph-springboot
  (badge 'springboot "Spring Boot" 'springboot "framework" "#6DB33F"))

(define glyph-flutter
  (badge 'flutter "Flutter" 'flutter "framework" "#02569B"))

(define glyph-electron
  (badge 'electron "Electron" 'electron "framework" "#47848F"))

;; ====== Data and infrastructure ======

(define glyph-postgresql
  (badge 'postgresql "PostgreSQL" 'postgresql "database" "#4169E1"))

(define glyph-mysql
  (badge 'mysql "MySQL" 'mysql "database" "#4479A1"))

(define glyph-mariadb
  (badge 'mariadb "MariaDB" 'mariadb "database" "#003545"))

(define glyph-sqlite
  (badge 'sqlite "SQLite" 'sqlite "database" "#003B57"))

(define glyph-mongodb
  (badge 'mongodb "MongoDB" 'mongodb "database" "#47A248"))

(define glyph-redis
  (badge 'redis "Redis" 'redis "database" "#FF4438"))

(define glyph-clickhouse
  (badge 'clickhouse "ClickHouse" 'clickhouse "database" "#FFCC01"))

(define glyph-duckdb
  (badge 'duckdb "DuckDB" 'duckdb "database" "#FFF000"))

(define glyph-elasticsearch
  (badge 'elasticsearch "Elasticsearch" 'elasticsearch "search" "#005571"))

(define glyph-prisma
  (badge 'prisma "Prisma" 'prisma "orm" "#2D3748"))

(define glyph-supabase
  (badge 'supabase "Supabase" 'supabase "backend" "#3FCF8E"))

(define glyph-kubernetes
  (badge 'kubernetes "Kubernetes" 'kubernetes "containers" "#326CE5"))

(define glyph-podman
  (badge 'podman "Podman" 'podman "containers" "#892CA0"))

(define glyph-terraform
  (badge 'terraform "Terraform" 'terraform "infrastructure" "#844FBA"))

(define glyph-ansible
  (badge 'ansible "Ansible" 'ansible "infrastructure" "#EE0000"))

(define glyph-nginx
  (badge 'nginx "NGINX" 'nginx "server" "#009639"))

(define glyph-apache
  (badge 'apache "Apache" 'apache "server" "#D22128"))

(define glyph-rabbitmq
  (badge 'rabbitmq "RabbitMQ" 'rabbitmq "queue" "#FF6600"))

;; ====== Version control, cloud and CI ======

(define glyph-github
  (badge 'github "GitHub" 'github "git" "#181717"))

(define glyph-gitlab
  (badge 'gitlab "GitLab" 'gitlab "git" "#FC6D26"))

(define glyph-gitea
  (badge 'gitea "Gitea" 'gitea "git" "#609926"))

(define glyph-githubactions
  (badge 'githubactions "GitHub Actions" 'githubactions "ci" "#2088FF"))

(define glyph-circleci
  (badge 'circleci "CircleCI" 'circleci "ci" "#343434"))

(define glyph-vercel
  (badge 'vercel "Vercel" 'vercel "cloud" "#000000"))

(define glyph-netlify
  (badge 'netlify "Netlify" 'netlify "cloud" "#00C7B7"))

(define glyph-cloudflare
  (badge 'cloudflare "Cloudflare" 'cloudflare "cloud" "#F38020"))

(define glyph-googlecloud
  (badge 'googlecloud "Google Cloud" 'googlecloud "cloud" "#4285F4"))

(define glyph-firebase
  (badge 'firebase "Firebase" 'firebase "cloud" "#FFCA28"))

;; ====== Observability ======

(define glyph-grafana
  (badge 'grafana "Grafana" 'grafana "metrics" "#F46800"))

(define glyph-prometheus
  (badge 'prometheus "Prometheus" 'prometheus "metrics" "#E6522C"))

(define glyph-sentry
  (badge 'sentry "Sentry" 'sentry "errors" "#362D59"))

(define glyph-datadog
  (badge 'datadog "Datadog" 'datadog "monitoring" "#632CA6"))

;; ====== Operating systems and desktops ======

(define glyph-ubuntu
  (badge 'ubuntu "Ubuntu" 'ubuntu "os" "#E95420"))

(define glyph-archlinux
  (badge 'archlinux "Arch Linux" 'archlinux "os" "#1793D1"))

(define glyph-opensuse
  (badge 'opensuse "openSUSE" 'opensuse "os" "#73BA25"))

(define glyph-freebsd
  (badge 'freebsd "FreeBSD" 'freebsd "os" "#AB2B28"))

(define glyph-openbsd
  (badge 'openbsd "OpenBSD" 'openbsd "os" "#F2CA30"))

(define glyph-alpinelinux
  (badge 'alpinelinux "Alpine Linux" 'alpinelinux "os" "#0D597F"))

(define glyph-gnome
  (badge 'gnome "GNOME" 'gnome "desktop" "#4A86CF"))

(define glyph-kde
  (badge 'kde "KDE" 'kde "desktop" "#1D99F3"))

(define glyph-xfce
  (badge 'xfce "Xfce" 'xfce "desktop" "#2284F2"))

(define glyph-wayland
  (badge 'wayland "Wayland" 'wayland "desktop" "#FFBC00"))

;; ====== Editors, IDEs and shells ======

(define glyph-vim
  (badge 'vim "Vim" 'vim "editor" "#019733"))

(define glyph-helix
  (badge 'helix "Helix" 'helix "editor" "#6A5ACD"))

(define glyph-sublimetext
  (badge 'sublimetext "Sublime Text" 'sublimetext "editor" "#FF9800"))

(define glyph-zed
  (badge 'zed "Zed" 'zedindustries "editor" "#084CCF"))

(define glyph-intellijidea
  (badge 'intellijidea "IntelliJ IDEA" 'intellijidea "ide" "#000000"))

(define glyph-tmux
  (badge 'tmux "tmux" 'tmux "terminal" "#1BB91F"))

(define glyph-zsh
  (badge 'zsh "Zsh" 'zsh "shell" "#F15A24"))

(define glyph-gnubash
  (badge 'gnubash "Bash" 'gnubash "shell" "#4EAA25"))

(define glyph-fishshell
  (badge 'fishshell "fish" 'fishshell "shell" "#4B8BBE"))

(define glyph-nushell
  (badge 'nushell "Nushell" 'nushell "shell" "#4E9906"))

;; ====== AI and data science ======

(define glyph-huggingface
  (badge 'huggingface "Hugging Face" 'huggingface "ai" "#FFD21E"))

(define glyph-pytorch
  (badge 'pytorch "PyTorch" 'pytorch "ai" "#EE4C2C"))

(define glyph-tensorflow
  (badge 'tensorflow "TensorFlow" 'tensorflow "ai" "#FF6F00"))

(define glyph-ollama
  (badge 'ollama "Ollama" 'ollama "ai" "#000000"))

(define glyph-jupyter
  (badge 'jupyter "Jupyter" 'jupyter "notebook" "#F37626"))

(define glyph-numpy
  (badge 'numpy "NumPy" 'numpy "science" "#013243"))

(define glyph-pandas
  (badge 'pandas "pandas" 'pandas "science" "#150458"))

;; ====== Testing and build tooling ======

(define glyph-jest
  (badge 'jest "Jest" 'jest "testing" "#C21325"))

(define glyph-vitest
  (badge 'vitest "Vitest" 'vitest "testing" "#6E9F18"))

(define glyph-cypress
  (badge 'cypress "Cypress" 'cypress "testing" "#17202C"))

(define glyph-pytest
  (badge 'pytest "pytest" 'pytest "testing" "#0A9EDC"))

(define glyph-eslint
  (badge 'eslint "ESLint" 'eslint "linting" "#4B32C3"))

(define glyph-prettier
  (badge 'prettier "Prettier" 'prettier "formatting" "#F7B93E"))

(define glyph-esbuild
  (badge 'esbuild "esbuild" 'esbuild "bundler" "#FFCF00"))

(define glyph-npm
  (badge 'npm "npm" 'npm "package" "#CB3837"))

(define glyph-pnpm
  (badge 'pnpm "pnpm" 'pnpm "package" "#F69220"))

(define glyph-bun
  (badge 'bun "Bun" 'bun "runtime" "#FBF0DF"))

(define glyph-deno
  (badge 'deno "Deno" 'deno "runtime" "#70FFAF"))

;; ====== Media, design and notes ======

(define glyph-blender
  (badge 'blender "Blender" 'blender "3d" "#E87D0D"))

(define glyph-krita
  (badge 'krita "Krita" 'krita "design" "#3DABE0"))

(define glyph-excalidraw
  (badge 'excalidraw "Excalidraw" 'excalidraw "design" "#6965DB"))

(define glyph-obsstudio
  (badge 'obsstudio "OBS Studio" 'obsstudio "video" "#302E31"))

(define glyph-ffmpeg
  (badge 'ffmpeg "FFmpeg" 'ffmpeg "video" "#007808"))

(define glyph-libreoffice
  (badge 'libreoffice "LibreOffice" 'libreoffice "office" "#18A303"))

(define glyph-obsidian
  (badge 'obsidian "Obsidian" 'obsidian "notes" "#7C3AED"))

(define glyph-notion
  (badge 'notion "Notion" 'notion "notes" "#000000"))

(define glyph-wikipedia
  (badge 'wikipedia "Wikipedia" 'wikipedia "docs" "#000000"))

;; ====== Chat and community ======

(define glyph-discord
  (badge 'discord "Discord" 'discord "chat" "#5865F2"))

(define glyph-telegram
  (badge 'telegram "Telegram" 'telegram "chat" "#26A5E4"))

(define glyph-matrix
  (badge 'matrix "Matrix" 'matrix "chat" "#000000"))

(define glyph-reddit
  (badge 'reddit "Reddit" 'reddit "social" "#FF4500"))

(define ggg-glyphs
  ;; Languages
  (list glyph-python
        glyph-javascript
        glyph-typescript
        glyph-go
        glyph-swift
        glyph-cplusplus
        glyph-dart
        glyph-elixir
        glyph-erlang
        glyph-lua
        glyph-julia
        glyph-perl
        glyph-ocaml
        glyph-crystal
        glyph-nim
        ;; Web frameworks and tools
        glyph-react
        glyph-svelte
        glyph-astro
        glyph-nextjs
        glyph-nuxt
        glyph-vite
        glyph-tailwindcss
        glyph-bootstrap
        glyph-html5
        glyph-markdown
        glyph-graphql
        glyph-htmx
        glyph-django
        glyph-fastapi
        glyph-flask
        glyph-laravel
        glyph-springboot
        glyph-flutter
        glyph-electron
        ;; Data and infrastructure
        glyph-postgresql
        glyph-mysql
        glyph-mariadb
        glyph-sqlite
        glyph-mongodb
        glyph-redis
        glyph-clickhouse
        glyph-duckdb
        glyph-elasticsearch
        glyph-prisma
        glyph-supabase
        glyph-kubernetes
        glyph-podman
        glyph-terraform
        glyph-ansible
        glyph-nginx
        glyph-apache
        glyph-rabbitmq
        ;; Version control, cloud and CI
        glyph-github
        glyph-gitlab
        glyph-gitea
        glyph-githubactions
        glyph-circleci
        glyph-vercel
        glyph-netlify
        glyph-cloudflare
        glyph-googlecloud
        glyph-firebase
        ;; Observability
        glyph-grafana
        glyph-prometheus
        glyph-sentry
        glyph-datadog
        ;; Operating systems and desktops
        glyph-ubuntu
        glyph-archlinux
        glyph-opensuse
        glyph-freebsd
        glyph-openbsd
        glyph-alpinelinux
        glyph-gnome
        glyph-kde
        glyph-xfce
        glyph-wayland
        ;; Editors, IDEs and shells
        glyph-vim
        glyph-helix
        glyph-sublimetext
        glyph-zed
        glyph-intellijidea
        glyph-tmux
        glyph-zsh
        glyph-gnubash
        glyph-fishshell
        glyph-nushell
        ;; AI and data science
        glyph-huggingface
        glyph-pytorch
        glyph-tensorflow
        glyph-ollama
        glyph-jupyter
        glyph-numpy
        glyph-pandas
        ;; Testing and build tooling
        glyph-jest
        glyph-vitest
        glyph-cypress
        glyph-pytest
        glyph-eslint
        glyph-prettier
        glyph-esbuild
        glyph-npm
        glyph-pnpm
        glyph-bun
        glyph-deno
        ;; Media, design and notes
        glyph-blender
        glyph-krita
        glyph-excalidraw
        glyph-obsstudio
        glyph-ffmpeg
        glyph-libreoffice
        glyph-obsidian
        glyph-notion
        glyph-wikipedia
        ;; Chat and community
        glyph-discord
        glyph-telegram
        glyph-matrix
        glyph-reddit))
