;BUILD-ROAD section
;build roads in the direction of the settlement goal

(defrule determine-if-can-build-road
    (goal build-road)
    (or
        (free-roads ?)
        (and
            (resource-cards (kind lumber) (amnt ?lamnt&:(>= ?lamnt 1)))
            (resource-cards (kind brick) (amnt ?bamnt&:(>= ?bamnt 1)))
        )
    )
    =>
    (assert (can-build-road))
)

(defrule build-road
    (goal build-road)
    (can-build-road)
    (next-road-placement ?eid)
    =>
    (assert (action "Build Road" ?eid))
    ;(printout t crlf "ACTION: Build Road " ?eid crlf)
    ;(exit)
)

(defrule trade-for-road
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
