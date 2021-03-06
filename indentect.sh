#!/usr/bin/env bash
#
# NAME
#        indentect.sh - Diagnose indentation
#
# SYNOPSIS
#        indentect [<options>] FILE...
#        <command> | indentect [<options>]
#
# DESCRIPTION
#        Checks whether you have mixed indentation in the specified files (or
#        standard input), and returns with exit code 1 if indentation is
#        inconsistent.
#
#        -s N, --spaces=N
#               Assume that the indentation is N spaces. Useful if the first
#               indented line doesn't have N space indentation.
#
#        -h, --help
#               Display this information and quit.
#
#        -v, --verbose
#               Verbose output. Prints a summary of the indentation diagnostics.
#
# EXAMPLES
#        indentect *
#               Checks whether indentation is consistent in all files.
#
#        indentect -v file
#               Checks and outputs a summary of the line indentation.
#
# EXIT CODES
#        1
#               Detected inconsistent indentation.
#        2
#               Internal error.
#
# BUGS
#        https://github.com/l0b0/indentect/issues
#
#        When reporting any bugs, please include:
#        * Input (if you're using a command, make sure to redirect to a file
#          and include that).
#        * The full command you ran.
#        * --verbose output.
#        * What you expected to see.
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
params="$(getopt -o hs:v -l help,spaces:,verbose --name "$0" -- "$@")" || usage

eval set -- "$params"
unset params

while true
do
    case $1 in
        -h|--help)
            usage
            exit
            ;;
        -s|--spaces)
            first_indentation="$2"
            shift 2
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
declare -r mixed_re=$'( \t|\t )'
declare -i unindented_lines=0
declare -i tabs_lines=0
declare -i spaces_lines=0
declare -i mixed_lines=0
declare -i other_lines=0

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
            space_counts="${space_counts+$space_counts }${#indentation}"
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

while IFS= read -r line || [ -n "$line" ]
do
    check_whitespace
done < <(cat "$@")

declare -i exit_code=$((other_lines + mixed_lines + spaces_lines * tabs_lines > 0))

# Check space indentation multiple.
if [[ spaces_lines -ne 0 ]]
then
    if [ "${first_indentation-undefined}" = undefined ]
    then
        first_indentation="${space_counts%% *}"
    fi
    declare -ir first_indentation
    declare -i inconsistent=0

    for indentation in $space_counts
    do
        if [[ $(( indentation % first_indentation )) -ne 0 ]]
        then
            exit_code=1
            let inconsistent+=1
        fi
    done
fi
declare -r exit_code

# Print results
if [[ ${verbose+defined} = defined ]]
then
    if [[ -x /usr/bin/tput && exit_code -ne 0 ]]
    then
        color="$(tput bold && tput setaf 1)"
        reset="$(tput sgr0)"
    fi

    if [[ unindented_lines -ne 0 ]]
    then
        echo "$unindented_lines unindented line$([[ unindented_lines -gt 1 ]] && printf s)"
    fi
    if [[ tabs_lines -ne 0 ]]
    then
        echo "$tabs_lines tab-indented line$([[ tabs_lines -gt 1 ]] && printf s)"
    fi
    if [[ spaces_lines -ne 0 ]]
    then
        echo "$spaces_lines space-indented line$([[ spaces_lines -gt 1 ]] && printf s)"
        echo -n "$first_indentation space indentation"
        if [[ inconsistent -ne 0 ]]
        then
            echo "; ${color-}$inconsistent exception$([[ inconsistent -gt 1 ]] && printf s)${reset-}"
            echo -n "Tip: Find lines with extended regular expression "
            echo "^( {$first_indentation})* {1,$(($first_indentation - 1))}[^ ]"
        else
            echo
        fi
    fi
    if [[ mixed_lines -ne 0 ]]
    then
        echo "${color-}$mixed_lines mixed-indented line$([[ mixed_lines -gt 1 ]] && printf s)${reset-}"
        echo -n "Tip: Find lines with extended regular expression "
        echo "^(( +\t)|(\t+ ))"
    fi
fi

if [[ other_lines -ne 0 ]]
then
    echo "${color-}Internal error: $other_lines unknown indentation line$([[ other_lines -gt 1 ]] && printf s)${reset-}" >&2
    exit 2
fi

exit $exit_code
