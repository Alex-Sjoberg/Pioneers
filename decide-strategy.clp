; If our current probability of grain and ore is greater than our probability of lumber and 
;brick, do (strategy cities), otherwise do (strategy settlements)

;NOTE seems to happen every turn??
; the (goal init-X-strategy) facts are what is used, not the (strategy X) facts

(defrule determine-strategy "If we must take our turn, decide whether to go for cities or settlements."
  (goal decide-strategy)
  (total-resource-prob (kind lumber) (prob ?lumber))
  (total-resource-prob (kind brick) (prob ?brick))
  (total-resource-prob (kind wool) (prob ?wool))
  (total-resource-prob (kind grain) (prob ?grain))
  (total-resource-prob (kind ore) (prob ?ore))
  =>
  (assert (city-total (+ ?grain ?ore))
          (settlement-total (+ ?lumber ?brick)))
)

(defrule discover-city-strategy
  ?g <- (goal decide-strategy)
  (city-total ?city)
  (settlement-total ?settlement&:(> ?city ?settlement))
  =>
  (retract ?g)
  (printout t "Switching GOAL to init-city-strategy" crlf)
  (assert (goal init-city-strategy)
          (strategy cities))
)

(defrule discover-settlement-strategy
  ?g <- (goal decide-strategy)
  (city-total ?city)
  (settlement-total ?settlement&:(>= ?settlement ?city))
  =>
  (retract ?g)
  (printout t "Switching GOAL to init-settlement-strategy" crlf)
  (assert (goal init-settlement-strategy)
          (strategy settlements))
)
