# 04 : Le Singe et ses Lancers

Status: ready-for-agent
Blocked by: 02
Spec: ../spec.md (user stories 34 à 39, 41, 59)

## Objectif

Le Singe remplace la touche de debug. Il se déplace dans l'Arène et enchaîne Élan puis Lancer, avec trois types de Lancer. Le tout est reproductible avec une graine donnée.

## À faire

- Créer le Singe : son IA choisit une destination sur l'Arène (Plateforme principale ou Plateforme haute), s'y déplace (course et saut), puis exécute son Élan et lance.
- Les trois types de Lancer :
  - Arc : parabole d'angle et de force variables ;
  - Tir tendu : rapide, presque horizontal ;
  - Lob : très haut et lent, il retombe presque à la verticale.
- Visée : les Lancers visent la position du Joueur, avec une dispersion propre à chaque type.
- Élan : un état du Singe d'une durée propre à chaque type. Le signal Lancer est émis avec le type au moment où la Banane part.
- Tous les tirages (destination, type, dispersion) utilisent le générateur aléatoire de la Partie, initialisé par la graine.
- Le Singe ne fait aucun dégât par contact : il n'a aucune collision dangereuse avec le Joueur.
- Le forçage de Lancer (ticket 02) continue de fonctionner et prend le pas sur l'IA. Prévoir aussi un moyen de désactiver l'IA en test.
- La Cadence reste fixe pour l'instant. La progression est traitée au ticket 05.
- Retirer la touche de debug, ou la limiter aux builds de debug.

## Critères d'acceptation

- [ ] Tests qui vérifient que :
  - deux Parties lancées avec la même graine et les mêmes entrées produisent la même suite de signaux Lancer (types et instants) ;
  - sur un grand nombre de Lancers, les trois types apparaissent ;
  - un Tir tendu atteint la zone du Joueur plus vite qu'un Lob lancé depuis la même position ;
  - le Joueur peut traverser le Singe sans recevoir de Coup ni perdre de Pourcentage.
- [ ] Une Partie jouée à la main se déroule sans intervention de debug.

## Comments
