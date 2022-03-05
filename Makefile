bundle:
	esbuild --bundle --platform=node --outfile=assets/bundle.cjs assets/index.js

watch-bundle:
	esbuild --bundle --platform=node --outfile=assets/bundle.cjs --watch assets/index.js

clean:
	rm assets/bundle.cjs
