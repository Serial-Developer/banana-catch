/goal Les tickets 01 à 08 de .scratch/banana-catch/issues/ ont tous `Status: done`, la suite de tests Godot passe entièrement sans affichage (code de sortie 0), et chaque ticket a son commit.

Tu réalises en autonomie complète le jeu « Banana Catch » décrit dans `.scratch/banana-catch/spec.md`, ticket par ticket, sans me poser de question.

## Contexte à lire avant tout

1. `CLAUDE.md`, puis `docs/agents/issue-tracker.md` et `docs/agents/triage-labels.md`.
2. `GLOSSARY.md` : utilise exclusivement ce vocabulaire (Joueur, Singe, Banane, Attrape, Coup, Échec, Stock…) dans le code, les noms de tests, les commits et les commentaires de tickets. Pour un concept nouveau, ajoute-le au glossaire en respectant son format.
3. `.scratch/banana-catch/spec.md`, puis tous les tickets de `.scratch/banana-catch/issues/`.
4. Pour t'en inspirer : le lanceur de tests de `~/Desktop/Projets/ffta-remake/tests/run_tests.gd`. Ce projet sert uniquement de référence : ne modifie **jamais** rien dans `ffta-remake`. Le binaire Godot 4.7.2 se trouve dans `~/Desktop/Projets/ffta-remake/tools/godot/Godot.app/Contents/MacOS/Godot`.

## Boucle de travail

Tant qu'il reste un ticket `ready-for-agent` :

1. **Choisir** le ticket `ready-for-agent` de plus petit numéro dont tous les tickets listés dans `Blocked by:` sont en `Status: done`. Ignore le 09 (`ready-for-human`).
2. **Réserver** le ticket : passe sa ligne à `Status: in-progress` et enregistre le fichier.
3. **Implémenter en TDD** avec le skill `mattpocock-skills:tdd`, en cycles rouge → vert → refactor :
   - Tout se teste par un seul point d'entrée : la scène de Partie, lancée sans affichage et pilotée par des actions d'entrée simulées. On vérifie les signaux émis et l'état observable, jamais les nœuds internes.
   - Chaque critère d'acceptation testable du ticket devient au moins un test.
   - Les valeurs ajustables vont dans la ressource de réglages, pas en dur dans le code.
4. **Vérifier** :
   - lance la suite complète sans affichage (pas seulement les nouveaux tests) ;
   - lance aussi le jeu quelques secondes sans affichage et vérifie qu'il démarre sans erreur ni avertissement dans la sortie.
5. **Clore le ticket** :
   - coche ses critères d'acceptation ;
   - passe-le en `Status: done` ;
   - ajoute sous `## Comments` un court compte rendu : ce qui a été fait, les décisions prises et pourquoi, et les critères manuels qui restent à vérifier par un humain (rendu, son, ressenti).
6. **Committer** : un commit par ticket, avec un message du type `NN: <titre du ticket>`. Si le dossier n'est pas encore un dépôt git, initialise-le au premier ticket, avec un `.gitignore` Godot qui exclut `.godot/` et les exports. Ne pousse jamais vers un dépôt distant.

## Règles de décision

- **Ne me pose pas de question.** Si un point est ambigu, choisis l'option la plus cohérente avec la spec et le glossaire, puis note la décision et sa justification dans les commentaires du ticket.
- Si tu découvres qu'une règle de la spec est contradictoire ou injouable, applique la correction minimale, documente-la dans le ticket et dans `## Further Notes` de la spec, puis continue.
- Si un ticket est réellement bloqué (impossible techniquement après plusieurs tentatives) :
  - passe-le en `Status: needs-info` et explique le blocage dans ses commentaires ;
  - continue avec les tickets qui ne dépendent pas de lui.
- Respecte le hors-périmètre de la spec : aucun asset Nintendo ou externe (image, son, police), pas de relance de Banane, pas d'esquive, pas de musique.
- Ne désactive jamais un test pour le faire passer, et n'affaiblis pas une vérification pour qu'elle réussisse.
- Les effets visuels (gel d'image, secousse) et le son ne doivent ni casser les tests ni les ralentir quand le jeu tourne sans affichage.

## Fin

Quand plus aucun ticket n'est disponible, termine par un rapport qui contient :
- l'état de chaque ticket ;
- le résultat de la dernière exécution des tests (nombre de tests réussis et échoués) ;
- les commandes pour lancer le jeu et les tests ;
- la liste consolidée des vérifications manuelles à faire en jouant, qui prépare le ticket 09.
