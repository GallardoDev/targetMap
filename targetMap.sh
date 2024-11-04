#!/bin/bash

echo -e "\e[32m"
echo "#############################################################"
echo "#                                                           #"
echo "#      ██████╗ ███████╗██████╗ ███████╗███████╗██████╗      #"
echo "#      ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗     #"
echo "#      ██║  ██║█████╗  ██████╔╝█████╗  █████╗  ██████╔╝     #"
echo "#      ██║  ██║██╔══╝  ██╔═══╝ ██╔══╝  ██╔══╝  ██╔══██╗     #"
echo "#      ██████╔╝███████╗██║     ██║     ███████╗██║  ██║     #"
echo "#      ╚═════╝ ╚══════╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝     #"
echo "#                       GallardoDev                         #"
echo "#           Herramienta de Recolección de Información       #"
echo "#############################################################"
echo -e "\e[0m\n"

# Solicita al usuario una IP o un dominio
read -p "Introduce la dirección IP o dominio objetivo: " target

# Función para verificar si un comando está disponible
check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "[ERROR] $1 no está instalado. Por favor instálalo antes de ejecutar este script."
    exit 1
  fi
}

# Verificar que los comandos necesarios estén disponibles
for cmd in "ping" "whois" "dig" "nmap" "curl"; do
  check_command "$cmd"
done

# Información general
echo -e "\n\033[32m[*] Recolectando información general...\033[0m"
ping_result=$(ping -c 1 "$target" | grep "bytes from" | awk '{print $4}' | tr -d ':')
whois_info=$(whois "$target" | grep -E 'OrgName|Country|Address|NetRange')

# DNS
echo -e "\033[32m[*] Recolectando información DNS...\033[0m"
dns_info=$(dig "$target" ANY +short)

# Escaneo de puertos
echo -e "\033[32m[*] Realizando escaneo de puertos...\033[0m"
nmap_info=$(nmap -Pn -F "$target" | grep "open")

# Geolocalización (usando ipinfo.io)
echo -e "\033[32m[*] Obteniendo información de geolocalización...\033[0m"
geo_info=$(curl -s "https://ipinfo.io/$target")

# Mostrar resultados en una tabla
echo -e "\n\033[32m============================================================\033[0m"
echo -e "                   \033[1mResumen de Información\033[0m                   "
echo -e "\033[32m============================================================\033[0m"

# Imprimir la información en formato de tabla
echo -e "\033[1m|\033[0m \033[1mCampo               \033[0m| \033[1mInformación                                    \033[0m|"
echo -e "\033[32m------------------------------------------------------------\033[0m"
echo -e "|\033[1m Dirección IP       \033[0m| $ping_result                           |"
echo -e "|\033[1m Organización       \033[0m| $(echo "$whois_info" | grep "OrgName" | cut -d ':' -f2) |"
echo -e "|\033[1m País               \033[0m| $(echo "$whois_info" | grep "Country" | cut -d ':' -f2) |"
echo -e "|\033[1m Rango de IPs       \033[0m| $(echo "$whois_info" | grep "NetRange" | cut -d ':' -f2) |"
echo -e "|\033[1m Servidores DNS     \033[0m| $dns_info                           |"
echo -e "|\033[1m Puertos Abiertos   \033[0m| $(echo "$nmap_info" | tr '\n' ',' | sed 's/,$//') |"
echo -e "|\033[1m Geolocalización    \033[0m| $(echo "$geo_info" | jq -r '.city, .region, .country') |"
echo -e "\033[32m============================================================\033[0m"
