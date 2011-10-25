#!/usr/bin/env bash
#
# NAME
#        indentect.sh - Diagnose indentation
#
# SYNOPSIS
#        indentect [<options>] FILE...
#
# DESCRIPTION
#        Checks whether you have mixed indentation in the specified files (or
#        standard input), and returns with exit code 1 if indentation is
#        inconsistent.
#
#        -h, --help
#               Display this information and quit.
#
#        -v, --verbose
#               Verbose output.
#
# EXAMPLES
#        indentect *
#               Checks whether indentation is consistent in all files.
#
#        indentect -v file
#               Checks and outputs a summary of the line indentation.
#
# BUGS
#        https://github.com/l0b0/indentect/issues
#
# COPYRIGHT
#        Copyright (C) 2011 Victor Engmark
#
#        This program is free software: you can redistribute it and/or modify
#        it under the terms of the GNU General Public License as published by
#        the Free Software Foundation, either version 3 of the License, or
#        (at your option) any later version.
#
#        This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#        GNU General Public License for more details.
#
#        You should have received a copy of the GNU General Public License
#        along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

set -o errexit -o noclobber -o nounset -o pipefail

usage() {
    # Print documentation until the first empty line
    # @param $1: Exit code (optional)
    while IFS= read -r -u 9
    do
        if [[ -z "$REPLY" ]]
        then
            exit ${1:-0}
        elif [[ "${REPLY:0:2}" == '#!' ]]
        then
            # Shebang line
            continue
        fi
        echo "${REPLY:2}" # Remove comment characters
    done 9< "$0"
}

# Process parameters
params="$(getopt -o hv -l help,verbose --name "$0" -- "$@")" || usage

eval set -- "$params"
unset params

while true
do
    case $1 in
        -h|--help)
            usage
            exit
            ;;
        -v|--verbose)
            verbose='--verbose'
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            usage
            ;;
    esac
done

declare -r whitespace_re='^([[:space:]]+)'
declare -r tabs_re=$'^\t+$'
declare -r spaces_re='^ +$'
declare -r mixed_re=$'^( \t|\t )$'
declare -i unindented_lines=0
declare -i tabs_lines=0
declare -i spaces_lines=0
declare -i mixed_lines=0
declare -i other_lines=0
declare indentation

check_whitespace() {
    if [[ "$line" =~ $whitespace_re ]]
    then
        # Indented line
        indentation="${BASH_REMATCH[1]}"
        if [[ "$indentation" =~ $tabs_re ]]
        then
            let tabs_lines+=1
        elif [[ "$indentation" =~ $spaces_re ]]
        then
            let spaces_lines+=1
        elif [[ "$indentation" =~ $mixed_re ]]
        then
            let mixed_lines+=1
        else
            echo "Unknown indentation: $(printf %q "$indentation")" >&2
            echo "$line" >&2
            let other_lines+=1
        fi
    else
        let unindented_lines+=1
    fi
}

while IFS= read -r line
do
    check_whitespace
done < <(cat "$@")

if [ "${line+defined}" = defined ]
then
    # Missing newline at EOF
    check_whitespace
fi

declare -ri exit_code=$((other_lines + mixed_lines + spaces_lines * tabs_lines > 0))

if [[ ${verbose+defined} = defined ]]
then
    if [[ -x /usr/bin/tput && $exit_code -ne 0 ]]
    then
        color="$(tput bold && tput setaf 1)"
        reset="$(tput sgr0)"
    fi

    >&2 echo "Summary:
Unindented lines: $unindented_lines
Tab-indented lines: $tabs_lines
Space-indented lines: $spaces_lines
Mixed-indented lines: $mixed_lines
Unknown indentation lines: $other_lines"

    if [[ $exit_code -ne 0 ]]
    then
        >&2 echo -n "${color-}in"
    fi
    >&2 echo "consistent indentation${reset-}"
fi

exit $exit_code
