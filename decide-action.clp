(defrule discover-place-robber
  ?g <- (goal decide-action)
  (game-phase place-robber)
  =>
  (retract ?g)
  (printout t "Switching GOAL to place-robber" crlf)
  (assert (goal place-robber))
)

(defrule discover-discard
  ?g <- (goal decide-action)
  (game-phase discard)
  =>
  (retract ?g)
  (printout t "Switching GOAL to discard" crlf)
  (assert (goal discard))
)

(defrule discover-dice-roll
  ?g <- (goal decide-action)
  (game-phase do-turn)
  (not (dice-already-rolled))
  =>
  (retract ?g)
  (printout t "Switching GOAL to before-dice" crlf)
  (assert (goal before-dice))
)

(defrule discover-road-building
  ?g <- (goal decide-action)
  (game-phase road-building)
  =>
  (retract ?g)
  (printout t "Switching GOAL to build-road" crlf)
  (assert (goal build-road))
)

(defrule discover-strategy
  (declare (salience -10))
  ?g <- (goal decide-action)
  =>
  (retract ?g)
  (printout t "Switching GOAL to decide-strategy" crlf)
  (assert (goal decide-strategy))
)
