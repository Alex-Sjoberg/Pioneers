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

; calculate the number of roads each player has
(defrule init-find-roads
    (goal init-turn-1)
    (player (id ?pid))
    =>
    (assert (road-count (player ?pid) (count 0)))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIND-RESOURCE-TOTAL-PROBS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule find-my-resource-total-probs
    (goal init-turn-1)
    (my-id ?pid)
    (settlement (node ?nid) (player ?pid))
    (node (id ?nid) (hexes $? ?hid $?))
    (hex (id ?hid) (resource ?res&~desert&~sea) (prob ?prob))
    =>
    (assert (add-to-resource-sum ?res ?prob))
)

(defrule init-resource-probs
    (goal init-turn-1)
    (add-to-resource-sum ?res ?prob)
    (not (total-resource-prob (kind ?res)))
    =>
    (assert (total-resource-prob (kind ?res) (prob 0)))
)

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

(defrule sum-resource-rarity
    (hex (id ?hid) (resource ?res) (prob ?prob))
    ?t <- (dot-total (kind ?res) (amnt ?amnt))
    =>
    (modify ?t (amnt ?prob))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVE TO INIT-TURN-2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule move-to-init-turn-2
  (declare (salience -10))
  ?f <- (goal init-turn-1)
  =>
  (retract ?f)
  (assert (goal init-turn-2))
)
