;PLACE-ROBBER section

;might not put on the highest dot count if it cuts off the only source of something

;move robber
;determine where to place the robber
;place the robber on a spot that has a 5,6,8, or 9
;place the robber on someone who is competing with you for a board position
;place the robber on someone with a rare resource
;place the robber on someone who has a lot of something you need
;place the robber on a hex with settlements of more than one player
;place the robber on hexes with cites over those with settlements

;total number of enemy dots

(defrule create-hex-totals
    (declare (salience 10))
    (goal place-robber)
    (hex (id ?hid))
    =>
    (assert (hex-total (id ?hid) (val 0)))
)

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

(defrule put-hex-addend-settlement
    (goal place-robber)
    (my-id ?pid)
    (node (id ?nid) (hexes ?h1 ?h2 ?h3))
    (settlement (player ~?pid) (node ?nid))
    =>
    (assert (hex-addend (id ?h1) (nid ?nid) (val 1))
            (hex-addend (id ?h2) (nid ?nid) (val 1))
            (hex-addend (id ?h3) (nid ?nid) (val 1))
    )
)
(defrule put-hex-addend-city
    (goal place-robber)
    (my-id ?pid)
    (node (id ?nid) (hexes ?h1 ?h2 ?h3))
    (city (player ~?pid) (node ?nid))
    =>
    (assert (hex-addend (id ?h1) (nid ?nid) (val 2))
            (hex-addend (id ?h2) (nid ?nid) (val 2))
            (hex-addend (id ?h3) (nid ?nid) (val 2))
    )
)
(defrule sum-hex-dot-total
    (goal place-robber)
    ?a <- (hex-addend (id ?hid) (val ?val))
    ?h <- (hex-total (id ?hid) (val ?total))
    =>
    (retract ?a)
    (modify ?h (val (+ ?val ?total)))
)

(defrule find-hex-score
    (declare (salience -10))
    (goal place-robber)
    (hex (id ?hid) (prob ?prob))
    (hex-total (id ?hid) (val ?dot-total))
    (hex-rarity (id ?hid) (rarity ?rarity))
    =>
    (assert (hex-score (id ?hid) (score (+ (* 3 ?rarity) (* ?dot-total ?prob)))))
)




(defrule move-robber
    (declare (salience -20))
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
    (hex-score (id ?hid) (score ?score))
    (not
      (and
        (potential-robber-placement ?hid2)
        (hex-score (id ?hid2) (score ?score2&:(> ?score2 ?score)))
      )
    )
    ;(not
    ;  (and
    ;    (potential-robber-placement ?hid2)
    ;    (hex (id ?hid2) (prob ?prob2&:(> ?prob2 ?prob)))
    ;  )
    ;)
    =>
    (assert (action "Place Robber" ?hid))
    ;(printout t crlf "ACTION: Place Robber " ?hid crlf)
    ;(exit)
)
