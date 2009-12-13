;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                         TURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;figure out how much the intersection will produce, count dots
;make choices based on the combinations
;


;if there is not much brick or lumber and there is a lot of wheat or ore, don't consider the settlement strategy even if the best spot dot-wise is for that strategy
;if you are the last person, order your settlements so that you get the resources you want
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

;highest dots
;wood/brick or ore/grain
;consider ports nearby
;wood and ore do not go well together
;wood, wheat, and sheep sort of go together since they are all needed for a settlement
;if there is a lot of sheep and you can get the sheep port, maybe go for that
;go for places with expansion opportunites, especially in the direction of those with 6-8 dots if other players are yet to play
;expansion also includes resouces you nee
;consider resource rarity
;if you are player 4 or the last to place, coordinate your settlement placements
;don't put two settlements on the same numbers
;

;statistics say clumping does happen
;especially for your second settlement, 


; INITIAL-SETUP


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
)
