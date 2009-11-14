(deftemplate hex
    (slot id)
    (slot xpos)
    (slot ypos)
    (slot resource)
    (slot port)
    (slot prob)
    (slot robber)
)

(deftemplate node
    (slot id)
    (multislot hexes)
)

(deftemplate edge
    (slot id)
    (multislot nodes)
)

(deftemplate settlement
    (slot player)
    (slot node)
)

(deftemplate city
    (slot player)
    (slot node)
)

(deftemplate road
    (slot player)
    (slot edge)
)

(deftemplate mycard
    (slot kind)
)

(deftemplate num-cards
    (slot player)
    (slot num)
)

(deftemplate card
    (slot kind)
)

;(deffacts board
;    (hex (id 0) (xpos 0) (ypos 3) (resource water) (port none))
;    (hex (id 1) (xpos 1) (ypos 1) (resource water) (port any))
;    (hex (id 2) (xpos 1) (ypos 2) (resource water) (port any))
;    (hex (id 3) (xpos 1) (ypos 3) (resource sheep) (prob 5))
;    (hex (id 4) (xpos 1) (ypos 4) (resource water) (port wheat))
;    (hex (id 5) (xpos 1) (ypos 5) (resource water) (port none))
;    (hex (id 6) (xpos 2) (ypos 0) (resource water) (port wood))
;    (hex (id 7) (xpos 2) (ypos 1) (resource sheep) (prob 8))
;    (hex (id 8) (xpos 2) (ypos 2) (resource metal) (prob 10))
;    (hex (id 9) (xpos 2) (ypos 3) (resource brick) (prob 9))
;    (hex (id 10) (xpos 2) (ypos 4) (resource metal) (prob 2))
;    (hex (id 11) (xpos 2) (ypos 5) (resource sheep) (prob 6))
;    (hex (id 12) (xpos 2) (ypos 6) (resource water) (port any))
;    (hex (id 13) (xpos 3) (ypos 0) (resource water) (port none))
;    (hex (id 14) (xpos 3) (ypos 1) (resource wood) (prob 4))
;    (hex (id 15) (xpos 3) (ypos 2) (resource metal) (prob 12))
;    (hex (id 16) (xpos 3) (ypos 3) (resource wheat) (prob 11))
;    (hex (id 17) (xpos 3) (ypos 4) (resource wood) (prob 4))
;    (hex (id 18) (xpos 3) (ypos 5) (resource wheat) (prob 3))
;    (hex (id 19) (xpos 3) (ypos 6) (resource water) (port none))
;    (hex (id 20) (xpos 4) (ypos 0) (resource water) (port metal))
;    (hex (id 21) (xpos 4) (ypos 1) (resource sheep) (prob 11))
;    (hex (id 22) (xpos 4) (ypos 2) (resource wheat) (prob 3))
;    (hex (id 23) (xpos 4) (ypos 3) (resource metal) (prob 6))
;    (hex (id 24) (xpos 4) (ypos 4) (resource wheat) (prob 5))
;    (hex (id 25) (xpos 4) (ypos 5) (resource brick) (prob 8))
;    (hex (id 26) (xpos 4) (ypos 6) (resource water) (port any))
;    (hex (id 27) (xpos 5) (ypos 0) (resource water) (port none))
;    (hex (id 28) (xpos 5) (ypos 1) (resource water) (port any))
;    (hex (id 29) (xpos 5) (ypos 2) (resource wood) (prob 12))
;    (hex (id 30) (xpos 5) (ypos 3) (resource wood) (prob 9))
;    (hex (id 31) (xpos 5) (ypos 4) (resource brick) (prob 10))
;    (hex (id 32) (xpos 5) (ypos 5) (resource water) (port brick))
;    (hex (id 33) (xpos 5) (ypos 6) (resource water) (port none))
;    (hex (id 34) (xpos 6) (ypos 2) (resource water) (port none))
;    (hex (id 35) (xpos 6) (ypos 3) (resource water) (port sheep))
;    (hex (id 36) (xpos 6) (ypos 4) (resource water) (port none))
;
;    (node (id 0) (hexes 0 2 3))
;    (node (id 1) (hexes 0 3 4))
;    (node (id 2) (hexes 1 2 8))
;    (node (id 3) (hexes 2 3 8))
;    (node (id 4) (hexes 3 4 10))
;    (node (id 5) (hexes 4 5 10))
;    (node (id 6) (hexes 1 6 7))
;    (node (id 7) (hexes 1 7 8))
;    (node (id 8) (hexes 3 8 9))
;    (node (id 9) (hexes 3 9 10))
;    (node (id 10) (hexes 5 10 11))
;    (node (id 11) (hexes 5 11 12))
;    (node (id 12) (hexes 6 7 13))
;    (node (id 13) (hexes 7 8 15))
;    (node (id 14) (hexes 8 9 15))
;    (node (id 15) (hexes 9 10 17))
;    (node (id 16) (hexes 10 11 17))
;    (node (id 17) (hexes 11 12 19))
;    (node (id 18) (hexes 7 13 14))
;    (node (id 19) (hexes 7 14 15))
;    (node (id 20) (hexes 9 15 16))
;    (node (id 21) (hexes 9 16 17))
;    (node (id 22) (hexes 11 17 18))
;    (node (id 23) (hexes 11 18 19))
;    (node (id 24) (hexes 13 14 20))
;    (node (id 25) (hexes 14 15 22))
;    (node (id 26) (hexes 15 16 22))
;    (node (id 27) (hexes 16 17 24))
;    (node (id 28) (hexes 17 18 24))
;    (node (id 29) (hexes 18 19 26))
;    (node (id 30) (hexes 14 20 21))
;    (node (id 31) (hexes 14 21 22))
;    (node (id 32) (hexes 16 22 23))
;    (node (id 33) (hexes 16 23 24))
;    (node (id 34) (hexes 18 24 25))
;    (node (id 35) (hexes 18 25 26))
;    (node (id 36) (hexes 20 21 27))
;    (node (id 37) (hexes 21 22 29))
;    (node (id 38) (hexes 22 23 29))
;    (node (id 39) (hexes 23 24 31))
;    (node (id 40) (hexes 24 25 31))
;    (node (id 41) (hexes 25 26 33))
;    (node (id 42) (hexes 21 27 28))
;    (node (id 43) (hexes 28 29 34))
;    (node (id 44) (hexes 23 29 30))
;    (node (id 45) (hexes 23 30 31))
;    (node (id 46) (hexes 25 31 32))
;    (node (id 47) (hexes 25 32 33))
;    (node (id 48) (hexes 28 29 34))
;    (node (id 49) (hexes 29 30 34))
;    (node (id 50) (hexes 30 31 36))
;    (node (id 51) (hexes 31 32 36))
;    (node (id 52) (hexes 30 34 35))
;    (node (id 53) (hexes 30 35 36))
;
;    (edge (id 0) (nodes 0 1))
;    (edge (id 1) (nodes 3 0))
;    (edge (id 2) (nodes 1 4))
;    (edge (id 3) (nodes 2 3))
;    (edge (id 4) (nodes 4 5))
;    (edge (id 5) (nodes 7 2))
;    (edge (id 6) (nodes 3 8))
;    (edge (id 7) (nodes 9 4))
;    (edge (id 8) (nodes 5 10))
;    (edge (id 9) (nodes 6 7))
;    (edge (id 10) (nodes 8 9))
;    (edge (id 11) (nodes 10 11))
;    (edge (id 12) (nodes 12 6))
;    (edge (id 13) (nodes 7 13))
;    (edge (id 14) (nodes 14 8))
;    (edge (id 15) (nodes 9 15))
;    (edge (id 16) (nodes 16 10))
;    (edge (id 17) (nodes 11 17))
;    (edge (id 18) (nodes 13 14))
;    (edge (id 19) (nodes 15 16))
;    (edge (id 20) (nodes 12 18))
;    (edge (id 21) (nodes 19 13))
;    (edge (id 22) (nodes 14 20))
;    (edge (id 23) (nodes 21 15))
;    (edge (id 24) (nodes 16 22))
;    (edge (id 25) (nodes 23 17))
;    (edge (id 26) (nodes 18 19))
;    (edge (id 27) (nodes 20 21))
;    (edge (id 28) (nodes 22 23))
;    (edge (id 29) (nodes 24 18))
;    (edge (id 30) (nodes 19 25))
;    (edge (id 31) (nodes 26 20))
;    (edge (id 32) (nodes 21 27))
;    (edge (id 33) (nodes 28 22))
;    (edge (id 34) (nodes 23 29))
;    (edge (id 35) (nodes 25 26))
;    (edge (id 36) (nodes 27 28))
;    (edge (id 37) (nodes 24 30))
;    (edge (id 38) (nodes 31 25))
;    (edge (id 39) (nodes 26 32))
;    (edge (id 40) (nodes 33 27))
;    (edge (id 41) (nodes 28 34))
;    (edge (id 42) (nodes 35 29))
;    (edge (id 43) (nodes 30 31))
;    (edge (id 44) (nodes 32 33))
;    (edge (id 45) (nodes 34 35))
;    (edge (id 46) (nodes 36 30))
;    (edge (id 47) (nodes 31 37))
;    (edge (id 48) (nodes 38 32))
;    (edge (id 49) (nodes 33 39))
;    (edge (id 50) (nodes 40 34))
;    (edge (id 51) (nodes 35 41))
;    (edge (id 52) (nodes 37 38))
;    (edge (id 53) (nodes 39 40))
;    (edge (id 54) (nodes 36 42))
;    (edge (id 55) (nodes 43 37))
;    (edge (id 56) (nodes 38 44))
;    (edge (id 57) (nodes 45 39))
;    (edge (id 58) (nodes 40 46))
;    (edge (id 59) (nodes 47 41))
;    (edge (id 60) (nodes 42 43))
;    (edge (id 61) (nodes 44 45))
;    (edge (id 62) (nodes 46 47))
;    (edge (id 63) (nodes 43 48))
;    (edge (id 64) (nodes 49 44))
;    (edge (id 65) (nodes 45 50))
;    (edge (id 66) (nodes 51 46))
;    (edge (id 67) (nodes 48 49))
;    (edge (id 68) (nodes 50 51))
;    (edge (id 69) (nodes 49 52))
;    (edge (id 70) (nodes 53 50))
;    (edge (id 71) (nodes 52 53))
;)

(deffacts pieces
    (settlement (player 1) (node 5))
    (road (player 1) (edge 14))
    (road (player 1) (edge 15))
    (city (player 1) (node 12))
    (my-id 1)

    (settlement (player 2) (node 5))
    (settlement (player 2) (node 5))
    (road (player 2) (edge 15))
    (road (player 2) (edge 15))
    (road (player 2) (edge 15))
    (road (player 2) (edge 15))
    (road (player 2) (edge 15))

    (mycard (kind wheat))
    (mycard (kind sheep))
    (mycard (kind sheep))
    (mycard (kind soldier))
    (mycard (kind plenty))
    (num-cards (player 2) (num 4))
    (num-cards (player 3) (num 1))
)



(defrule build-settlement
    (card (kind wood))
    (card (kind brick))
    (card (kind wheat))
    (card (kind sheep))
    (my-id ?my-id)
    (road (player ?id&:(= ?id ?my-id)) (edge ?edge))
    (edge (id ?edge) (nodes $? ?node $?))
    =>
    (printout t "Build road p1 node " ?node crlf)
)


;Settlers of Catan
;
;Strategy
;
;If I have more than 7 cards in my hand, then I want to trade them
;If I have lots of wood and bricks then I want to make a road
; 
;
;Deftemplates
;
;(deftempate development-card
;  (slot kind (allowed-values soldier monopoly victory plenty))
;)
;
;(deftemplate player
;    (slot name (type STRING))
;    (multislot cards-in-hand)
;)
;
;(deftemplate thief
;    (slot board-hex-id (type INTEGER))
;)
;
;(deftemplate hex-connection
;    (multislot ids (cardinality 3 3))
;)
;
;
;(deftemplate resource-card
;    (slot kind (allowed-values wood brick sheep wheat metal))
;)
;
;(deftemplate board-hex
;    (slot id)
;    (slot kind (allowed-values water3to1 water2wood water2brick water2sheep water2wheat water2metal desert wood brick sheep wheat metal))
;    (slot port (allowed-values none) (default none))
;)
;
;(deffacts ihavecards
;    (resource-card (kind 
;
;(deftemplate game-state
;)
;
;
;Deffacts
;
;(deffacts deck
;  
;)
;
;
;Rules
;
;(defrule get-rid-of-cards
;    haha
;  =>
;    (aoeu)
;)
;
;
;0 hill
;1 field
;2 mountain
;3 pasture
;4 forest
;5 desert
;6 sea
;
;0 brick
;1 grain
;2 ore
;3 wool
;4 lumber
;5 none
;6 any
;
;[0,3] terrain=6, resource=5, num=0
;[1,1] terrain=6, resource=5, num=0
;[1,2] terrain=6, resource=6, num=0
;[1,3] terrain=5, resource=5, num=0
;[1,4] terrain=6, resource=6, num=0
;[1,5] terrain=6, resource=5, num=0
;[2,0] terrain=6, resource=3, num=0
;[2,1] terrain=4, resource=5, num=11
;[2,2] terrain=0, resource=5, num=4
;[2,3] terrain=4, resource=5, num=3
;[2,4] terrain=0, resource=5, num=8
;[2,5] terrain=2, resource=5, num=5
;[2,6] terrain=6, resource=2, num=0
;[3,0] terrain=6, resource=5, num=0
;[3,1] terrain=3, resource=5, num=12
;[3,2] terrain=2, resource=5, num=6
;[3,3] terrain=1, resource=5, num=11
;[3,4] terrain=3, resource=5, num=10
;[3,5] terrain=1, resource=5, num=2
;[3,6] terrain=6, resource=5, num=0
;[4,0] terrain=6, resource=6, num=0
;[4,1] terrain=1, resource=5, num=9
;[4,2] terrain=0, resource=5, num=5
;[4,3] terrain=4, resource=5, num=4
;[4,4] terrain=3, resource=5, num=9
;[4,5] terrain=4, resource=5, num=6
;[4,6] terrain=6, resource=0, num=0
;[5,0] terrain=6, resource=5, num=0
;[5,1] terrain=6, resource=1, num=0
;[5,2] terrain=3, resource=5, num=10
;[5,3] terrain=1, resource=5, num=8
;[5,4] terrain=2, resource=5, num=3
;[5,5] terrain=6, resource=6, num=0
;[5,6] terrain=6, resource=5, num=0
;[6,2] terrain=6, resource=5, num=0
;[6,3] terrain=6, resource=4, num=0
;[6,4] terrain=6, resource=5, num=0
;
;
;
;------------------------------------------------------------------
;
;
;
