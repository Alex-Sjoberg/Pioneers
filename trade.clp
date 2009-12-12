; Trade for development card
(defrule trade-for-grain
  ;(goal buy-development-card)
  (goal trade)
  (resource-cards (kind grain) (amnt ?gamnt&:(< ?gamnt 2)))
  =>
  (printout t "ACTION: Trade for " (- 2 ?gamnt) " grain." crlf)
  (exit)
)

(defrule trade-for-ore
  ;(goal buy-development-card)
  (goal trade)
  (resource-cards (kind ore) (amnt ?oamnt&:(< ?oamnt 3)))
  =>
  (printout t "ACTION: Trade for " (- 3 ?oamnt) " ore." crlf)
  (exit)
)
