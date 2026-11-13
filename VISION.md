# Vision

`ggg` draws badges, and it does it the long way: a glyph is a Scheme value, the SVG is built as SXML, and the geometry is arithmetic rather than a template — 20px of shields-style badge drawn 9.18% larger so it sits better beside body text, with text width estimated per character and every finish required to keep the same canvas. That last constraint is the whole design in one sentence: a row of badges in ten different finishes still lines up, because a style may decorate the geometry but never move it. This document is about where that discipline should be spent next — from a renderer with a nice server attached, into the badge service for a whole software collection.

## Where ggg is today

Eleven modules under `src/ggg/`: `sxml.scm` and `svg.scm` for the drawing and the measurement tables, `glyph.scm` for layout, `style.scm` for the finishes, `colors.scm` for the palettes, `logo.scm` for the logo library, `gallery.scm` for the browsable page, `server.scm` for HTTP, `prelude.scm`, `version.scm` and `main.scm` for the command line. `version.scm` is the single source of the version: `ggg --version` prints it, `default.nix` reads it while evaluating, and `maak release` writes it into `guix.scm`, the one file that cannot read a Scheme module.

The feature set is larger than the tagline suggests. A glyph has any number of sections, each with its own background, text colour and text; the logo belongs to the first. Backgrounds and ink are named colours — 236 of them across Catppuccin's four flavours, Doom and Doom One Light, Dracula and Alucard, Solarized dark and light, and Modus Operandi and Vivendi — or raw hex, validated. Ten finishes (`flat`, `square`, `shadow`, `plastic`, `frosted-glass`, `material`, `frutiger`, `neon`, `crystal`, `crystal-mono`) are implemented as a skin contract: `radius`, `defs`, `background-fill`, `overlays`, `border`, `text-fill`, `text-filter`, `font-family` and `font-scale`. The last two are what make a style able to be a *type variant*, which is how `crystal-mono` sets its labels a tenth smaller so a wider font fits the box the sans widths measured. The library ships 286 logos as complete SVG documents, each credited with its origin and licence in `CREDITS.org`, with the marks whose upstream terms are not free deliberately left out.

The output side has three front doors. `ggg -f glyphs.scm -d dist` writes SVG, and PNG through ImageMagick's `convert` with Inkscape as the fallback when a distribution disables SVG in ImageMagick's policy. `ggg --gallery FILE --glyphs DIR` writes one self-contained HTML page rendering every badge at its real size, inlining every logo with its snippet, and showing every named colour as a copyable swatch, with the light/dark toggle the builder also has. `ggg --serve` answers four paths: the builder page at `/`, `/badge.svg` (or `/badge`) for a badge described by its query string, `/logo.svg` for the project mark and `/logo.svg?name=NAME` for one library logo. A successful badge carries `Cache-Control: public, max-age=300`; an invalid request gets HTTP 400 and the reasons — an unknown colour, logo or style, a missing `text`, an empty or overlong section — because a broken image in a README is worse than an error. A URL describes at most ten sections of a hundred characters each.

Validation is the part the project is quietly proudest of, and it deserves to be: the whole glyph file is checked before anything is written, every problem is reported together, near-miss names get a suggestion, and an invalid file leaves the destination untouched. The test suite covers colour resolution, the logo library, glyph validation and the gallery, and it enforces the accessibility floor in the other direction — every section of the shipped glyph files reaches at least 4.5:1, so a badge whose text becomes unreadable fails `maak test` rather than a reader's eyes.

The deployment is real, not aspirational. `maak deploy` writes the gallery into `dist/`, which the Woodpecker/Byggsteg job publishes on every push; `maak production-server` starts the server the way the deployment does, on loopback port 50055, where nginx proxies `ggg.jointhefreeworld.org` to it; and the API documentation is generated to `jointhefreeworld.org/api-docs/ggg/API.html`. The project is packaged for Guix, Nix, a Podman/Docker image on Docker Hub, and — source-only, awaiting submission — Debian, openSUSE and Arch, with `packaging/FOLLOW-UP-PLAN.org` recording what each one still needs.

Two glyph files ship with the project, and between them they are the best documentation of what the tool is for. `glyphs/showcase.scm` has one badge per popular logo, grouped by what the project is — languages, web frameworks and APIs, databases and queues, infrastructure, security and networking, cloud, git, observability, distributions, editors, shells, AI, testing, media, chat — plus a theme-variants group and a styles group, 189 badges in all. `glyphs/jjba23.scm` is the other half: 72 badges for the things a project ticks off one by one, language and tool versions, build and packaging, CI, tests and linting, data and deployment, licences. Since v2.0.0 the second set declares each badge once and renders it twice — the `crystal` finish takes the plain id, and the finish the set shipped with before takes a `showcase-` id — which means 152 badges come from 72 declarations plus eight palette variants. That is the shape the whole project should grow into.

## The vision

1. **The service is the interface, and the file workflow is the fallback.** A README anywhere can point at a `ggg` URL and get a cached, correct badge, in SVG or PNG, without a glyph file and without a regeneration step; the same glyph files still render to `dist/` for anyone who prefers bytes in a repository. Today the file is primary and the URL is a convenience.

   What has to be true first: raster output on the server, a cache with an honest `ETag`, and a glyph registry so a URL can name a badge instead of describing one.

2. **Every badge is addressable and identifiable.** Each badge carries a `<title>` and `role="img"`, its gradient and filter ids are namespaced by glyph, and the licence of the logo inside it is recoverable from the badge or its metadata. A page of thirty inlined badges is usable with a screen reader and does not break its own `<defs>`.

   What has to be true first: one function that writes the root element, and a discipline about ids in `style.scm` and `logo.scm` — both of which already have the seam for it.

3. **The finish contract is complete and public.** A style can change decoration *and* type, the canvas is invariant, and the contract is documented well enough for someone to write an eleventh finish without reading the other ten. The catalogue stops being a list of names and becomes a specification.

   What has to be true first: the nine keys of the skin contract written down as a table, with a golden badge per finish that a new one can be compared against.

4. **A badge set is a page of Scheme, not a list of declarations.** Families, per-version badges and per-palette variants are generated from a handful of expressions — the direction `crystal-badge` and `showcase-badge` already point — so 189 badges stay maintainable and a new release adds one line.

   What has to be true first: names for the things a family varies, so a template can say "the same badge in catppuccin-latte" without repeating its sections.

5. **The renderer is portable and its output is stable.** The measurement tables and the layout arithmetic are the asset; a second front end in another language, or a WASM build of this one, produces the same bytes. Badges change when the design changes, and never because a build ran.

   What has to be true first: goldens, a version on the output, and a test that the same glyph file twice is the same bytes twice.

## Features that are in scope and not built yet

The code already anticipates these; each is a seam the current design leaves open.

- **PNG from the server.** `--serve` answers SVG only, because rasterising means ImageMagick or Inkscape in the request path. The hard part is not the conversion but the policy: a content-addressed cache, a timeout, a refusal to run arbitrary transforms, and a fallback that answers with a clear error instead of a broken image.
- **Height, radius and border over the query string.** A glyph can set `style`, `border-radius` and `height`, and the URL exposes none of the second two. The hard part is that measurement is calibrated per font size, so a number there has to move the width table with it.
- **Dynamic badges.** The server describes static text. A badge whose text comes from a URL — shields' endpoint style — needs a fetcher, a timeout, its own cache headers and a story about what the server is willing to fetch on someone else's behalf.
- **Golden SVG per finish.** The suite covers colours, logos, validation and the gallery; it does not compare a style's output against a known-good file. The hard part is that a golden catches a geometry regression only if the golden is regenerated deliberately, which is a workflow decision rather than a test.
- **`--watch`.** Re-rendering a glyph file as it is edited is the natural companion to the REPL workflow the README argues for, and the hard part is cheap: it is a filesystem watcher and a debounce, not a design question.
- **Licence provenance in the gallery.** `CREDITS.org` is maintained by hand beside 286 files. The hard part is the asymmetry — a missing credit is invisible until someone audits, so the check has to run both ways: every logo has a line, every line has a logo.
- **The distribution packages.** Debian, openSUSE and Arch are written and unsubmitted; `packaging/FOLLOW-UP-PLAN.org` says what each one is missing. The hard part is a licence and documentation install that matches the layout `scripts/ggg` resolves at runtime.
- **Machine-readable listings.** `--list-colors`, `--list-logos` and `--list-styles` print for a person. The gallery and the builder both need the same data as data; an editor completing a glyph file needs it too.
- **`--stdout` and `--stdin` documented as a contract.** Both flags exist, and they are what makes `ggg` usable inside another program — a pipeline, a hook, a generator. The hard part is not the flags but the promise: that what reaches standard output is the SVG and nothing else, on every path, including when a warning is logged.
- **A glyph file's report as data.** Validation already collects every problem with a hint. Emitting them as JSON, for an editor to underline them in place, is the difference between a build failure and a diagnostic.
- **Logo references that fail loudly in the gallery.** A glyph naming a logo that does not exist is caught by validation; a logo in `resources/logos/` that no glyph uses is invisible. The reverse check is the one that keeps a 286-file library honest as it grows.

## New features that would be worth having

- **A tall finish.** Every style keeps the compact canvas on purpose. One deliberate exception — a `for-the-badge`-sized variant with its own measurement — would test whether the skin contract is really a contract, and it is the single most requested shape in the badge world.
- **Logo tinting.** Many brand marks are multicolour and vanish on a dark plate. `(logo-tint . text)` — one colour, applied to the whole logo — is a small feature that would make logos usable on every finish without editing 286 SVG files.
- **A badge that names its own provenance.** `?provenance=1` answering an HTML or JSON document, or a comment in the SVG, naming the glyph, the finish, the palette, the logo and that logo's licence. It is the natural extension of the licence discipline this project already keeps carefully, and no other badge service does it.
- **A contrast report as a command.** The 4.5:1 floor is enforced for the shipped glyph files by the test suite; exposing it as `ggg --check-contrast glyphs/*.scm` makes the same knowledge useful for a reader building their own palette.
- **A style sheet endpoint.** The builder shows one preview per finish and the gallery shows every finish twice over; a single `/styles.svg` sprite — the same badge in all ten finishes, in one request — would let any page do the same.
- **A short URL.** The query string is honest and long. A glyph file already has ids; `/g/scheme-guile.svg` serving one of them, with the file's hash in the ETag, would make `ggg` a badge registry rather than a renderer.
- **A gallery per glyph file.** `maak deploy` publishes `dist/gallery.html` for the whole library. A page per file, generated the same way, would let the showcase and the personal set be linked and reviewed separately — which is what a reader wants when a set has 189 badges.
- **A badge that links to the builder.** The gallery already copies the snippet that makes a badge; a URL that opens the builder with that badge loaded turns every sample into a starting point, and the builder already has starting points for exactly this.
- **Two sections that are the same badge, named.** A glyph can have any number of sections, and the same text can appear twice — a label and a value that happen to coincide. Naming sections, so a template can refer to one, is a small DSL feature that makes generated families (a version, a status, a licence) composable instead of positional.

## Contributions that would move the needle

Ranked roughly by value per hour. The first two are afternoons.

1. **Accessibility metadata in the badge root.** A `<title>` holding the badge's text, `role="img"` and an `aria-label` on the `<svg>`, in one function in `glyph.scm`. It costs almost nothing, it makes the output correct for screen readers and for the dozens of tools that read an SVG's title, and it is the kind of gap a design-led project should not have.
2. **Namespacing the ids a skin emits.** `style-id-prefix` already exists; making every gradient, clip path and filter id carry it — and the logo's internal ids too — removes a real collision when two badges are inlined in one page.
3. **Golden SVGs for the ten finishes.** A directory of expected files and a loop, exactly like the serialisers' tests in a sibling project, and the only way a change to `average-character-width` becomes visible before a reader notices it.
4. **The logo credit check, both directions.** Every file in `resources/logos/` has a line in `CREDITS.org`, and every line names a file that exists with the licence recorded. The project's care about licences is one of its best features; a test turns the care into a guarantee.
5. **`--list-colors`, `--list-logos` and `--list-styles` with `--json`.** The data all exists and the gallery already consumes it. This is what an editor needs to complete a glyph file, and it is a few dozen lines.
6. **The server's raster path.** Valuable and the largest single piece of work: a cache, a policy, a timeout and an error story, on a component that is already deployed publicly.
7. **The distribution packages.** Least glamorous, most useful to a stranger: an openSUSE, Debian or Arch user who can `zypper install ggg` does not need to learn Guix first.
8. **A documented skin contract.** The nine keys a style may return, each with what it replaces and what it must not touch, next to the invariant-canvas rule. It is a page of writing that makes the design reviewable and turns "add a finish" into a task someone else can finish.
9. **A `--check` for glyph files in CI.** Validation and the contrast floor already exist; running them over a repository's own glyph files, and exiting non-zero, is what lets a project that vendors its badges treat them like code.
10. **The logo library pruned of what nobody uses.** 286 files is a fine number and a growing liability: an unused logo is a licence obligation nobody is using. A listing of ids no glyph references is a small script with a real maintenance dividend.

## Compared to related projects

| Project | What it is | Where ggg differs |
|---|---|---|
| shields.io | The incumbent badge service: a Node server, hundreds of integrated data sources, dynamic JSON and endpoint badges, raster output and a CDN | shields has the integrations, the scale and the raster cache. `ggg` has ten hand-drawn finishes over five palettes with contrast enforced in tests, a canvas no finish may change, and glyph files in version control rather than a query string — so a badge set is reviewable |
| badgen.net | A fast badge service on Cloudflare Workers, with fewer styles and a smaller palette | Built for latency at the edge; `ggg` is a Scheme renderer you can read, run and self-host, and its design work goes into finishes rather than into reach |
| badge-maker | shields' own library for building badge SVGs from JavaScript, used by its server | A library with one flat look and per-call options; `ggg` is a program and a language for describing badges, with validation, a logo library and a gallery |
| Simple Icons | A CC0 collection of brand marks, the source of most of `ggg`'s tech logos | A logo set, not a renderer. `ggg` ships a curated subset and records the provenance and licence of every file, including the marks it deliberately excludes |
| readme-typing-svg, capsule-render | Generators for animated and decorative README headers, served as SVGs from a URL | Adjacent rather than competing: they animate, `ggg` composes. Both prove the same thing — that a README image can be generated on demand rather than committed |
| ImageMagick, Inkscape, `rsvg-convert` | The rasterisers `ggg` calls for PNG output | Dependencies, and the reason a `/badge.png` endpoint is a policy question rather than a flag |
| Guile's own `sxml->xml` and the SXML conventions | The serialiser `ggg` builds on | A general XML writer; `ggg` is what a decade of writing badges as S-expressions looks like on top of it |
| GitHub Actions and other vendor-run badge endpoints | Status badges served by the platform that knows the answer, with its own cache and no configuration | The data is the platform's and the look is fixed. `ggg` renders a badge whose text anyone can supply, in a design someone chose, which is why it is used for facts a platform does not track |
| PyPI, NuGet, Docker Hub and Crates.io badge endpoints | Vendor-served images for version and download counts, one per package page | Same shape as above: a fixed look, no theming, no composition. `ggg` can put the same fact next to a logo and a status in one badge with three sections, from a file that is under review |

What the others do that `ggg` could still add: shields' data integrations and its raster-plus-cache story, badgen's edge deployment, and the "point a URL at a service and get a picture" ergonomics that makes them ubiquitous. Those are the three things standing between this renderer and a badge endpoint someone else could adopt.

Where `ggg` is ahead and should stay ahead: a palette system with 236 named colours whose contrast is a test rather than a hope; finishes that are decoration over an invariant layout, so mixed rows line up; a logo library that carries its licences in the repository and says what it left out and why; and generation from a Scheme file, which makes a badge set a program that can be reviewed, diffed and extended, rather than a hundred URLs pasted into a README.

The two things worth copying are both about reach rather than quality. shields' dynamic endpoints are what make a badge *true* without anyone re-rendering it, and its raster-plus-CDN path is what makes an image cheap to fetch a million times. Neither is a design problem; both are the difference between a renderer people use and a renderer people build with.

The thing worth not copying is the query string as the only interface. It is why shield badges are all one shape: a URL can say "three sections of text" but it cannot say "this set of badges, in this palette, with this version of the design". A glyph file can, and that is the part of this project that would be missed if it went away.

## In the long run

- **A badge service for the collection.** The projects in this account already link `jointhefreeworld.org/ggg/dist/...`. The bet is that those links become URLs served by the server, with a cache in front and a glyph registry behind, so a badge is never stale because a file was not regenerated.
- **The measurement tables as the asset.** Any badge service can draw a rectangle; very few can put text in a box that looks intentional at every size. If a second front end ever exists, it will exist because the width tables and the scale factors are worth porting — which is also the reason they deserve documentation and golden tests.
- **Licences as a feature.** A logo library with provenance, an explicit list of excluded marks, and a badge that can say which licence the picture inside it carries is a small idea that no incumbent has, and it is the natural extension of this project's habits.
- **The gallery as a design document.** It already shows every finish, every palette and every logo. The bet is that it becomes how the design system is argued — what a finish is for, what a palette does to contrast, which badge to use for what — rather than a page of samples.
- **A Scheme-native answer in a JavaScript field.** Badges are generated by Node services and Rust edge workers. `ggg` is a small, readable, reproducible program in a language with a REPL, and the long bet is that being the one you can read and hack is a durable reason to exist.
- **A design that survives its own styles.** Ten finishes is already more than any comparable tool, and each one is a small argument about what a badge should look like. The bet is that the argument keeps being made in the same place — the invariant canvas — so that a badge drawn in 2024 and a badge drawn in 2029 still sit in the same row.

## A closing note

The interesting thing about this project is not that it makes badges. It is that it refuses two easy shortcuts: that a style may change the size of a badge, and that a colour may be a hex string someone guessed. Everything here follows from those refusals — the skin contract, the calibrated width tables, the five palettes with qualified names, the contrast floor in the test suite, and a validation pass that reports every problem before writing anything.

It also follows from a third: that the description of a badge should be a value in a language with a REPL. A glyph file is short, diffable, and answerable — you can evaluate the section that is wrong. That is why the improvements above are mostly about making the value more useful (goldens, ids, provenance, registries) rather than about adding features to a renderer.

*This document describes intent, not commitments: it names directions the maintainer finds worth taking, and nothing here is a promise that a given feature will exist, in the order listed, or at all.*
