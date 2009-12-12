;DISCARD
(defrule discard-cards
  (declare (salience 10))
  (goal discard)
  =>
  (printout t crlf "ACTION: Discard")
)

(defrule find-least-valuable-card
  (goal discard)
  ?n <- (num-to-discard ?num&:(> ?num 0))
  ?c <- (resource-cards (kind ?kind) (amnt ?amnt&:(> ?amnt 0)))
  (not (resource-cards (amnt ?namnt&:(> ?namnt ?amnt))))
  =>
  (retract ?n)
  (assert (num-to-discard (- ?num 1)))
  (modify ?c (amnt (- ?amnt 1)))
  (printout t " " ?kind)
)

(defrule done-discarding
  (declare (salience -10))
  (phase discard)
  =>
  (printout t crlf)
  (exit)
)
