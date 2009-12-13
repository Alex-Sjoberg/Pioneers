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
    (printout t crlf "ACTION: Play Soldier" crlf)
    (exit)
)

(defrule roll-dice
    (declare (salience -10))
    (goal before-dice)
    =>
    (printout t crlf "ACTION: Roll Dice" crlf)
    (exit)
)
