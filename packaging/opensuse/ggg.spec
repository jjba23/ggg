#
# spec file for package ggg
#
# Copyright (c) 2026 SUSE LLC and contributors
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# ggg is Scheme sources plus a bash launcher: there is no compiled binary to
# debug, so the empty -debugsource package the build would otherwise create
# is skipped.
%global debug_package %{nil}

Name:           ggg
Version:        0.16.4
Release:        0
Summary:        SVG badge and glyph generator written in Guile Scheme
License:        AGPL-3.0-or-later
URL:            https://codeberg.org/jjba23/ggg
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  pkgconfig(guile-3.0)
Requires:       bash
Requires:       coreutils
Requires:       guile
Requires:       util-linux
Recommends:     ImageMagick
Recommends:     inkscape

%description
GGG (Guile Glyph Generator) generates the SVG badges projects use to
announce the technologies they build with, the versions they support and the
projects they appreciate.

Badges are described in ordinary Scheme files, can have one, two or three
sections, and are rendered from S-expressions, so a badge is a value in your
build rather than a screenshot.  Converting the badges to PNG is optional and
is done with ImageMagick, falling back to Inkscape.

%prep
%autosetup -n %{name}-%{version}

# The launcher is a bash script; point it at the interpreter path openSUSE
# packages are expected to use instead of relying on /usr/bin/env.
sed -i '1s|^#!%{_bindir}/env \(.*\)$|#!%{_bindir}/\1|' scripts/ggg

%build
# Nothing to build: the program is Scheme sources plus a bash launcher, and
# the sources are byte-compiled during %%install so that they land in the
# interpreter's compiled-module directory.

%install
# Both directories are asked of Guile's pkg-config file rather than assumed, so
# the compiled modules land where this distribution's Guile looks for them.
SITE_DIR="%{buildroot}$(pkg-config --variable=sitedir guile-3.0)"
CCACHE_DIR="%{buildroot}$(pkg-config --variable=siteccachedir guile-3.0)"

mkdir -p "$SITE_DIR/ggg" "$CCACHE_DIR/ggg"
cp src/ggg/*.scm "$SITE_DIR/ggg/"

# Byte-compile every module so that starting ggg does not compile it again on
# first run.
find "$SITE_DIR/ggg" -name '*.scm' | while read -r scm_file; do
  rel_path="${scm_file#$SITE_DIR/}"
  go_file="$CCACHE_DIR/${rel_path%.scm}.go"
  mkdir -p "$(dirname "$go_file")"
  guild compile -L "$SITE_DIR" -o "$go_file" "$scm_file"
done

install -D -m 0755 scripts/ggg %{buildroot}%{_bindir}/ggg

install -d "%{buildroot}%{_datadir}/ggg/resources/logos"
install -D -m 0644 resources/help.txt "%{buildroot}%{_datadir}/ggg/resources/help.txt"
cp resources/logos/*.svg "%{buildroot}%{_datadir}/ggg/resources/logos/"

%check
guile -L ./src ./test/ggg-tests.scm

%files
%license COPYING
%doc README.org CREDITS.org
%doc glyphs/*.scm
%{_bindir}/ggg
%dir %{_datadir}/guile
%dir %{_datadir}/guile/site
%dir %{_datadir}/guile/site/3.0
%{_datadir}/guile/site/3.0/ggg
%dir %{_libdir}/guile
%dir %{_libdir}/guile/3.0
%dir %{_libdir}/guile/3.0/site-ccache
%{_libdir}/guile/3.0/site-ccache/ggg
%dir %{_datadir}/ggg
%{_datadir}/ggg/resources/help.txt
%{_datadir}/ggg/resources/logos

%changelog
