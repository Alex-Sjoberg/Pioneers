;BUY-DEVELOPMENT-CARD section

; If the phase is onsider-quote and its our goal to buy a development card, and we can buy
;a development card, then switch our goal to consider-quote and make our trade-goal to buy-development card
(defrule domestic-trade-for-development-card
    (game-phase consider-quote)
    ?g <- (goal buy-development-card)
    (can-buy-development-card)
    =>
    (retract ?g)
    (printout t "Switching GOAL to consider-quote" crlf)
    (assert (goal consider-quote)
            (trade-goal buy-development-card))
)


(defrule maritime-trade-for-development-card
  (goal buy-development-card)
  (willing-to-trade)
  (my-maritime-trade ?price) ;how much we need to trade of one resource to get one of another - 4 or 3
  (resource-cards (kind ?want&wool|grain|ore) (amnt 0)) ;we have 0 of either wood, grain, or ores
  (or ;we have enough resources to trade for what we want. Doesn't trade away other things we want
      (resource-cards (kind ?trade&~wool&~grain&~ore) (amnt ?amnt&:(>= ?amnt ?price)))
      (resource-cards (kind ?trade&~?want&wool|grain|ore) (amnt ?amnt&:(>= ?amnt (+ ?price 1))))
  )
  =>
  (assert (action "Do Maritime" ?price ?trade ?want))
)

;If we want to buy a development card, we can, and we have to resources to do it, do it
(defrule buy-development-card
    (not (game-phase consider-quote))
    (goal buy-development-card)
    (can-buy-development-card)
    (have-resources-for-development-card)
    =>
    (assert (action "Buy Development Card"))
)
