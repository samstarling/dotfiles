function fut-agents --description 'Run the mikker/fut#17 build with configurable agent rows'
    set -l bin ~/Development/personal/fut-agents-sidebar/target/debug/fut
    set -l dir ~/.config/fut-agents
    mkdir -p $dir
    python3 -c '
import re, sys
main, block, out = sys.argv[1:4]
config = open(main).read()
replacement = re.split(r"(?m)^\[ui\.sidebar\.right\]$", open(block).read(), maxsplit=1)[1]
config, count = re.subn(r"(?ms)^\[ui\.sidebar\.right\]\n.*?(?=^\[)", lambda _: "[ui.sidebar.right]" + replacement.rstrip() + "\n\n", config)
if count != 1:
    sys.exit("fut-agents: no [ui.sidebar.right] table in " + main)
open(out, "w").write(config)
' ~/.config/fut/config.toml ~/.config/fut/agents-sidebar.toml $dir/config.toml
    or return 1
    $bin --socket $TMPDIR/fut-agents.sock --config-dir $dir $argv
end
