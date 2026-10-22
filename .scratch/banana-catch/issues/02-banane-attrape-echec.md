# 02 : Bananes, Attrape, Échec et boucle de Partie minimale

Status: done
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

- [x] Tests (scénarios avec Lancers forcés) qui vérifient que :
  - un appui juste avant le contact donne une Attrape et Score = 1, au sol ;
  - le même cas fonctionne en l'air, au-dessus du vide ;
  - un appui trop tôt mène à la Récupération, puis à l'absence d'Attrape au contact ;
  - après une Attrape, une deuxième Banane peut être attrapée immédiatement (pas de Récupération) ;
  - une Banane sur la Plateforme principale donne un Échec et Stocks = 2 ;
  - une Banane sur une Plateforme haute donne un Échec ;
  - une Banane dans le vide donne un Échec ;
  - 3 Échecs déclenchent Fin de Partie ;
  - chaque Banane n'émet qu'une seule issue.
- [x] Jouable à la main avec une touche de debug qui force un Lancer aléatoire.

## Comments

### Compte rendu (agent, 2026-10-22)

**Fait**
- `Lancer` (type Arc, Tir tendu ou Lob, départ, vitesse) et `Banane` (trajectoire balistique, avancée par petits pas de 6 px au maximum pour ne jamais traverser une Plateforme).
- La Partie résout chaque Banane à chaque image physique, après le déplacement du Joueur (`process_physics_priority = 10`). Elle teste d'abord le contact avec le Joueur pendant la Fenêtre d'attrape (Attrape), puis les Plateformes, le vide et les limites (Échec). Une Banane retirée ne peut plus rien émettre : une seule issue par Banane.
- Machine à états d'attrape du Joueur : Normal → Fenêtre d'attrape (0,2 s) → Récupération (0,4 s) → Normal. Une Attrape ramène directement à Normal.
- Signaux de la Partie : `lancer(type)`, `attrape`, `echec`, `stock_perdu(stocks_restants)`, `fin_de_partie(score, record_battu)`. État observable : `score()`, `stocks()`, `terminee()`, `nombre_bananes_en_vol()`, `positions_bananes()`, `joueur_etat_attrape()`.
- `forcer_lancer(Lancer)` pour les tests. Touche de debug F1, uniquement dans les builds de debug, qui force un Lancer aléatoire vers le Joueur.
- Nouveaux réglages : durées de Fenêtre et de Récupération, gravité et rayon des Bananes, Stocks de départ.

**Décisions**
- En dessous de y = 780 (sous l'écran), une Banane est « tombée dans le vide ». Une Banane qui sort des limites latérales de l'Arène compte aussi comme un Échec, ce qui suit la règle « toute Banane non attrapée qui sort du jeu est un Échec ».
- À la Fin de Partie, les Bananes restantes sont retirées sans issue et le Joueur est figé.
- Un contact hors Fenêtre d'attrape laisse passer la Banane. Le Coup sera traité au ticket 03.

**À vérifier à la main**
- Avec F1 : le ressenti du timing de la Fenêtre d'attrape (0,2 s) et la gêne causée par la Récupération (0,4 s).
- La couleur provisoire du Joueur : vert pendant la Fenêtre, gris pendant la Récupération.
