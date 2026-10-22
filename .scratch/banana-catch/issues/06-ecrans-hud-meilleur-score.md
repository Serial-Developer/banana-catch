# 06 : Écrans, HUD, pause et Meilleur score

Status: ready-for-agent
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

- [ ] Tests qui vérifient que :
  - le signal Fin de Partie indique si le Meilleur score transmis au démarrage est battu ;
  - la pause fige les Bananes en vol et le temps de la Fenêtre d'attrape.
- [ ] Vérification manuelle :
  - parcours titre → Partie → fin → Rejouer → titre ;
  - le Meilleur score survit à un redémarrage du jeu ;
  - le Pourcentage du HUD change de couleur en montant.

## Comments
