#!/usr/bin/env bash
#
# NAME
#    test.sh - Test script
#
# BUGS
#    https://github.com/l0b0/indentect/issues
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2011 Victor Engmark
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

declare -r directory=$(dirname $(readlink -f "$0"))
declare -r cmd="${directory}/$(basename "$directory").sh"

oneTimeSetUp() {
    test_dir="$__shunit_tmpDir"/$'--$`\! *@ \a\b\E\f\r\t\v\\\"\' \n'
}

test_empty() {
    assertEquals "/dev/null" 0 "$("$cmd" < /dev/null; printf $?)"
    assertEquals "Nothing" 0 "$(printf '' | "$cmd"; printf $?)"
    assertEquals "Single newline" 0 "$(echo '' | "$cmd"; printf $?)"
}

test_simple() {
    assertEquals \
        "No indentation" \
        0 \
        "$(printf %s $'foo\nbar\n' | "$cmd"; printf $?)"
    assertEquals \
        "Single space indentation" \
        0 \
        "$(printf %s $' foo\n bar\n' | "$cmd"; printf $?)"
    assertEquals \
        "Multiple space indentation" \
        0 \
        "$(printf %s $' foo\n  bar\n   baz\n' | "$cmd"; printf $?)"
    assertEquals \
        "Single tab indentation" \
        0 \
        "$(printf %s $'\tfoo\n\tbar\n' | "$cmd"; printf $?)"
    assertEquals \
        "Multiple tab indentation" \
        0 \
        "$(printf %s $'\tfoo\n\t\tbar\n\t\t\tbaz\n' | "$cmd"; printf $?)"
    assertEquals \
        "Space, then tab" \
        1 \
        "$(printf %s $' \tfoo\n' | "$cmd"; printf $?)"
    assertEquals \
        "Multiple space, then tab" \
        1 \
        "$(printf %s $'  \tfoo\n' | "$cmd"; printf $?)"
    assertEquals \
        "Tab, then space" \
        1 \
        "$(printf %s $'\t foo\n' | "$cmd"; printf $?)"
    assertEquals \
        "Multiple tab, then space" \
        1 \
        "$(printf %s $'\t\t foo\n' | "$cmd"; printf $?)"
}

test_complex(){
    assertEquals \
        "Valid; no newline at end" \
        0 \
        "$(printf %s $' foo\n bar' | "$cmd"; printf $?)"
    assertEquals \
        "Invalid; no newline at end" \
        1 \
        "$(printf %s $' foo\n\tbar' | "$cmd"; printf $?)"
    assertEquals \
        "Valid space; tabs and spaces after text" \
        0 \
        "$(printf %s $' foo \t \n' | "$cmd"; printf $?)"
    assertEquals \
        "Valid tab; tabs and spaces after text" \
        0 \
        "$(printf %s $'\tfoo \t \n' | "$cmd"; printf $?)"
    assertEquals \
        "Invalid; tabs and spaces after text" \
        1 \
        "$(printf %s $' \tfoo \t \n' | "$cmd"; printf $?)"
}

# load and run shUnit2
test -n "${ZSH_VERSION:-}" && SHUNIT_PARENT=$0
. /usr/share/shunit2/shunit2
