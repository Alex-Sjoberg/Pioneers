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

(defrule calculate-node-score
    (my-id ?pid)
    (node (id ?nid) (can-build 1) (hexes ?hid1 ?hid2 ?hid3))
    (hex (id ?hid1) (resource ?res) (port ?port1) (prob ?prob1))
    (hex (id ?hid2) (resource ?res) (port ?port2) (prob ?prob2))
    (hex (id ?hid3) (resource ?res) (port ?port3) (prob ?prob3))
    (not (settlement (player ~?pid) (node ?nid)))
    =>
    (assert (calculated-node (id ?nid) (score (+ ?prob1 ?prob2 ?prob3))))
)

(defrule assert-node-distances
    (declare (salience 10))
    (node (id ?nid))
    =>
    (assert (node-distance (id ?nid) (distance -1)))
)

(defrule my-nodes-are-zero "any node that has my settlement or city on it, or has my road going to it is distance 0"
    (declare (salience 10))
    (my-id ?pid)
    ?d <- (node-distance (id ?nid) (distance -1))
    (or
        (and ;there is an empty node that I have a road going to
            (node (id ?nid) (can-build 1))
            (edge (id ?eid) (nodes ?nid ?))
            (road (player ?pid) (edge ?eid))
        )
        (and ;or I have a settlement or city on that node
            (node (id ?nid))
            (or
                (settlement (player ?pid) (node ?nid))
                (city (player ?pid) (node ?nid))
            )
        )
    )
    =>
    (modify ?d (distance 0))
)
(defrule nodes-by-my-nodes-are-one "any node that is touching a node with distance 0 is length 1"
    (my-id ?pid)
    (node (id ?nid) (can-build 1))
    ?d <- (node-distance (id ?nid) (distance -1))
    ?o <- (node-distance (id ?nid2) (distance 0))
    (edge (id ?eid) (nodes ?nid ?nid2))
    (not (road (player ~?pid) (edge ?eid)))
    =>
    (modify ?d (distance 1))
)
(defrule nodes-by-those-nodes-are-two "any node that is touching a node with distance 1 is length 2"
    (declare (salience -10))
    (my-id ?pid)
    (node (id ?nid) (can-build 1))
    ?d <- (node-distance (id ?nid) (distance -1))
    ?o <- (node-distance (id ?nid2) (distance 1))
    (edge (id ?eid) (nodes ?nid ?nid2))
    (not (road (player ~?pid) (edge ?eid)))
    =>
    (modify ?d (distance 2))
)
(defrule nodes-by-those-nodes-are-three "any node that is touching a node with distance 2 is length 3"
    (declare (salience -20))
    (my-id ?pid)
    (node (id ?nid) (can-build 1))
    ?d <- (node-distance (id ?nid) (distance -1))
    ?o <- (node-distance (id ?nid2) (distance 2))
    (edge (id ?eid) (nodes ?nid ?nid2))
    (not (road (player ~?pid) (edge ?eid)))
    =>
    (modify ?d (distance 3))
)
(defrule clean-neg1-distance-nodes
    (declare (salience -30))
    ?d <- (node-distance (distance -1))
    =>
    (retract ?d)
)

(defrule discover-initial-setup
  ?g <- (goal init-turn-2)
  (game-phase initial-setup)
  =>
  (retract ?g)
  (printout t "Switching GOAL to initial-setup" crlf)
  (assert (goal initial-setup))
)

(defrule move-to-turn
  (declare (salience -10))
  ?g <- (goal init-turn-2)
  =>
  (facts)
  (retract ?g)
  (printout t "Switching GOAL to decide-action" crlf)
  (assert (goal decide-action))
)
