#!/bin/bash

# Chemins des répertoires
SCRIPT_DIR=$(dirname "$0")
RAW_DATA_DIR="$SCRIPT_DIR/../raw_data"
RAW_TEXT_DIR="$SCRIPT_DIR/../raw_text"

# Vérifier que pdftotext est installé
if ! command -v pdftotext &> /dev/null; then
    echo "Erreur : pdftotext n'est pas installé. Veuillez l'installer avec 'sudo apt-get install poppler-utils' (Debian/Ubuntu) ou équivalent."
    exit 1
fi

# Parcourir tous les fichiers PDF dans raw_data et ses sous-répertoires
find "$RAW_DATA_DIR" -type f -name "*.pdf" | while read -r pdf_file; do
    # Chemin relatif par rapport à raw_data
    relative_path="${pdf_file#$RAW_DATA_DIR/}"
    # Chemin du fichier texte correspondant dans raw_text
    txt_file="$RAW_TEXT_DIR/${relative_path%.pdf}.pdf.txt"

    # Vérifier si le fichier texte n'existe pas
    if [ ! -f "$txt_file" ]; then
        echo "Conversion de : $pdf_file vers $txt_file"
        # Créer le répertoire parent s'il n'existe pas
        mkdir -p "$(dirname "$txt_file")"
        # Convertir le PDF en texte
        pdftotext -nopgbrk "$pdf_file" "$txt_file"
        if [ $? -eq 0 ]; then
            echo "Conversion réussie : $txt_file"
        else
            echo "Erreur lors de la conversion de : $pdf_file"
        fi
    else
        echo "Déjà converti : $pdf_file (-> $txt_file existe)"
    fi
done

echo "Traitement terminé."