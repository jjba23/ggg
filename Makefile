
dev:
	rm -rfv dist
	mkdir dist
	guile --fresh-auto-compile src/sigilcraft/main.scm
