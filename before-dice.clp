; BEFORE-DICE Section

;; If the robber is on a hex adjacent to one of our cities or settlements, play a soldier
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

;; If we have a monopoly card we can play, do it.
(defrule play-mono
    (goal before-dice)

    (devel-card (kind monopoly) (can-play 1))
    =>
    (assert (action "Play Monopoly"))
)

;; If we have a year of plenty card, play it.
(defrule play-plenty
    (goal before-dice)

    (devel-card (kind year-of-plenty) (can-play 1))
    =>
    (assert (action "Play Year Of Plenty"))
)

;; Roll the dice if none of the other rule spaply
(defrule roll-dice
    (declare (salience -10))
    (goal before-dice)
    =>
    (assert (action "Roll Dice"))
)
