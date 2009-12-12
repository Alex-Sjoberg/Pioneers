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
  ?g <- (goal init-city-strategy)
  (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
  (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
  =>
  (retract ?g)
  (assert (goal build-city))
)

(defrule try-build-settlement
  (declare (salience 10))
  ?g <- (goal init-city-strategy)
  (settlement-count ?n&:(<= ?n 2))
  =>
  (retract ?g)
  (assert (goal build-settlement))
)

;Medium priority rules
(defrule build-city-if-have-none
  ?g <- (goal init-city-strategy)
  (my-num ?pid)
  (player (id ?pid) (num-cities ?num&:(= ?num 0)))
  =>
  (retract ?g)
  (assert (goal build-city))
)

(defrule buy-development-card-over-city
  ?g <- (goal init-city-strategy)
  (my-num ?pid)
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
  (assert (goal buy-development-card))
)

;Low priority catch-all rules
(defrule else-buy-development-card
  (declare (salience -10))
  ?g <- (goal init-city-strategy)
  =>
  (retract ?g)
  (assert (goal buy-development-card))
)
