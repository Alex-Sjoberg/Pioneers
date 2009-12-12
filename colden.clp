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

(deftemplate total-resource-prob
  (slot kind)
  (slot prob)
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
  (victory-sum 0)
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
    (load "../trade.clp")
    (assert (goal init-turn-1))
)



;to win the girls heart,
;make her feel important and that her ideas matter over a period of time
;do small things that are thoughtful
;when she is stressed out

;mia considers this cute:
;Before tonight, I never believed in predestination...

(defrule play-victory
    (game-phase do-turn)
    (my-num ?pid)
    (player (id ?pid) (score ?score))
    (devel-card (kind victory) (amnt ?amnt) (can-play 1))
    (test (>= (+ ?score ?amnt) 10))
    =>
    (printout t crlf "ACTION: Play Victory" crlf)
    (exit)
)


;TRADE section
;client needs to print out all the possible quotes and the system pick one
;don't accept trades for resources you have good supplies of
;accept trades for resources you don't have access to


(defrule end-turn
    (declare (salience -1000))
    =>
    (printout t crlf "ACTION: End Turn (default)" crlf)
    (exit)
)
