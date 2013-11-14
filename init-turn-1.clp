;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                      INIT-TURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; swap all the edges so we don't have to match on both orders
(defrule swap-edges
    (goal init-turn-1)
    (edge (id ?eid) (nodes ?n1 ?n2))
    (not (edge (nodes ?n2 ?n1)))
    =>
    (assert (edge (id ?eid) (nodes ?n2 ?n1)))
)

(defrule calculate-port-nodes
    (goal init-turn-1)
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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIND-RESOURCE-TOTAL-PROBS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; If we have a settlement on a node, add the resource probability for the adjacent hexes to our 
;'resource sum'. Also print out the facts   
(defrule find-my-resource-settlement-probs
    (goal init-turn-1)
    (my-id ?pid)
    (settlement (node ?nid) (player ?pid))
    (or
      (node (id ?nid) (hexes ?hid ? ?))
      (node (id ?nid) (hexes ? ?hid ?))
      (node (id ?nid) (hexes ? ? ?hid))
    )
    (hex (id ?hid) (resource ?res&~desert&~sea) (prob ?prob))
    =>
    (facts)
    (assert (add-to-resource-sum ?res ?prob))
)

;Same as above, except for cities
(defrule find-my-resource-city-probs
    (goal init-turn-1)
    (my-id ?pid)
    (city (node ?nid) (player ?pid))
    (or
      (node (id ?nid) (hexes ?hid ? ?))
      (node (id ?nid) (hexes ? ?hid ?))
      (node (id ?nid) (hexes ? ? ?hid))
    )
    (hex (id ?hid) (resource ?res&~desert&~sea) (prob ?prob))
    =>
    (assert (add-to-resource-sum ?res (* 2 ?prob)))
)

; Adds the probability of getting a resources generated above to our total probability of getting 
;that resource
(defrule sum-resource-probs
    (goal init-turn-1)
    ?a <- (add-to-resource-sum ?res ?prob)
    ?f <- (total-resource-prob (kind ?res) (prob ?sprob))
    =>
    (modify ?f (prob (+ ?sprob ?prob)))
    (retract ?a)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUM-VICTORY-POINTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;If we have victory point cards add those to our victory point total
(defrule find-victory-points
    (goal init-turn-1)
    (devel-card (kind victory) (amnt ?num))
    =>
    (assert (add-to-victory-sum ?num))
)

(defrule sum-victory-points
    (goal init-turn-1)
    ?a <- (add-to-victory-sum ?add)
    ?s <- (victory-sum ?sum)
    =>
    (retract ?a ?s)
    (assert (victory-sum (+ ?sum ?add)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TRADING PRICES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If we have a settlement on a node with a 3to1 port, assert a my-maritime-trade fact with a value of three, otherwise 4

(defrule get-trading-price-1
    (goal init-turn-1)
    (my-id ?pid)
    (settlement (player ?pid) (node ?nid))
    ;(hex (id ?hid) (port 3to1))
    (node (id ?nid) (port 3to1))
    =>
    (assert (my-maritime-trade 3))
)

(defrule get-trading-price-2
    ;(not (hex (id ?id) (port 3to1)))
    (goal init-turn-1)
    =>
    (assert (my-maritime-trade 4))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RESOURCE RARITY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Adds up the total probability of a certain resource on the board and stores it in a dot-total fact

(defrule start-sum-resource-rarity
    (goal init-turn-1)
    (hex (id ?hid) (resource ?res) (prob ?prob))
    =>
    (assert (dot-addend (kind ?res) (amnt ?prob)))
)


(defrule finish-sum-resource-rarity
    (goal init-turn-1)
    ?a <- (dot-addend (kind ?res) (amnt ?amnt))
    ?t <- (dot-total (kind ?res) (amnt ?total))
    =>
    (retract ?a)
    (modify ?t (amnt (+ ?amnt ?total)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TARGET SETTLEMENT LOCATION PART 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If we have a settlement on a nvode, set its distance to zero

(defrule find-my-settlement-nodes
    (goal init-turn-1)
    (my-id ?pid)
    (or
        (settlement (player ?pid) (node ?nid))
        (city (player ?pid) (node ?nid))
    )
    ?n <- (node (id ?nid) (distance -1))
    =>
    (modify ?n (distance 0))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVE TO INIT-TURN-2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule move-to-init-turn-2
  (declare (salience -10))
  ?f <- (goal init-turn-1)
  =>
  (retract ?f)
  (printout t "Switching GOAL to init-turn-2" crlf)
  (assert (goal init-turn-2))
)
