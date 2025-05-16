
serve:
	rm -rfv dist
	mkdir dist
	guix shell -m manifest.scm -- guile --fresh-auto-compile src/sigilcraft/main.scm
dev:
	watchexec -i "dist/**" -r -e scm,css,js -- "make serve"

