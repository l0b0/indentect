/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

const char *usage =
"NAME\n\
       indentect.sh - Diagnose indentation\n\
\n\
SYNOPSIS\n\
       indentect [<options>] FILE...\n\
       <command> | indentect [<options>]\n\
\n\
DESCRIPTION\n\
       Checks whether you have mixed indentation in the specified files (or standard input if not specified), and returns with exit code 1 if indentation is inconsistent.\n\
\n\
       -h, --help\n\
              Display this information and quit.\n\
\n\
       -v, --verbose\n\
              Verbose output. Prints a summary of the indentation diagnostics.\n\
\n\
EXAMPLES\n\
       indentect *\n\
              Checks whether indentation is consistent in all files.\n\
\n\
       indentect -v file\n\
              Checks and outputs a summary of the line indentation.\n\
\n\
EXIT CODES\n\
       1\n\
              Detected inconsistent indentation.\n\
       2\n\
              Internal error.\n\
\n\
BUGS\n\
       https://github.com/l0b0/indentect/issues\n\
\n\
       When reporting any bugs, please include:\n\
       * Input (if you're using a command, make sure to redirect to a file and include that).\n\
       * The full command you ran.\n\
       * --verbose output.\n\
       * What you expected to see.\n\
\n\
COPYRIGHT\n\
       Copyright (C) 2011-2012 Victor Engmark\n\
\n\
       This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.\n\
\n\
       This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n\
\n\
       You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.\n\
";


