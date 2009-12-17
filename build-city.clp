;BUILD-CITY section

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
    ;(printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
    ;(exit)
)


;(defrule trade-for-city
;  (goal build-city)
;  (more stuff
;  =>
;
;  (printout t crlf "ACTION: Trade Domestic brick 0 lumber 0 grain 2 ore 1 sheep 0 brick 0 lumber 0 grain 2 ore 1 sheep 0" crlf)
;)

(defrule determine-best-city-location "needs to be improved"
  (goal build-city)
  (my-id ?pid)
  (settlement (player ?pid) (node ?nid))
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
    (goal build-city)
    (best-city-location ?node)
    (my-id ?pid)
    (player (id ?pid) (num-cities ?num&:(< ?num 4)))
    (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
    (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
    =>
    (assert (action "Build City" ?node))
)

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
