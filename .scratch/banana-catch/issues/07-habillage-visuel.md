# 07 : Habillage visuel façon Smash

Status: ready-for-agent
Blocked by: 03, 04
Spec: ../spec.md (user stories 13 à 15, 26, 40, 54, 55, 57)

## Objectif

Remplacer les formes provisoires par un style cartoon inspiré de Smash, entièrement dessiné en code et sans aucun asset Nintendo, et ajouter les effets qui donnent du poids aux actions.

## À faire

- Joueur : un personnage original en formes vectorielles, avec des contours épais et des couleurs vives, et des poses distinctes pour :
  - repos et course ;
  - saut ;
  - Fenêtre d'attrape (bras tendus ou halo) ;
  - Récupération (visuel « essoufflé » ou grisé) ;
  - Éjection ;
  - Invulnérabilité (clignotement).
- Singe : un singe original qui fait penser à Diddy (casquette, salopette, queue) sans le copier, avec un Élan visuellement différent pour l'Arc, le Tir tendu et le Lob.
- Banane : forme cartoon qui tourne sur elle-même en vol.
- Arène : plateforme flottante stylisée et fond animé (ciel en dégradé, nuages ou parallaxe).
- Effets :
  - Attrape : particules et petit gel d'image ;
  - Coup : étincelles d'impact, gel d'image et secousse de caméra proportionnels à l'Éjection ;
  - Échec : la Banane s'écrase et laisse une tache ;
  - perte de Stock : explosion de sortie sur le bord de l'écran, comme dans Smash.
- Indicateur hors écran : une flèche en bord d'écran pointe vers chaque Banane sortie du cadre.
- Tous ces effets réagissent aux signaux de la scène de Partie et ne modifient pas les règles. Le gel d'image ne doit pas fausser les tests : désactivable via les réglages ou ignoré sans affichage.

## Critères d'acceptation

- [ ] Toute la suite de tests existante passe toujours.
- [ ] Vérification manuelle :
  - chaque état du Joueur est reconnaissable à l'écran ;
  - les trois Élans du Singe se distinguent ;
  - un Lob sorti par le haut est signalé par une flèche ;
  - aucun fichier image ou son externe n'est ajouté au projet.

## Comments
