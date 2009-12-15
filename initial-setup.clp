;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                         TURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;DONE figure out how much the intersection will produce, count dots
;if there is not much brick or lumber and there is a lot of wheat or ore, don't consider the settlement strategy even if the best spot dot-wise is for that strategy
;if someone offers you one for two if you need it, 
;if it is a rare resource, place on it if there is already someone there, since that will deter the robber
;if you are settlements, don't make a 6/8 your only source of lumber or brick if you are the only one on that node
;one good number and 2 bad numbers is a robber magnet
;don't place both settlements on the same hex at the beginning
;if there are two settlements on a hex, you might put your settlement there too, since the robber will not stay there
;if you place don't expect to get any particuar other hex
;do the opposite of what everyone else is doing according to their strategy that we calculate
;ore/wheat should stay away from road builders, and road builders can try to cut off ore/wheaters
;don't have all the same numbers because it can cause you to have too many cards because they come in clumps, though two numbers on two resources that go together can be good
;build roads in the direction you want to expand, and don't expand in the direction of hexes people will most likely take
;if you are a road builder and you can beat the ore/wheaters, you might build inland if you can beat them
;it is harder to get blocked in when you build in two different places, do this especially if you are ore/grain and can't build roads right away
;build your starting roads toward your third and fourth settlements, and don't try to connect them right away or you will waste time

;DONE highest dots
;DONE lumber/brick or ore/grain
;consider ports nearby
;lumber and ore do not go well together
;lumber, wheat, and sheep sort of go together since they are all needed for a settlement
;if there is a lot of sheep and you can get the sheep port, maybe go for that
;go for places with expansion opportunites, especially in the direction of those with 6-8 dots if other players are yet to play
;expansion also includes resouces you nee
;consider resource rarity
;if you are player 4 or the last to place, coordinate your settlement placements
;don't put two settlements on the same numbers

;SECOND PLACEMENT
;try to make up for the resources you missed on your first one or make them corresponding
;try not to repeat numbers
;if you are going for the middle strategy, try for a 3-1 port
;if you are the last person, order your settlements so that you get the resources you want

;statistics say clumping does happen
;especially for your second settlement, 


; INITIAL-SETUP


;(defglobal ?*total-dots* = 5
;           ?*min-brick-lumber* = 2
;           ?*total-brick* = 2
;           ?*min-ore-grain* = 2
;           ?*total-ore* = 2
;           ?*resource-rarity* = 3
;)

(defrule count-num-opponents-settlements-to-place
    (declare (salience 10))
    (goal initial-setup)
    (settlements-to-place ?snum)
    (my-id ?pid)
    (not (settlement (player ?pid)))
    (num-players ?pnum)
    =>
    (assert (num-opponents-settlements-to-place (* 2 (- ?pnum ?pid 1) (+ (* -1 ?snum) 2))))
)


(defrule find-available-nodes "don't even consider nodes we can't place on"
    (declare (salience 10))
    (goal initial-setup)

    ; At least one settlement to place
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
    (assert (possible-settlement-node (id ?nid) (hexes ?h1 ?h2 ?h3)))
)

(deffunction count-this-resource (?h1 ?h2 ?h3 ?res)
    (bind ?num 0)
    (if (eq ?res ?h1) then (bind ?num (+ ?num 1)))
    (if (eq ?res ?h2) then (bind ?num (+ ?num 1)))
    (if (eq ?res ?h3) then (bind ?num (+ ?num 1)))
    (return ?num)
)
(defrule score-nodes-by-what-can-be-calculated-from-the-hexes-themselves "total dots min of brick+lumber amount of brick min of ore+grain amount of ore"
    (goal initial-setup)
    (possible-settlement-node (id ?nid) (hexes ?h1 ?h2 ?h3))
    (hex (id ?h1) (prob ?dots1) (resource ?res1))
    (hex (id ?h2) (prob ?dots2) (resource ?res2))
    (hex (id ?h3) (prob ?dots3) (resource ?res3))
    =>
    (assert (node-attribute (id ?nid) (attr total-dots) (val (+ ?dots1 ?dots2 ?dots3)))
            (node-attribute (id ?nid) (attr min-brick-lumber)
                (val (min (count-this-resource ?h1 ?h2 ?h3 lumber)
                          (count-this-resource ?h1 ?h2 ?h3 brick))))
            (node-attribute (id ?nid) (attr total-brick) (val (count-this-resource ?h1 ?h2 ?h3 brick)))
            (node-attribute (id ?nid) (attr min-ore-grain)
                (val (min (count-this-resource ?h1 ?h2 ?h3 ore)
                          (count-this-resource ?h1 ?h2 ?h3 grain))))
            (node-attribute (id ?nid) (attr total-ore) (val (count-this-resource ?h1 ?h2 ?h3 ore)))
    )
)

(defrule score-nodes-by-resource-rarity
    (goal initial-setup)
    (possible-settlement-node (id ?nid) (hexes ?h1 ?h2 ?h3))
    (hex (id ?h1) (resource ?res1))
    (hex-rarity (id ?h1) (rarity ?r1))
    (hex (id ?h2) (resource ?res2))
    (hex-rarity (id ?h2) (rarity ?r2))
    (hex (id ?h3) (resource ?res3))
    (hex-rarity (id ?h3) (rarity ?r3))
    =>
    (assert (node-attribute (id ?nid) (attr resource-rarity) (val (+ ?r1 ?r2 ?r3))))
)
(defrule find-hex-rarity
    (hex (id ?hid) (resource ?res) (prob ?this))
    (dot-total (kind ?res) (amnt ?total&~0))
    =>
    (assert (hex-rarity (id ?hid) (rarity (/ ?this ?total))))
)

(defrule score-nodes-by-dot-lopsidedness "one high number and two low numbers is a robber magnet"
    =>    
)

(defrule score-nodes-by-dot-differentness "one high number and two low numbers is a robber magnet"
    =>    
)


(defrule calculate-overall-goodness-of-nodes
    (possible-settlement-node (id ?nid) (hexes ?h1 ?h2 ?h3))
    (node-attribute (id ?nid) (attr total-dots) (val ?total-dots))
    (node-attribute (id ?nid) (attr min-brick-lumber) (val ?min-brick-lumber))
    (node-attribute (id ?nid) (attr total-brick) (val ?total-brick))
    (node-attribute (id ?nid) (attr min-ore-grain) (val ?min-ore-grain))
    (node-attribute (id ?nid) (attr total-ore) (val ?total-ore))
    (node-attribute (id ?nid) (attr resource-rarity) (val ?resource-rarity))
    =>
    (assert (calculated-node (id ?nid) (score
        (+ (* ?*total-dots* ?total-dots)
           (* ?*min-brick-lumber* ?min-brick-lumber)
           (* ?*total-brick* ?total-brick)
           (* ?*min-ore-grain* ?min-ore-grain)
           (* ?*total-ore* ?total-ore)
           (* ?*resource-rarity* ?resource-rarity)
        ))))
)

(defrule place-starting-settlement
    (goal initial-setup)
    (settlements-to-place ?num&:(> ?num 0))
    (calculated-node (id ?nid) (score ?score))

    ; ...and for which there is no other possible settlement spot
    ; which has a higher probability
    (not (calculated-node (score ?score2&:(> ?score2 ?score))))
    =>
    (printout t crlf "ACTION: Build Settlement " ?nid crlf)
    (exit)
)

(defrule place-starting-road
    (goal initial-setup)
    (my-id ?pnum)

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
    (exit)
)
