options = require 'options-parser'
walk = require './walk'
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
        help: "Only show files matching regex filter. e.g -name ^walk"
        short: 'n'

    ignore:
        help: "ignore files or folder matching regex filter. e.g -i '.git|node_modules'"
        short: 'i'

    ext:
        help: "Only show files matching extension. e.g -e js"
        short: 'e'

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

walk walkOpts, (path, name, level) ->
    if walkOpts.tree then c.log "  ".repeat(level), name
    else c.log path

#c.log errors

