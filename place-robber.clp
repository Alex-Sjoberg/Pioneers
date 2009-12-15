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
    (hex (id ?hid) (prob ?prob) (resource ?res&~sea&~desert))
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
    (or
      (potential-robber-placement ?hid)
      (and
        (not (potential-robber-placement ?))
        (hex (id ?hid) (resource ?res&~sea&~desert))
        (not (robber (hex ?hid)))
        (not
          (and
            (or
              (node (id ?nid) (hexes ?hid ? ?))
              (node (id ?nid) (hexes ? ?hid ?))
              (node (id ?nid) (hexes ? ? ?hid))
            )
            (my-id ?pid)
            (settlement (node ?nid) (player ?pid))
          )
        )
      )
    )
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
