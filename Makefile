
serve:
	rm -rfv dist
	mkdir dist
	guix shell -m manifest.scm -- guile --fresh-auto-compile src/sigilcraft/main.scm
	cp -rfv resources/js/index.js dist/
	darkhttpd ./dist --port 50089
dev:
	watchexec -i "dist/**" -r -e scm,css,js -- "make serve"

