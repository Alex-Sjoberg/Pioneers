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
    (slot can-build (default 0))
)

(deftemplate edge
    (slot id)
    (multislot nodes (type INTEGER) (cardinality 2 2))
)

(deftemplate settlement
    (slot player)
    (slot node)
)

(deftemplate possible-settlement
    (slot node)
    (slot prob-sum)
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







; swap all the edges so we don't have to match on both orders
(defrule swap-edges
    (declare (salience 2000))
    (edge (id ?eid) (nodes ?n1 ?n2))
    (not (edge (nodes ?n2 ?n1)))
    =>
    (assert (edge (id ?eid) (nodes ?n2 ?n1)))
)

; calculate which nodes can be built upon and which cannot
(defrule can-build-on-nodes
    (declare (salience 1000))
    ?n <- (node (id ?nid) (hexes $? ?hid $?) (can-build 0))
    (not
      (or
        (settlement (node ?nid))
        (city (node ?nid))
      )
    )
    (hex (id ?hid) (resource ~desert&~sea))
    (not
      (and
        (or
          (settlement (node ?cnode))
          (city (node ?cnode))
        )
        (edge (nodes ?nid ?cnode))
      )
    )
    =>
    (modify ?n (can-build 1))
)




; INITIAL-SETUP
(defrule find-settlement-possibilities
    ; At least one settlement to place
    (phase initial-setup)
    (settlements-to-place ?num&:(> ?num 0))

    ; Find a node that doesn't have a settlement...
    (node (id ?nid) (hexes ?h1 ?h2 ?h3))
    (not (settlement (node ?nid)))
    (hex (id ?h1) (prob ?p1))
    (hex (id ?h2) (prob ?p2))
    (hex (id ?h3) (prob ?p3))

    ; ...and that isn't next to a node that has a settlement
    (not
      (and
        (settlement (node ?cnode))
        (edge (nodes ?nid ?cnode))
      )
    )
    =>
    (assert (possible-settlement (node ?nid) (prob-sum (+ ?p1 ?p2 ?p3))))
)

(defrule place-starting-settlement
    (declare (salience -10))

    (phase initial-setup)
    (settlements-to-place ?num&:(> ?num 0))
    (possible-settlement (node ?nid) (prob-sum ?psum))

    ; ...and for which there is no other possible settlement spot
    ; which has a higher probability
    (not (possible-settlement (prob-sum ?psum2&:(> ?psum2 ?psum))))

    =>

    (printout t crlf "ACTION: Place Settlement " ?nid crlf)
    (exit)
)

(defrule place-starting-road
    (phase initial-setup)
    (my-num ?pnum)

    (roads-to-place ?num&:(> ?num 0))

    (settlement (player ?pnum) (node ?nid))
    (not
      (and
        (road (edge ?eid))
        (edge (id ?eid) (nodes $? ?nid $?))
      )
    )

    (edge (id ?eid) (nodes ?nid ?cnode))
    (not (road (edge ?eid)))
    (node (id ?cnode) (hexes $? ?chex $?))
    (hex (id ?chex) (resource ?res&~sea&~desert))

    =>

    (printout t crlf "ACTION: Place Road " ?eid crlf)
    (exit)
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
    (not (resource-cards (amnt ?namnt&:(> ?namnt ?amnt))))
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
    (my-num ?pid)
    (hex (id ?hid) (number 8))
    (not (robber (hex ?hid)))
    (not
      (and
        (node (id ?nid) (hexes $? ?hid $?))
        (or
          (settlement (node ?nid) (player ?pid))
          (city (node ?nid) (player ?pid))
        )
      )
    )
    =>
    (printout t crlf "ACTION: Place Robber " ?hid crlf)
    (exit)
)



; DO-TURN
(defrule play-soldier
    (declare (salience 1000))
    (phase do-turn)
    (devel-card (kind soldier) (can-play 1))
    (my-num ?pid)
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
    (my-num ?pid)
    (player (id ?pid) (num-roads ?num&:(< ?num 15)))
    (resource-cards (kind lumber) (amnt ?lamnt&:(>= ?lamnt 1)))
    (resource-cards (kind brick) (amnt ?bamnt&:(>= ?bamnt 1)))
    (settlement (player ?pid) (node ?nid))
    (or
      (and
        (edge (id ?eid1) (nodes ?nid ?cnode))
        (road (player ?pid) (edge ?eid1))
        (edge (id ?eidtobuild) (nodes ?cnode ?cnode2&~?nid))
        (node (id ?cnode2) (can-build 1))
      )
      (edge (id ?eidtobuild) (nodes ?nid ?cnode2))
    )

    (not (road (edge ?eidtobuild)))

    (node (id ?cnode2) (hexes ?h1 ?h2 ?h3))
    (hex (id ?h1) (resource ?res1) (number ?p1))
    (hex (id ?h2) (resource ?res2) (number ?p2))
    (hex (id ?h3) (resource ?res3) (number ?p3))
    =>
    (printout t crlf "DEBUG: " ?res1 " " ?p1 " | " ?res2 " " ?p2 " | "  " " ?res3 " " ?p3 crlf)
    (printout t crlf "ACTION: Build Road " ?eidtobuild crlf)
    (exit)
)

(defrule build-settlement
    (declare (salience 10))
    (phase do-turn)
    (my-num ?pid)
    (player (id ?pid) (num-settlements ?num&:(< ?num 5)))
    (resource-cards (kind lumber) (amnt ?lamnt&:(>= ?lamnt 1)))
    (resource-cards (kind brick) (amnt ?bamnt&:(>= ?bamnt 1)))
    (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 1)))
    (resource-cards (kind wool) (amnt ?wamnt&:(>= ?wamnt 1)))
    (road (player ?pid) (edge ?edge))
    (edge (id ?edge) (nodes $? ?node $?))
    (node (id ?node) (can-build 1))

    (node (id ?node) (hexes ?h1 ?h2 ?h3))
    (hex (id ?h1) (resource ?res1) (number ?p1))
    (hex (id ?h2) (resource ?res2) (number ?p2))
    (hex (id ?h3) (resource ?res3) (number ?p3))
    =>
    (printout t crlf "DEBUG: " ?res1 " " ?p1 " | " ?res2 " " ?p2 " | "  " " ?res3 " " ?p3 crlf)
    (printout t crlf "ACTION: Build Settlement " ?node crlf)
    (exit)
)

(defrule build-city
    (declare (salience 20))
    (phase do-turn)
    (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
    (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
    (my-num ?pid)
    (settlement (player ?pid) (node ?node))
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
    (printout t crlf "ACTION: End Turn (default)" crlf)
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
