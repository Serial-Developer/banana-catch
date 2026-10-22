# 05 : Progression : Cadence, Bananes simultanées, mélange des Lancers

Status: ready-for-agent
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

- [ ] Tests qui vérifient que :
  - l'intervalle moyen entre Lancers est plus court à Score élevé qu'à Score 0 (Score injecté ou atteint par des Attrapes forcées) ;
  - à Score 0, il n'y a jamais plus d'une Banane en vol ;
  - au palier « 3 Bananes », on observe 3 Bananes en vol simultanément et jamais plus ;
  - la proportion de Tirs tendus et de Lobs est plus élevée au dernier palier qu'au premier, sur un grand échantillon avec une graine fixée.

## Comments
