# 02 : Bananes, Attrape, Échec et boucle de Partie minimale

Status: ready-for-agent
Blocked by: 01
Spec: ../spec.md (user stories 8 à 12, 24, 25, 27, 33, 59)

## Objectif

Obtenir la première boucle complète. Des Bananes sont lancées (pour l'instant uniquement par Lancers forcés). Le Joueur les attrape avec la Fenêtre d'attrape. Les Bananes manquées sont des Échecs qui coûtent un Stock, et la Partie s'arrête à 0 Stock.

## À faire

- Créer la Banane : trajectoire balistique, avec détection des contacts avec le Joueur, avec les Plateformes et avec le vide (limites de l'Arène).
- Ajouter à la scène de Partie une méthode de test qui force un Lancer (position de départ, vitesse). Le Singe n'existe pas encore : les Lancers viennent uniquement de cette méthode.
- Créer la machine à états d'attrape du Joueur :
  - Normal → (appui sur `catch`) Fenêtre d'attrape (≈ 0,2 s) ;
  - expiration sans Attrape → Récupération (≈ 0,4 s), pendant laquelle on ne peut pas attraper ;
  - une Attrape ferme la Fenêtre sans déclencher de Récupération.
- Attrape : un contact avec le Joueur pendant la Fenêtre d'attrape fait disparaître la Banane, augmente le Score de 1 et émet le signal Attrape. Elle fonctionne au sol et en l'air.
- Échec : une Banane qui touche une Plateforme ou sort par le bas émet Échec et retire un Stock (signal Stock perdu).
- Contact avec le Joueur hors Fenêtre d'attrape : la Banane le traverse pour l'instant. Le Coup est traité au ticket 03.
- Stocks : 3 au départ. À 0, la scène émet Fin de Partie avec le Score.
- Exposer l'état observable : Score, Stocks, nombre de Bananes en vol, état d'attrape du Joueur.
- Mettre les durées dans la ressource de réglages.

## Critères d'acceptation

- [ ] Tests (scénarios avec Lancers forcés) qui vérifient que :
  - un appui juste avant le contact donne une Attrape et Score = 1, au sol ;
  - le même cas fonctionne en l'air, au-dessus du vide ;
  - un appui trop tôt mène à la Récupération, puis à l'absence d'Attrape au contact ;
  - après une Attrape, une deuxième Banane peut être attrapée immédiatement (pas de Récupération) ;
  - une Banane sur la Plateforme principale donne un Échec et Stocks = 2 ;
  - une Banane sur une Plateforme haute donne un Échec ;
  - une Banane dans le vide donne un Échec ;
  - 3 Échecs déclenchent Fin de Partie ;
  - chaque Banane n'émet qu'une seule issue.
- [ ] Jouable à la main avec une touche de debug qui force un Lancer aléatoire.

## Comments
