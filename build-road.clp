;BUILD-ROAD section
;build roads in the direction of the settlement goal

;(defrule aoeu
;  (declare (salience 1))
;  (game-phase consider-quote)
;  (goal build-road)
;  =>
;  (facts)
;  (matches domestic-trade-for-road)
;)


(defrule domestic-trade-for-road
    (game-phase consider-quote)
    ?g <- (goal build-road)
    (next-road-placement ?)
    =>
    (retract ?g)
    (printout t "Switching GOAL to consider-quote" crlf)
    (assert (goal consider-quote)
            (trade-goal build-road))
)

(defrule build-road
    (not (game-phase consider-quote))
    (goal build-road)
    (have-resources-for-road)
    (next-road-placement ?eid)
    =>
    (assert (action "Build Road" ?eid))
)

(defrule maritime-trade-for-road
    (goal build-road)
    (my-maritime-trade ?price)
    (resource-cards (kind ?want&lumber|brick) (amnt 0))
    (or
        (resource-cards (kind ?trade&~lumber&~brick) (amnt ?amnt&:(>= ?amnt ?price)))
        (resource-cards (kind ?trade&~?want&lumber|brick) (amnt ?amnt&:(>= ?amnt (+ ?price 1))))
    )
    =>
    (assert (action "Do Maritime" ?price ?trade ?want))
)
