#!/bin/bash

# Check if user can run Docker commands without sudo
docker ps &>/dev/null
RESULT=$?

if [[ "$RESULT" -ne 0 ]]; then
    echo -e "${BRED}[-] Please run $0 as root${RESET}"
    exit 1
fi

# Color codes
BRED="\033[1;31m"
BGREEN="\033[1;32m"
BCYAN='\033[1;36m'
BYELLOW='\033[1;33m'
YELLOW='\033[0;33m'
BBLUE='\033[1;34m'
RESET="\033[0m"

DOCKERID=""
DOCKERNAME="postgres"
BINDS=""
IP=""

if [[ -z $1 ]]; then
    echo -e "${BYELLOW}[-] No docker name specified..."
    echo -e "${BGREEN}[+] Using ${BCYAN}$DOCKERNAME${RESET}"
else
    DOCKERNAME=$1
fi

echo -e "${BGREEN}[+] Docker name: ${BCYAN}$DOCKERNAME${RESET}"

until [ -n "$DOCKERID" ]; do
    sleep 0.1
    echo -e "${BBLUE}[+] Looking for Docker ID...${RESET}"
    DOCKERID=$(docker ps | grep -i "$DOCKERNAME" | head -n 1 | awk '{print $1}')
done

echo -e "${BGREEN}[+] Aquired Docker ID: ${BCYAN}$DOCKERID${RESET}"

BINDS=$(docker inspect -f '{{range.NetworkSettings.Ports}}{{.}}{{end}}' "$DOCKERID")
if [[ -z $BINDS ]]; then
    echo -e "${BRED}[-] No port mappings found${RESET}"
else
    echo -en "${BGREEN}[+] Port mappings:${RESET}\n"
    echo -e "${BCYAN} $BINDS ${RESET}"
fi

IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$DOCKERID")
if [[ -z $IP ]]; then
    echo -e "${BRED}[-] No IP address found"
else
    echo -e "${BGREEN}[+] IP address: ${BCYAN}$IP${RESET}"
fi

echo -e "${BGREEN}[+] Displaying logs continously:\n\n${RESET}"
echo -e "${YELLOW}"
docker logs -f "$DOCKERID"

echo -en "${RESET}\n\n"
