(deftemplate player
  (slot id)
  (multislot name)
  (slot score)
  (slot num-resource-cards)
  (slot num-devel-cards)
  (slot has-largest-army)
  (slot has-longest-road)
  (slot num-soldiers)
  (slot num-settlements)
  (slot num-cities)
)

(deftemplate hex
    (slot id (type INTEGER))
    (slot xpos)
    (slot ypos)
    (slot resource (allowed-values lumber brick wool grain ore sea desert))
    (slot port)
    (slot number (default 0))
    (slot prob (type INTEGER) (range 0 5))
)

(deftemplate robber
    (slot hex)
)

(deftemplate node
    (slot id (type INTEGER))
    (multislot hexes (type INTEGER) (cardinality 3 3))
)

(deftemplate edge
    (slot id)
    (multislot nodes (type INTEGER) (cardinality 2 2))
)

(deftemplate settlement
    (slot player)
    (slot node)
)

(deftemplate city
    (slot player)
    (slot node)
)

(deftemplate road
    (slot player)
    (slot edge)
)

(deftemplate resource-cards
    (slot kind)
    (slot amnt)
)

(deftemplate devel-card
    (slot kind)
    (slot can-play)
)








; INITIAL-SETUP
(defrule place-starting-settlement
    ; At least one settlement to place
    (phase initial-setup)
    (my-num ?pnum)
    ?s <- (settlements-to-place ?num&:(> ?num 0))

    ; Find a highest probability hex
    (hex (id ?hid) (prob ?prob))
    (not (hex (prob ?other&:(> ?other ?prob))))

    ; Find a node on this hex that doesn't have a settlement
    (node (id ?nid) (hexes $? ?hid $?))
    (not (settlement (node ?nid)))

    ; ...and that isn't next to a node that has a settlement
    (not
      (and
        (or
          (edge (nodes ?cnode ?nid))
          (edge (nodes ?nid ?cnode))
        )
        (node (id ?cnode) (hexes $? ?chex $?))
        (hex (id ?chex) (resource ?res&~sea&~desert))
        (settlement (node ?cnode))
      )
    )

    =>

    (printout t crlf "ACTION: Place Settlement " ?nid crlf)
    (assert (settlement (player ?pnum) (node ?nid)))

    (retract ?s)
    (assert (settlements-to-place (- ?num 1)))
)

(defrule place-starting-road
    (phase initial-setup)
    (my-num ?pnum)

    ?s <- (roads-to-place ?num&:(> ?num 0))

    (settlement (player ?pnum) (node ?nid))
    (not
      (and
        (edge (id ?eid) (nodes $? ?nid $?))
        (road (edge ?eid))
      )
    )

    ; DEBUG
    ;(node (id ?nid) (hexes ?h1 ?h2 ?h3))
    ;(hex (id ?h1) (resource ?res1))
    ;(hex (id ?h2) (resource ?res2))
    ;(hex (id ?h3) (resource ?res3))

    (or
      (edge (id ?eid) (nodes ?cnode ?nid))
      (edge (id ?eid) (nodes ?nid ?cnode))
    )
    (not (road (edge ?eid)))
    (node (id ?cnode) (hexes $? ?chex $?))
    (hex (id ?chex) (resource ?res&~sea&~desert))

    ; DEBUG
    ;(node (id ?cnode) (hexes ?h4 ?h5 ?h6))
    ;(hex (id ?h4) (resource ?res4))
    ;(hex (id ?h5) (resource ?res5))
    ;(hex (id ?h6) (resource ?res6))

    =>
    ;(printout t "DEBUG: node1=" ?res1 " " ?res2 " " ?res3 " ; node2=" ?res4 " " ?res5 " " ?res6 crlf);

    (printout t crlf "ACTION: Place Road " ?eid crlf)
    (assert (road (player ?pnum) (edge ?eid)))

    (retract ?s)
    (assert (roads-to-place (- ?num 1)))
)

(defrule end-initial-setup
    (phase initial-setup)
    (settlements-to-place 0)
    (roads-to-place 0)
    =>
    (printout t crlf "ACTION: End Turn" crlf)
)






; DISCARD
(defrule discard-cards
    (phase discard)
    =>
    (assert (discarding))
    (printout t crlf "ACTION: Discard")
)

(defrule find-least-valuable-card
    (phase discard)
    (discarding)
    ?n <- (num-to-discard ?num&:(> ?num 0))
    ?c <- (resource-cards (kind ?kind) (amnt ?amnt&:(> ?amnt 0)))
    =>
    (retract ?n)
    (assert (num-to-discard (- ?num 1)))
    (modify ?c (amnt (- ?amnt 1)))
    (printout t " " ?kind)
)

(defrule done-discarding
    (declare (salience -10))
    ?f <- (discarding)
    =>
    (retract ?f)
    (printout t crlf)
    (exit)
)





; MOVE-ROBBER
(defrule move-robber
    (phase place-robber)
    (hex (id ?hid) (number 8))
    (not (robber (hex ?hid)))
    =>
    (printout t crlf "ACTION: Place Robber " ?hid crlf)
    (exit)
)



; DO-TURN
(defrule play-soldier
    (declare (salience 1000))
    (phase do-turn)
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
    (declare (salience 500))
    (phase do-turn)
    (not (dice-already-rolled))
    =>
    (printout t crlf "ACTION: Roll Dice" crlf)
    (exit)
)

(defrule build-road
    (phase do-turn)
    (my-id ?pid)
    (resource-cards (kind lumber) (amnt ?amnt&:(>= ?amnt 1)))
    (resource-cards (kind brick) (amnt ?amnt&:(>= ?amnt 1)))
    (edge (id ?edge1) (nodes $? ?node $?))
    (edge (id ?edge2&~?edge1) (nodes $? ?node $?))
    =>
    (printout t crlf "ACTION: Build Road " ?edge2 crlf)
    (exit)
)

(defrule build-settlement
    (phase do-turn)
    (my-id ?pid)
    (resource-cards (kind lumber) (amnt ?amnt&:(>= ?amnt 1)))
    (resource-cards (kind brick) (amnt ?amnt&:(>= ?amnt 1)))
    (resource-cards (kind grain) (amnt ?amnt&:(>= ?amnt 1)))
    (resource-cards (kind wool) (amnt ?amnt&:(>= ?amnt 1)))
    (road (player ?id&:(= ?id ?pid)) (edge ?edge))
    (edge (id ?edge) (nodes $? ?node $?))
    =>
    (printout t crlf "ACTION: Build Settlement " ?edge crlf)
    (exit)
)

(defrule build-city
    (phase do-turn)
    (my-id ?pid)
    (settlement (player ?pid) (node ?node))
    (resource-cards (kind grain) (amnt ?amnt&:(>= ?amnt 2)))
    (resource-cards (kind ore) (amnt ?amnt&:(>= ?amnt 3)))
    =>
    (printout t crlf "ACTION: Build City " ?node crlf)
    (exit)
)

(defrule buy-devel-card
    (phase do-turn)
    (resource-cards (kind wool) (amnt ?amnt&:(>= ?amnt 1)))
    (resource-cards (kind grain) (amnt ?amnt&:(>= ?amnt 1)))
    (resource-cards (kind ore) (amnt ?amnt&:(>= ?amnt 1)))
    =>
    (printout t crlf "ACTION: Buy Development Card" crlf)
    (exit)
)

(defrule end-turn
    (declare (salience -1000))
    =>
    (printout t crlf "ACTION: End Turn" crlf)
    (exit)
)


;Settlers of Catan
;
;Strategy
;
;If I have more than 7 cards in my hand, then I want to trade them
;If I have lots of lumber and bricks then I want to make a road
;
;
;0 hill
;1 field
;2 mountain
;3 pasture
;4 forest
;5 desert
;6 sea
;
;0 brick
;1 grain
;2 ore
;3 wool
;4 lumber
;5 none
;6 any
