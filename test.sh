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
    assertTrue "/dev/null" "\"$cmd\" < /dev/null"
    assertTrue "Nothing" "printf '' | \"$cmd\""
    assertTrue "Single newline" "echo '' | \"$cmd\""
}

test_simple() {
    assertTrue \
        "No indentation" \
        "printf %s $'foo\nbar\n' | \"$cmd\""
    assertTrue \
        "Single space indentation" \
        "printf %s $' foo\n bar\n' | \"$cmd\""
    assertTrue \
        "Multiple space indentation" \
        "printf %s $' foo\n  bar\n   baz\n' | \"$cmd\""
    assertTrue \
        "Single tab indentation" \
        "printf %s $'\tfoo\n\tbar\n' | \"$cmd\""
    assertTrue \
        "Multiple tab indentation" \
        "printf %s $'\tfoo\n\t\tbar\n\t\t\tbaz\n' | \"$cmd\""
    assertFalse \
        "Space, then tab" \
        "printf %s $' \tfoo\n' | \"$cmd\""
    assertFalse \
        "Multiple space, then tab" \
        "printf %s $'  \tfoo\n' | \"$cmd\""
    assertFalse \
        "Tab, then space" \
        "printf %s $'\t foo\n' | \"$cmd\""
    assertFalse \
        "Multiple tab, then space" \
        "printf %s $'\t\t foo\n' | \"$cmd\""
}

test_complex(){
    assertTrue \
        "Valid; no newline at end" \
        "printf %s $' foo\n bar' | \"$cmd\""
    assertFalse \
        "Invalid; no newline at end" \
        "printf %s $' foo\n\tbar' | \"$cmd\""
    assertTrue \
        "Valid space; tabs and spaces after text" \
        "printf %s $' foo \t \n' | \"$cmd\""
    assertTrue \
        "Valid tab; tabs and spaces after text" \
        "printf %s $'\tfoo \t \n' | \"$cmd\""
    assertFalse \
        "Invalid; tabs and spaces after text" \
        "printf %s $' \tfoo \t \n' | \"$cmd\""
}

# load and run shUnit2
test -n "${ZSH_VERSION:-}" && SHUNIT_PARENT=$0
. shunit2
