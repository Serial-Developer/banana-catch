# 03 : Coup, Pourcentage, Éjection, sortie d'Arène et Réapparition

Status: done
Blocked by: 02
Spec: ../spec.md (user stories 16 à 23, 28 à 32)

## Objectif

Les Bananes mal timées font mal. Un Coup augmente le Pourcentage et provoque une Éjection d'autant plus forte que ce Pourcentage est élevé. Sortir de l'Arène coûte un Stock. Le Joueur réapparaît ensuite avec une Invulnérabilité.

## À faire

- Coup : un contact avec le Joueur hors Fenêtre d'attrape (et hors Invulnérabilité) produit les effets suivants :
  - la Banane disparaît, sans Échec ;
  - le Pourcentage augmente ;
  - le signal Coup est émis, avec le Pourcentage obtenu ;
  - le Joueur subit une Éjection.
- Éjection : la force vaut base + Pourcentage × facteur. La direction suit la vitesse de la Banane, légèrement orientée vers le haut. Pendant un temps proportionnel à la force, le Joueur n'a plus le contrôle et ne peut pas attraper. Il retrouve ensuite le contrôle, y compris le double saut, pour revenir vers l'Arène.
- Sortie d'Arène : franchir les limites (côtés, haut, bas) fait perdre un Stock.
- Perte de Stock, quelle qu'en soit la cause (Échec ou sortie) :
  - le Pourcentage repasse à 0 ;
  - si le Joueur est hors de l'Arène, il réapparaît au-dessus de l'Arène et le signal Réapparition est émis ;
  - une Invulnérabilité de 2 s commence.
- Invulnérabilité :
  - les Bananes traversent le Joueur sans Coup et poursuivent leur course, puis peuvent finir en Échec ;
  - l'Attrape reste possible.
- Priorité quand plusieurs contacts arrivent dans la même image physique : Attrape > Coup > Échec.
- Mettre les valeurs dans la ressource de réglages.

## Critères d'acceptation

- [x] Tests qui vérifient que :
  - un Coup augmente le Pourcentage, fait disparaître la Banane et ne provoque aucun Échec ;
  - à Pourcentage élevé, la même Banane éjecte plus loin qu'à 0 % (comparaison de distances, sans valeur exacte) ;
  - pendant l'Éjection, un appui sur `catch` est sans effet ;
  - une Éjection forte qui fait sortir le Joueur de l'Arène lui coûte un Stock, remet le Pourcentage à 0 et déclenche une Réapparition ;
  - pendant l'Invulnérabilité, une Banane traverse le Joueur sans Coup puis finit en Échec ;
  - pendant l'Invulnérabilité, l'Attrape reste possible ;
  - une Banane qui touche le Joueur et une Plateforme dans la même image donne un Coup et pas d'Échec.

## Comments

### Compte rendu (agent, 2026-10-22)

**Fait**
- Coup : contact hors Fenêtre d'attrape et hors Invulnérabilité. La Banane disparaît, le Pourcentage augmente de `pourcentage_par_coup` et le signal `coup(pourcentage)` est émis.
- Éjection : la force vaut `ejection_base + Pourcentage × ejection_facteur`, calculée avec le Pourcentage *après* le Coup, comme dans Smash. La durée sans contrôle est proportionnelle à cette force, avec un minimum. Pendant l'Éjection, le Joueur ne peut ni bouger ni ouvrir de Fenêtre d'attrape. Il retrouve ensuite tout son contrôle, double saut compris.
- Sortie des limites de l'Arène : perte d'un Stock, Réapparition au point d'apparition (signal `reapparition`), Pourcentage remis à 0, Invulnérabilité de 2 s.
- Toute perte de Stock (Échec ou sortie) remet le Pourcentage à 0 et donne l'Invulnérabilité. Un Échec ne fait pas réapparaître un Joueur resté dans l'Arène.
- Pendant l'Invulnérabilité, une Banane traverse le Joueur et continue sa course, mais l'Attrape reste possible.
- La priorité entre contacts est évaluée sur toute l'image physique : si la Banane touche le Joueur à un moment de l'image, ce contact l'emporte sur un contact avec une Plateforme.
- État observable ajouté : `pourcentage()`, `joueur_en_ejection()`, `joueur_invulnerable()`.
- Lanceur de tests : un Logger compte les erreurs moteur et de script. Un test qui en provoque une échoue désormais, alors qu'avant il pouvait passer à tort.

**Décisions**
- Direction de l'Éjection : composante horizontale = celle de la vitesse de la Banane (normalisée), composante verticale fixe vers le haut (`ejection_composante_haute`). Pour une Banane presque verticale, le Joueur est repoussé du côté opposé à la Banane, avec un minimum horizontal de 0,3.
- Le test du ticket 02 « appui trop tôt » attend désormais un Coup au lieu d'un Échec, comme le prévoyait ce ticket.

**À vérifier à la main**
- La sensation de l'Éjection à 0 %, 50 % et 100 % et vers quel Pourcentage une Éjection devient mortelle (réglage au ticket 09).
- La lisibilité du clignotement pendant l'Invulnérabilité.
