# Banana Catch

Petit jeu d'arcade 2D inspiré de Smash Bros. Un Singe te lance des Bananes : attrape-les au bon moment, sans les laisser tomber et sans te les prendre dans la figure. Tous les visuels et les sons sont générés par code.

## Jouer

- **Dans le navigateur** : ouvre le lien de la version web. Clique une fois dans la page pour activer le son.
- **Contrôles clavier** : flèches ou ZQSD pour bouger, haut / Z / Espace pour sauter, **J ou X pour attraper**, K / C / Maj pour le dash, Échap pour la pause.
- **Manette** : stick ou croix pour bouger, A pour sauter, **B pour attraper**, RB pour le dash, Start pour la pause.

Une Banane qui te touche pendant ta Fenêtre d'attrape (un court instant après l'appui) est attrapée. Sinon, c'est un Coup : ton Pourcentage monte et tu es éjecté. Une Banane qui touche la Plateforme principale ou tombe dans le vide te coûte un Stock. Tu as 3 Stocks.

## Développer

Prérequis : [Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/), version standard (pas .NET).

```bash
./tools/godot.sh editeur      # ouvrir le projet dans l'éditeur Godot
./tools/godot.sh jeu          # lancer le jeu
./tools/godot.sh tests        # lancer les tests sans affichage (code de sortie 0 = tout passe)
./tools/godot.sh export-web   # exporter la version web dans build/web/
```

Le script cherche Godot dans cet ordre : la variable `GODOT_BIN`, puis la commande `godot` du PATH, puis `/Applications/Godot.app`. Par exemple :
`GODOT_BIN=/chemin/vers/Godot ./tools/godot.sh tests`. L'export web demande les modèles d'export de Godot 4.7.2 (Éditeur → Gérer les modèles d'export).

Pour s'y retrouver :
- `GLOSSARY.md` : le vocabulaire du jeu (Joueur, Singe, Banane, Attrape, Coup, Échec, Stock…).
- `.scratch/banana-catch/` : la spec et les tickets.
- `src/reglages.gd` : toutes les valeurs ajustables.
- `src/partie.gd` : les règles, dans la scène de Partie. C'est le seul point d'entrée des tests (`tests/unit/`).
