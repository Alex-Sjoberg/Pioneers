; BEFORE-DICE Section
(defrule play-soldier
    (goal before-dice)

    (devel-card (kind soldier) (can-play 1))
    (my-id ?pid)

    (robber (hex ?hid))
    (node (id ?nid) (hexes $? ?hid $?))
    (or (settlement (player ?pid) (node ?nid))
        (city (player ?pid) (node ?nid)))
    =>
    (assert (action "Play Soldier"))
)

(defrule play-plenty
    (goal before-dice)

    (devel-card (kind year-of-plenty) (can-play 1))
    =>
    (assert (action "Play Year Of Plenty"))
)

(defrule roll-dice
    (declare (salience -10))
    (goal before-dice)
    =>
    (assert (action "Roll Dice"))
)
