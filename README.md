# msjamokha-shell-scripts
A portfolio of miscellaneous shell scripts that are mainly for self-study.

### How I'm Using Filename Extensions

The scripts' filename extension will explicitly adhere to the shell referenced
in the shebang.

If a script is a POSIX shell script, it is intended to be as portable as
possible. For example, they should behave the same whether the environment is
Arch Linux with bash, macOS with zsh, FreeBSD with tsch, etc.

If a script has a specific filename extension (E.g. .bash, .csh) then it makes
use of specific features in that shell, and will **not** work on the lowest-
common denominator, sh.
