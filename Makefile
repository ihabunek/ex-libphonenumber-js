bundle:
	esbuild --bundle --platform=node --outfile=priv/bundle.cjs priv/index.js

watch-bundle:
	esbuild --bundle --platform=node --outfile=priv/bundle.cjs --watch priv/index.js
