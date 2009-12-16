(defrule road-building
    (goal road-building)
    (next-road-placement ?eid)
    =>
    (assert (action "Build Road" ?eid))
)
