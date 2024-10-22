#!/bin/bash

# Función para mostrar el arte ASCII del bunker
display_bunker() {
    echo "         ____ "
    echo "    ____/    \_____. "
    echo "    |              |"
    echo "    |   BUNKERBITS  |"
    echo "    |______________|"
    echo "                      "
    echo "      bunkerbits.cl   "
    echo "        By Stealbytes  "
}

# Inicializa la variable de la subred
SUBRED=""

# Llama a la función para mostrar el bunker
display_bunker

# Maneja la señal SIGINT (Ctrl+C)
trap 'echo -e "\nEjecución cancelada."; exit 0;' SIGINT

# Función para validar la dirección IP
validate_ip() {
    local ip="$1"
    # Expresión regular para validar la IP
    if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi

    # Validar que cada octeto esté en el rango 0-255
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    if (( i1 > 255 || i2 > 255 || i3 > 255 || i4 > 255 )); then
        return 1
    fi

    return 0
}

# Procesa los argumentos
while getopts "r:" opt; do
    case $opt in
        r)
            SUBRED="$OPTARG"
            ;;
        *)
            echo "Uso: $0 -r <IP_de_red>"
            echo "Ejemplo: $0 -r 192.168.0.0"
            exit 1
            ;;
    esac
done

# Verifica si se proporcionó una IP de red
if [ -z "$SUBRED" ]; then
    echo "Debe proporcionar una IP de red con el parámetro -r."
    echo "Ejemplo: $0 -r 192.168.0.0"
    exit 1
fi

# Valida la IP
if ! validate_ip "$SUBRED"; then
    echo "La dirección IP proporcionada no es válida. Debe ser en el formato xxx.xxx.xxx.xxx."
    echo "Ejemplo: $0 -r 192.168.0.0"
    exit 1
fi

# Extrae los primeros tres octetos de la dirección IP
IFS='.' read -r i1 i2 i3 i4 <<< "$SUBRED"
SUBRED_BASE="${i1}.${i2}.${i3}"

# Inicia un contador para el tiempo de ejecución
SECONDS=0
TIME_LIMIT=60

# Función para realizar el ping
ping_hosts() {
    for i in {1..254}; do
        IP="${SUBRED_BASE}.${i}"
        
        # Realiza el ping y verifica si hay respuesta
        if ping -c 1 -W 1 "$IP" > /dev/null; then
            # Si hay respuesta, imprime la IP
            echo "$IP está vivo"
        fi
        
        # Verifica si ha pasado el tiempo límite
        if [ "$SECONDS" -ge "$TIME_LIMIT" ]; then
            echo "Se alcanzó el tiempo de ejecución máximo de $TIME_LIMIT segundos."
            break
        fi
    done
}

# Ejecuta la función de ping en segundo plano
ping_hosts &

# Espera a que el proceso de ping finalice o se alcance el tiempo límite
wait

# Mensaje final
echo "Ejecución completada."
