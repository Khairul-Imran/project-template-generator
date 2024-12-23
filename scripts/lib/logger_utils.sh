#!/bin/bash

# Set strict error handling
set -euo pipefail

# ANSI colour codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Spinner characters for progress indication
SPINNER_CHARS=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} ${1}"
}

log_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} ${1}"
}

log_error() {
    echo -e "${RED}✗${NC} ${1}" >&2
}

log_section() {
    echo -e "\n${BOLD}▶ ${1}${NC}"
}

# Progress spinner
start_spinner() {
    local msg="$1"
    echo -ne "${msg}"

    # Hides cursor
    tput civis

    # Start spinner in background
    (
        i=0
        while true; do
            echo -ne "\r${msg}${SPINNER_CHARS[i]}"
            i=$(( (i + 1) % ${#SPINNER_CHARS[@]} ))
            sleep 0.1
        done
    ) &

    # Store spinner process ID
    SPINNER_PID=$!
}

stop_spinner() {
    local success=$1
    
    # Kill spinner process
    kill $SPINNER_PID 2>/dev/null
    
    # Show cursor
    tput cnorm
    
    # Clear spinner line
    echo -ne "\r\033[K"
    
    # Show final status
    if [[ $success -eq 0 ]]; then
        log_success "$2"
    else
        log_error "$3"
    fi
}

# Progress bar for long operations
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\rProgress: ["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' ' '
    printf "] %d%%" "$percentage"
}

# Verbose logging (controlled by -v flag)
VERBOSE=0

log_verbose() {
    if [[ $VERBOSE -eq 1 ]]; then
        echo -e "${BLUE}verbose${NC} $1"
    fi
}

# To clarify some parts of the syntax