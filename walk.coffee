c = console
fs = require 'fs'
fsPath = require 'path'

walk = (opts = {}, callback = c.log) ->
    if typeof opts is "function" then [callback, opts] = [opts, callback]
    if opts.root is undefined then opts.root = process.cwd()
    if opts.recurse is undefined then opts.recurse = true
    if opts.dirs is undefined then opts.dirs = false
    if opts.files is undefined then opts.files = true
    if opts.symLinks is undefined then opts.symLinks = true
    if isNaN(opts.maxDepth) then opts.maxDepth = Number.MAX_VALUE
    if opts.ignore then opts.excludeFilter = new RegExp("#{opts.ignore}","i")
    if opts.name then opts.includeFilter = new RegExp("#{opts.name}","i")
    if opts.ext then opts.includeFilter = new RegExp("\\.#{opts.ext}$","i")
    if opts.name and opts.ext then opts.includeFilter = new RegExp("{opts.name}.*\\.#{opts.ext}$","i")

    walkDir(opts, callback, "", 0)

walkDir = (opts, callback, dirPath, level) ->
    if level >= opts.maxDepth then return

    dirFullPath = fsPath.resolve(opts.root, dirPath)
    if not fs.existsSync(dirFullPath)
        return c.error dirFullPath, "doesn't exist"

    dirContents = fs.readdirSync dirFullPath
    include = opts.includeFilter
    exclude = opts.excludeFilter

    for itemName in dirContents
        fullPath = fsPath.resolve(dirFullPath, itemName)
        itemPath = if dirPath then dirPath + fsPath.sep + itemName else itemName

        try
            stat = fs.lstatSync fullPath
        catch e
            continue

        if (!opts.symLinks) and stat.isSymbolicLink() then continue

        if stat.isDirectory()
            if not (exclude and itemName.match(exclude))
                if opts.dirs
                    if (not include or itemName.match(include))
                        callback(itemPath, itemName, level, stat)

                if opts.recurse
                    walkDir(opts, callback, itemPath, level + 1)

        else if stat.isFile()
            if opts.files
                 if (not include or itemName.match(include)) and not (exclude and itemName.match(exclude))
                    callback(itemPath, itemName, level, stat)

module.exports = walk