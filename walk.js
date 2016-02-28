var c, fs, fsPath, walk, walkDir;

c = console;

fs = require('fs');

fsPath = require('path');

walk = function(opts, callback) {
  var ref;
  if (opts == null) {
    opts = {};
  }
  if (callback == null) {
    callback = c.log;
  }
  if (typeof opts === "function") {
    ref = [opts, callback], callback = ref[0], opts = ref[1];
  }
  if (opts.root === void 0) {
    opts.root = process.cwd();
  }
  if (opts.recurse === void 0) {
    opts.recurse = true;
  }
  if (opts.dirs === void 0) {
    opts.dirs = false;
  }
  if (opts.files === void 0) {
    opts.files = true;
  }
  if (opts.symLinks === void 0) {
    opts.symLinks = true;
  }
  if (isNaN(opts.maxDepth)) {
    opts.maxDepth = Number.MAX_VALUE;
  }
  if (opts.ignore) {
    opts.excludeFilter = new RegExp("" + opts.ignore, "i");
  }
  if (opts.name) {
    opts.includeFilter = new RegExp("" + opts.name, "i");
  }
  if (opts.ext) {
    opts.includeFilter = new RegExp("\\." + opts.ext + "$", "i");
  }
  if (opts.name && opts.ext) {
    opts.includeFilter = new RegExp("{opts.name}.*\\." + opts.ext + "$", "i");
  }
  return walkDir(opts, callback, "", 0);
};

walkDir = function(opts, callback, dirPath, level) {
  var dirContents, dirFullPath, e, error, exclude, fullPath, i, include, itemName, itemPath, len, results, stat;
  if (level >= opts.maxDepth) {
    return;
  }
  dirFullPath = fsPath.resolve(opts.root, dirPath);
  if (!fs.existsSync(dirFullPath)) {
    return c.error(dirFullPath, "doesn't exist");
  }
  dirContents = fs.readdirSync(dirFullPath);
  include = opts.includeFilter;
  exclude = opts.excludeFilter;
  results = [];
  for (i = 0, len = dirContents.length; i < len; i++) {
    itemName = dirContents[i];
    fullPath = fsPath.resolve(dirFullPath, itemName);
    itemPath = dirPath ? dirPath + fsPath.sep + itemName : itemName;
    try {
      stat = fs.lstatSync(fullPath);
    } catch (error) {
      e = error;
      continue;
    }
    if ((!opts.symLinks) && stat.isSymbolicLink()) {
      continue;
    }
    if (stat.isDirectory()) {
      if (!(exclude && itemName.match(exclude))) {
        if (opts.dirs) {
          if (!include || itemName.match(include)) {
            callback(itemPath, itemName, level, stat);
          }
        }
        if (opts.recurse) {
          results.push(walkDir(opts, callback, itemPath, level + 1));
        } else {
          results.push(void 0);
        }
      } else {
        results.push(void 0);
      }
    } else if (stat.isFile()) {
      if (opts.files) {
        if ((!include || itemName.match(include)) && !(exclude && itemName.match(exclude))) {
          results.push(callback(itemPath, itemName, level, stat));
        } else {
          results.push(void 0);
        }
      } else {
        results.push(void 0);
      }
    } else {
      results.push(void 0);
    }
  }
  return results;
};

module.exports = walk;
