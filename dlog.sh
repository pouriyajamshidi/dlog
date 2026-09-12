#!/usr/bin/env bash

set -euo pipefail

# Colors, but only when we are talking to a terminal.
if [[ -t 1 ]]; then
    BRED="\033[1;31m"
    BGREEN="\033[1;32m"
    BCYAN="\033[1;36m"
    YELLOW="\033[0;33m"
    BBLUE="\033[1;34m"
    RESET="\033[0m"
else
    BRED="" BGREEN="" BCYAN="" YELLOW="" BBLUE="" RESET=""
fi

# Make sure we never leave the terminal stuck in yellow.
trap 'printf "%b" "$RESET"' EXIT

usage() {
    cat <<USAGE
Usage: ${0##*/} <container-name>

Waits for a Docker container whose name contains <container-name>
(case-insensitive), then prints its IP address and port mappings
and follows its logs.
USAGE
}

case "${1-}" in
-h | --help)
    usage
    exit 0
    ;;
esac

if [[ -z ${1-} ]]; then
    usage >&2
    exit 1
fi

if ! command -v docker &>/dev/null; then
    echo -e "${BRED}[-] docker not found in PATH${RESET}" >&2
    exit 1
fi

if ! docker ps &>/dev/null; then
    echo -e "${BRED}[-] Cannot talk to the Docker daemon.${RESET}" >&2
    echo -e "${BRED}[-] Is it running, and are you in the 'docker' group or root?${RESET}" >&2
    exit 1
fi

NAME="$1"

echo -e "${BGREEN}[+] Container name: ${BCYAN}${NAME}${RESET}"

echo -en "${BBLUE}[+] Looking for container ID...${RESET}"
while :; do
    # (?i) makes the name match case-insensitive; it is a substring match.
    ID=$(docker ps --filter "name=(?i)${NAME}" --format '{{.ID}}' | head -n 1)
    [[ -n $ID ]] && break
    echo -n "."
    sleep 0.5
done
echo

echo -e "${BGREEN}[+] Acquired container ID: ${BCYAN}${ID}${RESET}"

PORTS=$(docker port "$ID" || true)
if [[ -z $PORTS ]]; then
    echo -e "${BRED}[-] No port mappings found${RESET}"
else
    echo -e "${BGREEN}[+] Port mappings:${RESET}"
    echo -e "${BCYAN}${PORTS}${RESET}"
fi

IPS=$(docker inspect -f \
    '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}}: {{$conf.IPAddress}}{{"\n"}}{{end}}' \
    "$ID")
if [[ -z ${IPS//[[:space:]]/} ]]; then
    echo -e "${BRED}[-] No IP address found${RESET}"
else
    echo -e "${BGREEN}[+] IP addresses:${RESET}"
    echo -e "${BCYAN}${IPS}${RESET}"
fi

echo -e "${BGREEN}[+] Following logs:${RESET}\n"
echo -en "${YELLOW}"
docker logs -f "$ID"
