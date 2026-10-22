# 03 : Coup, Pourcentage, Éjection, sortie d'Arène et Réapparition

Status: ready-for-agent
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

- [ ] Tests qui vérifient que :
  - un Coup augmente le Pourcentage, fait disparaître la Banane et ne provoque aucun Échec ;
  - à Pourcentage élevé, la même Banane éjecte plus loin qu'à 0 % (comparaison de distances, sans valeur exacte) ;
  - pendant l'Éjection, un appui sur `catch` est sans effet ;
  - une Éjection forte qui fait sortir le Joueur de l'Arène lui coûte un Stock, remet le Pourcentage à 0 et déclenche une Réapparition ;
  - pendant l'Invulnérabilité, une Banane traverse le Joueur sans Coup puis finit en Échec ;
  - pendant l'Invulnérabilité, l'Attrape reste possible ;
  - une Banane qui touche le Joueur et une Plateforme dans la même image donne un Coup et pas d'Échec.

## Comments
