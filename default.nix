# ggg: guile glyph generator

# Copyright © Josep Bigorra <jjbigorra@gmail.com>

# ggg is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# ggg is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with ggg.  If not, see <https://www.gnu.org/licenses/>.

{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
, guile ? pkgs.guile
, imagemagick ? pkgs.imagemagick
, coreutils ? pkgs.coreutils
, util-linux ? pkgs.util-linux
, bash ? pkgs.bash
, makeWrapper ? pkgs.makeWrapper
}:

stdenv.mkDerivation {
  pname = "ggg";
  version = "0.1.0-dev";

  src = ./.;

  nativeBuildInputs = [
    guile
    makeWrapper
  ];

  buildInputs = [
    guile
    imagemagick
    coreutils
    util-linux
    bash
  ];

  buildPhase = ''
    runHook preBuild

    SITE_DIR="$out/share/guile/site/3.0"
    CCACHE_DIR="$out/lib/guile/3.0/site-ccache"

    mkdir -p "$SITE_DIR" "$CCACHE_DIR"

    # 1. Copy Scheme modules into $SITE_DIR/ggg preserving module hierarchy
    if [ -d "src/ggg" ]; then
      cp -r src/ggg "$SITE_DIR/"
    elif [ -d "src" ]; then
      mkdir -p "$SITE_DIR/ggg"
      cp -r src/* "$SITE_DIR/ggg/"
    elif [ -d "ggg" ]; then
      cp -r ggg "$SITE_DIR/"
    else
      mkdir -p "$SITE_DIR/ggg"
      find . -maxdepth 1 -name "*.scm" -exec cp {} "$SITE_DIR/ggg/" \;
    fi

    # 2. Export load paths so guild compile can resolve cross-module imports
    export GUILE_LOAD_PATH="$SITE_DIR:$GUILE_LOAD_PATH"
    export GUILE_LOAD_COMPILED_PATH="$CCACHE_DIR:$GUILE_LOAD_COMPILED_PATH"

    # 3. Dynamically byte-compile all Scheme files (.scm -> .go)
    cd "$SITE_DIR"
    find ggg -name "*.scm" | while read -r scm_file; do
      go_file="$CCACHE_DIR/''${scm_file%.scm}.go"
      mkdir -p "$(dirname "$go_file")"
      guild compile -L "$SITE_DIR" -o "$go_file" "$scm_file" || true
    done
    cd -

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # 1. Install resource files (help text, logos, assets)
    mkdir -p "$out/share/resources/logos"
    if [ -f "resources/help.txt" ]; then
      cp resources/help.txt "$out/share/resources/"
    fi
    if [ -d "resources/logos" ]; then
      cp -r resources/logos/* "$out/share/resources/logos/" 2>/dev/null || true
    fi

    # 2. Install main executable script
    mkdir -p "$out/bin"
    if [ -f "scripts/ggg" ]; then
      cp scripts/ggg "$out/bin/ggg"
    elif [ -f "ggg" ]; then
      cp ggg "$out/bin/ggg"
    fi
    chmod +x "$out/bin/ggg"

    # 3. Helper to copy completion scripts if present
    copy_completion() {
      local src_file=$1
      local dest_path=$2
      if [ -f "scripts/$src_file" ]; then
        cp "scripts/$src_file" "$dest_path"
      elif [ -f "$src_file" ]; then
        cp "$src_file" "$dest_path"
      fi
    }

    # Install shell completions
    mkdir -p "$out/share/bash-completion/completions"
    mkdir -p "$out/share/fish/vendor_completions.d"
    mkdir -p "$out/share/zsh/site-functions"

    copy_completion "ggg-completion.bash" "$out/share/bash-completion/completions/ggg"
    copy_completion "ggg-completion.fish" "$out/share/fish/vendor_completions.d/ggg.fish"
    copy_completion "ggg-completion.zsh" "$out/share/zsh/site-functions/_ggg"

    # 4. Wrap executable with runtime PATH and standard Guile load paths
    wrapProgram "$out/bin/ggg" \
      --prefix PATH : ${lib.makeBinPath [ guile imagemagick coreutils util-linux bash ]} \
      --prefix GUILE_LOAD_PATH : "$out/share/guile/site/3.0" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/lib/guile/3.0/site-ccache"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Guile Glyph Generator (GGG) - SVG badge generator written in Guile Scheme";
    homepage = "https://codeberg.org/jjbigorra/ggg";
    license = licenses.agpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "ggg";
  };
}
