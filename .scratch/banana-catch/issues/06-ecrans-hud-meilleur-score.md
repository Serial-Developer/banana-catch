# 06 : Écrans, HUD, pause et Meilleur score

Status: done
Blocked by: 03
Spec: ../spec.md (user stories 45 à 50)

## Objectif

Créer le parcours complet : écran titre, Partie avec HUD et pause, écran de fin avec Rejouer. Le Meilleur score est conservé entre deux lancements du jeu.

## À faire

- Écran titre : nom du jeu, Meilleur score, rappel des contrôles (clavier et manette), et une action pour démarrer.
- HUD pendant la Partie :
  - le Pourcentage en gros chiffre façon Smash, dont la couleur passe progressivement du blanc au rouge ;
  - les icônes des Stocks restants ;
  - le Score.
- Pause avec Échap ou Start : la simulation se fige et un menu propose Reprendre et Quitter (retour à l'écran titre).
- Écran de fin : Score, Meilleur score, mention « Nouveau meilleur score ! » si le record est battu, et deux actions, Rejouer et Titre.
- Meilleur score :
  - il est lu depuis un fichier dans le dossier utilisateur Godot et transmis à la scène de Partie au démarrage ;
  - la couche d'écrans le sauvegarde quand elle reçoit Fin de Partie ;
  - la scène de Partie n'écrit jamais sur le disque.
- Le HUD lit l'état et les signaux de la scène de Partie, et ne contient aucune règle.

## Critères d'acceptation

- [x] Tests qui vérifient que :
  - le signal Fin de Partie indique si le Meilleur score transmis au démarrage est battu ;
  - la pause fige les Bananes en vol et le temps de la Fenêtre d'attrape.
- [ ] Vérification manuelle :
  - parcours titre → Partie → fin → Rejouer → titre ;
  - le Meilleur score survit à un redémarrage du jeu ;
  - le Pourcentage du HUD change de couleur en montant.

## Comments

### Compte rendu (agent, 2026-10-22)

**Fait**
- Scène principale `scenes/jeu.tscn` (`Jeu`) : écran titre (Meilleur score et contrôles), puis Partie avec HUD, pause superposée (Reprendre, Quitter), puis écran de fin (Score, Meilleur score, « Nouveau meilleur score ! », Rejouer, Titre). Navigation au clavier et à la manette par le focus des boutons.
- HUD (`Hud`) : il ne fait que lire l'état de la Partie. Pourcentage en gros, dont la couleur passe progressivement du blanc au rouge entre 0 et 150 %, icônes de Stocks et Score.
- Pause dans la Partie (`en_pause()`, `mettre_en_pause()`, signal `pause_changee`, action `pause`) : tout ce qui se fige (Arène, Joueur, Singe, Bananes) est regroupé dans un nœud « Monde », désactivé pendant la pause.
- Meilleur score : il est lu dans `user://meilleur_score.cfg` par `Jeu` et transmis à la Partie. `Jeu` le sauvegarde à la réception de `fin_de_partie` si le record est battu. La Partie n'écrit jamais sur le disque.
- Outil `./tools/godot.sh capture <dossier>` : lance le jeu avec affichage, joue un scénario (titre, Partie, pause, fin) et enregistre des captures. Je l'ai utilisé pour vérifier les écrans.

**Décisions**
- Égaler le Meilleur score ne le bat pas : il faut le dépasser strictement. Un test le vérifie.
- L'écran de fin apparaît 1,2 s après la Fin de Partie, pour laisser voir le dernier Échec.
- La police est celle de Godot par défaut, sans fichier externe.

**À vérifier à la main**
- [ ] Le parcours titre → Partie → fin → Rejouer → titre, au clavier et à la manette.
- [ ] Le Meilleur score est conservé après un redémarrage du jeu.
- [ ] La couleur du Pourcentage dans le HUD change bien en montant.
