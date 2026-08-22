#!/bin/bash

# Vérification des prérequis
if [ -z "$1" ]; then
    echo "Usage: $0 <url>"
    echo "Exemple: $0 https://www.hedios.com/gammes-h/h-rendement-64"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "Erreur: curl est requis mais n'est pas installé."
    exit 1
fi

url="$1"

# Extraction du type de produit et du numéro depuis l'URL
if [[ "$url" =~ h-([a-z]+)-([0-9]+) ]]; then
    product_type="${BASH_REMATCH[1]}"
    product_number="${BASH_REMATCH[2]}"
else
    echo "Erreur: URL non reconnue. Format attendu: https://www.hedios.com/gammes-h/h-[type]-[number]"
    exit 1
fi

# Construction du nom de base pour les fichiers
base_name="h_${product_type}_${product_number}"

# Récupération du code ISIN depuis la page
isin=$(curl -s -L "$url" | grep -oP '<td>\K[A-Z]{2}[0-9A-Z]{10}' | head -1)

if [ -z "$isin" ]; then
    echo "Erreur: Impossible de trouver le code ISIN dans la page."
    exit 1
fi

echo "Code ISIN trouvé: $isin"

# Création du dossier de sortie
script_dir=$(dirname "$0")
output_dir="${script_dir}/../../raw_data/hedios/${isin}"
mkdir -p "$output_dir"

# Sauvegarde de la page HTML
html_filename="${output_dir}/${isin}_${base_name}_page.html"
if curl -s -L "$url" -o "$html_filename"; then
    echo "Page HTML sauvegardée dans: $html_filename"
else
    echo "Erreur: Échec de la sauvegarde de la page HTML."
    exit 1
fi

# Définition des URLs et noms de fichiers pour les PDF
declare -A pdfs=(
    ["https://www.hedios.com/sites/default/files/brochures/medium_term/1_${base_name}_brochure.pdf"]="${output_dir}/${isin}_${base_name}_brochure.pdf"
    ["https://www.hedios.com/sites/default/files/others/medium_term/2_${base_name}_annexe_complementaire.pdf"]="${output_dir}/${isin}_${base_name}_annexe_complementaire.pdf"
    ["https://www.hedios.com/sites/default/files/others/medium_term/5_${base_name}_informations_cles.pdf"]="${output_dir}/${isin}_${base_name}_informations_cles.pdf"
)

# Téléchargement des PDF
for pdf_url in "${!pdfs[@]}"; do
    pdf_filename="${pdfs[$pdf_url]}"
    if curl -s -f -L "$pdf_url" -o "$pdf_filename"; then
        echo "PDF téléchargé: $pdf_filename"
    else
        echo "Avertissement: Échec du téléchargement de $pdf_url"
        rm -f "$pdf_filename"
    fi
done

echo "Toutes les opérations sont terminées. Les fichiers sont disponibles dans le dossier: $output_dir"