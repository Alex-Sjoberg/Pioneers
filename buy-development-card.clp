;BUY-DEVELOPMENT-CARD section


(defrule domestic-trade-for-development-card
    (game-phase consider-quote)
    ?g <- (goal buy-development-card)
    (can-buy-development-card)
    =>
    (retract ?g)
    (assert (goal consider-quote)
            (trade-goal buy-development-card))
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
  (assert (action "Do Maritime" ?price ?trade ?want))
)


(defrule buy-development-card
    (not (game-phase consider-quote))
    (goal buy-development-card)
    (can-buy-development-card)
    (have-resources-for-development-card)
    =>
    (assert (action "Buy Development Card"))
)
