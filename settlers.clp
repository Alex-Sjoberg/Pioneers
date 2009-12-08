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
    (slot port (allowed-values lumber brick wool grain ore 3to1 nil))
    (slot number (default 0) (range 0 12))
    (slot prob (type INTEGER) (range 0 5))
)

(deftemplate robber
    (slot hex)
)

(deftemplate node
    (slot id (type INTEGER))
    (multislot hexes (type INTEGER) (cardinality 3 3))
    (slot can-build (default 0))
    (slot port)
)

(deftemplate edge
    (slot id (type INTEGER))
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
    (slot kind (allowed-values lumber brick wool grain ore sea desert))
    (slot amnt (type INTEGER))
)

(deftemplate devel-card
    (slot kind (allowed-values road_building monopoly year_of_plenty victory soldier))
    (slot amnt (type INTEGER))
    (slot can-play)
)

(deftemplate road-count
    (slot player)
    (slot count)
)

(deftemplate port
  (multislot port-hex)
  (multislot conn-hex)
)

(deffacts port-locations
  (port (port-hex 6 2) (conn-hex 5 2))
  (port (port-hex 6 4) (conn-hex 5 3))
  (port (port-hex 5 5) (conn-hex 4 5))
  (port (port-hex 3 6) (conn-hex 3 5))
  (port (port-hex 1 5) (conn-hex 2 5))
  (port (port-hex 0 4) (conn-hex 1 3))
  (port (port-hex 0 2) (conn-hex 1 2))
  (port (port-hex 2 1) (conn-hex 2 2))
  (port (port-hex 4 1) (conn-hex 4 2))
)


(deffacts initial-state
  (phase init-turn-1)
)




















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                      INIT-TURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FINDING THE GOAL
(defrule determine-goal
    (phase init-turn-1)
    =>
    (assert (goal build-city))
)

; swap all the edges so we don't have to match on both orders
(defrule swap-edges
    (phase init-turn-1)
    (edge (id ?eid) (nodes ?n1 ?n2))
    (not (edge (nodes ?n2 ?n1)))
    =>
    (assert (edge (id ?eid) (nodes ?n2 ?n1)))
)

(defrule calculate-port-nodes
    (phase init-turn-1)
    (port (port-hex ?x1 ?y1) (conn-hex ?x2 ?y2))
    (hex (id ?hid1) (xpos ?x1) (ypos ?y1) (port ?res&~nil))
    (hex (id ?hid2) (xpos ?x2) (ypos ?y2))
    (or
      ?n <- (node (id ?nid) (hexes $? ?hid1 $? ?hid2 $?) (port nil))
      ?n <- (node (id ?nid) (hexes $? ?hid2 $? ?hid1 $?) (port nil))
    )
    =>
    (modify ?n (port ?res))
)

; calculate the number of roads each player has
(defrule init-find-roads
    (phase init-turn-1)
    (player (id ?pid))
    =>
    (assert (road-count (player ?pid) (count 0)))
)

(defrule count-roads
    (phase init-turn-2)
    (road (player ?pid))
    =>
    (assert (add-to-road-sum ?pid))
)

(defrule get-trading-price-1
    (phase init-turn-1)
    (my-id ?pid)
    (settlement (player ?pid) (node ?nid))
    ;(hex (id ?hid) (port 3to1))
    (node (id ?nid) (port 3to1))
    =>
    (assert (my-maritime-trade 3))
)
(defrule get-trading-price-2
    ;(not (hex (id ?id) (port 3to1)))
    (phase init-turn-1)
    =>
    (assert (my-maritime-trade 4))
)








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     INIT-TURN-2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; calculate which nodes can be built upon and which cannot
(defrule can-build-on-nodes
    (phase init-turn-2)
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

(defrule count-road-sums
    ?c <- (add-to-road-sum ?pid)
    ?f <- (road-count (player ?pid) (count ?cnt))
    =>
    (retract ?c)
    (modify ?f (count (+ ?cnt 1)))
)

















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                         TURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INITIAL-SETUP
(defrule find-settlement-possibilities
    ; At least one settlement to place
    (phase turn)
    (game-phase initial-setup)
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

    (phase turn)
    (game-phase initial-setup)
    (settlements-to-place ?num&:(> ?num 0))
    (possible-settlement (node ?nid) (prob-sum ?psum))

    ; ...and for which there is no other possible settlement spot
    ; which has a higher probability
    (not (possible-settlement (prob-sum ?psum2&:(> ?psum2 ?psum))))

    =>

    (printout t crlf "ACTION: Build Settlement " ?nid crlf)
    (exit)
)

(defrule place-starting-road
    (phase turn)
    (game-phase initial-setup)
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

    (printout t crlf "ACTION: Build Road " ?eid crlf)
    (exit)
)

(defrule end-initial-setup
    (phase turn)
    (game-phase initial-setup)
    (settlements-to-place 0)
    (roads-to-place 0)
    =>
    (printout t crlf "ACTION: End Turn" crlf)
)






; DISCARD
(defrule discard-cards
    (phase turn)
    (game-phase discard)
    =>
    (assert (discarding))
    (printout t crlf "ACTION: Discard")
)

(defrule find-least-valuable-card
    (phase turn)
    (game-phase discard)
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
    (phase turn)
    ?f <- (discarding)
    =>
    (retract ?f)
    (printout t crlf)
    (exit)
)








;TRADING WITH THE BANK

(defrule trade-4-for-road
    (phase turn)
    (game-phase do-turn)
    (goal build-road)
    (my-maritime-trade ?price)
    (resource-cards (kind ?want&lumber|brick) (amnt 0))
    (or
        (resource-cards (kind ?trade&~lumber&~brick) (amnt ?amnt&:(>= ?amnt ?price)))
        (resource-cards (kind ?trade&~?want&lumber|brick) (amnt ?amnt&:(>= ?amnt (+ ?price 1))))
    )
    =>
    (printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
    (exit)
)
(defrule trade-4-for-development-card
    (phase turn)
    (game-phase do-turn)
    (goal buy-development-card)
    (my-maritime-trade ?price)
    (resource-cards (kind ?want&wool|grain|ore) (amnt 0))
    (or
        (resource-cards (kind ?trade&~wool&~grain&~ore) (amnt ?amnt&:(>= ?amnt ?price)))
        (resource-cards (kind ?trade&~?want&wool|grain|ore) (amnt ?amnt&:(>= ?amnt (+ ?price 1))))
    )
    =>
    (printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
    (exit)
)
(defrule trade-4-for-settlement
    (phase turn)
    (game-phase do-turn)
    (goal build-settlement)
    (my-maritime-trade ?price)
    (resource-cards (kind ?want&lumber|brick|wool|grain) (amnt 0))
    (or
        (resource-cards (kind ?trade&~lumber&~brick&~wool&~grain) (amnt ?amnt&:(>= ?amnt ?price)))
        (resource-cards (kind ?trade&~?want&lumber|brick|wool|grain) (amnt ?amnt&:(>= ?amnt (+ ?price 1))))
    )
    =>
    (printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
    (exit)
)
(defrule trade-4-for-city
    (phase turn)
    (game-phase do-turn)
    (goal build-city)
    (my-maritime-trade ?price)
    (or
        (resource-cards (kind ?want&grain) (amnt ?amnt&:(< ?amnt 2)))
        (resource-cards (kind ?want&ore) (amnt ?amnt&:(< ?amnt 3)))
    )
    (or
        (resource-cards (kind ?trade&~grain&~ore) (amnt ?amnt2&:(>= ?amnt2 ?price)))
        (resource-cards (kind ?trade&grain) (amnt ?amnt2&:(> ?amnt2 (+ ?price 2))))
        (resource-cards (kind ?trade&ore) (amnt ?amnt2&:(> ?amnt2 (+ ?price 3))))
    )
    =>
    (printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
    (exit)
)








; MOVE-ROBBER
(defrule find-robber-placements
    (declare (salience 2))
    (phase turn)
    (game-phase place-robber)
    (my-num ?pid)
    (or
      (settlement (player ~?pid) (node ?nid))
      (city (player ~?pid) (node ?nid))
    )
    (node (id ?nid) (hexes $? ?hid $?))
    (not (robber (hex ?hid)))
    (hex (id ?hid) (prob ?prob))
    (not
      (and
        (node (id ?tnid) (hexes $? ?hid $?))
        (or
          (settlement (player ?pid) (node ?tnid))
          (city (player ?pid) (node ?tnid))
        )
      )
    )
    =>
    (assert (potential-robber-placement ?hid))
)

(defrule move-robber
    (declare (salience 1))
    (phase turn)
    (game-phase place-robber)
    (potential-robber-placement ?hid)
    (hex (id ?hid) (prob ?prob))
    (not
      (and
        (potential-robber-placement ?hid2)
        (hex (id ?hid2) (prob ?prob2&:(> ?prob2 ?prob)))
      )
    )
    =>
    (facts)
    (printout t crlf "ACTION: Place Robber " ?hid crlf)
    (exit)
)







; DO-TURN
(defrule play-soldier
    (declare (salience 1000))
    (phase turn)
    (game-phase do-turn)
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

(defrule play-victory
    (phase turn)
    (game-phase do-turn)
    (devel-card (kind victory) (can-play 1))
    =>
    (printout t crlf "ACTION: Play Victory" crlf)
)

(defrule roll-dice
    (declare (salience 500))
    (phase turn)
    (game-phase do-turn)
    (not (dice-already-rolled))
    =>
    (printout t crlf "ACTION: Roll Dice" crlf)
    (exit)
)

(defrule build-road
    (phase turn)
    (game-phase do-turn)
    ;(goal build-road)
    (my-num ?pid)
    (road-count (player ?pid) (count ?cnt&:(< ?cnt 15)))
    (resource-cards (kind lumber) (amnt ?lamnt&:(>= ?lamnt 1)))
    (resource-cards (kind brick) (amnt ?bamnt&:(>= ?bamnt 1)))
    (or
      (settlement (player ?pid) (node ?nid))
      (city (player ?pid) (node ?nid))
    )
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
    (phase turn)
    (game-phase do-turn)
    ;(goal build-settlement)
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
    (phase turn)
    (game-phase do-turn)
    ;(goal build-city)
    (my-num ?pid)
    (player (id ?pid) (num-cities ?num&:(< ?num 4)))
    (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
    (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
    (my-num ?pid)
    (settlement (player ?pid) (node ?node))
    =>
    (printout t crlf "ACTION: Build City " ?node crlf)
    (exit)
)

(defrule buy-development-card
    (phase turn)
    (game-phase do-turn)
    ;(goal buy-development-card)
    (num-develop-in-deck ?num&:(> ?num 0))
    (resource-cards (kind wool) (amnt ?wamnt&:(>= ?wamnt 1)))
    (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 1)))
    (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 1)))
    =>
    (printout t crlf "ACTION: Buy Development Card" crlf)
    (exit)
)









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       END-TURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule end-turn
    (phase end-turn)
    =>
    (printout t crlf "ACTION: End Turn (default)" crlf)
    (exit)
)








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                      CONTROL-FACTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule move-to-init-turn-2
  (declare (salience -100))
  ?f <- (phase init-turn-1)
  =>
  (retract ?f)
  (assert (phase init-turn-2))
)

(defrule move-to-turn
  (declare (salience -100))
  ?f <- (phase init-turn-2)
  =>
  (retract ?f)
  (assert (phase turn))
)

(defrule move-to-end-turn
  (declare (salience -100))
  ?f <- (phase turn)
  =>
  (retract ?f)
  (assert (phase end-turn))
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
