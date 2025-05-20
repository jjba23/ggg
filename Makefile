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

run:
	rm -rfv dist
	mkdir dist
	guix shell -m manifest.scm -- guile --fresh-auto-compile src/ggg/main.scm glyphs/jjba23.scm
dev:
	watchexec -i "dist/**" -r -e scm,css,js -- "make run"

# Target to format source code files according to the style guide
# Find all .scm files and format them using 'guix style'
fmt:
	$(call hygguile-log-info,"formatting all Scheme files")
	find . -maxdepth 8 -name "*.scm" -type f -exec guix style -f {} \;


# Development REPL
repl:
	guix shell -m manifest.scm -- guile --fresh-auto-compile -c '((@ (ares server) run-nrepl-server))'

# Deploy generated assets to jointhefreeworld
deploy:
	CI=true make run
	mkdir -p /srv/http/jointhefreeworld.org/ggg
	rm -rfv /srv/http/jointhefreeworld.org/ggg/dist
	mv -v dist /srv/http/jointhefreeworld.org/ggg/dist
