;BUILD-ROAD section

(defrule build-road
    (goal build-road)
    (my-num ?pid)
    (road-count (player ?pid) (count ?cnt&:(< ?cnt 15)))
    (resource-cards (kind lumber) (amnt ?lamnt&:(>= ?lamnt 1)))
    (resource-cards (kind brick) (amnt ?bamnt&:(>= ?bamnt 1)))
    (or
      (settlement (player ?pid) (node ?nid))
      (city (player ?pid) (node ?nid))
    )
    (or
      (and
        (edge (id ?eid1) (nodes ?nid ?cnode))
        (road (player ?pid) (edge ?eid1))
        (edge (id ?eidtobuild) (nodes ?cnode ?cnode2&~?nid))
        (node (id ?cnode2) (can-build 1))
      )
      (edge (id ?eidtobuild) (nodes ?nid ?cnode2))
    )

    (not (road (edge ?eidtobuild)))

    (node (id ?cnode2) (hexes ?h1 ?h2 ?h3))
    (hex (id ?h1) (resource ?res1) (number ?p1))
    (hex (id ?h2) (resource ?res2) (number ?p2))
    (hex (id ?h3) (resource ?res3) (number ?p3))
    =>
    (printout t crlf "DEBUG: " ?res1 " " ?p1 " | " ?res2 " " ?p2 " | "  " " ?res3 " " ?p3 crlf)
    (printout t crlf "ACTION: Build Road " ?eidtobuild crlf)
    (exit)
)





(defrule trade-4-for-road
    (code-phase process)
    (goal build-road)
    (my-maritime-trade ?price)
    (resource-cards (kind ?want&lumber|brick) (amnt 0))
    (or
        (resource-cards (kind ?trade&~lumber&~brick) (amnt ?amnt&:(>= ?amnt ?price)))
        (resource-cards (kind ?trade&~?want&lumber|brick) (amnt ?amnt&:(>= ?amnt (+ ?price 1))))
    )
    =>
    (printout t crlf "ACTION: Do Maritime " ?price " " ?trade " " ?want crlf)
    (exit)
)
