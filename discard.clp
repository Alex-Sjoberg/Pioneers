;DISCARD
(defrule discard-cards
  (declare (salience 10))
  (goal discard)
  =>
  (assert (discard-str "Discard"))
  ;(printout t crlf "ACTION: Discard")
)

(defrule find-least-valuable-card
  (goal discard)
  ?s <- (discard-str $?str)
  ?n <- (num-to-discard ?num&:(> ?num 0))
  ?c <- (resource-cards (kind ?kind) (amnt ?amnt&:(> ?amnt 0)))
  (not (resource-cards (amnt ?namnt&:(> ?namnt ?amnt))))
  =>
  (retract ?n ?s)
  (assert (num-to-discard (- ?num 1)))
  (modify ?c (amnt (- ?amnt 1)))
  (assert (discard-str $?str ?kind))
  ;(printout t " " ?kind)
)

(defrule done-discarding
  (declare (salience -10))
  (goal discard)
  (discard-str $?str)
  =>
  (assert (action $?str))
  ;(printout t crlf)
  ;(exit)
)
