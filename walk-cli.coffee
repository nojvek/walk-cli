fsPath = require 'path'
execSync = require('child_process').execSync
options = require 'options-parser'
walk = require './walk'
c = console

pathEscRegExp = new RegExp("([^\\w\\-\\.\\#{fsPath.sep}])","g")
errors = []
walkOpts = {}
String::repeat = (n) -> Array(n + 1).join(this)

opts =
    files:
        help: "List files? Default y"
        short: 'f'
        default: 'y'

    dirs:
        help: "List directories? Default n"
        short: 'd'
        default: 'n'

    recurse:
        help: "Recurse child directories? Default y"
        short: 'r'
        default: 'y'

    symLinks:
        help: "Recurse symbolic links? Default y"
        short: 's'
        default: 'y'

    name:
        help: "Only show files or directories matching regex filter. e.g -name ^walk"
        short: 'n'

    ignore:
        help: "ignore files or directories matching regex filter. e.g -i '.git|node_modules'"
        short: 'i'

    ext:
        help: "Only show files matching extension. e.g -e js"
        short: 'e'

    maxDepth:
        help: "Only recurse until a specific depth. e.g -m 3"
        short: 'm'

    exec:
        help: "For each entry execute a command. e.g -X 'echo $i $path $dir $base $name.$ext $level $size $mtime $ctime' -X 'cat $path'."
        short: 'X'
        multi: true

    echo:
        help: "For each entry output variable transform. e.g -x '$i $path $dir $base $name $ext $level $size $mtime $ctime'"
        short: 'x'
        multi: true

    tree:
        help: "Show output as indented tree?"
        short: 't'
        flag: true

    help:
        help: "Show this help menu"
        short: 'h'
        flag: true

help = ->
    c.log "Usage:", process.argv[0], "[options (VAL = y|n)]"
    options.help opts, output: c.log

parseArgs = ->
    args = {}
    parsed = options.parse opts, process.argv, (error) ->
        for key,val of error
            errors.push "  #{key} #{val}"

    for arg, val of parsed.opt
        if val == 'y' then val = true
        else if val == 'n' then val = false
        args[arg] = val

    if args.tree then args.dirs = true
    if args.maxDepth then args.maxDepth = parseInt(args.maxDepth)

    if errors.length
        c.error "Invalid arguments"
        c.error errors.join("\n")
        help()
        process.exit(1)

    else if args.help
        help(0)
        process.exit(0)

    return args


### main ###
walkOpts = parseArgs()
#c.log walkOpts

walkCount = 0
walk walkOpts, (path, file, level, stat) ->
    if walkOpts.tree then c.log "|  ".repeat(level) + name
    else
        if walkOpts.exec or walkOpts.echo
            walkCount += 1
            #path = path.replace(pathEscRegExp,"\\$1") #escape non-word characters
            parsed = fsPath.parse(path)
            replacers =
                i : walkCount
                path: path
                dir: parsed.dir
                base: parsed.base
                ext: parsed.ext
                name: parsed.name
                level: level
                size: stat.size
                mtime: Math.floor(stat.mtime.getTime() / 1000)
                ctime: Math.floor(stat.ctime.getTime() / 1000)

            commands = walkOpts.exec || walkOpts.echo
            for cmd in commands
                for key, val of replacers
                    cmd = cmd.replace(new RegExp("\\$#{key}", "g"), val)

                if walkOpts.exec
                    try process.stdout.write execSync cmd
                    catch e then c.error e.message
                else
                    c.log cmd
        else
            c.log path

