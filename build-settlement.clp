;BUILD-SETTLEMENT section

(defrule domestic-trade-for-settlement
    (game-phase consider-quote)
    ?g <- (goal build-settlement)
    (can-build-settlement)
    =>
    (retract ?g)
    (assert (goal consider-quote)
            (trade-goal build-settlement))
)

(defrule maritime-trade-for-settlement
    (goal build-settlement)
    (willing-to-trade)
    (my-maritime-trade ?price)
    (resource-cards (kind ?want&lumber|brick|wool|grain) (amnt 0))
    (bank-cards (kind ?want) (amnt ~0))
    (or
        (resource-cards (kind ?trade&~lumber&~brick&~wool&~grain) (amnt ?amnt&:(>= ?amnt ?price)))
        (resource-cards (kind ?trade&~?want&lumber|brick|wool|grain) (amnt ?amnt&:(>= ?amnt (+ ?price 1))))
    )
    =>
    (assert (action "Do Maritime" ?price ?trade ?want))
)

(defrule build-settlement
    (not (game-phase consider-quote))
    (goal build-settlement)
    (have-resources-for-settlement)
    (can-build-settlement)
    (settlement-target ?node)
    =>
    (assert (action "Build Settlement" ?node))
)

(defrule build-road-if-none
  (declare (salience -10))
  ?g <- (goal build-settlement)
  (my-id ?pid)
  (player (id ?pid) (num-roads ~0))
  (not
    (and
      (my-id ?pid)
      (node (id ?nid) (can-build 1))
      (road (edge ?eid) (player ?pid))
      (edge (id ?eid) (nodes $? ?nid $?))
    )
  )
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-road" crlf)
  (assert (goal build-road)
          (willing-to-trade))
)
