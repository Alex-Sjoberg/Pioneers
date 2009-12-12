(defrule discover-place-robber
  ?g <- (goal decide-action)
  (game-phase place-robber)
  =>
  (retract ?g)
  (assert (goal place-robber))
)

(defrule discover-discard
  ?g <- (goal decide-action)
  (game-phase discard)
  =>
  (retract ?g)
  (assert (goal discard))
)

(defrule discover-dice-roll
  ?g <- (goal decide-action)
  (game-phase do-turn)
  (not (dice-already-rolled))
  =>
  (retract ?g)
  (assert (goal before-dice))
)

(defrule discover-initial-setup
  ?g <- (goal decide-action)
  (game-phase initial-setup)
  =>
  (retract ?g)
  (assert (goal initial-setup))
)
