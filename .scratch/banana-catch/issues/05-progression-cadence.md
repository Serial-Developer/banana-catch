# 05 : Progression : Cadence, Bananes simultanées, mélange des Lancers

Status: done
Blocked by: 04
Spec: ../spec.md (user stories 42 à 44)

## Objectif

La difficulté monte avec le Score. La Cadence accélère, plusieurs Bananes peuvent être en vol en même temps et les Tirs tendus et les Lobs deviennent plus fréquents.

## À faire

- Ajouter à la ressource de réglages une table de paliers indexée par le Score. Chaque palier donne :
  - l'intervalle entre deux Lancers ;
  - le nombre maximal de Bananes en vol ;
  - les probabilités de chaque type de Lancer.
- Le Singe consulte le palier courant à chaque décision. Il ne lance pas si le maximum de Bananes en vol est atteint.
- Valeurs de départ proposées, à ajuster au ticket 09 :
  - de 0 à 9 : 1 Banane max, Arcs surtout ;
  - de 10 à 24 : 2 Bananes max ;
  - 25 et plus : 3 Bananes max, avec un intervalle qui décroît jusqu'à un plancher.

## Critères d'acceptation

- [x] Tests qui vérifient que :
  - l'intervalle moyen entre Lancers est plus court à Score élevé qu'à Score 0 (Score injecté ou atteint par des Attrapes forcées) ;
  - à Score 0, il n'y a jamais plus d'une Banane en vol ;
  - au palier « 3 Bananes », on observe 3 Bananes en vol simultanément et jamais plus ;
  - la proportion de Tirs tendus et de Lobs est plus élevée au dernier palier qu'au premier, sur un grand échantillon avec une graine fixée.

## Comments

### Compte rendu (agent, 2026-10-22)

**Fait**
- `Palier` (Resource) : score minimal, intervalle, nombre maximal de Bananes en vol, Lancers depuis une même position et poids de chaque type. La table `Reglages.paliers` contient :

| Score | Intervalle | Bananes max | Lancers par position | Arc / Tir tendu / Lob |
|---|---|---|---|---|
| 0 | 1,4 s | 1 | 1 | 70 / 15 / 15 |
| 10 | 1,0 s | 2 | 2 | 50 / 25 / 25 |
| 25 | 0,45 s | 3 | 3 | 34 / 33 / 33 |

- Au-delà du dernier Palier, l'intervalle diminue de 0,02 s par Attrape, jusqu'à 0,2 s au minimum (`Reglages.intervalle_lancers(score)`).
- Le Singe consulte le Palier à chaque décision. Il ne lance pas tant que le maximum de Bananes en vol est atteint.
- Helper de test `marquer(n)` : il fait atteindre un Score par de vraies Attrapes, et non par injection.
- « Palier » est ajouté au glossaire.

**Décisions**
- J'ai ajouté le nombre de « Lancers depuis une même position » (rafale). Sans lui, chaque Lancer était précédé d'un déplacement du Singe, et le temps de trajet empêchait d'avoir plusieurs Bananes en vol, même avec un intervalle court.
- L'intervalle du dernier Palier passe à 0,45 s, au lieu des 0,7 s envisagés, pour que 3 Bananes simultanées arrivent réellement.

**À vérifier à la main**
- La difficulté aux Paliers 10 et 25 : est-ce encore jouable ? Le plancher de 0,2 s est-il trop dur ? À ajuster au ticket 09.
