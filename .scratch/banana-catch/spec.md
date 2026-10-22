# Spec : Banana Catch

Status: ready-for-agent

Vocabulaire : voir `GLOSSARY.md` à la racine. Tous les termes en majuscule (Joueur, Singe, Banane, Attrape, Coup, Échec, Stock…) y sont définis.

## Problem Statement

Je veux un petit jeu d'arcade 2D qui donne le ressenti d'un Smash Bros : une Arène flottante, un compteur de Pourcentage, des Éjections qui claquent, des effets d'impact. Le cœur du jeu est un défi de réflexe et de positionnement : un Singe adverse (inspiré de Diddy Kong) me lance des Bananes, et je dois les attraper au bon moment, sans les laisser tomber et sans me les prendre dans la figure. Aujourd'hui ce jeu n'existe pas, et je ne veux pas utiliser d'assets Nintendo.

## Solution

Un jeu Godot 4 jouable sur Mac, au clavier ou à la manette. Le Joueur évolue dans une Arène type « Champ de bataille » (une Plateforme principale flottante, des Plateformes hautes traversables, du vide autour). Le Singe se déplace dans l'Arène et enchaîne des Lancers (Arc, Tir tendu, Lob), chacun annoncé par un Élan. Chaque Banane se résout en exactement une issue :

- **Attrape** : le Joueur presse le bouton d'attrape et la Banane le touche pendant la Fenêtre d'attrape → Score +1.
- **Coup** : la Banane touche le Joueur hors Fenêtre d'attrape → Pourcentage augmenté, Éjection, la Banane disparaît.
- **Échec** : la Banane touche une Plateforme ou tombe dans le vide → perte d'un Stock.

La Partie dure tant qu'il reste des Stocks (3 au départ). La Cadence augmente avec le Score, et à partir de certains paliers plusieurs Bananes sont en vol simultanément. Les graphismes sont des formes vectorielles cartoon dessinées en code (contours épais, couleurs vives, particules d'impact), le son est fait d'effets synthétisés.

## User Stories

### Déplacements du Joueur

1. En tant que Joueur, je veux courir à gauche et à droite, afin de me placer sous la trajectoire d'une Banane.
2. En tant que Joueur, je veux sauter, afin d'aller chercher une Banane en hauteur.
3. En tant que Joueur, je veux un double saut en l'air, afin de corriger ma trajectoire ou de revenir vers l'Arène.
4. En tant que Joueur, je veux un dash, afin de traverser rapidement l'Arène pour une Banane lointaine.
5. En tant que Joueur, je veux traverser les Plateformes hautes par le dessous en sautant, afin de monter rapidement.
6. En tant que Joueur, je veux pouvoir descendre à travers une Plateforme haute (bas + saut), afin de redescendre rapidement.
7. En tant que Joueur, je veux tomber dans le vide si je sors de la Plateforme principale sans revenir, afin que le positionnement près des bords soit risqué.

### Attrape

8. En tant que Joueur, je veux appuyer sur un bouton d'attrape qui ouvre une courte Fenêtre d'attrape, afin d'attraper une Banane au bon moment.
9. En tant que Joueur, je veux qu'une Banane qui me touche pendant la Fenêtre d'attrape soit une Attrape, afin que le timing soit récompensé.
10. En tant que Joueur, je veux pouvoir attraper au sol comme en l'air, afin de pouvoir aller chercher une Banane au-dessus du vide.
11. En tant que Joueur, je veux qu'un appui sans Attrape entraîne une Récupération pendant laquelle je ne peux pas attraper, afin que marteler le bouton ne soit pas une stratégie.
12. En tant que Joueur, je veux qu'une Attrape réussie ne déclenche pas de Récupération, afin de pouvoir enchaîner les Attrapes quand plusieurs Bananes arrivent.
13. En tant que Joueur, je veux un retour visuel et sonore marqué sur une Attrape (son, particules, petit gel d'image), afin que le geste soit satisfaisant.
14. En tant que Joueur, je veux voir que ma Fenêtre d'attrape est ouverte (pose ou halo), afin de comprendre mes ratés.
15. En tant que Joueur, je veux voir que je suis en Récupération, afin de comprendre pourquoi je ne peux pas attraper.

### Coup, Pourcentage et Éjection

16. En tant que Joueur, je veux qu'une Banane qui me touche hors Fenêtre d'attrape soit un Coup, afin qu'il y ait une vraie pénalité à mal timer.
17. En tant que Joueur, je veux que chaque Coup augmente mon Pourcentage, afin de sentir les dégâts s'accumuler.
18. En tant que Joueur, je veux qu'un Coup provoque une Éjection d'autant plus forte que mon Pourcentage est élevé, afin de retrouver la tension propre à Smash.
19. En tant que Joueur, je veux que l'Éjection parte dans la direction de la Banane, afin que la physique soit lisible.
20. En tant que Joueur, je veux être brièvement sans contrôle et sans possibilité d'attraper pendant l'Éjection, afin que le Coup se ressente.
21. En tant que Joueur, je veux qu'une Banane qui m'a causé un Coup disparaisse, afin qu'elle ne compte pas aussi comme un Échec.
22. En tant que Joueur, je veux pouvoir revenir vers l'Arène après une Éjection (double saut), afin de ne pas perdre un Stock à coup sûr.
23. En tant que Joueur, je veux perdre un Stock si je sors des limites de l'Arène, afin qu'une grosse Éjection soit dangereuse.

### Échec

24. En tant que Joueur, je veux qu'une Banane non attrapée qui touche n'importe quelle Plateforme soit un Échec, afin que chaque Banane compte.
25. En tant que Joueur, je veux qu'une Banane qui tombe dans le vide soit aussi un Échec, afin que le Singe n'ait pas de Lancers que je pourrais ignorer.
26. En tant que Joueur, je veux un retour visuel et sonore clair sur un Échec (Banane qui s'écrase, son), afin de comprendre pourquoi je perds un Stock.

### Stocks, Réapparition, fin de Partie

27. En tant que Joueur, je veux commencer chaque Partie avec 3 Stocks, afin d'avoir droit à l'erreur.
28. En tant que Joueur, je veux que mon Pourcentage repasse à 0 quand je perds un Stock, comme dans Smash.
29. En tant que Joueur, je veux réapparaître au-dessus de l'Arène après la perte d'un Stock, afin de reprendre la Partie.
30. En tant que Joueur, je veux une Invulnérabilité de 2 secondes après la Réapparition, pendant laquelle les Bananes ne me causent pas de Coup, afin de ne pas perdre deux Stocks d'affilée injustement.
31. En tant que Joueur, je veux pouvoir attraper pendant mon Invulnérabilité, afin que ce temps reste utile.
32. En tant que Joueur, je veux que les Bananes qui touchent une Plateforme pendant mon Invulnérabilité restent des Échecs, afin que l'Invulnérabilité ne soit pas une pause.
33. En tant que Joueur, je veux que la Partie se termine quand je perds mon dernier Stock, afin d'avoir une fin claire.

### Singe et Lancers

34. En tant que Joueur, je veux que le Singe se déplace dans l'Arène et sur les Plateformes, afin que les Lancers viennent de positions variées.
35. En tant que Joueur, je veux que le Singe ne me fasse jamais de dégâts par contact, afin que le jeu reste centré sur l'Attrape.
36. En tant que Joueur, je veux que le Singe lance des Arcs (paraboles d'angle et de force variables), afin d'avoir un Lancer de base lisible.
37. En tant que Joueur, je veux que le Singe lance des Tirs tendus rapides, afin de tester mes réflexes.
38. En tant que Joueur, je veux que le Singe lance des Lobs hauts et lents, afin de tester mon placement.
39. En tant que Joueur, je veux que chaque type de Lancer soit précédé d'un Élan distinct, afin de pouvoir anticiper.
40. En tant que Joueur, je veux un indicateur en bord d'écran quand une Banane est hors du cadre (un Lob qui monte), afin de savoir où elle va retomber.
41. En tant que Joueur, je veux que les Lancers visent globalement la zone où je me trouve, afin que le défi soit juste.

### Progression

42. En tant que Joueur, je veux que la Cadence augmente avec mon Score, afin que la difficulté monte progressivement.
43. En tant que Joueur, je veux qu'à partir de certains paliers de Score plusieurs Bananes soient en vol en même temps, afin d'avoir à choisir quelle Banane sauver.
44. En tant que Joueur, je veux que la proportion de Tirs tendus et de Lobs augmente avec le Score, afin que la variété accompagne la difficulté.

### Interface et écrans

45. En tant que Joueur, je veux un écran titre avec le nom du jeu, mon Meilleur score et les contrôles, afin de savoir comment jouer.
46. En tant que Joueur, je veux voir pendant la Partie mon Pourcentage (gros chiffre façon Smash, qui rougit en montant), mes Stocks restants et mon Score, afin de connaître ma situation.
47. En tant que Joueur, je veux pouvoir mettre en pause avec Échap ou Start, afin de m'interrompre.
48. En tant que Joueur, je veux un écran de fin avec mon Score, mon Meilleur score et un bouton Rejouer, afin de relancer rapidement.
49. En tant que Joueur, je veux que mon Meilleur score soit conservé entre deux lancements du jeu, afin d'avoir un objectif.
50. En tant que Joueur, je veux une indication « Nouveau meilleur score ! » quand je bats mon record, afin d'être récompensé.

### Contrôles

51. En tant que Joueur, je veux jouer au clavier (flèches ou ZQSD pour bouger, une touche pour sauter, une pour attraper, une pour le dash), afin de jouer sans manette.
52. En tant que Joueur, je veux jouer à la manette (stick ou croix, boutons de saut, d'attrape, de dash, Start), afin d'avoir le feeling Smash.
53. En tant que Joueur, je veux que le clavier et la manette fonctionnent sans configuration, afin de jouer immédiatement.

### Rendu et son

54. En tant que Joueur, je veux un style cartoon façon Smash (contours épais, couleurs vives, fond animé derrière l'Arène), afin que le jeu soit agréable à regarder.
55. En tant que Joueur, je veux un Singe original reconnaissable « à la Diddy » (casquette, salopette) sans être Diddy, afin de garder le clin d'œil sans enfreindre de droits.
56. En tant que Joueur, je veux des effets sonores distincts pour le Lancer, l'Attrape, le Coup, l'Échec et la perte de Stock, afin de comprendre ce qui se passe sans regarder partout.
57. En tant que Joueur, je veux une secousse de caméra et un gel d'image sur un Coup, afin que l'impact soit ressenti.

### Développement

58. En tant que développeur, je veux lancer tous les tests en une commande sans affichage, afin de vérifier les règles rapidement.
59. En tant que développeur, je veux pouvoir fixer la graine aléatoire et forcer des Lancers précis dans une Partie, afin d'écrire des tests reproductibles.
60. En tant que développeur, je veux que toutes les valeurs de réglage (durées, forces, Pourcentages, Cadence) soient regroupées en un seul endroit, afin d'ajuster le jeu sans fouiller le code.

## Implementation Decisions

- **Moteur** : Godot 4.7.2, en GDScript typé. On réutilise le binaire déjà présent dans le projet `ffta-remake` (`tools/godot/Godot.app`), via un petit script outil qui le localise. Cible : application macOS (l'export web reste possible plus tard).
- **Scène de Partie (module central)** : une scène autonome qui contient l'Arène, le Joueur, le Singe et les Bananes, et qui porte toutes les règles. Son interface publique :
  - Entrées au démarrage : réglages (ressource de réglages), graine aléatoire, Meilleur score courant.
  - Pendant la Partie : elle lit les actions d'entrée Godot (`move_left`, `move_right`, `down`, `jump`, `catch`, `dash`, `pause`), ce qui permet de la piloter en test en simulant ces actions.
  - Signaux émis : Lancer (type), Attrape, Coup (Pourcentage après le Coup), Échec, Stock perdu (Stocks restants), Réapparition, Fin de Partie (Score, Meilleur score éventuellement battu).
  - État observable : Score, Pourcentage, Stocks, Bananes en vol, état du Joueur (normal, Fenêtre d'attrape, Récupération, Éjection, Invulnérabilité).
  - Pour les tests : une méthode permettant de forcer le prochain Lancer (type, position de départ, vitesse) à la place de la décision du Singe.
- **Physique** : celle de Godot. Le Joueur est un corps de personnage avec gravité, saut, double saut, dash. Les Plateformes hautes sont des collisions à sens unique. Les Bananes suivent une trajectoire balistique et détectent leurs contacts (Joueur ou Plateforme) via des zones de détection. Les limites de l'Arène (zone de sortie) déclenchent la perte d'un Stock.
- **Résolution d'une Banane** : une Banane n'a qu'une seule issue. Ordre de priorité quand plusieurs contacts arrivent dans la même image physique : Attrape > Coup > Échec. Pendant l'Invulnérabilité, un contact avec le Joueur hors Fenêtre d'attrape est ignoré (la Banane continue sa course).
- **États du Joueur** : machine à états explicite. Normal → (appui attrape) Fenêtre d'attrape → (expiration sans Attrape) Récupération → Normal. Une Attrape ferme la Fenêtre sans Récupération. Coup → Éjection (pas de contrôle, pas d'attrape) → Normal. Perte de Stock → Réapparition → Invulnérabilité (cumulable avec les autres états) → fin après 2 s.
- **Éjection** : la force croît avec le Pourcentage (formule simple inspirée de Smash : base + Pourcentage × facteur), direction donnée par la vitesse de la Banane, légèrement vers le haut.
- **Singe** : une IA simple qui choisit une destination dans l'Arène, s'y déplace, puis enchaîne Élan → Lancer. Le type de Lancer et la visée (vers la position du Joueur avec une dispersion) sont tirés avec le générateur aléatoire de la Partie, initialisé par la graine. Le Singe n'a aucune collision dangereuse avec le Joueur.
- **Cadence et progression** : un module de réglages fournit, en fonction du Score, l'intervalle entre deux Lancers, le nombre maximal de Bananes en vol et les probabilités de chaque type de Lancer. C'est une table de paliers dans la ressource de réglages.
- **Réglages** : une seule ressource Godot regroupe toutes les valeurs ajustables. Valeurs de départ : Fenêtre d'attrape ≈ 0,2 s, Récupération ≈ 0,4 s, Invulnérabilité 2 s, 3 Stocks. Les autres valeurs (Pourcentage par Coup, forces, vitesses) seront ajustées en jouant.
- **Écrans** : écran titre → scène de Partie → écran de fin, avec une pause superposée. L'écran titre lit le Meilleur score depuis un fichier dans le dossier utilisateur Godot, et le transmet à la Partie. C'est la couche autour de la Partie qui sauvegarde le nouveau Meilleur score à la réception du signal Fin de Partie. La scène de Partie n'écrit jamais sur le disque.
- **Rendu** : tout est dessiné en code (polygones, contours, dégradés) ou avec des formes Godot. Particules pour l'Attrape, le Coup et l'Échec. Secousse de caméra et gel d'image sur un Coup. Le HUD affiche le Pourcentage, les Stocks et le Score. Indicateur de bord d'écran pour les Bananes hors cadre. Aucun asset Nintendo.
- **Son** : effets générés par code (générateur audio Godot) pour le Lancer, l'Attrape, le Coup, l'Échec et la perte de Stock. Pas de musique.
- **Entrées** : actions définies dans la carte d'entrées du projet, avec des liaisons clavier (flèches et ZQSD/WASD) et manette.

## Testing Decisions

- **Un seul point de test : la scène de Partie, lancée sans affichage.** Les tests chargent la scène avec une graine fixée et des Lancers forcés, simulent des actions d'entrée image par image physique, puis vérifient les signaux émis et l'état observable. La physique Godot tourne pour de vrai : on teste ce qui sera joué.
- **Ce qu'est un bon test ici** : un scénario de jeu décrit dans le vocabulaire du glossaire (« un Tir tendu arrive sur le Joueur, il presse attraper 0,1 s avant le contact → Attrape, Score = 1 »). On vérifie uniquement des comportements externes (signaux, Score, Pourcentage, Stocks, état du Joueur), jamais des nœuds internes, des noms de variables ou des positions exactes au pixel.
- **Scénarios à couvrir au minimum** :
  - Attrape au sol et en l'air, ainsi qu'Attrape au-dessus du vide.
  - Appui trop tôt : Récupération, puis Coup.
  - Spam du bouton : pas d'Attrape garantie.
  - Coup : Pourcentage augmenté, Éjection plus forte à haut Pourcentage, Banane disparue et pas d'Échec.
  - Échec sur la Plateforme principale, sur une Plateforme haute, dans le vide.
  - Sortie de l'Arène par Éjection : Stock perdu, Pourcentage remis à 0, Réapparition, Invulnérabilité (Banane qui traverse, Attrape toujours possible).
  - Dernier Stock perdu : signal Fin de Partie, avec le Meilleur score battu ou non.
  - Deux contacts dans la même image : la priorité est respectée.
  - Progression : la Cadence et le nombre de Bananes simultanées suivent la table de paliers.
  - Les Lancers sont reproductibles avec une graine donnée.
- **Lanceur de tests** : on reprend le principe du projet `ffta-remake` (`tests/run_tests.gd`). C'est un script lancé sans affichage qui exécute toutes les méthodes `test_*` des fichiers `tests/unit/test_*.gd`, puis sort avec un code 0 ou 1. On ajoute le support des tests asynchrones, qui doivent attendre des images physiques.
- **Non testé automatiquement** : le rendu, les particules, le son, la caméra, l'écran titre et l'écran de fin (vérification manuelle en jouant), ainsi que l'équilibrage fin.

## Out of Scope

- Relancer une Banane attrapée sur le Singe, Pourcentage du Singe et condition de victoire (évolution possible).
- Esquive au sol ou aérienne.
- Multijoueur, plusieurs Singes, choix de personnages.
- Plusieurs Arènes ou niveaux.
- Bananes qui rebondissent sur les Plateformes.
- Musique.
- Remappage des touches.
- Export web, classement en ligne.
- Tout asset (sprite, son, police, logo) issu de Nintendo ou de Smash Bros.

## Further Notes

- Le projet est vide : tout est à créer (projet Godot, carte d'entrées, lanceur de tests, script de lancement).
- Les valeurs de réglage annoncées sont des points de départ. Prévoir une itération d'équilibrage en jouant une fois la boucle complète en place.
- Ordre de réalisation suggéré : lanceur de tests et scène de Partie minimale (Arène + Joueur), puis Bananes et résolution, puis Pourcentage, Éjection et Stocks, puis le Singe et la progression, puis les écrans, puis le rendu et le son.
