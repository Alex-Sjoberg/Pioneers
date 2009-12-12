;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                         TURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;if there is not much brick or lumber and there is a lot of wheat or ore, don't consider the settlement strategy even if the best spot dot-wise is for that strategy
;if you are the last person, order your settlements so that you get the resources you want
;if someone offers you one for two if you need it, 

; INITIAL-SETUP
(defrule find-settlement-possibilities
    ; At least one settlement to place
    (goal initial-setup)
    (settlements-to-place ?num&:(> ?num 0))

    ; Find a node that doesn't have a settlement...
    (node (id ?nid) (hexes ?h1 ?h2 ?h3))
    (not (settlement (node ?nid)))
    (hex (id ?h1) (prob ?p1))
    (hex (id ?h2) (prob ?p2))
    (hex (id ?h3) (prob ?p3))

    ; ...and that isn't next to a node that has a settlement
    (not
      (and
        (settlement (node ?cnode))
        (edge (nodes ?nid ?cnode))
      )
    )
    =>
    (assert (possible-settlement (node ?nid) (prob-sum (+ ?p1 ?p2 ?p3))))
)

(defrule place-starting-settlement
    (declare (salience -10))

    (goal initial-setup)
    (settlements-to-place ?num&:(> ?num 0))
    (possible-settlement (node ?nid) (prob-sum ?psum))

    ; ...and for which there is no other possible settlement spot
    ; which has a higher probability
    (not (possible-settlement (prob-sum ?psum2&:(> ?psum2 ?psum))))

    =>

    (printout t crlf "ACTION: Build Settlement " ?nid crlf)
    (exit)
)

(defrule place-starting-road
    (goal initial-setup)
    (my-num ?pnum)

    (roads-to-place ?num&:(> ?num 0))

    (settlement (player ?pnum) (node ?nid))
    (not
      (and
        (road (edge ?eid))
        (edge (id ?eid) (nodes $? ?nid $?))
      )
    )

    (edge (id ?eid) (nodes ?nid ?cnode))
    (not (road (edge ?eid)))
    (node (id ?cnode) (hexes $? ?chex $?))
    (hex (id ?chex) (resource ?res&~sea&~desert))

    =>

    (printout t crlf "ACTION: Build Road " ?eid crlf)
    (exit)
)

(defrule end-initial-setup
    (goal initial-setup)
    (settlements-to-place 0)
    (roads-to-place 0)
    =>
    (printout t crlf "ACTION: End Turn" crlf)
)
