#!/bin/bash


# Colores ANSI usando \e
ve='\e[1;32m'
azul='\e[1;34m'
rojo='\e[1;31m'
reset='\e[0m'
sin_color='\033[0m'
ama='\e[33m'

# Colores ANSI
CRE='\033[31m'  # Rojo 
CYE='\033[33m'  # Amarillo
CGR='\033[32m'  # Verde
CBL='\033[34m'  # Azul  
CBLE='\033[36m' # Cyan
CBK='\033[37m'  # Blanco
CGY='\033[38m'  # Gris
BLD='\033[1m'   # Negrita
CNC='\033[0m'   # Resetear colores

# Función para imprimir línea animada
animar_linea() {
    texto="$1"
    for ((i = 0; i < ${#texto}; i++)); do
        echo -ne "${texto:$i:1}"
        sleep 0.02
    done
    echo
}
clear

echo "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  "
echo "░░░░░░░▄██▄░░░░░░▄▄░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  "
echo "░░░░░░░▐███▀░░░░░▄███▌░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  "
echo "░░▄▀░░▄█▀▀░░░░░░░░▀██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  "
echo "░█░░░██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  "
echo "█▌░░▐██░░▄██▌░░▄▄▄░░░▄░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  "
echo "██░░▐██▄░▀█▀░░░▀██░░▐▌░░░░  _        _ __   __    ░░░░░░░░  "
echo "██▄░▐███▄▄░░▄▄▄░▀▀░▄██░░░░   \  /\  / |_   |__|   ░░░░░░░░  "
echo "▐███▄██████▄░▀░▄█████▌░░░░    \/  \/  |__  |__|   ░░░░░░░░  "
echo "▐████████████▀▀██████░  ___  ____ ____ _  _ ____ ____ ░░░░  "
echo "░▐████▀██████░░█████░░  |  \ |  | |    |_/  |___ |__/ ░░░░  "
echo "░░░▀▀▀░░█████▌░████▀░░  |__/ |__| |___ | \_ |___ |  \ ░░░░  "
echo "░░░░░░░░░▀▀███░▀▀▀░░░░                                ░░░░  "
echo "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  "


# Mostrar banner
echo -e "${azul}╔════════════════════════════════════════════════════════╗"
animar_linea   "║                Welcome to our Website                  ║"
animar_linea   "║        Developed by: Alfonso Company Rodriguez         ║"
echo -e "${azul}╚════════════════════════════════════════════════════════╝${sin_color}"
sleep 1



TAR_FILE="$1"

# ------------------------------
# Función para mostrar_spinner
# ------------------------------

mostrar_spinner() {
    local pid=$1
    local delay=0.30
    local spinstr='⏳ ⏳ ⏳ ⏳ '
    local i=0

    echo -n " "
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r\e[1;93mEsperando... ${spinstr:$i:1}\e[0m"
        sleep $delay
    done
    
}


# ------------------------------
# Función para detener y eliminar contenedor e imagen si ya existen
# ------------------------------
detener_y_eliminar_contenedor() {
    IMAGE_NAME="${TAR_FILE%.tar}"
    CONTAINER_NAME="${IMAGE_NAME}_container"

    # Detener y eliminar contenedor si está en ejecución o detenido
    if docker ps -q -f name="$CONTAINER_NAME" > /dev/null; then
        docker stop "$CONTAINER_NAME" > /dev/null 2>&1
        docker rm "$CONTAINER_NAME" > /dev/null 2>&1
    elif docker ps -a -q -f name="$CONTAINER_NAME" > /dev/null; then
        docker rm "$CONTAINER_NAME" > /dev/null 2>&1
    fi

    # Eliminar imagen si ya existe
    if docker images -q "$IMAGE_NAME" > /dev/null; then
        docker rmi "$IMAGE_NAME" > /dev/null 2>&1
    fi
}

# ------------------------------
# Manejador para Ctrl+C
# ------------------------------
ctrl_c() {
    echo -e "\n\e[1mEliminando el laboratorio, espere un momento...\e[0m"
     # Oculta el cursor
    tput civis

    detener_y_eliminar_contenedor &
     mostrar_spinner $!

      # Muestra el cursor nuevamente
    tput cnorm
    stty echoctl
    echo -e "\n\e[1mEl laboratorio ha sido eliminado por completo del sistema.\e[0m"
    exit 0
}

trap ctrl_c INT

# ------------------------------
# Verificación de argumentos
# ------------------------------
if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_tar>"
    exit 1
fi

TAR_FILE="$1"

# ------------------------------
# Verificar si Docker está instalado
# ------------------------------
if ! command -v docker &> /dev/null; then
    echo -e "\033[1;36m\nDocker no está instalado. Instalando Docker...\033[0m"
    sudo apt update
    sudo apt install docker.io -y
    echo -e "\033[1;36m\nHabilitando el servicio de Docker. Espere un momento...\033[0m"
    sleep 10
    sudo systemctl restart docker && sudo systemctl enable docker
    if [ $? -eq 0 ]; then
        echo "Docker ha sido instalado correctamente."
    else
        echo "Error al instalar Docker. Por favor, verifique e intente de nuevo."
        exit 1
    fi
fi

# ------------------------------
# Despliegue de la máquina
# ------------------------------
echo -e "\e[1;93m\nDesplegando Contenedores,   espera......\e[0m"
detener_y_eliminar_contenedor

# Cargar la imagen en segundo plano y mostrar animación
docker load -i "$TAR_FILE" > /dev/null 2>&1 &

# ------------------------------
# Ocultar ^C
# ------------------------------
stty -echoctl


 # Oculta el cursor
    tput civis
mostrar_spinner $!


if docker load -i "$TAR_FILE" > /dev/null 2>&1; then
    IMAGE_NAME="${TAR_FILE%.tar}"
    CONTAINER_NAME="${IMAGE_NAME}_container"

    docker run -d --name "$CONTAINER_NAME" "$IMAGE_NAME" > /dev/null 2>&1

    IP_ADDRESS=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")

    echo -e "\e[1;96m\nMáquina desplegada, su dirección IP es --> \e[0m\e[1;97m$IP_ADDRESS\e[0m"
    echo -e "\e[1;91m\nPresiona Ctrl+C cuando termines con la máquina para eliminarla\e[0m"

     # Muestra el cursor nuevamente
    tput cnorm
    
else
    echo -e "\e[91m\nHa ocurrido un error al cargar el laboratorio en Docker.\e[0m"
    exit 1
fi




# ------------------------------
# Espera indefinida
# ------------------------------
while true; do
    sleep 1
done
