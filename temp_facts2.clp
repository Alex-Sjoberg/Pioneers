(hex (id 19643664) (xpos 0) (ypos 2) (resource sea) (port wool) (number 0) (prob 0))
(node (id 19667552) (hexes 0 19643664 19656896))
(node (id 19667744) (hexes 0 0 19643664))
(node (id 19667936) (hexes 0 0 19643664))
(node (id 19663888) (hexes 19643664 0 19657376))
(node (id 19663696) (hexes 19643664 19657376 19657536))
(node (id 19668208) (hexes 19656896 19643664 19657536))
(edge (id 19667664) (nodes 19667552 19668208))
(edge (id 19667856) (nodes 19667552 19667744))
(edge (id 19668048) (nodes 19667744 19667936))
(edge (id 19668128) (nodes 19667936 19663888))
(edge (id 19664000) (nodes 19663888 19663696))
(edge (id 19668320) (nodes 19668208 19663696))
(hex (id 19656896) (xpos 0) (ypos 3) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19671568) (hexes 0 19656896 19657056))
(node (id 19671760) (hexes 0 0 19656896))
(node (id 19667552) (hexes 0 19643664 19656896))
(node (id 19668208) (hexes 19656896 19643664 19657536))
(node (id 19668400) (hexes 19656896 19657536 19657696))
(node (id 19672032) (hexes 19657056 19656896 19657696))
(edge (id 19671680) (nodes 19671568 19672032))
(edge (id 19671872) (nodes 19671568 19671760))
(edge (id 19671952) (nodes 19671760 19667552))
(edge (id 19667664) (nodes 19667552 19668208))
(edge (id 19668592) (nodes 19668208 19668400))
(edge (id 19672144) (nodes 19672032 19668400))
(hex (id 19657056) (xpos 0) (ypos 4) (resource sea) (port 3to1) (number 0) (prob 0))
(node (id 19675200) (hexes 0 19657056 19657216))
(node (id 19675392) (hexes 0 0 19657056))
(node (id 19671568) (hexes 0 19656896 19657056))
(node (id 19672032) (hexes 19657056 19656896 19657696))
(node (id 19672224) (hexes 19657056 19657696 19657856))
(node (id 19675664) (hexes 19657216 19657056 19657856))
(edge (id 19675312) (nodes 19675200 19675664))
(edge (id 19675504) (nodes 19675200 19675392))
(edge (id 19675584) (nodes 19675392 19671568))
(edge (id 19671680) (nodes 19671568 19672032))
(edge (id 19672416) (nodes 19672032 19672224))
(edge (id 19675776) (nodes 19675664 19672224))
(hex (id 19657216) (xpos 0) (ypos 5) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19678832) (hexes 0 19657216 0))
(node (id 19679024) (hexes 0 0 19657216))
(node (id 19675200) (hexes 0 19657056 19657216))
(node (id 19675664) (hexes 19657216 19657056 19657856))
(node (id 19675856) (hexes 19657216 19657856 19658016))
(node (id 19679296) (hexes 0 19657216 19658016))
(edge (id 19678944) (nodes 19679296 19678832))
(edge (id 19679136) (nodes 19678832 19679024))
(edge (id 19679216) (nodes 19679024 19675200))
(edge (id 19675312) (nodes 19675200 19675664))
(edge (id 19676048) (nodes 19675664 19675856))
(edge (id 19679408) (nodes 19679296 19675856))
(hex (id 19657376) (xpos 1) (ypos 1) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19663696) (hexes 19643664 19657376 19657536))
(node (id 19663888) (hexes 19643664 0 19657376))
(node (id 19664080) (hexes 0 0 19657376))
(node (id 19664272) (hexes 19657376 0 19658176))
(node (id 19664464) (hexes 19657376 19658176 19658336))
(node (id 19664656) (hexes 19657536 19657376 19658336))
(edge (id 19663808) (nodes 19663696 19664656))
(edge (id 19664000) (nodes 19663888 19663696))
(edge (id 19664192) (nodes 19663888 19664080))
(edge (id 19664384) (nodes 19664080 19664272))
(edge (id 19664576) (nodes 19664464 19664272))
(edge (id 19664768) (nodes 19664656 19664464))
(road (edge 19664768) (player 2))
(hex (id 19657536) (xpos 1) (ypos 2) (resource brick) (port nil) (number 11) (prob 2))
(node (id 19668400) (hexes 19656896 19657536 19657696))
(node (id 19668208) (hexes 19656896 19643664 19657536))
(node (id 19663696) (hexes 19643664 19657376 19657536))
(node (id 19664656) (hexes 19657536 19657376 19658336))
(node (id 19668672) (hexes 19657536 19658336 19658496))
(settlement (node 19668672) (player 2))
(node (id 19668864) (hexes 19657696 19657536 19658496))
(edge (id 19668512) (nodes 19668400 19668864))
(edge (id 19668592) (nodes 19668208 19668400))
(edge (id 19668320) (nodes 19668208 19663696))
(edge (id 19663808) (nodes 19663696 19664656))
(edge (id 19668784) (nodes 19668672 19664656))
(road (edge 19668784) (player 2))
(edge (id 19668976) (nodes 19668864 19668672))
(hex (id 19657696) (xpos 1) (ypos 3) (resource brick) (port nil) (number 12) (prob 1))
(node (id 19672224) (hexes 19657056 19657696 19657856))
(node (id 19672032) (hexes 19657056 19656896 19657696))
(node (id 19668400) (hexes 19656896 19657536 19657696))
(node (id 19668864) (hexes 19657696 19657536 19658496))
(node (id 19672496) (hexes 19657696 19658496 19658656))
(node (id 19672688) (hexes 19657856 19657696 19658656))
(edge (id 19672336) (nodes 19672224 19672688))
(edge (id 19672416) (nodes 19672032 19672224))
(edge (id 19672144) (nodes 19672032 19668400))
(edge (id 19668512) (nodes 19668400 19668864))
(edge (id 19672608) (nodes 19672496 19668864))
(edge (id 19672800) (nodes 19672688 19672496))
(hex (id 19657856) (xpos 1) (ypos 4) (resource lumber) (port nil) (number 9) (prob 4))
(node (id 19675856) (hexes 19657216 19657856 19658016))
(node (id 19675664) (hexes 19657216 19657056 19657856))
(node (id 19672224) (hexes 19657056 19657696 19657856))
(node (id 19672688) (hexes 19657856 19657696 19658656))
(node (id 19676128) (hexes 19657856 19658656 19658816))
(settlement (node 19676128) (player 1))
(node (id 19676320) (hexes 19658016 19657856 19658816))
(edge (id 19675968) (nodes 19675856 19676320))
(edge (id 19676048) (nodes 19675664 19675856))
(edge (id 19675776) (nodes 19675664 19672224))
(edge (id 19672336) (nodes 19672224 19672688))
(edge (id 19676240) (nodes 19676128 19672688))
(road (edge 19676240) (player 1))
(edge (id 19676432) (nodes 19676320 19676128))
(hex (id 19658016) (xpos 1) (ypos 5) (resource sea) (port 3to1) (number 0) (prob 0))
(node (id 19679488) (hexes 0 19658016 0))
(node (id 19679296) (hexes 0 19657216 19658016))
(node (id 19675856) (hexes 19657216 19657856 19658016))
(node (id 19676320) (hexes 19658016 19657856 19658816))
(node (id 19679760) (hexes 19658016 19658816 19658976))
(node (id 19679952) (hexes 0 19658016 19658976))
(edge (id 19679600) (nodes 19679952 19679488))
(edge (id 19679680) (nodes 19679488 19679296))
(edge (id 19679408) (nodes 19679296 19675856))
(edge (id 19675968) (nodes 19675856 19676320))
(edge (id 19679872) (nodes 19679760 19676320))
(edge (id 19680064) (nodes 19679952 19679760))
(hex (id 19658176) (xpos 2) (ypos 1) (resource sea) (port grain) (number 0) (prob 0))
(node (id 19664464) (hexes 19657376 19658176 19658336))
(node (id 19664272) (hexes 19657376 0 19658176))
(node (id 19664928) (hexes 0 0 19658176))
(node (id 19662736) (hexes 19658176 0 19659136))
(node (id 19648096) (hexes 19658176 19659136 19659296))
(node (id 19665200) (hexes 19658336 19658176 19659296))
(edge (id 19664848) (nodes 19664464 19665200))
(edge (id 19664576) (nodes 19664464 19664272))
(edge (id 19665040) (nodes 19664272 19664928))
(edge (id 19665120) (nodes 19664928 19662736))
(edge (id 19662848) (nodes 19662736 19648096))
(edge (id 19665312) (nodes 19665200 19648096))
(hex (id 19658336) (xpos 2) (ypos 2) (resource wool) (port nil) (number 4) (prob 3))
(node (id 19668672) (hexes 19657536 19658336 19658496))
(settlement (node 19668672) (player 2))
(node (id 19664656) (hexes 19657536 19657376 19658336))
(node (id 19664464) (hexes 19657376 19658176 19658336))
(node (id 19665200) (hexes 19658336 19658176 19659296))
(node (id 19665392) (hexes 19658336 19659296 19659456))
(node (id 19669136) (hexes 19658496 19658336 19659456))
(edge (id 19669056) (nodes 19668672 19669136))
(edge (id 19668784) (nodes 19668672 19664656))
(road (edge 19668784) (player 2))
(edge (id 19664768) (nodes 19664656 19664464))
(road (edge 19664768) (player 2))
(edge (id 19664848) (nodes 19664464 19665200))
(edge (id 19665584) (nodes 19665200 19665392))
(edge (id 19669248) (nodes 19669136 19665392))
(hex (id 19658496) (xpos 2) (ypos 3) (resource wool) (port nil) (number 6) (prob 5))
(node (id 19672496) (hexes 19657696 19658496 19658656))
(node (id 19668864) (hexes 19657696 19657536 19658496))
(node (id 19668672) (hexes 19657536 19658336 19658496))
(settlement (node 19668672) (player 2))
(node (id 19669136) (hexes 19658496 19658336 19659456))
(node (id 19669328) (hexes 19658496 19659456 19659616))
(node (id 19672960) (hexes 19658656 19658496 19659616))
(settlement (node 19672960) (player 3))
(edge (id 19672880) (nodes 19672496 19672960))
(edge (id 19672608) (nodes 19672496 19668864))
(edge (id 19668976) (nodes 19668864 19668672))
(edge (id 19669056) (nodes 19668672 19669136))
(edge (id 19669520) (nodes 19669136 19669328))
(edge (id 19673072) (nodes 19672960 19669328))
(hex (id 19658656) (xpos 2) (ypos 4) (resource grain) (port nil) (number 5) (prob 4))
(robber (hex 19658656))
(node (id 19676128) (hexes 19657856 19658656 19658816))
(settlement (node 19676128) (player 1))
(node (id 19672688) (hexes 19657856 19657696 19658656))
(node (id 19672496) (hexes 19657696 19658496 19658656))
(node (id 19672960) (hexes 19658656 19658496 19659616))
(settlement (node 19672960) (player 3))
(node (id 19673152) (hexes 19658656 19659616 19659776))
(node (id 19676592) (hexes 19658816 19658656 19659776))
(edge (id 19676512) (nodes 19676128 19676592))
(edge (id 19676240) (nodes 19676128 19672688))
(road (edge 19676240) (player 1))
(edge (id 19672800) (nodes 19672688 19672496))
(edge (id 19672880) (nodes 19672496 19672960))
(edge (id 19673344) (nodes 19672960 19673152))
(road (edge 19673344) (player 3))
(edge (id 19676704) (nodes 19676592 19673152))
(hex (id 19658816) (xpos 2) (ypos 5) (resource ore) (port nil) (number 10) (prob 3))
(node (id 19679760) (hexes 19658016 19658816 19658976))
(node (id 19676320) (hexes 19658016 19657856 19658816))
(node (id 19676128) (hexes 19657856 19658656 19658816))
(settlement (node 19676128) (player 1))
(node (id 19676592) (hexes 19658816 19658656 19659776))
(node (id 19676784) (hexes 19658816 19659776 19659936))
(settlement (node 19676784) (player 2))
(node (id 19680224) (hexes 19658976 19658816 19659936))
(edge (id 19680144) (nodes 19679760 19680224))
(edge (id 19679872) (nodes 19679760 19676320))
(edge (id 19676432) (nodes 19676320 19676128))
(edge (id 19676512) (nodes 19676128 19676592))
(edge (id 19676976) (nodes 19676592 19676784))
(road (edge 19676976) (player 2))
(edge (id 19680336) (nodes 19680224 19676784))
(hex (id 19658976) (xpos 2) (ypos 6) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19682464) (hexes 0 19658976 0))
(node (id 19679952) (hexes 0 19658016 19658976))
(node (id 19679760) (hexes 19658016 19658816 19658976))
(node (id 19680224) (hexes 19658976 19658816 19659936))
(node (id 19680416) (hexes 19658976 19659936 19660096))
(node (id 19682736) (hexes 0 19658976 19660096))
(edge (id 19682576) (nodes 19682736 19682464))
(edge (id 19682656) (nodes 19682464 19679952))
(edge (id 19680064) (nodes 19679952 19679760))
(edge (id 19680144) (nodes 19679760 19680224))
(edge (id 19680608) (nodes 19680224 19680416))
(edge (id 19682848) (nodes 19682736 19680416))
(hex (id 19659136) (xpos 3) (ypos 0) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19648096) (hexes 19658176 19659136 19659296))
(node (id 19662736) (hexes 19658176 0 19659136))
(node (id 19662928) (hexes 0 0 19659136))
(node (id 19663120) (hexes 19659136 0 0))
(node (id 19663312) (hexes 19659136 0 19660256))
(node (id 19663504) (hexes 19659296 19659136 19660256))
(edge (id 19662656) (nodes 19648096 19663504))
(edge (id 19662848) (nodes 19662736 19648096))
(edge (id 19663040) (nodes 19662736 19662928))
(edge (id 19663232) (nodes 19662928 19663120))
(edge (id 19663424) (nodes 19663120 19663312))
(edge (id 19663616) (nodes 19663504 19663312))
(hex (id 19659296) (xpos 3) (ypos 1) (resource lumber) (port nil) (number 8) (prob 5))
(node (id 19665392) (hexes 19658336 19659296 19659456))
(node (id 19665200) (hexes 19658336 19658176 19659296))
(node (id 19648096) (hexes 19658176 19659136 19659296))
(node (id 19663504) (hexes 19659296 19659136 19660256))
(node (id 19665664) (hexes 19659296 19660256 19660416))
(node (id 19665856) (hexes 19659456 19659296 19660416))
(settlement (node 19665856) (player 3))
(edge (id 19665504) (nodes 19665392 19665856))
(edge (id 19665584) (nodes 19665200 19665392))
(edge (id 19665312) (nodes 19665200 19648096))
(edge (id 19662656) (nodes 19648096 19663504))
(edge (id 19665776) (nodes 19665664 19663504))
(edge (id 19665968) (nodes 19665856 19665664))
(hex (id 19659456) (xpos 3) (ypos 2) (resource brick) (port nil) (number 3) (prob 2))
(node (id 19669328) (hexes 19658496 19659456 19659616))
(node (id 19669136) (hexes 19658496 19658336 19659456))
(node (id 19665392) (hexes 19658336 19659296 19659456))
(node (id 19665856) (hexes 19659456 19659296 19660416))
(settlement (node 19665856) (player 3))
(node (id 19669600) (hexes 19659456 19660416 19660576))
(node (id 19669792) (hexes 19659616 19659456 19660576))
(edge (id 19669440) (nodes 19669328 19669792))
(edge (id 19669520) (nodes 19669136 19669328))
(edge (id 19669248) (nodes 19669136 19665392))
(edge (id 19665504) (nodes 19665392 19665856))
(edge (id 19669712) (nodes 19669600 19665856))
(road (edge 19669712) (player 3))
(edge (id 19669904) (nodes 19669792 19669600))
(road (edge 19669904) (player 3))
(hex (id 19659616) (xpos 3) (ypos 3) (resource ore) (port nil) (number 11) (prob 2))
(node (id 19673152) (hexes 19658656 19659616 19659776))
(node (id 19672960) (hexes 19658656 19658496 19659616))
(settlement (node 19672960) (player 3))
(node (id 19669328) (hexes 19658496 19659456 19659616))
(node (id 19669792) (hexes 19659616 19659456 19660576))
(node (id 19673424) (hexes 19659616 19660576 19660736))
(node (id 19673616) (hexes 19659776 19659616 19660736))
(settlement (node 19673616) (player 0))
(edge (id 19673264) (nodes 19673152 19673616))
(edge (id 19673344) (nodes 19672960 19673152))
(road (edge 19673344) (player 3))
(edge (id 19673072) (nodes 19672960 19669328))
(edge (id 19669440) (nodes 19669328 19669792))
(edge (id 19673536) (nodes 19673424 19669792))
(road (edge 19673536) (player 0))
(edge (id 19673728) (nodes 19673616 19673424))
(road (edge 19673728) (player 0))
(hex (id 19659776) (xpos 3) (ypos 4) (resource wool) (port nil) (number 4) (prob 3))
(node (id 19676784) (hexes 19658816 19659776 19659936))
(settlement (node 19676784) (player 2))
(node (id 19676592) (hexes 19658816 19658656 19659776))
(node (id 19673152) (hexes 19658656 19659616 19659776))
(node (id 19673616) (hexes 19659776 19659616 19660736))
(settlement (node 19673616) (player 0))
(node (id 19677056) (hexes 19659776 19660736 19660896))
(node (id 19677248) (hexes 19659936 19659776 19660896))
(edge (id 19676896) (nodes 19676784 19677248))
(edge (id 19676976) (nodes 19676592 19676784))
(road (edge 19676976) (player 2))
(edge (id 19676704) (nodes 19676592 19673152))
(edge (id 19673264) (nodes 19673152 19673616))
(edge (id 19677168) (nodes 19677056 19673616))
(edge (id 19677360) (nodes 19677248 19677056))
(hex (id 19659936) (xpos 3) (ypos 5) (resource grain) (port nil) (number 8) (prob 5))
(node (id 19680416) (hexes 19658976 19659936 19660096))
(node (id 19680224) (hexes 19658976 19658816 19659936))
(node (id 19676784) (hexes 19658816 19659776 19659936))
(settlement (node 19676784) (player 2))
(node (id 19677248) (hexes 19659936 19659776 19660896))
(node (id 19680688) (hexes 19659936 19660896 19661056))
(node (id 19680880) (hexes 19660096 19659936 19661056))
(edge (id 19680528) (nodes 19680416 19680880))
(edge (id 19680608) (nodes 19680224 19680416))
(edge (id 19680336) (nodes 19680224 19676784))
(edge (id 19676896) (nodes 19676784 19677248))
(edge (id 19680800) (nodes 19680688 19677248))
(edge (id 19680992) (nodes 19680880 19680688))
(hex (id 19660096) (xpos 3) (ypos 6) (resource sea) (port ore) (number 0) (prob 0))
(node (id 19682928) (hexes 0 19660096 0))
(node (id 19682736) (hexes 0 19658976 19660096))
(node (id 19680416) (hexes 19658976 19659936 19660096))
(node (id 19680880) (hexes 19660096 19659936 19661056))
(node (id 19683200) (hexes 19660096 19661056 0))
(node (id 19683392) (hexes 0 19660096 0))
(edge (id 19683040) (nodes 19683392 19682928))
(edge (id 19683120) (nodes 19682928 19682736))
(edge (id 19682848) (nodes 19682736 19680416))
(edge (id 19680528) (nodes 19680416 19680880))
(edge (id 19683312) (nodes 19683200 19680880))
(edge (id 19683504) (nodes 19683200 19683392))
(hex (id 19660256) (xpos 4) (ypos 1) (resource sea) (port lumber) (number 0) (prob 0))
(node (id 19665664) (hexes 19659296 19660256 19660416))
(node (id 19663504) (hexes 19659296 19659136 19660256))
(node (id 19663312) (hexes 19659136 0 19660256))
(node (id 19666128) (hexes 19660256 0 0))
(node (id 19666320) (hexes 19660256 0 19661216))
(node (id 19666512) (hexes 19660416 19660256 19661216))
(edge (id 19666048) (nodes 19665664 19666512))
(edge (id 19665776) (nodes 19665664 19663504))
(edge (id 19663616) (nodes 19663504 19663312))
(edge (id 19666240) (nodes 19663312 19666128))
(edge (id 19666432) (nodes 19666128 19666320))
(edge (id 19666624) (nodes 19666512 19666320))
(hex (id 19660416) (xpos 4) (ypos 2) (resource lumber) (port nil) (number 10) (prob 3))
(node (id 19669600) (hexes 19659456 19660416 19660576))
(node (id 19665856) (hexes 19659456 19659296 19660416))
(settlement (node 19665856) (player 3))
(node (id 19665664) (hexes 19659296 19660256 19660416))
(node (id 19666512) (hexes 19660416 19660256 19661216))
(node (id 19666704) (hexes 19660416 19661216 19661376))
(node (id 19670064) (hexes 19660576 19660416 19661376))
(edge (id 19669984) (nodes 19669600 19670064))
(edge (id 19669712) (nodes 19669600 19665856))
(road (edge 19669712) (player 3))
(edge (id 19665968) (nodes 19665856 19665664))
(edge (id 19666048) (nodes 19665664 19666512))
(edge (id 19666896) (nodes 19666512 19666704))
(edge (id 19670176) (nodes 19670064 19666704))
(hex (id 19660576) (xpos 4) (ypos 3) (resource desert) (port nil) (number 0) (prob 0))
(node (id 19673424) (hexes 19659616 19660576 19660736))
(node (id 19669792) (hexes 19659616 19659456 19660576))
(node (id 19669600) (hexes 19659456 19660416 19660576))
(node (id 19670064) (hexes 19660576 19660416 19661376))
(node (id 19670256) (hexes 19660576 19661376 19661536))
(node (id 19673888) (hexes 19660736 19660576 19661536))
(edge (id 19673808) (nodes 19673424 19673888))
(edge (id 19673536) (nodes 19673424 19669792))
(road (edge 19673536) (player 0))
(edge (id 19669904) (nodes 19669792 19669600))
(road (edge 19669904) (player 3))
(edge (id 19669984) (nodes 19669600 19670064))
(edge (id 19670448) (nodes 19670064 19670256))
(edge (id 19674000) (nodes 19673888 19670256))
(hex (id 19660736) (xpos 4) (ypos 4) (resource grain) (port nil) (number 9) (prob 4))
(node (id 19677056) (hexes 19659776 19660736 19660896))
(node (id 19673616) (hexes 19659776 19659616 19660736))
(settlement (node 19673616) (player 0))
(node (id 19673424) (hexes 19659616 19660576 19660736))
(node (id 19673888) (hexes 19660736 19660576 19661536))
(node (id 19674080) (hexes 19660736 19661536 19661696))
(node (id 19677520) (hexes 19660896 19660736 19661696))
(settlement (node 19677520) (player 0))
(edge (id 19677440) (nodes 19677056 19677520))
(road (edge 19677440) (player 0))
(edge (id 19677168) (nodes 19677056 19673616))
(edge (id 19673728) (nodes 19673616 19673424))
(road (edge 19673728) (player 0))
(edge (id 19673808) (nodes 19673424 19673888))
(edge (id 19674272) (nodes 19673888 19674080))
(edge (id 19677632) (nodes 19677520 19674080))
(hex (id 19660896) (xpos 4) (ypos 5) (resource grain) (port nil) (number 3) (prob 2))
(node (id 19680688) (hexes 19659936 19660896 19661056))
(node (id 19677248) (hexes 19659936 19659776 19660896))
(node (id 19677056) (hexes 19659776 19660736 19660896))
(node (id 19677520) (hexes 19660896 19660736 19661696))
(settlement (node 19677520) (player 0))
(node (id 19677712) (hexes 19660896 19661696 19661856))
(node (id 19681152) (hexes 19661056 19660896 19661856))
(edge (id 19681072) (nodes 19680688 19681152))
(edge (id 19680800) (nodes 19680688 19677248))
(edge (id 19677360) (nodes 19677248 19677056))
(edge (id 19677440) (nodes 19677056 19677520))
(road (edge 19677440) (player 0))
(edge (id 19677904) (nodes 19677520 19677712))
(edge (id 19681264) (nodes 19681152 19677712))
(hex (id 19661056) (xpos 4) (ypos 6) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19683200) (hexes 19660096 19661056 0))
(node (id 19680880) (hexes 19660096 19659936 19661056))
(node (id 19680688) (hexes 19659936 19660896 19661056))
(node (id 19681152) (hexes 19661056 19660896 19661856))
(node (id 19681344) (hexes 19661056 19661856 0))
(node (id 19683664) (hexes 0 19661056 0))
(edge (id 19683584) (nodes 19683664 19683200))
(edge (id 19683312) (nodes 19683200 19680880))
(edge (id 19680992) (nodes 19680880 19680688))
(edge (id 19681072) (nodes 19680688 19681152))
(edge (id 19681536) (nodes 19681152 19681344))
(edge (id 19683776) (nodes 19681344 19683664))
(hex (id 19661216) (xpos 5) (ypos 1) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19666704) (hexes 19660416 19661216 19661376))
(node (id 19666512) (hexes 19660416 19660256 19661216))
(node (id 19666320) (hexes 19660256 0 19661216))
(node (id 19666976) (hexes 19661216 0 0))
(node (id 19667168) (hexes 19661216 0 19662016))
(node (id 19667360) (hexes 19661376 19661216 19662016))
(settlement (node 19667360) (player 1))
(edge (id 19666816) (nodes 19666704 19667360))
(edge (id 19666896) (nodes 19666512 19666704))
(edge (id 19666624) (nodes 19666512 19666320))
(edge (id 19667088) (nodes 19666320 19666976))
(edge (id 19667280) (nodes 19666976 19667168))
(edge (id 19667472) (nodes 19667360 19667168))
(hex (id 19661376) (xpos 5) (ypos 2) (resource wool) (port nil) (number 5) (prob 4))
(node (id 19670256) (hexes 19660576 19661376 19661536))
(node (id 19670064) (hexes 19660576 19660416 19661376))
(node (id 19666704) (hexes 19660416 19661216 19661376))
(node (id 19667360) (hexes 19661376 19661216 19662016))
(settlement (node 19667360) (player 1))
(node (id 19670528) (hexes 19661376 19662016 19662176))
(node (id 19670720) (hexes 19661536 19661376 19662176))
(edge (id 19670368) (nodes 19670256 19670720))
(edge (id 19670448) (nodes 19670064 19670256))
(edge (id 19670176) (nodes 19670064 19666704))
(edge (id 19666816) (nodes 19666704 19667360))
(edge (id 19670640) (nodes 19670528 19667360))
(road (edge 19670640) (player 1))
(edge (id 19670832) (nodes 19670720 19670528))
(hex (id 19661536) (xpos 5) (ypos 3) (resource ore) (port nil) (number 2) (prob 1))
(node (id 19674080) (hexes 19660736 19661536 19661696))
(node (id 19673888) (hexes 19660736 19660576 19661536))
(node (id 19670256) (hexes 19660576 19661376 19661536))
(node (id 19670720) (hexes 19661536 19661376 19662176))
(node (id 19674352) (hexes 19661536 19662176 19662336))
(node (id 19674544) (hexes 19661696 19661536 19662336))
(edge (id 19674192) (nodes 19674080 19674544))
(edge (id 19674272) (nodes 19673888 19674080))
(edge (id 19674000) (nodes 19673888 19670256))
(edge (id 19670368) (nodes 19670256 19670720))
(edge (id 19674464) (nodes 19674352 19670720))
(edge (id 19674656) (nodes 19674544 19674352))
(hex (id 19661696) (xpos 5) (ypos 4) (resource lumber) (port nil) (number 6) (prob 5))
(node (id 19677712) (hexes 19660896 19661696 19661856))
(node (id 19677520) (hexes 19660896 19660736 19661696))
(settlement (node 19677520) (player 0))
(node (id 19674080) (hexes 19660736 19661536 19661696))
(node (id 19674544) (hexes 19661696 19661536 19662336))
(node (id 19677984) (hexes 19661696 19662336 19662496))
(node (id 19678176) (hexes 19661856 19661696 19662496))
(edge (id 19677824) (nodes 19677712 19678176))
(edge (id 19677904) (nodes 19677520 19677712))
(edge (id 19677632) (nodes 19677520 19674080))
(edge (id 19674192) (nodes 19674080 19674544))
(edge (id 19678096) (nodes 19677984 19674544))
(edge (id 19678288) (nodes 19678176 19677984))
(hex (id 19661856) (xpos 5) (ypos 5) (resource sea) (port 3to1) (number 0) (prob 0))
(node (id 19681344) (hexes 19661056 19661856 0))
(node (id 19681152) (hexes 19661056 19660896 19661856))
(node (id 19677712) (hexes 19660896 19661696 19661856))
(node (id 19678176) (hexes 19661856 19661696 19662496))
(node (id 19681616) (hexes 19661856 19662496 0))
(node (id 19681808) (hexes 0 19661856 0))
(edge (id 19681456) (nodes 19681808 19681344))
(edge (id 19681536) (nodes 19681152 19681344))
(edge (id 19681264) (nodes 19681152 19677712))
(edge (id 19677824) (nodes 19677712 19678176))
(edge (id 19681728) (nodes 19681616 19678176))
(edge (id 19681920) (nodes 19681616 19681808))
(hex (id 19662016) (xpos 6) (ypos 2) (resource sea) (port 3to1) (number 0) (prob 0))
(node (id 19670528) (hexes 19661376 19662016 19662176))
(node (id 19667360) (hexes 19661376 19661216 19662016))
(settlement (node 19667360) (player 1))
(node (id 19667168) (hexes 19661216 0 19662016))
(node (id 19670992) (hexes 19662016 0 0))
(node (id 19671184) (hexes 19662016 0 0))
(node (id 19671376) (hexes 19662176 19662016 0))
(edge (id 19670912) (nodes 19670528 19671376))
(edge (id 19670640) (nodes 19670528 19667360))
(road (edge 19670640) (player 1))
(edge (id 19667472) (nodes 19667360 19667168))
(edge (id 19671104) (nodes 19667168 19670992))
(edge (id 19671296) (nodes 19670992 19671184))
(edge (id 19671488) (nodes 19671184 19671376))
(hex (id 19662176) (xpos 6) (ypos 3) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19674352) (hexes 19661536 19662176 19662336))
(node (id 19670720) (hexes 19661536 19661376 19662176))
(node (id 19670528) (hexes 19661376 19662016 19662176))
(node (id 19671376) (hexes 19662176 19662016 0))
(node (id 19674816) (hexes 19662176 0 0))
(node (id 19675008) (hexes 19662336 19662176 0))
(edge (id 19674736) (nodes 19674352 19675008))
(edge (id 19674464) (nodes 19674352 19670720))
(edge (id 19670832) (nodes 19670720 19670528))
(edge (id 19670912) (nodes 19670528 19671376))
(edge (id 19674928) (nodes 19671376 19674816))
(edge (id 19675120) (nodes 19674816 19675008))
(hex (id 19662336) (xpos 6) (ypos 4) (resource sea) (port brick) (number 0) (prob 0))
(node (id 19677984) (hexes 19661696 19662336 19662496))
(node (id 19674544) (hexes 19661696 19661536 19662336))
(node (id 19674352) (hexes 19661536 19662176 19662336))
(node (id 19675008) (hexes 19662336 19662176 0))
(node (id 19678448) (hexes 19662336 0 0))
(node (id 19678640) (hexes 19662496 19662336 0))
(edge (id 19678368) (nodes 19677984 19678640))
(edge (id 19678096) (nodes 19677984 19674544))
(edge (id 19674656) (nodes 19674544 19674352))
(edge (id 19674736) (nodes 19674352 19675008))
(edge (id 19678560) (nodes 19675008 19678448))
(edge (id 19678752) (nodes 19678448 19678640))
(hex (id 19662496) (xpos 6) (ypos 5) (resource sea) (port nil) (number 0) (prob 0))
(node (id 19681616) (hexes 19661856 19662496 0))
(node (id 19678176) (hexes 19661856 19661696 19662496))
(node (id 19677984) (hexes 19661696 19662336 19662496))
(node (id 19678640) (hexes 19662496 19662336 0))
(node (id 19682080) (hexes 19662496 0 0))
(node (id 19682272) (hexes 0 19662496 0))
(edge (id 19682000) (nodes 19682272 19681616))
(edge (id 19681728) (nodes 19681616 19678176))
(edge (id 19678288) (nodes 19678176 19677984))
(edge (id 19678368) (nodes 19677984 19678640))
(edge (id 19682192) (nodes 19678640 19682080))
(edge (id 19682384) (nodes 19682080 19682272))
(resource-cards (kind brick) (amnt 1))
(resource-cards (kind grain) (amnt 1))
(resource-cards (kind ore) (amnt 0))
(resource-cards (kind wool) (amnt 3))
(resource-cards (kind lumber) (amnt 0))
(bank-cards (kind brick) (amnt 14))
(bank-cards (kind grain) (amnt 13))
(bank-cards (kind ore) (amnt 14))
(bank-cards (kind wool) (amnt 13))
(bank-cards (kind lumber) (amnt 14))
(devel-card (kind road-building) (amnt 0) (can-play 0))
(devel-card (kind monopoly) (amnt 0) (can-play 0))
(devel-card (kind year-of-plenty) (amnt 0) (can-play 0))
(devel-card (kind victory) (amnt 0) (can-play 0))
(devel-card (kind soldier) (amnt 0) (can-play 0))
(player (id 0) (name Computer Dude) (score 2) (num-resource-cards 10) (num-devel-cards 0) (has-largest-army 0) (has-longest-road 0) (num-soldiers 0) (num-cities 0) (num-settlements 2) (num-roads 12))
(player (id 1) (name Checkers) (score 2) (num-resource-cards 3) (num-devel-cards 0) (has-largest-army 0) (has-longest-road 0) (num-soldiers 0) (num-cities 0) (num-settlements 2) (num-roads 12))
(player (id 2) (name alex) (score 2) (num-resource-cards 5) (num-devel-cards 0) (has-largest-army 0) (has-longest-road 0) (num-soldiers 0) (num-cities 0) (num-settlements 2) (num-roads 12))
(player (id 3) (name Coolio) (score 2) (num-resource-cards 9) (num-devel-cards 0) (has-largest-army 0) (has-longest-road 0) (num-soldiers 0) (num-cities 0) (num-settlements 2) (num-roads 12))
(dice-already-rolled)
(num-players 4)
(my-id 2)
(current-player 2)
(num-develop-in-deck 22)