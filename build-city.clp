;BUILD-CITY section

(defrule maritime-trade-for-city
    (goal build-city)
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
    (printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
    (exit)
)


(defrule trade-for-city
  (goal build-city)
  (more stuff
  =>

  (printout t crlf "ACTION: Trade Domestic brick 0 lumber 0 grain 2 ore 1 sheep 0 brick 0 lumber 0 grain 2 ore 1 sheep 0" crlf)
)

(defrule determine-best-city-location "needs to be improved"
  (goal build-city)
  (my-num ?pid)
  (settlement (player ?pid) (node ?node))
  =>
  (assert (best-city-location ?node))
)

(defrule build-city
    (goal build-city)
    (best-city-location ?node)
    (my-num ?pid)
    (player (id ?pid) (num-cities ?num&:(< ?num 4)))
    (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
    (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
    =>
    (printout t crlf "ACTION: Build City " ?node crlf)
    (exit)
)
