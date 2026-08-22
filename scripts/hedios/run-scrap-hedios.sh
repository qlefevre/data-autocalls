#!/bin/bash

# Chemin relatif vers le script scrap-hedios.sh (supposé dans le même répertoire)
SCRIPT_PATH="./scrap-hedios.sh"

# Fonction pour générer les URLs et appeler le script
run_scrap() {
    local base_url="$1"
    local start="$2"
    local end="$3"

    for i in $(seq "$start" "$end"); do
        local url="${base_url%-*}-$i"
        echo "Appel de $SCRIPT_PATH avec l'URL : $url"
        "$SCRIPT_PATH" "$url"
    done
}

# Exécution pour chaque gamme
run_scrap "https://www.hedios.com/gammes-h/h-capital-0" 5 13
run_scrap "https://www.hedios.com/gammes-h/h-absolu-0" 18 24
run_scrap "https://www.hedios.com/gammes-h/h-performance-0" 55 71
run_scrap "https://www.hedios.com/gammes-h/h-rendement-0" 58 64

echo "Tous les appels ont été effectués."