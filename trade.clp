(defrule find-action-that-would-have-executed
    (declare (salience 9000)) ;ITS OVER 9000
    (game-phase consider-quote)
    (action ?action $?)
    ?a <- (dont-do-action)
    =>
    (retract ?a)
    (assert (goal consider-quote)
            (trade-goal ?action)
    )
)

(defrule init-trade
    (declare (salience 2000))
    (goal consider-quote)
    =>
    (assert (trade-commodity (direction they-want) (kind lumber) (amnt 0))
            (trade-commodity (direction they-want) (kind brick) (amnt 0))
            (trade-commodity (direction they-want) (kind grain) (amnt 0))
            (trade-commodity (direction they-want) (kind ore) (amnt 0))
            (trade-commodity (direction they-want) (kind wool) (amnt 0))
            (trade-commodity (direction they-supply) (kind lumber) (amnt 0))
            (trade-commodity (direction they-supply) (kind brick) (amnt 0))
            (trade-commodity (direction they-supply) (kind grain) (amnt 0))
            (trade-commodity (direction they-supply) (kind ore) (amnt 0))
            (trade-commodity (direction they-supply) (kind wool) (amnt 0))
    )
)

(defrule consider-quote-for-building-city
    (declare (salience 1000))
    (goal consider-quote)
    (trade-goal "Build City")
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
    (modify ?w (amnt 1)
            ?s (amnt 1))
)
(defrule consider-quote-for-building-settlement
    (declare (salience 1000))
    (goal consider-quote)
    (trade-goal "Build Settlement")

    (they-supply ?they-supply)
    (resource-cards (kind ?they-supply&lumber|brick|wool|grain) (amnt ?wamnt&:(< ?wamnt 1)))

    (they-want ?they-want)
    (or
        (resource-cards (kind ?they-want&ore) (amnt ?hamnt&:(> ?hamnt 1)))
        (resource-cards (kind ?they-want&~ore) (amnt ?hamnt&:(> ?hamnt 2)))
    )

    ?w <- (trade-commodity (direction they-want) (kind ?they-want))
    ?s <- (trade-commodity (direction they-supply) (kind ?they-supply))
    =>
    (modify ?w (amnt 1)
            ?s (amnt 1))
)
(defrule consider-quote-for-building-road
    (declare (salience 1000))
    (goal consider-quote)
    (trade-goal "Build Road")

    (they-supply ?they-supply&lumber|brick)
    (resource-cards (kind ?they-supply&lumber|brick) (amnt ?wamnt&:(< ?wamnt 1)))

    (they-want ?they-want&wool|grain|ore)
    (or
        (resource-cards (kind ?they-want&wool|grain|ore) (amnt ?hamnt&:(> ?hamnt 1)))
        (resource-cards (kind ?they-want&lumber|brick) (amnt ?hamnt&:(> ?hamnt 1)))
    )

    ?w <- (trade-commodity (direction they-want) (kind ?they-want))
    ?s <- (trade-commodity (direction they-supply) (kind ?they-supply))
    =>
    (modify ?w (amnt 1)
            ?s (amnt 1))
)

(defrule respond-to-quote
    (declare (salience 500))
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
    (assert (action "Quote" " Supply brick " ?wbamnt " grain " ?wgamnt " ore " ?woamnt " wool " ?wwamnt " lumber " ?wlamnt " Receive brick " ?sbamnt " grain " ?sgamnt " ore " ?soamnt " wool " ?swamnt " lumber 0")
)
