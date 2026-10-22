# 01 : Socle Godot, Arène et déplacements du Joueur

Status: done
Blocked by: (aucun)
Spec: ../spec.md (user stories 1 à 7, 51 à 53, 58, 60)

## Objectif

Mettre en place un projet Godot jouable et testable : on lance le jeu, le Joueur court, saute, fait un double saut et un dash dans l'Arène, et une commande unique exécute les tests sans affichage.

## À faire

- Créer le projet Godot 4.7.2 à la racine du dépôt.
- Ajouter un script outil qui localise le binaire Godot. Par défaut, il cherche celui de `~/Desktop/Projets/ffta-remake/tools/godot/Godot.app`, et une variable d'environnement permet d'en indiquer un autre. Le script expose deux commandes : lancer le jeu et lancer les tests.
- Ajouter un lanceur de tests sans affichage, sur le modèle de `ffta-remake/tests/run_tests.gd`. Il exécute les méthodes `test_*` des fichiers `tests/unit/test_*.gd`, avec en plus le support des tests asynchrones (`await` sur des images physiques). Il sort avec le code 0 si tous les tests passent, 1 sinon.
- Définir la carte d'entrées : `move_left`, `move_right`, `down`, `jump`, `catch`, `dash`, `pause`, avec des liaisons clavier (flèches, ZQSD et WASD, plus des touches d'action) et manette.
- Créer la ressource de réglages, qui regroupe toutes les valeurs ajustables. Ce ticket y met celles du déplacement, et les tickets suivants y ajouteront les leurs.
- Créer la scène de Partie, avec :
  - l'Arène : une Plateforme principale flottante, 2 ou 3 Plateformes hautes à collision à sens unique, et du vide autour ;
  - le Joueur : course, saut, double saut, dash, montée à travers une Plateforme haute, descente avec bas + saut.
- Un rendu provisoire avec des formes simples suffit : l'habillage est traité au ticket 07.
- La scène de Partie accepte au démarrage la ressource de réglages et une graine aléatoire.

## Critères d'acceptation

- [x] La commande de lancement du jeu ouvre la scène de Partie, jouable au clavier et à la manette.
- [x] La commande de test s'exécute sans affichage et renvoie un code de sortie correct.
- [x] Les tests vérifient que :
  - le Joueur posé au-dessus de la Plateforme principale atterrit et y reste ;
  - le double saut fonctionne une seule fois par saut ;
  - le Joueur traverse une Plateforme haute en montant et peut en redescendre ;
  - le Joueur qui sort de la Plateforme principale tombe dans le vide.
- [x] Les tests pilotent le Joueur en simulant des actions d'entrée, et non en modifiant directement ses nœuds.

## Comments

### Compte rendu (agent, 2026-10-22)

**Fait**
- Projet Godot 4.7.2 (`project.godot`, rendu GL Compatibility, 1280×720), scène de Partie `scenes/partie.tscn` + `src/partie.gd` (point d'entrée unique des tests via `Partie.creer(reglages, graine, meilleur_score)`).
- `tools/godot.sh jeu | tests | editeur | verifier-demarrage` : le binaire est pris dans ffta-remake, ou bien dans `GODOT_BIN`. Les tests tournent avec `--fixed-fps 60` : la simulation avance image par image aussi vite que possible et reste déterministe. La sortie est scannée (erreurs ou avertissements → code 1).
- `tests/run_tests.gd` : lanceur inspiré de ffta-remake, avec tests asynchrones (`await`), une instance neuve par test et un filtre optionnel `FILTRE_TESTS=<nom de fichier>`. `tests/lib/suite_partie.gd` fournit les helpers (presser, taper, images, secondes, espionner).
- Actions d'entrée déclarées par l'autoload `ActionsEntree` : clavier en touches physiques (flèches, WASD = ZQSD en AZERTY, Espace pour sauter, J/X pour attraper, K/C/Maj pour le dash, Échap/P pour la pause) et manette (croix, stick gauche, A/Y, B/X, gâchettes hautes, Start).
- `Reglages` (Resource) regroupe les valeurs du Joueur.
- Arène : Plateforme principale solide et 3 Plateformes hautes en collision à sens unique. Joueur : course, saut, double saut (une fois par saut), dash (un seul en l'air), descente bas + saut.

**Décisions**
- La détection « vient d'être pressé » est faite par le Joueur lui-même, image physique par image physique, au lieu de `is_action_just_pressed`. C'est plus fiable avec des entrées simulées et indépendant de la fréquence d'affichage.
- Les actions sont déclarées en code (autoload) plutôt que dans `project.godot`, ce qui est plus lisible et plus facile à modifier.

**À vérifier à la main**
- Le ressenti du saut, du double saut et du dash au clavier et à la manette.
- Le stick analogique (zone morte 0,4).
