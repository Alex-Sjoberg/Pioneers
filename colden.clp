; PLAYER
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

; HEX
(deftemplate hex
    (slot id (type INTEGER))
    (slot xpos)
    (slot ypos)
    (slot resource (allowed-values lumber brick wool grain ore sea desert))
    (slot port (allowed-values lumber brick wool grain ore 3to1 nil))
    (slot number (default 0) (range 0 12))
    (slot prob (type INTEGER) (range 0 5))
)

; NODE
(deftemplate node
    (slot id (type INTEGER))
    (multislot hexes (type INTEGER) (cardinality 3 3))
    (slot can-build (default 0))
    (slot distance (default -1)) ;the distance from my own roads or settlements
    (slot port)
)

; EDGE
(deftemplate edge
    (slot id (type INTEGER))
    (multislot nodes (type INTEGER) (cardinality 2 2))
)

; BULIDINGS
(deftemplate settlement (slot player) (slot node))
(deftemplate city (slot player) (slot node))
(deftemplate road (slot player) (slot edge))

(deftemplate robber (slot hex))




(deftemplate trade-commodity
    (slot direction)
    (slot kind)
    (slot amnt)
)

(deftemplate waypoint (slot id) (multislot links))
(deftemplate node-distance (slot id) (slot distance))

(deftemplate available-settlement-node
    (slot node)
    (slot prob-sum)
    (multislot hexes)
)
(deftemplate node-attribute (slot id) (slot attr) (slot val))

; HEX SCORING
(deftemplate hex-score (slot id) (slot score))
(deftemplate hex-attribute (slot id) (slot attr) (slot val))
(deftemplate hex-rarity (slot id) (slot nid) (slot rarity))
(deftemplate dot-total (slot kind) (slot amnt))
(deftemplate dot-addend (slot kind) (slot amnt))
(deftemplate hex-addend (slot id) (slot nid) (slot val))
(deftemplate hex-total (slot id) (slot val))
(deftemplate calculated-node (slot id) (slot score))
(deftemplate calculated-hex (slot id) (slot score))

; CARDS
(deftemplate resource-cards (slot kind) (slot amnt))
(deftemplate bank-cards (slot kind) (slot amnt))
(deftemplate devel-card
    (slot kind)
    (slot amnt)
    (slot can-play)
)

(deftemplate port (multislot port-hex) (multislot conn-hex))
(deftemplate total-resource-prob (slot kind) (slot prob))
(deftemplate possible-settlement-node (slot id) (multislot hexes))

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
  (victory-sum 0)
  (dot-total (kind lumber) (amnt 0))
  (dot-total (kind brick) (amnt 0))
  (dot-total (kind wool) (amnt 0))
  (dot-total (kind ore) (amnt 0))
  (dot-total (kind grain) (amnt 0))
  (total-resource-prob (kind lumber) (prob 0))
  (total-resource-prob (kind brick) (prob 0))
  (total-resource-prob (kind wool) (prob 0))
  (total-resource-prob (kind grain) (prob 0))
  (total-resource-prob (kind ore) (prob 0))
  (trade-commodity (direction they-want) (kind lumber) (amnt 0))
  (trade-commodity (direction they-want) (kind brick) (amnt 0))
  (trade-commodity (direction they-want) (kind grain) (amnt 0))
  (trade-commodity (direction they-want) (kind ore) (amnt 0))
  (trade-commodity (direction they-want) (kind wool) (amnt 0))
  (trade-commodity (direction they-supply) (kind lumber) (amnt 0))
  (trade-commodity (direction they-supply) (kind brick) (amnt 0))
  (trade-commodity (direction they-supply) (kind grain) (amnt 0))
  (trade-commodity (direction they-supply) (kind ore) (amnt 0))
  (trade-commodity (direction they-supply) (kind wool) (amnt 0))
)

(defrule load-clips-files
    =>
    (load "../before-dice.clp")
    (load "../build-city.clp")
    (load "../build-road.clp")
    (load "../build-settlement.clp")
    (load "../decide-action.clp")
    (load "../decide-strategy.clp")
    (load "../discard.clp")
    (load "../init-city-strategy.clp")
    (load "../init-settlement-strategy.clp")
    (load "../init-turn-1.clp")
    (load "../init-turn-2.clp")
    (load "../initial-setup.clp")
    (load "../place-robber.clp")
    (load "../choose-plenty.clp")
    (load "../choose-monopoly.clp")
    (load "../trade.clp")
    (load "../buy-development-card.clp")
    (load "../steal-building.clp")
    (printout t "Switching GOAL to init-turn-1" crlf)
    (assert (goal init-turn-1))
)



;to win the girls heart,
;make her feel important and that her ideas matter over a period of time
;do small things that are thoughtful
;when she is stressed out

;mia considers this cute:
;Before tonight, I never believed in predestination...




(defrule do-action
    (declare (salience 9000)) ;ITS OVER 9000
    (action ?action $?arguments)
    (not (dont-do-action))
    =>
    (printout t crlf "ACTION: " ?action " " (implode$ $?arguments) crlf)
    (exit)
)

(defrule play-victory
    (game-phase do-turn)
    (my-id ?pid)
    (player (id ?pid) (score ?score))
    (devel-card (kind victory) (amnt ?amnt) (can-play 1))
    (test (>= (+ ?score ?amnt) 10))
    =>
    (assert (action "Play Victory"))
    ;(printout t crlf "ACTION: Play Victory" crlf)
    ;(exit)
)


;TRADE section
;client needs to print out all the possible quotes and the system pick one
;don't accept trades for resources you have good supplies of
;accept trades for resources you don't have access to


(defrule end-turn
    (declare (salience -1000))
    (not (dont-do-action))
    =>
    (assert (action "End Turn (default)"))
)

(defrule end-turn-reject-trade
    (declare (salience -1000))
    ?a <- (dont-do-action)
    =>
    (retract ?a)
    (assert (action "Reject Quote (default)"))
)

(defrule print-cards
    (resource-cards (kind lumber) (amnt ?lamnt))
    (resource-cards (kind brick) (amnt ?bamnt))
    (resource-cards (kind wool) (amnt ?wamnt))
    (resource-cards (kind grain) (amnt ?gamnt))
    (resource-cards (kind ore) (amnt ?oamnt))
    =>
    (printout t crlf crlf)
    (printout t "Lumber: " ?lamnt crlf)
    (printout t "Brick: " ?bamnt crlf)
    (printout t "Wool: " ?wamnt crlf)
    (printout t "Grain: " ?gamnt crlf)
    (printout t "Ore: " ?oamnt crlf)
)
