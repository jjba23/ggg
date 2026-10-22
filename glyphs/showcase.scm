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
;;
;; Every badge labels itself with the Catppuccin palette (the mocha flavor). The
;; second section picks the accent that sits closest to the project's own hue --
;; blue stays blue, orange becomes peach, black brands become the neutral
;; overlay2 -- and the accent's text is `base`, the dark shade that reads well
;; on Catppuccin's light accents. The `Theme variants' group at the end paints
;; its second sections with every other palette ggg knows, so the showcase shows
;; all five theme families side by side, and the `Styles' group that follows it
;; renders the same kind of badge in every style a glyph can ask for. Switching
;; flavor is a matter of changing the theme prefix in `catppuccin' below.

(define-module (ggg config)
  #:declarative? #t)

;; ====== Helpers ======

(define (catppuccin color)
  "The Catppuccin mocha palette color COLOR, as a qualified color name: for
example (catppuccin 'blue) is the symbol catppuccin-mocha-blue. Qualifying the
name here keeps every badge independent of whatever palette is the default."
  (string->symbol (string-append "catppuccin-mocha-" (symbol->string color))))

(define (theme-color theme color)
  "COLOR of the palette THEME, as a qualified color name: (theme-color 'dracula
'purple) is the symbol dracula-purple."
  (string->symbol (string-append (symbol->string theme) "-" (symbol->string color))))

(define* (badge id label logo category accent
                #:key (theme 'catppuccin-mocha) (ink 'base))
  "A two-section badge: the logo with LABEL, then CATEGORY on ACCENT.

The first section always wears Catppuccin mocha, so every label in the library
reads alike; ACCENT is a color of THEME, and INK is the color its text is drawn
in -- the theme's own background shade in every case below."
  `((sections ((background . ,(catppuccin 'surface2))
               (text . ,label)
               (color . ,(catppuccin 'text))
               (logo . ,logo))
              ((background . ,(theme-color theme accent))
               (text . ,category)
               (color . ,(theme-color theme ink))))
    (id . ,id)))

(define* (styled-badge id label logo category accent style
                       #:key (theme 'catppuccin-mocha) (ink 'base))
  "A BADGE that also asks for a visual STYLE, so the showcase can show off
flat, square, shadow, plastic, frosted-glass, material, frutiger and neon."
  (append (badge id label logo category accent #:theme theme #:ink ink)
          `((style . ,style))))

;; ====== Languages ======

(define glyph-python
  (badge 'python "Python" 'python "language" 'blue))

(define glyph-javascript
  (badge 'javascript "JavaScript" 'javascript "language" 'yellow))

(define glyph-typescript
  (badge 'typescript "TypeScript" 'typescript "language" 'blue))

(define glyph-go
  (badge 'go "Go" 'go "language" 'sky))

(define glyph-swift
  (badge 'swift "Swift" 'swift "language" 'peach))

(define glyph-cplusplus
  (badge 'cplusplus "C++" 'cplusplus "language" 'blue))

(define glyph-dart
  (badge 'dart "Dart" 'dart "language" 'blue))

(define glyph-elixir
  (badge 'elixir "Elixir" 'elixir "language" 'mauve))

(define glyph-erlang
  (badge 'erlang "Erlang" 'erlang "language" 'red))

(define glyph-lua
  (badge 'lua "Lua" 'lua "language" 'lavender))

(define glyph-julia
  (badge 'julia "Julia" 'julia "language" 'mauve))

(define glyph-perl
  (badge 'perl "Perl" 'perl "language" 'sapphire))

(define glyph-ocaml
  (badge 'ocaml "OCaml" 'ocaml "language" 'peach))

(define glyph-crystal
  (badge 'crystal "Crystal" 'crystal "language" 'overlay2))

(define glyph-nim
  (badge 'nim "Nim" 'nim "language" 'yellow))

(define glyph-dotnet
  (badge 'dotnet "C#" 'dotnet "language" 'mauve))

(define glyph-fsharp
  (badge 'fsharp "F#" 'fsharp "language" 'sky))

(define glyph-fortran
  (badge 'fortran "Fortran" 'fortran "language" 'lavender))

(define glyph-haskell
  (badge 'haskell "Haskell" 'haskell "language" 'mauve))

(define glyph-java
  (badge 'java "Java" 'java "language" 'red))

(define glyph-kotlin
  (badge 'kotlin "Kotlin" 'kotlin "language" 'mauve))

(define glyph-scala
  (badge 'scala "Scala" 'scala "language" 'red))

(define glyph-webassembly
  (badge 'webassembly "WebAssembly" 'webassembly "language" 'lavender))

;; ====== Web frameworks and tools ======

(define glyph-react
  (badge 'react "React" 'react "framework" 'sky))

(define glyph-svelte
  (badge 'svelte "Svelte" 'svelte "framework" 'peach))

(define glyph-astro
  (badge 'astro "Astro" 'astro "framework" 'peach))

(define glyph-nextjs
  (badge 'nextjs "Next.js" 'nextdotjs "framework" 'overlay2))

(define glyph-nuxt
  (badge 'nuxt "Nuxt" 'nuxt "framework" 'green))

(define glyph-vite
  (badge 'vite "Vite" 'vite "bundler" 'lavender))

(define glyph-tailwindcss
  (badge 'tailwindcss "Tailwind CSS" 'tailwindcss "css" 'sky))

(define glyph-bootstrap
  (badge 'bootstrap "Bootstrap" 'bootstrap "css" 'mauve))

(define glyph-html5
  (badge 'html5 "HTML5" 'html5 "web" 'maroon))

(define glyph-markdown
  (badge 'markdown "Markdown" 'markdown "docs" 'overlay2))

(define glyph-graphql
  (badge 'graphql "GraphQL" 'graphql "api" 'pink))

(define glyph-htmx
  (badge 'htmx "htmx" 'htmx "web" 'blue))

(define glyph-django
  (badge 'django "Django" 'django "framework" 'green))

(define glyph-fastapi
  (badge 'fastapi "FastAPI" 'fastapi "framework" 'teal))

(define glyph-flask
  (badge 'flask "Flask" 'flask "framework" 'overlay2))

(define glyph-laravel
  (badge 'laravel "Laravel" 'laravel "framework" 'red))

(define glyph-springboot
  (badge 'springboot "Spring Boot" 'springboot "framework" 'green))

(define glyph-flutter
  (badge 'flutter "Flutter" 'flutter "framework" 'blue))

(define glyph-electron
  (badge 'electron "Electron" 'electron "framework" 'teal))

(define glyph-express
  (badge 'express "Express" 'express "framework" 'overlay2))

(define glyph-nestjs
  (badge 'nestjs "NestJS" 'nestjs "framework" 'red))

(define glyph-preact
  (badge 'preact "Preact" 'preact "framework" 'lavender))

(define glyph-remix
  (badge 'remix "Remix" 'remix "framework" 'sky))

(define glyph-phoenixframework
  (badge 'phoenixframework "Phoenix" 'phoenixframework "framework" 'peach))

(define glyph-gatsby
  (badge 'gatsby "Gatsby" 'gatsby "framework" 'mauve))

(define glyph-qt
  (badge 'qt "Qt" 'qt "toolkit" 'green))

(define glyph-apollographql
  (badge 'apollographql "Apollo" 'apollographql "api" 'pink))

(define glyph-openapiinitiative
  (badge 'openapiinitiative "OpenAPI" 'openapiinitiative "api" 'green))

(define glyph-postman
  (badge 'postman "Postman" 'postman "api" 'peach))

(define glyph-insomnia
  (badge 'insomnia "Insomnia" 'insomnia "api" 'mauve))

;; ====== Data and infrastructure ======

(define glyph-postgresql
  (badge 'postgresql "PostgreSQL" 'postgresql "database" 'blue))

(define glyph-mysql
  (badge 'mysql "MySQL" 'mysql "database" 'sapphire))

(define glyph-mariadb
  (badge 'mariadb "MariaDB" 'mariadb "database" 'teal))

(define glyph-sqlite
  (badge 'sqlite "SQLite" 'sqlite "database" 'sapphire))

(define glyph-mongodb
  (badge 'mongodb "MongoDB" 'mongodb "database" 'green))

(define glyph-redis
  (badge 'redis "Redis" 'redis "database" 'red))

(define glyph-clickhouse
  (badge 'clickhouse "ClickHouse" 'clickhouse "database" 'yellow))

(define glyph-duckdb
  (badge 'duckdb "DuckDB" 'duckdb "database" 'yellow))

(define glyph-elasticsearch
  (badge 'elasticsearch "Elasticsearch" 'elasticsearch "search" 'sapphire))

(define glyph-prisma
  (badge 'prisma "Prisma" 'prisma "orm" 'overlay2))

(define glyph-supabase
  (badge 'supabase "Supabase" 'supabase "backend" 'green))

(define glyph-kubernetes
  (badge 'kubernetes "Kubernetes" 'kubernetes "containers" 'blue))

(define glyph-podman
  (badge 'podman "Podman" 'podman "containers" 'mauve))

(define glyph-terraform
  (badge 'terraform "Terraform" 'terraform "infrastructure" 'mauve))

(define glyph-ansible
  (badge 'ansible "Ansible" 'ansible "infrastructure" 'red))

(define glyph-nginx
  (badge 'nginx "NGINX" 'nginx "server" 'green))

(define glyph-apache
  (badge 'apache "Apache" 'apache "server" 'red))

(define glyph-rabbitmq
  (badge 'rabbitmq "RabbitMQ" 'rabbitmq "queue" 'peach))

(define glyph-apachekafka
  (badge 'apachekafka "Kafka" 'apachekafka "queue" 'overlay2))

(define glyph-apachespark
  (badge 'apachespark "Spark" 'apachespark "data" 'peach))

(define glyph-apacheflink
  (badge 'apacheflink "Flink" 'apacheflink "data" 'pink))

(define glyph-apacheairflow
  (badge 'apacheairflow "Airflow" 'apacheairflow "workflow" 'teal))

(define glyph-celery
  (badge 'celery "Celery" 'celery "queue" 'green))

(define glyph-cockroachlabs
  (badge 'cockroachlabs "CockroachDB" 'cockroachlabs "database" 'mauve))

(define glyph-influxdb
  (badge 'influxdb "InfluxDB" 'influxdb "database" 'sky))

(define glyph-neo4j
  (badge 'neo4j "Neo4j" 'neo4j "database" 'blue))

(define glyph-helm
  (badge 'helm "Helm" 'helm "kubernetes" 'blue))

(define glyph-containerd
  (badge 'containerd "containerd" 'containerd "containers" 'sky))

(define glyph-envoyproxy
  (badge 'envoyproxy "Envoy" 'envoyproxy "proxy" 'pink))

(define glyph-caddy
  (badge 'caddy "Caddy" 'caddy "server" 'sky))

;; ====== Security and networking ======

(define glyph-openssl
  (badge 'openssl "OpenSSL" 'openssl "security" 'red))

(define glyph-wireguard
  (badge 'wireguard "WireGuard" 'wireguard "vpn" 'red))

(define glyph-tailscale
  (badge 'tailscale "Tailscale" 'tailscale "vpn" 'overlay2))

;; ====== Version control, cloud and CI ======

(define glyph-github
  (badge 'github "GitHub" 'github "git" 'overlay2))

(define glyph-gitlab
  (badge 'gitlab "GitLab" 'gitlab "git" 'peach))

(define glyph-gitea
  (badge 'gitea "Gitea" 'gitea "git" 'green))

(define glyph-bitbucket
  (badge 'bitbucket "Bitbucket" 'bitbucket "git" 'blue))

(define glyph-codeberg
  (badge 'codeberg "Codeberg" 'codeberg "git" 'blue))

(define glyph-githubactions
  (badge 'githubactions "GitHub Actions" 'githubactions "ci" 'blue))

(define glyph-circleci
  (badge 'circleci "CircleCI" 'circleci "ci" 'overlay2))

(define glyph-vercel
  (badge 'vercel "Vercel" 'vercel "cloud" 'overlay2))

(define glyph-netlify
  (badge 'netlify "Netlify" 'netlify "cloud" 'teal))

(define glyph-cloudflare
  (badge 'cloudflare "Cloudflare" 'cloudflare "cloud" 'peach))

(define glyph-googlecloud
  (badge 'googlecloud "Google Cloud" 'googlecloud "cloud" 'blue))

(define glyph-firebase
  (badge 'firebase "Firebase" 'firebase "cloud" 'yellow))

(define glyph-digitalocean
  (badge 'digitalocean "DigitalOcean" 'digitalocean "cloud" 'blue))

(define glyph-render
  (badge 'render "Render" 'render "cloud" 'lavender))

(define glyph-flydotio
  (badge 'flydotio "Fly.io" 'flydotio "cloud" 'mauve))

;; ====== Observability ======

(define glyph-grafana
  (badge 'grafana "Grafana" 'grafana "metrics" 'peach))

(define glyph-prometheus
  (badge 'prometheus "Prometheus" 'prometheus "metrics" 'maroon))

(define glyph-sentry
  (badge 'sentry "Sentry" 'sentry "errors" 'mauve))

(define glyph-datadog
  (badge 'datadog "Datadog" 'datadog "monitoring" 'mauve))

;; ====== Operating systems and desktops ======

(define glyph-ubuntu
  (badge 'ubuntu "Ubuntu" 'ubuntu "os" 'peach))

(define glyph-archlinux
  (badge 'archlinux "Arch Linux" 'archlinux "os" 'sky))

(define glyph-opensuse
  (badge 'opensuse "openSUSE" 'opensuse "os" 'green))

(define glyph-freebsd
  (badge 'freebsd "FreeBSD" 'freebsd "os" 'red))

(define glyph-openbsd
  (badge 'openbsd "OpenBSD" 'openbsd "os" 'yellow))

(define glyph-alpinelinux
  (badge 'alpinelinux "Alpine Linux" 'alpinelinux "os" 'sapphire))

(define glyph-gnome
  (badge 'gnome "GNOME" 'gnome "desktop" 'blue))

(define glyph-kde
  (badge 'kde "KDE" 'kde "desktop" 'sky))

(define glyph-xfce
  (badge 'xfce "Xfce" 'xfce "desktop" 'blue))

(define glyph-wayland
  (badge 'wayland "Wayland" 'wayland "desktop" 'yellow))

;; ====== Editors, IDEs and shells ======

(define glyph-vim
  (badge 'vim "Vim" 'vim "editor" 'green))

(define glyph-helix
  (badge 'helix "Helix" 'helix "editor" 'lavender))

(define glyph-sublimetext
  (badge 'sublimetext "Sublime Text" 'sublimetext "editor" 'peach))

(define glyph-zed
  (badge 'zed "Zed" 'zedindustries "editor" 'blue))

(define glyph-intellijidea
  (badge 'intellijidea "IntelliJ IDEA" 'intellijidea "ide" 'overlay2))

(define glyph-tmux
  (badge 'tmux "tmux" 'tmux "terminal" 'green))

(define glyph-zsh
  (badge 'zsh "Zsh" 'zsh "shell" 'peach))

(define glyph-gnubash
  (badge 'gnubash "Bash" 'gnubash "shell" 'green))

(define glyph-fishshell
  (badge 'fishshell "fish" 'fishshell "shell" 'sapphire))

(define glyph-nushell
  (badge 'nushell "Nushell" 'nushell "shell" 'green))

;; ====== AI and data science ======

(define glyph-huggingface
  (badge 'huggingface "Hugging Face" 'huggingface "ai" 'yellow))

(define glyph-pytorch
  (badge 'pytorch "PyTorch" 'pytorch "ai" 'maroon))

(define glyph-tensorflow
  (badge 'tensorflow "TensorFlow" 'tensorflow "ai" 'peach))

(define glyph-ollama
  (badge 'ollama "Ollama" 'ollama "ai" 'overlay2))

(define glyph-jupyter
  (badge 'jupyter "Jupyter" 'jupyter "notebook" 'peach))

(define glyph-numpy
  (badge 'numpy "NumPy" 'numpy "science" 'teal))

(define glyph-pandas
  (badge 'pandas "pandas" 'pandas "science" 'lavender))

;; ====== Testing and build tooling ======

(define glyph-jest
  (badge 'jest "Jest" 'jest "testing" 'red))

(define glyph-vitest
  (badge 'vitest "Vitest" 'vitest "testing" 'green))

(define glyph-cypress
  (badge 'cypress "Cypress" 'cypress "testing" 'overlay2))

(define glyph-pytest
  (badge 'pytest "pytest" 'pytest "testing" 'sky))

(define glyph-eslint
  (badge 'eslint "ESLint" 'eslint "linting" 'lavender))

(define glyph-prettier
  (badge 'prettier "Prettier" 'prettier "formatting" 'yellow))

(define glyph-esbuild
  (badge 'esbuild "esbuild" 'esbuild "bundler" 'yellow))

(define glyph-npm
  (badge 'npm "npm" 'npm "package" 'red))

(define glyph-pnpm
  (badge 'pnpm "pnpm" 'pnpm "package" 'peach))

(define glyph-bun
  (badge 'bun "Bun" 'bun "runtime" 'rosewater))

(define glyph-deno
  (badge 'deno "Deno" 'deno "runtime" 'green))

;; ====== Media, design and notes ======

(define glyph-blender
  (badge 'blender "Blender" 'blender "3d" 'peach))

(define glyph-krita
  (badge 'krita "Krita" 'krita "design" 'sky))

(define glyph-excalidraw
  (badge 'excalidraw "Excalidraw" 'excalidraw "design" 'lavender))

(define glyph-obsstudio
  (badge 'obsstudio "OBS Studio" 'obsstudio "video" 'overlay2))

(define glyph-ffmpeg
  (badge 'ffmpeg "FFmpeg" 'ffmpeg "video" 'green))

(define glyph-libreoffice
  (badge 'libreoffice "LibreOffice" 'libreoffice "office" 'green))

(define glyph-obsidian
  (badge 'obsidian "Obsidian" 'obsidian "notes" 'mauve))

(define glyph-notion
  (badge 'notion "Notion" 'notion "notes" 'overlay2))

(define glyph-wikipedia
  (badge 'wikipedia "Wikipedia" 'wikipedia "docs" 'overlay2))

(define glyph-latex
  (badge 'latex "LaTeX" 'latex "writing" 'teal))

;; ====== Chat and community ======

(define glyph-discord
  (badge 'discord "Discord" 'discord "chat" 'lavender))

(define glyph-telegram
  (badge 'telegram "Telegram" 'telegram "chat" 'sky))

(define glyph-matrix
  (badge 'matrix "Matrix" 'matrix "chat" 'overlay2))

(define glyph-reddit
  (badge 'reddit "Reddit" 'reddit "social" 'peach))

;; ====== Theme variants ======
;;
;; One badge per palette that ggg knows, so the second sections of the showcase
;; show all five theme families next to each other and not only Catppuccin
;; mocha.  The label keeps the mocha neutral, and the accent -- with the ink
;; that reads on it -- comes from the theme being shown.  `ggg --list-colors'
;; prints every name below with its hex value.

(define glyph-theme-catppuccin-mocha
  (badge 'theme-catppuccin-mocha "Catppuccin" 'paint "mocha" 'mauve))

(define glyph-theme-catppuccin-macchiato
  (badge 'theme-catppuccin-macchiato "Catppuccin" 'paint "macchiato" 'teal
         #:theme 'catppuccin-macchiato))

(define glyph-theme-catppuccin-frappe
  (badge 'theme-catppuccin-frappe "Catppuccin" 'paint "frappe" 'peach
         #:theme 'catppuccin-frappe))

(define glyph-theme-catppuccin-latte
  (badge 'theme-catppuccin-latte "Catppuccin" 'paint "latte" 'blue
         #:theme 'catppuccin-latte))

(define glyph-theme-doom-one
  (badge 'theme-doom-one "Doom" 'paint "one" 'blue
         #:theme 'doom-one #:ink 'bg))

(define glyph-theme-doom-one-light
  (badge 'theme-doom-one-light "Doom" 'paint "one-light" 'magenta
         #:theme 'doom-one-light #:ink 'bg))

(define glyph-theme-dracula
  (badge 'theme-dracula "Dracula" 'paint "dracula" 'purple
         #:theme 'dracula #:ink 'background))

(define glyph-theme-dracula-alucard
  (badge 'theme-dracula-alucard "Dracula" 'paint "alucard" 'pink
         #:theme 'dracula-alucard #:ink 'background))

(define glyph-theme-solarized-dark
  (badge 'theme-solarized-dark "Solarized" 'paint "dark" 'cyan
         #:theme 'solarized-dark #:ink 'base03))

(define glyph-theme-solarized-light
  (badge 'theme-solarized-light "Solarized" 'paint "light" 'violet
         #:theme 'solarized-light #:ink 'base3))

(define glyph-theme-modus-operandi
  (badge 'theme-modus-operandi "Modus" 'paint "operandi" 'red
         #:theme 'modus-operandi #:ink 'bg-main))

(define glyph-theme-modus-vivendi
  (badge 'theme-modus-vivendi "Modus" 'paint "vivendi" 'green
         #:theme 'modus-vivendi #:ink 'bg-main))

;; ====== Styles ======
;;
;; One badge per visual style that a glyph can ask for with (style . name).
;; Every style decorates the same geometry, so the label, the logo and the two
;; sections stay put and only the finish changes.  The default is flat.

(define glyph-style-flat
  (styled-badge 'style-flat "Flat" 'sparkle "minimal" 'blue 'flat))

(define glyph-style-square
  (styled-badge 'style-square "Square" 'cube "corners" 'green 'square))

(define glyph-style-shadow
  (styled-badge 'style-shadow "Shadow" 'planet "elevation" 'peach 'shadow))

(define glyph-style-plastic
  (styled-badge 'style-plastic "Plastic" 'bolt "gloss" 'pink 'plastic))

(define glyph-style-frosted-glass
  (styled-badge 'style-frosted-glass "Frosted" 'snowflake "glass" 'sapphire
                'frosted-glass))

(define glyph-style-material
  (styled-badge 'style-material "Material" 'compass "design" 'yellow 'material))

(define glyph-style-frutiger
  (styled-badge 'style-frutiger "Frutiger" 'leaf "aero" 'teal 'frutiger))

(define glyph-style-neon
  (styled-badge 'style-neon "Neon" 'atom-orbit "glow" 'red 'neon))

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
        glyph-dotnet
        glyph-fsharp
        glyph-fortran
        glyph-haskell
        glyph-java
        glyph-kotlin
        glyph-scala
        glyph-webassembly
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
        glyph-express
        glyph-nestjs
        glyph-preact
        glyph-remix
        glyph-phoenixframework
        glyph-gatsby
        glyph-qt
        glyph-apollographql
        glyph-openapiinitiative
        glyph-postman
        glyph-insomnia
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
        glyph-apachekafka
        glyph-apachespark
        glyph-apacheflink
        glyph-apacheairflow
        glyph-celery
        glyph-cockroachlabs
        glyph-influxdb
        glyph-neo4j
        glyph-helm
        glyph-containerd
        glyph-envoyproxy
        glyph-caddy
        ;; Security and networking
        glyph-openssl
        glyph-wireguard
        glyph-tailscale
        ;; Version control, cloud and CI
        glyph-github
        glyph-gitlab
        glyph-gitea
        glyph-bitbucket
        glyph-codeberg
        glyph-githubactions
        glyph-circleci
        glyph-vercel
        glyph-netlify
        glyph-cloudflare
        glyph-googlecloud
        glyph-firebase
        glyph-digitalocean
        glyph-render
        glyph-flydotio
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
        glyph-latex
        ;; Chat and community
        glyph-discord
        glyph-telegram
        glyph-matrix
        glyph-reddit
        ;; Theme variants
        glyph-theme-catppuccin-mocha
        glyph-theme-catppuccin-macchiato
        glyph-theme-catppuccin-frappe
        glyph-theme-catppuccin-latte
        glyph-theme-doom-one
        glyph-theme-doom-one-light
        glyph-theme-dracula
        glyph-theme-dracula-alucard
        glyph-theme-solarized-dark
        glyph-theme-solarized-light
        glyph-theme-modus-operandi
        glyph-theme-modus-vivendi
        ;; Styles
        glyph-style-flat
        glyph-style-square
        glyph-style-shadow
        glyph-style-plastic
        glyph-style-frosted-glass
        glyph-style-material
        glyph-style-frutiger
        glyph-style-neon))
