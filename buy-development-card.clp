;BUY-DEVELOPMENT-CARD section

(defrule buy-development-card
    (goal buy-development-card)
    (num-develop-in-deck ?num&:(> ?num 0))
    (resource-cards (kind wool) (amnt ?wamnt&:(>= ?wamnt 1)))
    (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 1)))
    (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 1)))
    =>
    (printout t crlf "ACTION: Buy Development Card" crlf)
    (exit)
)



(defrule maritime-trade-for-development-card
  (goal buy-development-card)
  (willing-to-trade)
  (my-maritime-trade ?price)
  (resource-cards (kind ?want&wool|grain|ore) (amnt 0))
  (or
      (resource-cards (kind ?trade&~wool&~grain&~ore) (amnt ?amnt&:(>= ?amnt ?price)))
      (resource-cards (kind ?trade&~?want&wool|grain|ore) (amnt ?amnt&:(>= ?amnt (+ ?price 1))))
  )
  =>
  (printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
  (exit)
)
