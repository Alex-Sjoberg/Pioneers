;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     INIT-TURN-2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; calculate which nodes can be built upon and which cannot
(defrule can-build-on-nodes
    (goal init-turn-2)
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
  (retract ?g)
  (printout t "Switching GOAL to decide-action" crlf)
  (assert (goal decide-action))
)
