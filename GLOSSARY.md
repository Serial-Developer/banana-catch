# Banana Catch

Platformer 2D de type « jeu de combat » inspiré de Smash Bros, où le Joueur doit attraper les Bananes lancées par un Singe adverse.

## Acteurs

**Joueur**:
Le personnage contrôlé par la personne qui joue.
_Avoid_: Héros, perso, avatar

**Singe**:
L'adversaire, un personnage original inspiré de Diddy Kong, qui lance des Bananes.
_Avoid_: Diddy, ennemi, boss

**Banane**:
Le projectile lancé par le Singe, que le Joueur doit attraper avant qu'elle ne provoque un Coup ou un Échec.
_Avoid_: Projectile, item

## Résolution d'une Banane

Chaque Banane se résout en exactement une issue : Attrape, Coup ou Échec.

**Attrape**:
Une Banane récupérée par le Joueur grâce au bouton d'attrape, pendant la Fenêtre d'attrape.
_Avoid_: Catch, réception, prise

**Fenêtre d'attrape**:
Le court intervalle pendant lequel un appui sur le bouton d'attrape transforme le contact avec une Banane en Attrape.
_Avoid_: Timing, frame window

**Récupération**:
Le court délai, après une Fenêtre d'attrape sans Attrape, pendant lequel le Joueur ne peut pas attraper.
_Avoid_: Cooldown, lag

**Coup**:
Une Banane qui touche le Joueur sans qu'il ait réussi d'Attrape ; elle augmente son Pourcentage et la Banane disparaît.
_Avoid_: Hit, dégât, touche

**Échec**:
Une Banane qui touche une Plateforme ou tombe dans le vide sans avoir été attrapée ni causé de Coup ; il coûte un Stock au Joueur.
_Avoid_: Drop, raté, banane perdue

## Lancers

**Lancer**:
L'envoi d'une Banane par le Singe ; il en existe trois types : Arc, Tir tendu et Lob.
_Avoid_: Tir, throw

**Arc**:
Un Lancer à trajectoire parabolique d'angle et de force variables.

**Tir tendu**:
Un Lancer rapide à trajectoire presque horizontale.

**Lob**:
Un Lancer très haut et lent qui retombe presque à la verticale.

**Élan**:
L'animation du Singe qui annonce le type du Lancer à venir.
_Avoid_: Wind-up, préparation, télégraphe

**Cadence**:
Le rythme auquel le Singe enchaîne ses Lancers, qui augmente avec le Score.
_Avoid_: Fréquence, vitesse

## Survie

**Partie**:
Une session de jeu, du premier Stock jusqu'à la perte du dernier.
_Avoid_: Run, round, manche

**Score**:
Le nombre d'Attrapes réussies pendant une Partie.
_Avoid_: Points

**Meilleur score**:
Le Score le plus élevé jamais atteint sur cet appareil.
_Avoid_: Record, high score

**Pourcentage**:
Les dégâts cumulés du Joueur, qui déterminent la force de son Éjection.
_Avoid_: PV, vie, santé, HP

**Éjection**:
Le recul subi par le Joueur lors d'un Coup, d'autant plus fort que son Pourcentage est élevé.
_Avoid_: Knockback, recul

**Réapparition**:
Le retour du Joueur dans l'Arène après la perte d'un Stock, suivi d'une Invulnérabilité.
_Avoid_: Respawn

**Invulnérabilité**:
La période après une Réapparition pendant laquelle les Bananes ne peuvent pas provoquer de Coup, mais restent attrapables.
_Avoid_: Invincibilité, i-frames

**Stock**:
Une vie du Joueur (3 par Partie) ; il en perd une en sortant de l'Arène ou lors d'un Échec, et son Pourcentage repart à 0.
_Avoid_: Vie, essai

## Terrain

**Arène**:
Le terrain de jeu : une Plateforme principale flottante entourée de vide.
_Avoid_: Niveau, stage, map

**Plateforme**:
Une surface de l'Arène sur laquelle le Joueur peut se tenir ; les Plateformes hautes sont traversables par le dessous.
_Avoid_: Sol, bloc
