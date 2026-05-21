#!/bin/bash

VERSION="4.0 ULTRA"
INSTALL_PATH="/usr/local/bin/tizrang"

RED=$'\e[1;31m'
GREEN=$'\e[1;32m'
YELLOW=$'\e[1;33m'
BLUE=$'\e[1;34m'
MAGENTA=$'\e[1;35m'
CYAN=$'\e[1;36m'
WHITE=$'\e[1;37m'
NC=$'\e[0m'

LANGUAGE="fa"

fa_title="ابزار تحلیل امنیتی TizRang"
en_title="TizRang Security Toolkit"

if [[ "$1" == "--install" ]]; then

    chmod +x "$0"

    if [ "$PREFIX" != "" ]; then
        INSTALL_PATH="$PREFIX/bin/tizrang"
    fi

    cp "$0" "$INSTALL_PATH"
    chmod +x "$INSTALL_PATH"

    echo "[+] Installing dependencies..."

    if command -v pkg >/dev/null 2>&1; then
        pkg update -y
        pkg install -y curl whois dnsutils nmap openssl jq
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y curl whois dnsutils nmap openssl jq
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm curl whois bind nmap openssl jq
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y curl whois bind-utils nmap openssl jq
    fi

    echo "[+] Installed successfully"
    echo "[+] Run using: tizrang"

    exit
fi

if [[ "$1" == "--uninstall" ]]; then

    rm -f "$INSTALL_PATH"

    echo "[+] TizRang removed"

    exit
fi

banner() {
clear

echo -e "${BLUE}"
cat << "EOF"

 ████████╗██╗███████╗██████╗  █████╗ ███╗   ██╗ ██████╗
╚══██╔══╝██║╚══███╔╝██╔══██╗██╔══██╗████╗  ██║██╔════╝
   ██║   ██║  ███╔╝ ██████╔╝███████║██╔██╗ ██║██║  ███╗
   ██║   ██║ ███╔╝  ██╔══██╗██╔══██║██║╚██╗██║██║   ██║
   ██║   ██║███████╗██║  ██║██║  ██║██║ ╚████║╚██████╔╝
   ╚═╝   ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝

EOF

echo -e "${NC}"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}        TizRang Cyber Intelligence Suite${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${BLUE}Version:${NC} ${VERSION}"
echo -e "${BLUE}Platform:${NC} Linux / Termux"
echo -e "${BLUE}Mode:${NC} Defensive Security Analysis"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

}

check_dependencies() {
for cmd in curl whois dig nmap openssl jq; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo -e "${RED}Missing:${NC} $cmd"
    fi
done
}

resolve_ip() {
    echo -e "${BLUE}[+] IP Resolution${NC}"
    dig +short "$TARGET"
}

whois_lookup() {
    echo -e "${BLUE}[+] WHOIS${NC}"
    whois "$TARGET" | head -n 40
}

advanced_dns() {
    echo -e "${BLUE}[+] DNS Analysis${NC}"

    dig "$TARGET" ANY +short

    echo

    for type in A AAAA MX TXT NS CNAME SOA; do
        echo "==== $type ===="
        dig "$TARGET" $type +short
        echo
    done
}

subdomain_scan() {
    echo -e "${BLUE}[+] Subdomain Discovery${NC}"

    for sub in www api dev test beta mail admin ftp vpn ns1 ns2 blog shop panel cdn static; do
        host "$sub.$TARGET" | grep "has address"
    done
}

port_scan() {
    echo -e "${BLUE}[+] Port Scan${NC}"
    nmap -Pn -T4 "$TARGET"
}

aggressive_scan() {
    echo -e "${YELLOW}[+] Aggressive Detection${NC}"
    nmap -A "$TARGET"
}

ssl_analysis() {
    echo -e "${BLUE}[+] SSL Analysis${NC}"

    echo | openssl s_client -connect "$TARGET":443 2>/dev/null | openssl x509 -noout -issuer -dates
}

security_headers() {
    echo -e "${BLUE}[+] Security Headers${NC}"

    curl -I -L -s "https://$TARGET"
}

technology_detection() {
    echo -e "${BLUE}[+] Technology Detection${NC}"

    headers=$(curl -I -s "https://$TARGET")

    echo "$headers" | grep -i server
    echo "$headers" | grep -i powered
    echo "$headers" | grep -i cloudflare
}

geoip() {
    echo -e "${BLUE}[+] GeoIP${NC}"

    ip=$(dig +short "$TARGET" | head -n1)

    curl -s "http://ip-api.com/json/$ip" | jq
}

risk_analysis() {
    echo -e "${RED}[+] Risk Analysis${NC}"

    headers=$(curl -I -s "https://$TARGET")

    if ! echo "$headers" | grep -iq "content-security-policy"; then
        echo "[!] Missing CSP"
    fi

    if ! echo "$headers" | grep -iq "x-frame-options"; then
        echo "[!] Missing X-Frame-Options"
    fi

    if ! echo "$headers" | grep -iq "strict-transport-security"; then
        echo "[!] Missing HSTS"
    fi

    echo

    echo "Potential Threats:"
    echo "- Clickjacking"
    echo "- MITM Risk"
    echo "- Header Leakage"
    echo "- Open Ports"
    echo "- DNS Exposure"
    echo "- Weak SSL Config"
}

save_report() {

    FILE="tizrang_report_$(date +%Y%m%d_%H%M%S).txt"

    {
        echo "TizRang Report"
        echo "Target: $TARGET"
        echo "Date: $(date)"
        echo

        resolve_ip
        whois_lookup
        advanced_dns
        subdomain_scan
        port_scan
        aggressive_scan
        ssl_analysis
        security_headers
        technology_detection
        geoip
        risk_analysis

    } > "$FILE"

    echo -e "${GREEN}[+] Saved:${NC} $FILE"
}

full_scan() {
    resolve_ip
    whois_lookup
    advanced_dns
    subdomain_scan
    port_scan
    aggressive_scan
    ssl_analysis
    security_headers
    technology_detection
    geoip
    risk_analysis
}

trap_ctrlq() {

    while true; do
        read -rsn1 key

        if [[ "$key" == $'' ]]; then
            echo
            printf "${RED}[+] Exiting TizRang...${NC}
"
            tput cnorm
            exit
        fi
    done

}

trap_ctrlq &

banner
check_dependencies

echo
read -p "Target: " TARGET

while true; do

    echo
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║            MAIN MENU                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"

    echo -e "${BLUE}[1]${NC} Full Intelligence Scan"
    echo -e "${BLUE}[2]${NC} Advanced DNS Analysis"
    echo -e "${BLUE}[3]${NC} Smart Port Scan"
    echo -e "${BLUE}[4]${NC} Aggressive Detection"
    echo -e "${BLUE}[5]${NC} SSL/TLS Inspector"
    echo -e "${BLUE}[6]${NC} Security Headers Audit"
    echo -e "${BLUE}[7]${NC} Risk & Threat Analysis"
    echo -e "${BLUE}[8]${NC} Generate Professional Report"
    echo -e "${BLUE}[9]${NC} Switch Language"
    echo -e "${RED}[0]${NC} Exit"

    echo

    read -p "TizRang > " option

    case $option in
        1) full_scan ;;
        2) advanced_dns ;;
        3) port_scan ;;
        4) aggressive_scan ;;
        5) ssl_analysis ;;
        6) security_headers ;;
        7) risk_analysis ;;
        8) save_report ;;
        9)
            if [ "$LANGUAGE" == "fa" ]; then
                LANGUAGE="en"
            else
                LANGUAGE="fa"
            fi
            banner
        ;;
        0)
            echo -e "${RED}Exiting TizRang...${NC}"
            exit
        ;;
        *)
            echo -e "${RED}Invalid Option${NC}"
        ;;
    esac

done