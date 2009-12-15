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
    (hex (id ?hid))
    =>
    (assert (hex-total (id ?hid) (val 0)))
)

(defrule put-hex-addend-settlement
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
    (my-id ?pid)
    (node (id ?nid) (hexes ?h1 ?h2 ?h3))
    (city (player ~?pid) (node ?nid))
    =>
    (assert (hex-addend (id ?h1) (nid ?nid) (val 2))
            (hex-addend (id ?h2) (nid ?nid) (val 2))
            (hex-addend (id ?h3) (nid ?nid) (val 2))
    )
)
;(defrule put-hex-addend-rarity
    ;(my-id ?pid)
    ;(node (id ?nid) (hexes ?h1 ?h2 ?h3))
    ;(city (player ~?pid) (node ?nid))
    ;=>
    ;(assert (hex-addend (id ?h1) (nid ?nid) (val 2))
            ;(hex-addend (id ?h2) (nid ?nid) (val 2))
            ;(hex-addend (id ?h3) (nid ?nid) (val 2))
    ;)
;)
(defrule aouaoeuaoeu
    (declare (salience 4))
    (hex-total (val ?val))
    =>
    (printout t "val " ?val crlf))

(defrule sum-hex-dot-total
    ?a <- (hex-addend (id ?hid) (val ?val))
    ?h <- (hex-total (id ?hid) (val ?total))
    =>
    (retract ?a)
    (modify ?h (val (+ ?val ?total)))
)

(defrule find-hex-score
    (declare (salience -10))
    (hex (id ?hid) (prob ?prob))
    (hex-total (id ?hid) (val ?dot-total))
    (hex-rarity (id ?hid) (rarity ?rarity))
    =>
    (printout t "Hex " ?hid " score " ?dot-total crlf)
    (assert (hex-score (id ?hid) (score (* ?dot-total ?prob))))
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
    (declare (salience -20))
    (goal place-robber)
    (hex-score (id ?hid) (score ?score))
    (not (hex-score (id ?hid2) (score ?score2&:(> ?score2 ?score))))
    =>
    (printout t crlf "ACTION: Place Robber " ?hid crlf)
    (exit)
)
