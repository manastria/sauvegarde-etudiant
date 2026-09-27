# Sauvegarde étudiant — scripts tar

Deux petits scripts (Linux et Windows) pour sauvegarder rapidement un dossier de travail en fin de séance, avant de le glisser vers un drive (OneDrive, Google Drive…) et/ou une clé USB.

## Pourquoi ce dépôt ?

En début d’année, un incident a montré qu’une clé USB éjectée trop vite peut faire perdre plusieurs jours de travail. Ces scripts ne remplacent pas une sauvegarde automatique, mais ils rendent le geste « je sauvegarde avant de partir » aussi simple qu’une seule commande.

## Récupérer les scripts

### Option 1 — créer sa propre copie (recommandé)

Ce dépôt est un *template* GitHub : en cliquant sur **Use this template → Create a new repository**, en haut de cette page, tu obtiens ta propre copie, sur ton compte, sans lien avec l’original. Tu peux ensuite la modifier et la versionner comme n’importe quel dépôt Git.

### Option 2 — récupération rapide, sans compte

Sur un poste du labo, en une seule commande :

```bash
git clone https://github.com/manastria/sauvegarde-etudiant.git
```

Sans Git, tu peux aussi télécharger directement chaque script via son bouton **Raw** sur GitHub.

## Utilisation

### Linux

```bash
chmod +x sauvegarde.sh
./sauvegarde.sh                    # sauvegarde le dossier courant
./sauvegarde.sh chemin/vers/projet # sauvegarde un dossier précis
```

### Windows

- Double-clic sur `sauvegarde.bat` : sauvegarde le dossier où se trouve le script.
- Glisser-déposer un dossier de projet directement sur l’icône `sauvegarde.bat`.
- En ligne de commande : `sauvegarde.bat C:\chemin\vers\projet`

## Ce que fait le script

1. Il empaquette et compresse (`tar --zstd`) le dossier indiqué — et bascule automatiquement sur `gzip` si `zstd` n’est pas installé sur le poste.
2. Il dépose l’archive dans un dossier `Sauvegardes` (bureau sous Windows, dossier personnel sous Linux) et ouvre l’explorateur de fichiers dessus.
3. Rien n’est envoyé automatiquement : c’est à toi de glisser l’archive vers ton drive (OneDrive Éducation, Google Drive…) et/ou de la copier sur ta clé USB.

## Pour aller plus loin

Le déroulé de la séance et le détail des commandes (`tar`, variables shell) sont repris dans le support de cours : *à compléter*.
