
serve:
	rm -rfv dist
	mkdir dist
	guix shell -m manifest.scm -- guile --fresh-auto-compile src/sigilcraft/main.scm
	cp -rfv resources/js/index.js dist/
	darkhttpd ./dist --port 50089
dev:
	watchexec -i "dist/**" -r -e scm,css,js -- "make serve"

# Target to format source code files according to the style guide
# Find all .scm files and format them using 'guix style'
fmt:
	$(call hygguile-log-info,"formatting all Scheme files")
	find . -maxdepth 8 -name "*.scm" -type f -exec guix style -f {} \;


# Development REPL
repl:
	guix shell -m manifest.scm -- guile --fresh-auto-compile -c '((@ (ares server) run-nrepl-server))'
