build:
	coffee -bc --no-header walk.coffee
	coffee -bc --no-header walk-cli.coffee
	echo '#!/usr/bin/env node' | cat - walk-cli.js > walk-cli
	rm walk-cli.js
	chmod a+x walk-cli