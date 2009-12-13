;PLACE-ROBBER section

;might not put on the highest dot count if it cuts off the only source of something

(defrule find-robber-placements
    (declare (salience 10))
    (goal place-robber)
    (my-id ?pid)
    (or
      (settlement (player ~?pid) (node ?nid))
      (city (player ~?pid) (node ?nid))
    )
    (node (id ?nid) (hexes $? ?hid $?))
    (not (robber (hex ?hid)))
    (hex (id ?hid) (prob ?prob))
    (not
      (and
        (node (id ?tnid) (hexes $? ?hid $?))
        (or
          (settlement (player ?pid) (node ?tnid))
          (city (player ?pid) (node ?tnid))
        )
      )
    )
    =>
    (assert (potential-robber-placement ?hid))
)

(defrule move-robber
    (goal place-robber)
    (potential-robber-placement ?hid)
    (hex (id ?hid) (prob ?prob))
    (not
      (and
        (potential-robber-placement ?hid2)
        (hex (id ?hid2) (prob ?prob2&:(> ?prob2 ?prob)))
      )
    )
    =>
    (printout t crlf "ACTION: Place Robber " ?hid crlf)
    (exit)
)
