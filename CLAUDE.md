# Contexte du projet

Ce dépôt contient des scripts de sauvegarde (`sauvegarde.sh` pour Linux/macOS,
`sauvegarde.bat` pour Windows) destinés à des **étudiants débutants**. Le but
n'est pas seulement que le script fonctionne, mais que les étudiants
puissent le lire, le comprendre et se l'approprier.

## Style d'écriture attendu pour ces scripts

- **Public cible : débutants.** Écrire comme si on expliquait le script à
  quelqu'un qui découvre le shell/bat. Privilégier la clarté à la concision
  ou à l'efficacité (tant pis si une commande est exécutée "pour rien" ou
  si on répète une vérification, pourvu que ce soit plus lisible).

- **Un commentaire par ligne ou par petit bloc**, expliquant surtout
  **à quoi elle sert** (l'intention), et si besoin **des précisions sur la
  syntaxe** (options de commande, redirections, variables spéciales comme
  `$#`, `$1`, `$?`, etc.). Ne pas se contenter de reformuler la commande en
  français : expliquer le rôle et, quand c'est utile, ce que renvoient les
  commandes (ex : "renvoie 0 si la commande existe, un autre code sinon").

- **Décomposer les commandes complexes.** Éviter les enchaînements du type
  `if commande1 && commande2; then` : les séparer en plusieurs étapes avec
  des `if` distincts et des **variables intermédiaires nommées de façon
  explicite** (ex : `ZSTD_EST_INSTALLE`, `ARCHIVE_CREEE_AVEC_ZSTD`) plutôt
  que des variables courtes ou des opérateurs enchaînés.

- **Noms de variables explicites et en français**, qui décrivent leur
  contenu plutôt que d'être des abréviations (`DOSSIER_A_SAUVEGARDER`,
  `NOM_DU_PROJET`, `CHEMIN_ARCHIVE`...).

- **Éviter les raccourcis idiomatiques** peu lisibles pour un débutant
  (ex : `${1:-$(pwd)}`, `cmd1 && cmd2 || cmd3`, `:` comme no-op). Préférer
  des `if`/`else` explicites même si c'est plus verbeux.

- Garder un en-tête de script clair (usage, ce que fait le script) et des
  messages `echo` qui informent l'utilisateur de ce qui se passe à chaque
  grande étape.

Cette convention s'applique à `sauvegarde.sh` et `sauvegarde.bat`, et à
tout futur script ajouté à ce dépôt pour un usage étudiant.
