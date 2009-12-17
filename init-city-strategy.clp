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
  (player (id ?pid) (num-cities ~4))
  (settlement (player ?pid))
  (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
  (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-city" crlf)
  (assert (goal build-city))
)

; in init-settlement-strategy.clp
;(defrule build-settlement-if-have-resources

(defrule try-build-settlement
  (declare (salience 10))
  ?g <- (goal init-city-strategy)
  (my-id ?pid)
  (or
    (player (id ?pid) (num-cities 0) (num-settlements 2))
    (player (id ?pid) (num-cities ~0) (num-settlements 0))
  )
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-settlement" crlf)
  (assert (goal build-settlement))
)

;Medium priority rules
(defrule build-city-if-have-none
  ?g <- (goal init-city-strategy)
  (my-id ?pid)
  (player (id ?pid) (num-cities 0))
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-city" crlf)
  (assert (goal build-city))
)

(defrule play-soldier-on-city-strategy
  (declare (salience 10))
  (not (game-phase consider-quote))
  (goal init-city-strategy)
  (my-id ?pid)
  (devel-card (kind soldier) (amnt ?nvic) (can-play 1))
  (or
    (and
      (player (id ?pid) (score ?score) (has-largest-army 0))
      (test (>= (+ ?score ?nvic) 6))
    )
    (player (id ~?pid) (has-largest-army 1))
  )
  =>
  (assert (action "Play Soldier"))

)

(defrule buy-development-card-over-city
  ?g <- (goal init-city-strategy)
  (my-id ?pid)
  (player (id ?pid) (score ?score&:(>= ?score 4)) (num-soldiers ?nsol))
  (player (id ~?pid) (num-soldiers ?onsol&:(>= ?onsol ?nsol)))
  =>
  (retract ?g)
  (printout t "Switching GOAL to buy-development-card" crlf)
  (assert (goal buy-development-card))
)

;Low priority catch-all rules
(defrule else-buy-city
  (declare (salience -10))
  ?g <- (goal init-city-strategy)
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-city" crlf)
  (assert (goal build-city))
)
