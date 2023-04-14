# msjamokha-shell-scripts
A portfolio of miscellaneous shell scripts that are mainly for self-study.

### How I'm using filename extensions

The scripts' filename extension will explicitly adhere to the shell referenced
in the shebang.

If a script is a POSIX shell script, it is intended to be as portable as
possible. For example, they should behave the same whether the environment is
Arch Linux with bash, macOS with zsh, FreeBSD with tsch, etc.

If a script has a specific filename extension (E.g. .bash, .csh) then it makes
use of specific features in that shell, and will **not** work on the lowest-
common denominator, sh.

### What does each script do?

Each script has a brief summary of it's purpose in a "header" of sorts.
Otherwise, refer to this list:

col\_mod.sh
Swaps 2 columns (fields) or delete 1 column from a .CSV or CSV-like file by
specifying a different delimiter.

mastermind.sh
Attempt at implementing the code-breaker game "Mastermind" in pure POSIX shell.
Uses digits 0 through 9 as symbols instead of colours. Codes are 4-digits long.
