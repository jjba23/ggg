{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "ggg";
  version = "0.1.0-dev";

  src = ./.;

  nativeBuildInputs = [
    pkgs.guile
    pkgs.makeWrapper
  ];

  buildInputs = [
    pkgs.guile
  ];

  # Tools required by ggg at runtime:
  # - guile: to run the scheme application
  # - imagemagick: provides 'convert' for PNG rendering
  # - coreutils: 'date', 'realpath', 'dirname'
  # - util-linux: 'getopt'
  pathInputs = [
    pkgs.guile
    pkgs.imagemagick
    pkgs.coreutils
    pkgs.util-linux
  ];

  buildPhase = ''
    runHook preBuild

    # Create directories for Guile source (.scm) and bytecode (.go)
    mkdir -p build/site/3.0
    mkdir -p build/site-cc/3.0

    # Copy scheme modules into place
    if [ -d "src/ggg" ]; then
      cp -r src/ggg build/site/3.0/
    else
      mkdir -p build/site/3.0/ggg
      cp *.scm build/site/3.0/ggg/
    fi

    # Compile Scheme modules into bytecode
    find build/site/3.0 -name "*.scm" | while read -r scm_file; do
      rel_path="''${scm_file#build/site/3.0/}"
      go_file="build/site-cc/3.0/''${rel_path%.scm}.go"
      mkdir -p "$(dirname "$go_file")"

      guild compile \
        -L build/site/3.0 \
        -o "$go_file" \
        "$scm_file"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # 1. Install Guile source modules and bytecode
    mkdir -p "$out/share/guile/site/3.0"
    mkdir -p "$out/share/guile/site-cc/3.0"
    cp -r build/site/3.0/* "$out/share/guile/site/3.0/"
    cp -r build/site-cc/3.0/* "$out/share/guile/site-cc/3.0/"

    # 2. Install resource files
    mkdir -p "$out/share/resources"
    if [ -f "resources/help.txt" ]; then
      cp resources/help.txt "$out/share/resources/"
    fi
    if [ -d "resources/svg-paths" ]; then
      cp -r resources/svg-paths "$out/share/resources/"
    fi

    # 3. Install executable script
    mkdir -p "$out/bin"
    if [ -f "scripts/ggg" ]; then
      cp scripts/ggg "$out/bin/ggg"
    elif [ -f "ggg" ]; then
      cp ggg "$out/bin/ggg"
    fi
    chmod +x "$out/bin/ggg"

    # 4. Wrap the ggg executable with runtime dependencies & Guile search paths
    wrapProgram "$out/bin/ggg" \
      --prefix PATH : ${pkgs.lib.makeBinPath finalAttrs.pathInputs} \
      --prefix GUILE_LOAD_PATH : "$out/share/guile/site/3.0" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/share/guile/site-cc/3.0"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Guile Glyph Generator (GGG) - SVG badge generator written in Guile Scheme";
    homepage = "https://codeberg.org/jjbigorra/ggg";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
    mainProgram = "ggg";
  };
})
