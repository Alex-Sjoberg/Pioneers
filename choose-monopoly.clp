;DISCARD
(defrule choose-monopoly
  (goal choose-monopoly)
  (resource-cards (kind ?res) (amnt ?amnt))
  (not (resource-cards (amnt ?oamnt&:(< ?oamnt ?amnt))))
  =>
  (assert (action "Choose Monopoly" ?res))
)
