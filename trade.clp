;(defrule find-action-that-would-have-executed
;    (declare (salience 2000))
;    (game-phase consider-quote)
;    (action ?action $?)
;    (dont-do-action)
;    ?g <- (goal ?goal)
;    =>
;    (retract ?g)
;    (assert (goal consider-quote)
;            (trade-goal ?action)
;    )
;)

(defrule find-free-offers
    (declare (salience 1000))
    (game-phase consider-quote)
    (they-supply ?they-supply)
    (not (they-want ?want))
    =>
    (assert (add-to-supply ?they-supply))
)

(defrule add-to-free-supply
    (declare (salience 1000))
    (game-phase consider-quote)
    ?a <- (add-to-supply ?they-supply)
    ?s <- (trade-commodity (direction they-supply) (kind ?they-supply))
    =>
    (retract ?a)
    (modify ?s (amnt 1))
)

(defrule accept-free-quotes
    (declare (salience 500))
    (game-phase consider-quote)
    (not (they-want ?))
    =>
    (assert (goal consider-quote)
            (offer-quote))
)


;If we don't have the resources fr a city and theyre offering city resources and wanting either
;or city resources we have more than enough of, offer them a 1-1 trade for those resources
(defrule consider-quote-for-building-city
    (goal consider-quote)
    (trade-goal build-city)
    (they-supply ?they-supply)
    (or
        (resource-cards (kind ?they-supply&ore) (amnt ?wamnt&:(< ?wamnt 3)))
        (resource-cards (kind ?they-supply&grain) (amnt ?wamnt&:(< ?wamnt 2)))
    )
    (they-want ?they-want)
    (or
        (resource-cards (kind ?they-want&wool|lumber|brick) (amnt ?hamnt&:(>= ?hamnt 1)))
        (resource-cards (kind ?they-want&ore) (amnt ?hamnt&:(> ?hamnt 3)))
        (resource-cards (kind ?they-want&grain) (amnt ?hamnt&:(> ?hamnt 2)))
    )
    ?w <- (trade-commodity (direction they-want) (kind ?they-want))
    ?s <- (trade-commodity (direction they-supply) (kind ?they-supply))
    =>
    (modify ?w (amnt 1))
    (modify ?s (amnt 1))
    (assert (offer-quote))
)


(defrule consider-quote-for-building-settlement
    (goal consider-quote)
    (trade-goal build-settlement)

    (they-supply ?they-supply&lumber|brick|wool|grain)
    (resource-cards (kind ?they-supply) (amnt 0))

    (they-want ?they-want)
    (or
        (resource-cards (kind ?they-want&ore) (amnt ?hamnt&:(>= ?hamnt 1)))
        (resource-cards (kind ?they-want&~ore) (amnt ?hamnt&:(>= ?hamnt 2)))
    )

    ?w <- (trade-commodity (direction they-want) (kind ?they-want))
    ?s <- (trade-commodity (direction they-supply) (kind ?they-supply))
    =>
    (modify ?w (amnt 1))
    (modify ?s (amnt 1))
    (assert (offer-quote))
    (agenda)
)


(defrule consider-quote-for-building-road
    (goal consider-quote)
    (trade-goal build-road)

    (they-supply ?they-supply&lumber|brick)
    (resource-cards (kind ?they-supply) (amnt 0))

    (they-want ?they-want)
    (or
        (resource-cards (kind ?they-want&~brick&~lumber) (amnt ?hamnt&:(>= ?hamnt 1)))
        (resource-cards (kind ?they-want&brick|lumber) (amnt ?hamnt&:(>= ?hamnt 2)))
    )

    ?w <- (trade-commodity (direction they-want) (kind ?they-want))
    ?s <- (trade-commodity (direction they-supply) (kind ?they-supply))
    =>
    (modify ?w (amnt 1))
    (modify ?s (amnt 1))
    (assert (offer-quote))
)

(defrule consider-quote-for-buying-development-card
    (goal consider-quote)
    (trade-goal buy-development-card)

    (they-supply ?they-supply&ore|grain|wool)
    (resource-cards (kind ?they-supply) (amnt 0))

    (they-want ?they-want)
    (or
        (resource-cards (kind ?they-want&~ore&~grain&~wool) (amnt ?hamnt&:(>= ?hamnt 1)))
        (resource-cards (kind ?they-want&ore|grain|wool) (amnt ?hamnt&:(>= ?hamnt 2)))
    )

    ?w <- (trade-commodity (direction they-want) (kind ?they-want))
    ?s <- (trade-commodity (direction they-supply) (kind ?they-supply))
    =>
    (modify ?w (amnt 1))
    (modify ?s (amnt 1))
    (assert (offer-quote))
)

(defrule respond-to-quote
    (declare (salience 1000))
    (goal consider-quote)
    (offer-quote)
    (trade-commodity (direction they-want) (kind brick) (amnt ?wbamnt))
    (trade-commodity (direction they-want) (kind grain) (amnt ?wgamnt))
    (trade-commodity (direction they-want) (kind ore) (amnt ?woamnt))
    (trade-commodity (direction they-want) (kind wool) (amnt ?wwamnt))
    (trade-commodity (direction they-want) (kind lumber) (amnt ?wlamnt))
    (trade-commodity (direction they-supply) (kind brick) (amnt ?sbamnt))
    (trade-commodity (direction they-supply) (kind grain) (amnt ?sgamnt))
    (trade-commodity (direction they-supply) (kind ore) (amnt ?soamnt))
    (trade-commodity (direction they-supply) (kind wool) (amnt ?swamnt))
    (trade-commodity (direction they-supply) (kind lumber) (amnt ?slamnt))
    =>
    (assert (action "Quote" Supply brick ?wbamnt grain ?wgamnt ore ?woamnt wool ?wwamnt lumber ?wlamnt Receive brick ?sbamnt grain ?sgamnt ore ?soamnt wool ?swamnt lumber ?slamnt))
)

(defrule reject-trade
    (declare (salience -10))
    (goal consider-quote)
    (not (offer-quote))
    =>
    (assert (action "Reject Quote"))
)
