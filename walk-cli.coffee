options = require 'options-parser'
walk = require './walk'
exec = require('child_process').exec
c = console
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
        help: "For each entry execute following command. e.g -x 'echo $i $name $path $level $size $mtime' -x 'cat $path'."
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
walk walkOpts, (path, name, level, stat) ->
    if walkOpts.tree then c.log "|  ".repeat(level) + name
    else
        if walkOpts.exec
            walkCount += 1
            replacers =
                i : walkCount
                path: path
                name: name
                level: level
                size: stat.size
                mtime: stat.mtime.getTime() / 1000
                ctime: stat.ctime.getTime() / 1000

            for cmd in walkOpts.exec
                for key, val of replacers
                    cmd = cmd.replace(new RegExp("\\$#{key}", "g"), val)

                exec cmd, (error, stdout, stderr) ->
                    if stdout then process.stdout.write stdout
                    if stderr then process.stderr.write stderr

        else
            c.log path

#c.log errors

