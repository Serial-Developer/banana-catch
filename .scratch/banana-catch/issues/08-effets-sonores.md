# 08 : Effets sonores synthétisés

Status: done
Blocked by: 03, 04
Spec: ../spec.md (user story 56)

## Objectif

Donner à chaque événement de la Partie un son distinct, entièrement généré par code.

## À faire

- Un module audio qui synthétise des sons courts avec le générateur audio de Godot (ondes, bruit, enveloppes) :
  - Lancer : un « whoosh » ;
  - Attrape : un « ding » clair et satisfaisant ;
  - Coup : un impact sourd, plus fort quand l'Éjection est forte ;
  - Échec : un « splat » ;
  - perte de Stock : une explosion ;
  - Réapparition : un court jingle.
- Le module réagit aux signaux de la scène de Partie, sans aucune logique de jeu.
- Ajouter un volume global dans la ressource de réglages.
- Aucun fichier audio externe.

## Critères d'acceptation

- [x] Toute la suite de tests existante passe toujours, sans erreur audio quand le jeu tourne sans affichage.
- [ ] Vérification manuelle : chaque événement a un son reconnaissable, et plusieurs sons simultanés ne saturent pas.

## Comments

### Compte rendu (agent, 2026-10-22)

**Fait**
- `Sons` : six sons synthétisés une seule fois au premier usage (PCM 16 bits mono, 22 050 Hz) et partagés entre les Parties, joués sur 10 voix.
  - Lancer : souffle de bruit filtré ;
  - Attrape : « ding » à 1320 Hz plus une harmonique, avec une légère montée. Il devient un peu plus aigu quand le Score monte ;
  - Coup : impact grave (balayage de 170 à 55 Hz) avec un claquement. Plus fort et plus grave quand le Pourcentage monte ;
  - Échec : « splat » de bruit filtré ;
  - perte de Stock : explosion (bruit et sinus à 48 Hz) ;
  - Réapparition : arpège do, mi, sol.
- Le module réagit uniquement aux signaux de la Partie. `Reglages.volume` règle le volume global. Une marge de -6 dB et des crêtes ≤ 0,8 évitent la saturation quand plusieurs sons se superposent.
- Vérifications faites : la suite passe sans affichage (pilote audio factice) et sans erreur. Une Partie lancée avec affichage et un vrai pilote audio, via l'outil de capture, ne produit ni erreur ni avertissement. Les crêtes ont été mesurées sur un export WAV et aucun son ne sature.

**Décisions**
- Les sons sont pré-calculés en `AudioStreamWAV` plutôt que générés en continu avec `AudioStreamGenerator`. C'est plus simple, ça ne coûte rien à l'exécution et ça permet la polyphonie. Ils restent générés entièrement par code, sans aucun fichier audio dans le projet.

**À vérifier à la main**
- [ ] Chaque événement a un son reconnaissable et agréable. Il faut écouter, je n'ai pas pu le faire.
- [ ] Plusieurs sons simultanés ne saturent pas en jeu, surtout au Palier 25 avec 3 Bananes en vol.

**Correction après la clôture** : la commande de test renvoyait le code 1 alors que les 42 tests passaient. En cause, l'avertissement « ObjectDB instances leaked at exit » :
- la banque de sons était stockée dans une variable statique, jamais libérée ;
- les lectures audio n'étaient pas arrêtées avec le pilote audio factice.

Correctifs : la banque passe dans un autoload `BanqueSons`, et `Sons` arrête ses voix en quittant l'arbre. `./tools/godot.sh tests` renvoie maintenant le code 0.

**Seconde correction** : les fuites revenaient de façon intermittente. Le pilote audio factice, utilisé sans affichage, ne libère jamais les lectures. `Sons.jouer` ne joue donc plus rien sans affichage, comme pour le gel d'image. Sur 5 exécutions consécutives, la suite renvoie le code 0 à chaque fois.
