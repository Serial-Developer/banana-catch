# 07 : Habillage visuel façon Smash

Status: done
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

- [x] Toute la suite de tests existante passe toujours.
- [ ] Vérification manuelle :
  - chaque état du Joueur est reconnaissable à l'écran ;
  - les trois Élans du Singe se distinguent ;
  - un Lob sorti par le haut est signalé par une flèche ;
  - aucun fichier image ou son externe n'est ajouté au projet.

## Comments

### Compte rendu (agent, 2026-10-22)

**Fait**
- `Dessin` : primitives cartoon cernées d'un contour épais (cercle, ellipse, polygone, membre, rectangle arrondi, Banane en croissant).
- Joueur original : mèche orange, tenue bleue, gants blancs. Ses poses :
  - Fenêtre d'attrape : bras tendus vers le haut et halo vert ;
  - Récupération : grisé, bras ballants, yeux mi-clos et goutte de sueur ;
  - Éjection : tournoiement et yeux en croix ;
  - Invulnérabilité : clignotement ;
  - course : jambes en balancier ; en l'air : jambes repliées ; dash : corps penché.
- Singe original : fourrure brune, casquette rouge avec un emblème banane, salopette bleue, queue en spirale. Ses Élans :
  - Arc : bras derrière l'épaule, aura orange ;
  - Tir tendu : accroupi, bras tiré en arrière à l'horizontale, aura rouge ;
  - Lob : deux bras au-dessus de la tête, aura violette.

  Pendant l'Élan, il tient la Banane dans sa main.
- Banane : croissant jaune cerné qui tourne sur lui-même en vol.
- Arène : île flottante (herbe sur roche) et dalles bleues lumineuses pour les Plateformes hautes. Décor `Fond` : ciel en dégradé, soleil, deux plans de montagnes et nuages en parallaxe.
- `Effets`, qui réagit aux signaux de la Partie :
  - Attrape : étincelles, anneau, « +1 » et petit gel d'image ;
  - Coup : étincelles, anneau, gel et secousse de caméra, proportionnels au Pourcentage ;
  - Échec : éclaboussure et tache qui s'efface en 3 s ;
  - perte de Stock hors de l'écran : explosion et faisceau depuis le bord de l'écran, comme dans Smash ;
  - Réapparition : halo ;
  - Banane au-dessus de l'écran : flèche en bord d'écran avec la distance.
- Gel d'image (`Partie.geler`) : il fige le « Monde ». Il est ignoré sans affichage et désactivable par `Reglages.gel_image`, donc les tests ne sont ni modifiés ni ralentis.
- Les signaux `attrape(lieu)` et `echec(lieu)` indiquent maintenant où l'événement a lieu, pour placer les effets. Un test le vérifie.
- `tools/capture.gd` : il capture aussi les Élans, un Lob hors écran, un Coup et la Fenêtre d'attrape.

**Vérifié sur les captures** : le titre, la Partie, la flèche du Lob hors écran, le halo de la Fenêtre d'attrape, l'Élan du Tir tendu, la pause et l'écran de fin. Aucun fichier image ou son n'a été ajouté.

**À vérifier à la main**
- L'Élan du Lob n'a pas pu être capturé : la Partie de capture s'est terminée avant qu'il apparaisse.
- La lisibilité des trois Élans en mouvement.
- La sensation du gel d'image et de la secousse.
- La lisibilité du « 0% » du HUD, qui recouvre le bas de l'île.
