;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     INIT-TURN-2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; calculate which nodes can be built upon and which cannot
(defrule can-build-on-nodes
    (declare (salience 10))
    (goal init-turn-2)
    ?n <- (node (id ?nid) (hexes $? ?hid $?) (can-build 0))
    (not
      (or
        (settlement (node ?nid))
        (city (node ?nid))
      )
    )
    ;(hex (id ?hid) (resource ~desert&~sea))
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

(defrule count-roads
    (goal init-turn-2)
    (road (player ?pid))
    =>
    (assert (add-to-road-sum ?pid))
)

(defrule count-road-sums
    (goal init-turn-2)
    ?c <- (add-to-road-sum ?pid)
    ?f <- (road-count (player ?pid) (count ?cnt))
    =>
    (retract ?c)
    (modify ?f (count (+ ?cnt 1)))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CALCULATE THE NEXT NODE TO BUILD A SETTLEMENT ON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defrule start-find-settlement-target
    (goal init-turn-2)
    (node (distance ~-1))
    =>
    (assert (cur-distance 1))
)

(defrule find-nodes-of-this-distance
    (goal init-turn-2)
    (cur-distance ?dist)
    (node (id ?old-id) (distance =(- ?dist 1)))
    (edge (id ?eid) (nodes ?old-id ?this-id))
    ?n <- (node (id ?this-id) (distance -1))
    =>
    (modify ?n (distance ?dist))
)

(defrule find-further-nodes
    (declare (salience -10))
    (goal init-turn-2)
    (node (distance -1))
    ?d <- (cur-distance ?dist)
    =>
    (retract ?d)
    (assert (cur-distance (+ ?dist 1)))
)

(defrule calculate-node-score
    (declare (salience -10))
    (goal init-turn-2)
    (my-id ?pid)
    (cur-distance ?)
    (node (id ?nid) (can-build 1) (hexes ?hid1 ?hid2 ?hid3) (distance ?dist))
    (hex (id ?hid1) (resource ?res1) (port ?port1) (prob ?prob1))
    (hex (id ?hid2) (resource ?res2) (port ?port2) (prob ?prob2))
    (hex (id ?hid3) (resource ?res3) (port ?port3) (prob ?prob3))
    (not (settlement (player ~?pid) (node ?nid)))
    (not (city (player ~?pid) (node ?nid)))
    =>
    (assert (calculated-node (id ?nid) (score (- (+ ?prob1 ?prob2 ?prob3) (* ?dist 2)))))
)

(defrule calculate-best-placement
    (declare (salience -20))
    (goal init-turn-2)
    (cur-distance ?)
    (calculated-node (id ?nid) (score ?score)) 
    (not (calculated-node (id ?nid2) (score ?score2&:(> ?score2 ?score))))
    =>
    (assert (settlement-target ?nid))
)

(defrule discover-initial-setup
  (declare (salience -100))
  ?g <- (goal init-turn-2)
  (game-phase initial-setup)
  =>
  (retract ?g)
  (printout t "Switching GOAL to initial-setup" crlf)
  (assert (goal initial-setup))
)

(defrule move-to-turn
  (declare (salience -100))
  ?g <- (goal init-turn-2)
  =>
  (retract ?g)
  (printout t "Switching GOAL to decide-action" crlf)
  (assert (goal decide-action))
)
