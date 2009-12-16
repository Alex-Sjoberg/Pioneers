;INIT-SETTLEMENT-STRATEGY section
;determine whether to build a settlement or settlement largest army

;if you have everything needed for a settlement, then build it
;if there is no place to put a settlement, build a road

(defrule build-settlement-if-have-resources-and-can-build
  (declare (salience 10))
  (or
    ?g <- (goal init-settlement-strategy)
    ?g <- (goal init-city-strategy)
  )
;  (my-id ?pid)
;  (road (player ?pid) (edge ?eid))
;  (edge (id ?eid) (nodes $? ?nid $?))
;  (node (id ?nid) (can-build 1))
  (resource-cards (kind lumber) (amnt ?lamnt&:(>= ?lamnt 1)))
  (resource-cards (kind brick) (amnt ?bamnt&:(>= ?bamnt 1)))
  (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 1)))
  (resource-cards (kind wool) (amnt ?wamnt&:(>= ?wamnt 1)))
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-settlement" crlf)
  (assert (goal build-settlement))
)

; in init-city-strategy.clp
;(defrule build-city-if-have-resources

(defrule build-city-if-have-used-all-settlement
  (declare (salience 10))
  ?g <- (goal init-settlement-strategy)
  (my-id ?pid)
  (player (id ?pid) (num-settlements 5))
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-city" crlf)
  (assert (goal build-city))
)

(defrule buy-devel-if-lots-of-resources
  ?g <- (goal init-settlement-strategy)
;  (or
;    (player (id ?pid) (num-resource-cards ?num&:(> ?num 7)))
;    (and
      (resource-cards (kind wool) (amnt ?wamnt&:(>= ?wamnt 2)))
      (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 1)))
      (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
;    )
;  )
  =>
  (retract ?g)
  (printout t "Switching GOAL to buy-development-card" crlf)
  (assert (goal buy-development-card))
)


(defrule build-city-if-none-and-lots-of-resources
  ?g <- (goal init-settlement-strategy)
  (my-id ?pid)
  (settlement (player ?pid))
  (or
    (and
      (resource-cards (kind grain) (amnt ?gamnt&:(<= (- 2 ?gamnt) 1)))
      (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
    )
    (and
      (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
      (resource-cards (kind ore) (amnt ?oamnt&:(<= (- 3 ?oamnt) 1)))
    )
  )
  (resource-cards (kind brick|wool|lumber) (amnt ~0))
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-city" crlf)
  (assert (goal build-city)
          (willing-to-trade))
)

(defrule else-build-settlement
  (declare (salience -10))
  ?g <- (goal init-settlement-strategy)
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-settlement" crlf)
  (assert (goal build-settlement)
          (willing-to-trade))
)
