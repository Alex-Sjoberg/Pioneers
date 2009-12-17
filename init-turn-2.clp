;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     INIT-TURN-2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIND-RESOURCE-TOTAL-PROBS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule find-have-resources-settlement
    (resource-cards (kind lumber) (amnt ~0))
    (resource-cards (kind brick) (amnt ~0))
    (resource-cards (kind grain) (amnt ~0))
    (resource-cards (kind wool) (amnt ~0))
    =>
    (assert (have-resources-for-settlement))
)

(defrule find-have-resources-city
    (resource-cards (kind grain) (amnt ?gamnt&:(>= ?gamnt 2)))
    (resource-cards (kind ore) (amnt ?oamnt&:(>= ?oamnt 3)))
    =>
    (assert (have-resources-for-city))
)

(defrule find-have-resources-road
    (resource-cards (kind brick) (amnt ~0))
    (resource-cards (kind lumber) (amnt ~0))
    =>
    (assert (have-resources-for-road))
)

(defrule find-have-resources-development-card
    (resource-cards (kind grain) (amnt ~0))
    (resource-cards (kind wool) (amnt ~0))
    (resource-cards (kind ore) (amnt ~0))
    =>
    (assert (have-resources-for-development-card))
)

(defrule find-can-build-settlement
    (my-id ?pid)
    (player (id ?pid) (num-settlements ?num&:(< ?num 5)))
    (road (player ?pid) (edge ?edge))
    (edge (id ?edge) (nodes $? ?node $?))
    (node (id ?node) (can-build 1))
    =>
    (assert (can-build-settlement))
)

(defrule find-can-build-city
    (my-id ?pid)
    (settlement (player ?pid))
    (player (id ?pid) (num-cities ?num&:(< ?num 4)))
    =>
    (assert (can-build-city))
)

(defrule find-can-buy-development-card
    (num-develop-in-deck ~0)
    =>
    (assert (can-buy-development-card))
)













; calculate which nodes can be built upon and which cannot
(defrule can-build-on-nodes
    (declare (salience 10))
    (goal init-turn-2)
    ?n <- (node (id ?nid) (hexes $? ?hid $?) (can-build 0))
    (not
      (or
        (settlement (node ?nid))
        (city (node ?nid))
      )
    )
    ;(hex (id ?hid) (resource ~desert&~sea))
    (not
      (and
        (or
          (settlement (node ?cnode))
          (city (node ?cnode))
        )
        (edge (nodes ?nid ?cnode))
      )
    )
    =>
    (modify ?n (can-build 1))
)

(defrule find-hex-rarity
    (goal init-turn-2)
    (hex (id ?hid) (resource ?res) (prob ?this))
    (dot-total (kind ?res) (amnt ?total&~0))
    =>
    (assert (hex-rarity (id ?hid) (rarity (/ ?this ?total))))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIND NEXT ROAD PLACEMENT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule start-road-discovery
    (goal init-turn-2)
    (settlement-target ?nid)
    =>
    (assert (looking-for-edges)
            (node-waypoint ?nid))
)

(defrule look-for-edges
    (goal init-turn-2)
    (not (next-road-placement ?))
    (looking-for-edges)
    (node-waypoint ?nid)
    (edge (id ?eid) (nodes ?nid ?))
    =>
    (assert (edge-waypoint ?eid))
)
(defrule look-for-nodes
    (goal init-turn-2)
    (not (next-road-placement ?))
    (looking-for-nodes)
    (edge-waypoint ?eid)
    (edge (id ?eid) (nodes ?nid ?))
    (node (id ?nid))
    =>
    (assert (node-waypoint ?nid))
)

(defrule determine-next-road-placement
    (goal init-turn-2)
    (not (next-road-placement ?))
    (not (game-phase initial-setup))
    (looking-for-edges)
    (my-id ?pid)
    (edge-waypoint ?eid)
    (edge (id ?eid) (nodes ?nid ?))

    (not
        (or
            (settlement (player ~?pid) (node ?nid))
            (city (player ~?pid) (node ?nid))
        )
    )
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
    (assert (next-road-placement ?eid))
)
(defrule determine-next-road-placement-in-initial-setup
    (game-phase initial-setup)
    (goal init-turn-2)
    (not (next-road-placement ?))
    (looking-for-edges)
    (my-id ?pid)

    ;find a waypoint next to a settlement
    (edge-waypoint ?etarget)
    (edge (id ?etarget) (nodes ?nid ?))
    (node (id ?nid))
    (settlement (player ?pid) (node ?nid))
    (not (road (edge ?etarget)))

    ;the other two edges coming off the node can not have roads on them
    (edge (id ?eid2&~?etarget) (nodes ?nid ?))
    (edge (id ?eid3&~?eid2&~?etarget) (nodes ?nid ?))
    (not (road (edge ?eid2)))
    (not (road (edge ?eid3)))
    =>
    (assert (next-road-placement ?etarget))
)


(defrule transition-to-look-for-nodes
    (declare (salience -10))
    (goal init-turn-2)
    (not (next-road-placement ?))
    (roads-to-place ~0)
    ?l <- (looking-for-edges)
    =>
    (retract ?l)
    (assert (looking-for-nodes))
)
(defrule transition-to-look-for-edges
    (declare (salience -10))
    (goal init-turn-2)
    (roads-to-place ~0)
    (not (next-road-placement ?))
    ?l <- (looking-for-nodes)
    =>
    (retract ?l)
    (assert (looking-for-edges))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CALCULATE THE NEXT NODE TO BUILD A SETTLEMENT ON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule find-nodes-of-this-distance
    (goal init-turn-2)
    (my-id ?pid)
    (settlement (player ?pid))
    (cur-distance ?dist)
    (node (id ?old-id) (distance =(- ?dist 1)))
    (edge (id ?eid) (nodes ?old-id ?this-id))
    ?n <- (node (id ?this-id) (distance -1))
    =>
    (modify ?n (distance ?dist))
)

(defrule find-further-nodes
    (declare (salience -10))
    (goal init-turn-2)
    (my-id ?pid)
    (settlement (player ?pid))
    (node (distance -1))
    ?d <- (cur-distance ?dist)
    =>
    (retract ?d)
    (assert (cur-distance (+ ?dist 1)))
)

(defrule calculate-node-score
    (declare (salience -10))
    (goal init-turn-2)
    (my-id ?pid)
    (settlement (player ?pid))
    (my-id ?pid)
    (cur-distance ?)
    (node (id ?nid) (can-build 1) (hexes ?hid1 ?hid2 ?hid3) (distance ?dist))
    (hex (id ?hid1) (resource ?res1) (port ?port1) (prob ?prob1))
    (hex (id ?hid2) (resource ?res2) (port ?port2) (prob ?prob2))
    (hex (id ?hid3) (resource ?res3) (port ?port3) (prob ?prob3))
    (total-resource-prob (kind lumber) (prob ?lprob))
    (total-resource-prob (kind brick) (prob ?bprob))
    (total-resource-prob (kind wool) (prob ?wprob))
    (total-resource-prob (kind grain) (prob ?gprob))
    (total-resource-prob (kind ore) (prob ?oprob))
    (not (settlement (player ~?pid) (node ?nid)))
    (not (city (player ~?pid) (node ?nid)))
    =>
    (assert (calculated-node (id ?nid)
        (score ( + (- (+ ?prob1 ?prob2 ?prob3) (* ?dist 2))
                   (/ (+
                         (if (eq ?port1 lumber) then ?lprob else 0)
                         (if (eq ?port1 brick) then ?bprob else 0)
                         (if (eq ?port1 wool) then ?wprob else 0)
                         (if (eq ?port1 grain) then ?gprob else 0)
                         (if (eq ?port1 ore) then ?oprob else 0)
                         (if (eq ?port2 lumber) then ?lprob else 0)
                         (if (eq ?port2 brick) then ?bprob else 0)
                         (if (eq ?port2 wool) then ?wprob else 0)
                         (if (eq ?port2 grain) then ?gprob else 0)
                         (if (eq ?port2 ore) then ?oprob else 0)
                         (if (eq ?port3 lumber) then ?lprob else 0)
                         (if (eq ?port3 brick) then ?bprob else 0)
                         (if (eq ?port3 wool) then ?wprob else 0)
                         (if (eq ?port3 grain) then ?gprob else 0)
                         (if (eq ?port3 ore) then ?oprob else 0)
                         (if (eq ?port1 3to1) then 3 else 0)
                         (if (eq ?port2 3to1) then 3 else 0)
                         (if (eq ?port3 3to1) then 3 else 0)
                      ) 2
                   )))))
)

(defrule calculate-best-placement
    (declare (salience -20))
    (goal init-turn-2)
    (my-id ?pid)
    (settlement (player ?pid))
    (not (settlement-target ?))
    (cur-distance ?)
    (calculated-node (id ?nid) (score ?score)) 
    (not (calculated-node (id ?nid2) (score ?score2&:(> ?score2 ?score))))
    =>
    (assert (settlement-target ?nid))
)

(defrule discover-initial-setup
  (declare (salience -100))
  ?g <- (goal init-turn-2)
  (game-phase initial-setup)
  =>
  (retract ?g)
  (printout t "Switching GOAL to initial-setup" crlf)
  (assert (goal initial-setup))
)

(defrule move-to-turn
  (declare (salience -100))
  ?g <- (goal init-turn-2)
  =>
  (retract ?g)
  (printout t "Switching GOAL to decide-action" crlf)
  (assert (goal decide-action))
)
