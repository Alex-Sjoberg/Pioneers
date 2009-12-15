;INIT-CITY-STRATEGY section
;if you have everything needed for a city, then build it
;if you only have 2 settlements, try to build a settlement
;if you don't have any cities, try to build a city
;if you don't have any soldiers and you have at least one city buy a development card
;if someone has more soldiers than you and you have at least 5 points, buy a development card
;try to build a city
;buy a development card





;High priority rules
(defrule build-city-if-have-resources
  (declare (salience 10))
  (or
    ?g <- (goal init-city-strategy)
    ?g <- (goal init-settlement-strategy)
  )
  (my-id ?pid)
  (settlement (player ?pid))
  (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
  (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
  =>
  (retract ?g)
  (printout t "Switched GOAL to build-city" crlf)
  (assert (goal build-city))
)

; in init-settlement-strategy.clp
;(defrule build-settlement-if-have-resources

(defrule try-build-settlement
  (declare (salience 10))
  ?g <- (goal init-city-strategy)
  (my-id ?pid)
  (player (id ?pid) (num-settlements ?n&:(<= ?n 3)))
  =>
  (retract ?g)
  (printout t "Switched GOAL to build-settlement" crlf)
  (assert (goal build-settlement))
)

;Medium priority rules
(defrule build-city-if-have-none
  ?g <- (goal init-city-strategy)
  (my-id ?pid)
  (player (id ?pid) (num-cities ?num&:(= ?num 0)))
  =>
  (retract ?g)
  (printout t "Switched GOAL to build-city" crlf)
  (assert (goal build-city))
)

(defrule buy-development-card-over-city
  ?g <- (goal init-city-strategy)
  (my-id ?pid)
  (or
    (player (id ?pid) (num-cities ?num&:(>= ?num 1)))
    (and
      (num-victory-points ?pts&:(>= ?pts 5))
      (my-soldiers ?mysol)
      (largest-opposing-army ?othersol&:(>= ?othersol ?mysol))
    )
  )
  =>
  (retract ?g)
  (printout t "Switched GOAL to buy-development-card" crlf)
  (assert (goal buy-development-card))
)

;Low priority catch-all rules
(defrule else-buy-development-card
  (declare (salience -10))
  ?g <- (goal init-city-strategy)
  =>
  (retract ?g)
  (printout t "Switched GOAL to buy-development-card-else" crlf)
  (assert (goal buy-development-card))
)
