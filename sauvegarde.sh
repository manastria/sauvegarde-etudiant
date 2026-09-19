#!/bin/bash
# ============================================================
# sauvegarde.sh
# Usage :
#   ./sauvegarde.sh                 -> sauvegarde le dossier courant
#   ./sauvegarde.sh /chemin/projet  -> sauvegarde ce dossier précis
# Crée une archive tar --zstd (fallback tar.gz si zstd absent)
# dans ~/Sauvegardes, prête à être glissée vers un drive
# (OneDrive/Google Drive) et/ou une clé USB.
# ============================================================

set -e

SOURCE="${1:-$(pwd)}"
SOURCE="$(readlink -f "$SOURCE")"

if [ ! -d "$SOURCE" ]; then
    echo "Dossier introuvable : $SOURCE"
    exit 1
fi

PROJET="$(basename "$SOURCE")"
PARENT="$(dirname "$SOURCE")"

DESTDIR="$HOME/Sauvegardes"
mkdir -p "$DESTDIR"

HORODATAGE="$(date +%Y%m%d_%H%M%S)"
ARCHIVE="$DESTDIR/${USER}_${PROJET}_${HORODATAGE}.tar.zst"

echo "Sauvegarde de $SOURCE vers :"
echo "  $ARCHIVE"
echo

if command -v zstd >/dev/null 2>&1 && tar --zstd -cf "$ARCHIVE" -C "$PARENT" "$PROJET" 2>/dev/null; then
    :
else
    echo "zstd indisponible sur ce poste, utilisation de gzip à la place."
    ARCHIVE="$DESTDIR/${USER}_${PROJET}_${HORODATAGE}.tar.gz"
    tar -czf "$ARCHIVE" -C "$PARENT" "$PROJET"
fi

echo
echo "Archive créée avec succès :"
echo "  $ARCHIVE"
echo
echo "Glissez ce fichier dans votre navigateur (OneDrive / Google Drive)"
echo "et/ou copiez-le sur votre clé USB."

xdg-open "$DESTDIR" >/dev/null 2>&1 &
