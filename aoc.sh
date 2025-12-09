#!/bin/sh

set -e

#<> begin

__aoc_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/aoc-cli"
__aoc_session_file="${__aoc_cache_dir}/session"
mkdir -p "$__aoc_cache_dir"

## Commands

### session

# shellcheck disable=SC2329
__aoc_cmd_session_help() {
    echo "Usage: $0 session get|invalidate|help" >&2
    echo "" >&2
    echo "  get         Get the session cookie for the current session" >&2
    echo "  invalidate  Invalidate the session cookie for the current session" >&2
    echo "  help        Print this help message" >&2
    return 0
}

# shellcheck disable=SC2329
__aoc_cmd_session_get() {
    if [ ! -f "$__aoc_session_file" ]; then
      echo "Please enter your session cookie: " >&2

      read -r SESSION
      if [ -z "$SESSION" ]; then
        echo "No session cookie provided." >&2
        return 1
      fi

      echo "" >&2
      echo "$SESSION" > "$__aoc_session_file"
    fi

    cat "$__aoc_session_file"
    return 0
}

# shellcheck disable=SC2329
__aoc_cmd_session_invalidate() {
    rm -f "$__aoc_session_file"
    return 0
}

### input

# shellcheck disable=SC2329
__aoc_cmd_input_help() {
    echo "Usage: $0 input download|help" >&2
    echo "" >&2
    echo "  download -- <day>  Download the input for the given day" >&2
    echo "  help               Print this help message" >&2
    return 0
}

# shellcheck disable=SC2329
__aoc_cmd_input_download() {
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: $0 input download -- <day> [year]" >&2
        exit 1
    fi
    
    DAY="$1"
    YEAR="${2:-$(date +%Y)}"
    OUTPUT_FILE="$__aoc_cache_dir/year$YEAR/day$1.txt"
    
    curl_with_opts() {
      curl -sSL -H "Cookie: session=$SESSION" "https://adventofcode.com/$YEAR/day/$DAY/input" "$@"
    }
    
    while [ ! -f "$OUTPUT_FILE" ]; do
      SESSION="$(eval __aoc_cmd_session_get)"
      
      STATUS_CODE="$(curl_with_opts -o /dev/null -w '%{http_code}')"
      if [ "$STATUS_CODE" == "400" ] || [ "$STATUS_CODE" == "500" ]; then
        echo "Your session appears to be invalid..." >&2
        echo "" >&2
        eval __aoc_cmd_session_invalidate
      elif [ "$STATUS_CODE" == "404" ]; then
        return 1
      else
        curl_with_opts -o "$OUTPUT_FILE"
        chmod 444 "$OUTPUT_FILE"
      fi
    done
    
    echo "$OUTPUT_FILE"
    return 0
}

### help

# shellcheck disable=SC2329
__aoc_cmd_help() {
    echo "Usage: aoc <command> -- [<args>]" >&2
    echo "" >&2
    echo "  session    Manage your AOC session" >&2
    echo "  input      Download problem inputs" >&2
    echo "  help       Show this help" >&2
    return 0
}

## End of commands

__aoc_found_cmd=false
__aoc_curr_cmd=__aoc_cmd
__aoc_curr_help_cmd=__aoc_cmd_help
__aoc_curr_cmd_pretty=""

while [ "$#" -gt 0 ]; do
    __aoc_req_cmd="$1"
    shift
    
    if [ "$__aoc_req_cmd" = "--" ]; then
        break
    fi
    
    __aoc_curr_cmd="${__aoc_curr_cmd}_${__aoc_req_cmd}"
    __aoc_curr_cmd_pretty="${__aoc_curr_cmd_pretty} ${__aoc_req_cmd}"
    if type "$__aoc_curr_cmd" > /dev/null 2>&1; then
        __aoc_found_cmd=true
    else
        __aoc_found_cmd=false
    fi
    
    if type "${__aoc_curr_cmd}_help" > /dev/null 2>&1; then
        __aoc_curr_help_cmd="${__aoc_curr_cmd}_help"
    fi
done

if [ "$__aoc_found_cmd" = false ]; then
    if [ "$__aoc_curr_help_cmd" != "${__aoc_curr_cmd}_help" ]; then
        echo "Unknown command: $(echo "$__aoc_curr_cmd_pretty" | xargs)" >&2
        echo "" >&2
    fi

    "$__aoc_curr_help_cmd"
    exit 1
fi

"$__aoc_curr_cmd" "$@"
exit $?