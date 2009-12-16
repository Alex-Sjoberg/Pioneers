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

(defrule start-road-discovery
    (goal build-road)
    (can-build-road)
    (settlement-target ?nid)
    =>
    (assert (looking-for-edges)
            (node-waypoint ?nid))
)

(defrule look-for-edges
    (goal build-road)
    (can-build-road)
    (looking-for-edges)
    (node-waypoint ?nid)
    (edge (id ?eid) (nodes ?nid ?))
    =>
    (assert (edge-waypoint ?eid))
)
(defrule look-for-nodes
    (goal build-road)
    (can-build-road)
    (looking-for-nodes)
    (edge-waypoint ?eid)
    (edge (id ?eid) (nodes ?nid ?))
    (node (id ?nid))
    =>
    (assert (node-waypoint ?nid))
)

(defrule build-road
    (goal build-road)
    (can-build-road)
    (looking-for-edges)
    (my-id ?pid)
    (edge-waypoint ?eid)
    (edge (id ?eid) (nodes ?nid ?))
    (or
        (settlement (player ?pid) (node ?nid))
        (city (player ?pid) (node ?nid))
        (and
            (edge (id ?eid2) (nodes ?nid ?))
            (road (player ?pid) (edge ?eid2))
        )
    )
    (not (road (edge ?eid)))
    =>
    (facts)
    (assert (action "Build Road" ?eid))
)

(defrule transition-to-look-for-nodes
    (declare (salience -10))
    (goal build-road)
    (can-build-road)
    ?l <- (looking-for-edges)
    =>
    (retract ?l)
    (assert (looking-for-nodes))
)
(defrule transition-to-look-for-edges
    (declare (salience -10))
    (goal build-road)
    (can-build-road)
    ?l <- (looking-for-nodes)
    =>
    (retract ?l)
    (assert (looking-for-edges))
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
