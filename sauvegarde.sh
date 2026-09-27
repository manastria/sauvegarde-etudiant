#!/bin/bash
# ============================================================
# sauvegarde.sh
#
# Ce script sert à sauvegarder un dossier de projet dans une
# "archive" (un seul fichier qui contient tout le dossier),
# rangée dans le dossier ~/Sauvegardes.
#
# Usage :
#   ./sauvegarde.sh                 -> sauvegarde le dossier courant
#   ./sauvegarde.sh /chemin/projet  -> sauvegarde ce dossier précis
#
# Une fois l'archive créée, il suffit de la glisser dans un
# service en ligne (OneDrive / Google Drive) et/ou sur une clé USB.
# ============================================================

# "set -e" veut dire : si une commande de ce script échoue
# (renvoie un code de retour différent de 0), le script s'arrête
# tout de suite au lieu de continuer avec des données incohérentes.
set -e


# ------------------------------------------------------------
# Étape 1 : déterminer quel dossier on doit sauvegarder
# ------------------------------------------------------------

# "$#" est une variable spéciale qui contient le NOMBRE d'arguments
# donnés au script au moment de le lancer.
# Exemple : pour "./sauvegarde.sh /chemin/projet", "$#" vaut 1.
if [ "$#" -eq 0 ]
then
    # Aucun argument fourni : on sauvegarde le dossier dans lequel
    # on se trouve actuellement.
    # "pwd" = "print working directory" = affiche le dossier courant.
    DOSSIER_A_SAUVEGARDER="$(pwd)"
else
    # Un argument a été fourni : "$1" contient ce premier argument,
    # c'est-à-dire le chemin donné par l'utilisateur.
    DOSSIER_A_SAUVEGARDER="$1"
fi

# "readlink -f" transforme un chemin en chemin absolu et "propre"
# (il enlève les éventuels "..", résout les liens symboliques, etc.).
# On écrase la variable avec cette version nettoyée du chemin.
DOSSIER_A_SAUVEGARDER="$(readlink -f "$DOSSIER_A_SAUVEGARDER")"

# "-d" teste si le chemin existe ET s'il s'agit bien d'un dossier.
# "!" veut dire "non" : on entre dans le "if" si ce n'est PAS un dossier.
if [ ! -d "$DOSSIER_A_SAUVEGARDER" ]
then
    echo "Erreur : ce dossier n'existe pas :"
    echo "  $DOSSIER_A_SAUVEGARDER"
    # "exit 1" arrête le script avec un code d'erreur (1 = erreur).
    exit 1
fi


# ------------------------------------------------------------
# Étape 2 : préparer les noms utiles pour la suite
# ------------------------------------------------------------

# "basename" garde uniquement le dernier morceau d'un chemin.
# Exemple : basename "/home/etu/mon_projet" -> "mon_projet"
NOM_DU_PROJET="$(basename "$DOSSIER_A_SAUVEGARDER")"

# "dirname" garde tout le chemin SAUF le dernier morceau.
# Exemple : dirname "/home/etu/mon_projet" -> "/home/etu"
# On en a besoin car la commande "tar" a besoin de savoir dans
# quel dossier "se placer" avant de faire l'archive.
DOSSIER_PARENT="$(dirname "$DOSSIER_A_SAUVEGARDER")"


# ------------------------------------------------------------
# Étape 3 : préparer le dossier et le nom de l'archive
# ------------------------------------------------------------

# "$HOME" est une variable d'environnement qui contient le chemin
# du dossier personnel de l'utilisateur (ex: /home/etu).
DOSSIER_DESTINATION="$HOME/Sauvegardes"

# "mkdir -p" crée le dossier de destination.
# L'option "-p" fait deux choses utiles :
#   - elle ne renvoie pas d'erreur si le dossier existe déjà ;
#   - elle crée aussi les dossiers "parents" manquants si besoin.
mkdir -p "$DOSSIER_DESTINATION"

# "date +%Y%m%d_%H%M%S" affiche la date et l'heure actuelles,
# formatées ainsi : AnnéeMoisJour_HeureMinuteSeconde
# Exemple : 20260927_143012
DATE_ET_HEURE="$(date +%Y%m%d_%H%M%S)"

# "$USER" est une variable d'environnement qui contient le nom
# de l'utilisateur connecté (ex: etu).
# On construit le nom de l'archive en assemblant plusieurs
# informations, séparées par des underscores "_", pour que le nom
# soit unique et facile à identifier.
NOM_ARCHIVE="${USER}_${NOM_DU_PROJET}_${DATE_ET_HEURE}.tar.zst"
CHEMIN_ARCHIVE="$DOSSIER_DESTINATION/$NOM_ARCHIVE"

echo "Sauvegarde de $DOSSIER_A_SAUVEGARDER vers :"
echo "  $CHEMIN_ARCHIVE"
echo


# ------------------------------------------------------------
# Étape 4 : vérifier si l'outil "zstd" est disponible
# ------------------------------------------------------------
#
# "tar" peut compresser une archive de deux façons :
#   - avec "zstd" : plus rapide et plus compact, mais pas toujours installé ;
#   - avec "gzip" : un peu moins efficace, mais installé quasiment partout.
#
# On va donc d'abord vérifier si "zstd" est disponible, puis essayer
# de l'utiliser, et sinon on se rabattra sur "gzip".

# "command -v zstd" est une commande qui recherche le programme "zstd".
#   - Si "zstd" existe, elle renvoie le code de retour 0.
#   - Si "zstd" n'existe pas, elle renvoie un code de retour différent de 0.
# ">/dev/null" jette l'affichage normal de la commande (on ne veut pas le voir).
# "2>/dev/null" jette aussi les éventuels messages d'erreur.
#
# On place cette commande dans un "if" : cela permet de réagir à son
# code de retour SANS faire arrêter le script (rappel : "set -e" arrête
# le script à la première commande en échec, sauf quand elle est testée
# par un "if").
if command -v zstd >/dev/null 2>/dev/null
then
    ZSTD_EST_INSTALLE="oui"
else
    ZSTD_EST_INSTALLE="non"
fi


# ------------------------------------------------------------
# Étape 5 : essayer de créer l'archive avec zstd (si possible)
# ------------------------------------------------------------

# Par défaut, on part du principe que ça n'a pas fonctionné.
# On corrigera cette variable juste après si ça marche vraiment.
ARCHIVE_CREEE_AVEC_ZSTD="non"

if [ "$ZSTD_EST_INSTALLE" = "oui" ]
then
    echo "zstd est disponible, tentative de création de l'archive..."

    # "tar" : commande qui crée l'archive.
    #   -c : "create", on crée une nouvelle archive
    #   -f : "file", le nom du fichier archive à créer
    #   --zstd : on demande la compression au format zstd
    #   -C "$DOSSIER_PARENT" : on demande à "tar" de se placer dans ce
    #        dossier avant de travailler (comme un "cd" temporaire)
    #   "$NOM_DU_PROJET" : le dossier à mettre dans l'archive
    #
    # "2>/dev/null" jette les messages d'erreur si la commande échoue.
    # On met cette commande dans un "if" pour éviter que "set -e"
    # n'arrête le script en cas d'échec : on veut pouvoir réagir
    # nous-mêmes avec le "gzip" de secours.
    if tar --zstd -cf "$CHEMIN_ARCHIVE" -C "$DOSSIER_PARENT" "$NOM_DU_PROJET" 2>/dev/null
    then
        ARCHIVE_CREEE_AVEC_ZSTD="oui"
    fi
fi


# ------------------------------------------------------------
# Étape 6 : si zstd n'a pas fonctionné, on utilise gzip à la place
# ------------------------------------------------------------

if [ "$ARCHIVE_CREEE_AVEC_ZSTD" = "non" ]
then
    echo "zstd indisponible ou échec : utilisation de gzip à la place."

    # On change le nom et l'extension de l'archive pour refléter
    # le nouveau format utilisé (.tar.gz au lieu de .tar.zst).
    NOM_ARCHIVE="${USER}_${NOM_DU_PROJET}_${DATE_ET_HEURE}.tar.gz"
    CHEMIN_ARCHIVE="$DOSSIER_DESTINATION/$NOM_ARCHIVE"

    # Ici, pas de "if" : si cette commande échoue, on préfère que
    # "set -e" arrête le script, car on n'a plus de solution de secours.
    #   -c : create      -f : nom du fichier      -z : compression gzip
    tar -czf "$CHEMIN_ARCHIVE" -C "$DOSSIER_PARENT" "$NOM_DU_PROJET"
fi


# ------------------------------------------------------------
# Étape 7 : message de fin et ouverture du dossier de destination
# ------------------------------------------------------------

echo
echo "Archive créée avec succès :"
echo "  $CHEMIN_ARCHIVE"
echo
echo "Glissez ce fichier dans votre navigateur (OneDrive / Google Drive)"
echo "et/ou copiez-le sur votre clé USB."

# "xdg-open" ouvre le gestionnaire de fichiers graphique sur le dossier
# donné en argument, pour que l'utilisateur puisse facilement glisser
# le fichier vers son navigateur ou sa clé USB.
#
# Le "&" à la fin de la ligne veut dire : "lance cette commande en
# arrière-plan et continue le script sans attendre qu'elle se termine".
# ">/dev/null 2>&1" jette l'affichage normal ET les erreurs :
#   - ">/dev/null" redirige la sortie normale vers "la poubelle" ;
#   - "2>&1" redirige la sortie d'erreur (flux numéro 2) vers le même
#     endroit que la sortie normale (flux numéro 1), donc vers /dev/null.
xdg-open "$DOSSIER_DESTINATION" >/dev/null 2>&1 &
