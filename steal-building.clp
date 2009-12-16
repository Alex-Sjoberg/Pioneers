;DISCARD
(defrule count-points
  (goal steal-building)
  (robber (hex ?hid))
  (or
    (node (id ?nid) (hexes ?hid ? ?))
    (node (id ?nid) (hexes ? ?hid ?))
    (node (id ?nid) (hexes ? ? ?hid))
  )
  (my-id ?pid)
  (or
    (city (node ?nid) (player ?player&~?pid))
    (settlement (node ?nid) (player ?player&~?pid))
  )
  (player (id ?player) (num-resource-cards ~0) (score ?score))
  =>
  (assert (steal-player ?player ?score))
)

(defrule steal-from-person-with-most-points
  (declare (salience -10))
  (goal steal-building)
  (steal-player ?player ?score)
  (not (steal-player ?oplayer ?oscore&:(> ?oscore ?score)))
  =>
  (assert (action "Steal From" ?player))
)
