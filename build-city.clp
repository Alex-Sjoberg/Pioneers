;BUILD-CITY section


;; If our goal is to build a city and we can build a city, change our goal to consider-quote and our trade goal to build city
(defrule domestic-trade-for-city
    (game-phase consider-quote)
    ?g <- (goal build-city)
    (can-build-city ?)
    =>
    (retract ?g)
    (printout t "Switching GOAL to consider-quote" crlf)
    (assert (goal consider-quote)
            (trade-goal build-city))
)


(defrule maritime-trade-for-city
    (goal build-city)
    (willing-to-trade)
    (my-maritime-trade ?price)
    (or
        (resource-cards (kind ?want&grain) (amnt ?amnt&:(< ?amnt 2)))
        (resource-cards (kind ?want&ore) (amnt ?amnt&:(< ?amnt 3)))
    )
    (or
        (resource-cards (kind ?trade&~grain&~ore) (amnt ?amnt2&:(>= ?amnt2 ?price)))
        (resource-cards (kind ?trade&grain) (amnt ?amnt2&:(> ?amnt2 (+ ?price 2))))
        (resource-cards (kind ?trade&ore) (amnt ?amnt2&:(> ?amnt2 (+ ?price 3))))
    )
    =>
    (assert (action "Do Maritime" ?price ?trade ?want))
)


(defrule determine-best-city-location "needs to be improved"
  (goal build-city)
  (my-id ?pid)
  (can-build-city ?nid)
  (node (id ?nid) (hexes ?h1 ?h2 ?h3))
  (hex (id ?h1) (prob ?prob1))
  (hex (id ?h2) (prob ?prob2))
  (hex (id ?h3) (prob ?prob3))
  (not (and
      (settlement (player ?pid) (node ?nid2))
      (node (id ?nid2) (hexes ?h4 ?h5 ?h6))
      (hex (id ?h4) (prob ?prob4))
      (hex (id ?h5) (prob ?prob5))
      (hex (id ?h6) (prob ?prob6))
      (test (> (+ ?prob4 ?prob5 ?prob6) (+ ?prob1 ?prob2 ?prob3)))
  ))
  =>
  (assert (best-city-location ?nid))
)

(defrule build-city-if-no-settlement
  ?g <- (goal build-city)
  (my-id ?pid)
  (not (settlement (player ?pid)))
  =>
  (retract ?g)
  (assert (goal build-settlemnt)
          (willing-to-trade))
)

(defrule build-city
    (not (game-phase consider-quote))
    (goal build-city)
    (best-city-location ?node)
    (have-resources-for-city)
    =>
    (assert (action "Build City" ?node))
)

;What is this rule for...?
(defrule city-else-build-settlement
  (declare (salience -10))
  ?g <- (goal build-city)
  (my-id ?pid)
  (player (id ?pid) (num-settlements ~5))
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-settlement" crlf)
  (assert (goal build-settlement)
          (willing-to-trade))
)
