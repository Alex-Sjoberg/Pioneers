;BUILD-SETTLEMENT section

(defrule aoeu
    (declare (salience 100))
    (goal build-settlement)
    (settlement-target ?t)
    (node (id ?t) (hexes ?h1 ?h2 ?h3))
    (hex (id ?h1) (prob ?prob1) (resource ?res1))
    (hex (id ?h2) (prob ?prob2) (resource ?res2))
    (hex (id ?h3) (prob ?prob3) (resource ?res3))
    =>
    (printout t "target1 " ?t " res1: " ?res1 " prob1: " ?prob1 crlf)
    (printout t "target2 " ?t " res2: " ?res2 " prob2: " ?prob2 crlf)
    (printout t "target3 " ?t " res3: " ?res3 " prob3: " ?prob3 crlf)
)

(defrule print-resource-cards
    (declare (salience 100))
    (goal build-settlement)
    (resource-cards (kind ?kind) (amnt ?amnt))
    =>
    (printout t "card " ?kind ": " ?amnt crlf)
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
    (printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
    (exit)
)

(defrule build-settlement
    (goal build-settlement)
    (my-id ?pid)
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
    (printout t crlf "ACTION: Build Settlement " ?node crlf)
    (exit)
)

(defrule build-road-if-none
  (declare (salience -10))
  ?g <- (goal build-settlement)
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
  (printout t "Switched GOAL to build-road" crlf)
  (assert (goal build-road)
          (willing-to-trade))
)
