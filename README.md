# Walk
Commandline utility to find files and directories by name, ext or regex. Can be used as a node module as well.

## Installation
```
npm install -g walk-cli
```

## Usage
```
walk -h
Usage: walk [options (VAL = y|n)]
  --files VAL, -f VAL      List files? Default y
  --dirs VAL, -d VAL       List directories? Default n
  --recurse VAL, -r VAL    Recurse child directories? Default y
  --symLinks VAL, -s VAL   Recurse symbolic links? Default y
  --name VAL, -n VAL       Only show files matching regex filter. e.g -name ^walk
  --ignore VAL, -i VAL     ignore files or folder matching regex filter. e.g -i '.git|node_modules'
  --ext VAL, -e VAL        Only show files matching extension. e.g -e js
  --tree, -t               Show output as indented tree?
  --help, -h               Show this help menu
```

## Module Usage
```
var walk = require('walk-cli');

String.prototype.repeat = function(n) {
  return Array(n + 1).join(this);
};

// Example Options
var walkOpts = {
    root: "/Users/Documents/me/code"
    files: true,
    dirs: true,
    recurse: true,
    ext: "js"
}

walk(walkOpts, function(path, name, level) {
  if (walkOpts.tree) {
    return console.log("  ".repeat(level), name);
  } else {
    return console.log(path);
  }
})
```
