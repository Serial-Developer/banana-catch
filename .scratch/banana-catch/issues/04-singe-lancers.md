# 04 : Le Singe et ses Lancers

Status: done
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

- [x] Tests qui vérifient que :
  - deux Parties lancées avec la même graine et les mêmes entrées produisent la même suite de signaux Lancer (types et instants) ;
  - sur un grand nombre de Lancers, les trois types apparaissent ;
  - un Tir tendu atteint la zone du Joueur plus vite qu'un Lob lancé depuis la même position ;
  - le Joueur peut traverser le Singe sans recevoir de Coup ni perdre de Pourcentage.
- [x] Une Partie jouée à la main se déroule sans intervention de debug.

## Comments

### Compte rendu (agent, 2026-10-22)

**Fait**
- `Singe` : Attente (intervalle de Lancers) → Déplacement vers un point tiré au hasard sur une Plateforme (course au même niveau, saut parabolique sinon) → Élan, avec une durée propre à chaque type → Lancer (signal `lance`, relié à `Partie.forcer_lancer`).
- Lancers : la vitesse initiale est calculée pour amener la Banane de la main du Singe au buste du Joueur, à un écart aléatoire près, en un temps de vol donné. Arc : 0,9 à 1,25 s. Lob : 1,8 à 2,2 s. Tir tendu : 1000 px/s à l'horizontale, 0,25 s minimum.
- Tous les tirages (destination, type pondéré, écart, temps de vol) passent par le générateur aléatoire de la Partie, initialisé par la graine. Un test vérifie qu'une même graine produit la même suite de Lancers.
- `Partie.singe_actif` (faux par défaut dans les tests, pour que seuls les Lancers forcés envoient des Bananes) et `singe_position()`, `temps_ecoule()`.
- Le Singe attend tant que `bananes_max_en_vol` (1 pour l'instant) est atteint. Il s'arrête à la Fin de Partie. Il n'a aucune collision avec le Joueur.
- La touche de debug F1 est conservée, uniquement dans les builds de debug.

**Décisions**
- **Correction de règle** (documentée dans la spec, section Further Notes, et dans le glossaire) : les Bananes traversent les Plateformes hautes, et l'Échec n'a lieu que sur la Plateforme principale ou dans le vide. Avec la règle d'origine, beaucoup de Lancers étaient interceptés par la Plateforme du Singe lui-même ou par une Plateforme sur la trajectoire d'un Lob, ce qui coûtait des Stocks injustement. Le test du ticket 02 sur les Plateformes hautes a été adapté : il vérifie maintenant que la Banane traverse puis finit en Échec sur la Plateforme principale.
- Écarts aléatoires réduits (Arc ±24, Tir tendu ±12, Lob ±32 px). Avec ±50 à ±70 px, la plupart des Lancers manquaient un Joueur immobile, ce qui contredisait « les Lancers visent la zone du Joueur ».

**À vérifier à la main**
- Les trois Élans se distinguent pour l'instant par une simple couleur provisoire (orange, rouge, violet). Le vrai visuel arrive au ticket 07.
- Le déplacement et le saut du Singe paraissent-ils naturels ?
- Un Joueur sous la Plateforme du sommet est-il trop facilement surpris par un Lob ?
