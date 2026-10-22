# 08 : Effets sonores synthétisés

Status: ready-for-agent
Blocked by: 03, 04
Spec: ../spec.md (user story 56)

## Objectif

Donner à chaque événement de la Partie un son distinct, entièrement généré par code.

## À faire

- Un module audio qui synthétise des sons courts avec le générateur audio de Godot (ondes, bruit, enveloppes) :
  - Lancer : un « whoosh » ;
  - Attrape : un « ding » clair et satisfaisant ;
  - Coup : un impact sourd, plus fort quand l'Éjection est forte ;
  - Échec : un « splat » ;
  - perte de Stock : une explosion ;
  - Réapparition : un court jingle.
- Le module réagit aux signaux de la scène de Partie, sans aucune logique de jeu.
- Ajouter un volume global dans la ressource de réglages.
- Aucun fichier audio externe.

## Critères d'acceptation

- [ ] Toute la suite de tests existante passe toujours, sans erreur audio quand le jeu tourne sans affichage.
- [ ] Vérification manuelle : chaque événement a un son reconnaissable, et plusieurs sons simultanés ne saturent pas.

## Comments
