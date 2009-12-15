/* Pioneers - Implementation of the excellent Settlers of Catan board game.
 *   Go buy a copy.
 *
 * Copyright (C) 1999 Dave Cole
 * Copyright (C) 2003 Bas Wijnen <shevek@fmf.nl>
 * Copyright (C) 2005 Roland Clobus <rclobus@bigfoot.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "config.h"
#include "ai.h"
#include "cost.h"
#include "expert.h"
#include <stdio.h>
#include <stdlib.h>
/*
 * This is a rudimentary AI for Pioneers. 
 *
 * What it does _NOT_ do:
 *
 * -Make roads explicitly to get the longest road card
 * -Initiate trade with other players
 * -Do anything seafarers
 *
 */

#define DEVEL_CARD 222

typedef struct resource_values_s {
	float value[NO_RESOURCE];
	MaritimeInfo info;
} resource_values_t;

static int quote_num;
/* used to avoid multiple chat messages when more than one other player
 * must discard resources */
static gboolean discard_starting;

/* things we can buy, in the order that we want them. */
static BuildType build_preferences[] = { BUILD_CITY, BUILD_SETTLEMENT,
	BUILD_ROAD, DEVEL_CARD
};

/*
 * Forward declarations
 */
static Edge *best_road_to_road_spot(Node * n, float *score,
				    const resource_values_t * resval);

static Edge *best_road_to_road(const resource_values_t * resval);

static Edge *best_road_spot(const resource_values_t * resval);

static Node *best_city_spot(const resource_values_t * resval);

static Node *best_settlement_spot(gboolean during_setup,
				  const resource_values_t * resval);

static int places_can_build_settlement(void);

/*
 * Functions to keep track of what nodes we've visited
 */

typedef struct node_seen_set_s {

	Node *seen[MAP_SIZE * MAP_SIZE];
	int size;

} node_seen_set_t;

static void nodeset_reset(node_seen_set_t * set)
{
	set->size = 0;
}

static void nodeset_set(node_seen_set_t * set, Node * n)
{
	int i;

	for (i = 0; i < set->size; i++)
		if (set->seen[i] == n)
			return;

	set->seen[set->size] = n;
	set->size++;
}

static int nodeset_isset(node_seen_set_t * set, Node * n)
{
	int i;

	for (i = 0; i < set->size; i++)
		if (set->seen[i] == n)
			return 1;

	return 0;
}

typedef void iterate_node_func_t(Node * n, void *rock);

/*
 * Iterate over all the nodes on the map calling func() with 'rock'
 *
 */
static void for_each_node(iterate_node_func_t * func, void *rock)
{
	Map *map;
	int i, j, k;

	map = callbacks.get_map();
	for (i = 0; i < map->x_size; i++) {
		for (j = 0; j < map->y_size; j++) {
			for (k = 0; k < 6; k++) {
				Node *n = map_node(map, i, j, k);

				if (n)
					func(n, rock);
			}
		}
	}

}

/** Determine the required resources.
 *  @param assets The resources that are available
 *  @param cost   The cost to buy something
 *  @retval need  The additional resources required to buy this
 *  @return TRUE if the assets are enough
 */
static gboolean can_pay_for(const gint assets[NO_RESOURCE],
			    const gint cost[NO_RESOURCE],
			    gint need[NO_RESOURCE])
{
	gint i;
	gboolean have_enough;

	have_enough = TRUE;
	for (i = 0; i < NO_RESOURCE; i++) {
		if (assets[i] >= cost[i])
			need[i] = 0;
		else {
			need[i] = cost[i] - assets[i];
			have_enough = FALSE;
		}
	}
	return have_enough;
}

/* How much does this cost to build? */
static const gint *cost_of(BuildType bt)
{
	switch (bt) {
	case BUILD_CITY:
		return cost_upgrade_settlement();
	case BUILD_SETTLEMENT:
		return cost_settlement();
	case BUILD_ROAD:
		return cost_road();
	case DEVEL_CARD:
		return cost_development();
	default:
		g_assert(0);
		return NULL;
	}
}

/*
 * Do I have the resources to buy this, is it available, and do I want it?
 */
static gboolean should_buy(const gint assets[NO_RESOURCE], BuildType bt,
			   const resource_values_t * resval,
			   gint need[NO_RESOURCE])
{
	if (!can_pay_for(assets, cost_of(bt), need))
		return FALSE;

	switch (bt) {
	case BUILD_CITY:
		return (stock_num_cities() > 0 &&
			best_city_spot(resval) != NULL);
	case BUILD_SETTLEMENT:
		return (stock_num_settlements() > 0 &&
			best_settlement_spot(FALSE, resval) != NULL);
	case BUILD_ROAD:
		/* don't sprawl :) */
		return (stock_num_roads() > 0 &&
			places_can_build_settlement() <= 2 &&
			(best_road_spot(resval) != NULL ||
			 best_road_to_road(resval) != NULL));
	case DEVEL_CARD:
		return (stock_num_develop() > 0 && can_buy_develop());
	default:
		/* xxx bridge, ship */
		return FALSE;
	}
}

/*
 * If I buy this, what will I have left?  Note that some values in need[]
 * can be negative if I can't afford it.
 */
static void leftover_resources(const gint assets[NO_RESOURCE],
			       BuildType bt, gint need[NO_RESOURCE])
{
	gint i;
	const gint *cost = cost_of(bt);

	for (i = 0; i < NO_RESOURCE; i++)
		need[i] = assets[i] - cost[i];
}

/*
 * Probability of a dice roll
 */

static float dice_prob(int roll)
{
	switch (roll) {
	case 2:
	case 12:
		return 1;
	case 3:
	case 11:
		return 2;
	case 4:
	case 10:
		return 3;
	case 5:
	case 9:
		return 4;
	case 6:
	case 8:
		return 5;
	default:
		return 0;
	}
}

/*
 * By default how valuable is this resource?
 */

static float default_score_resource(Resource resource)
{
	float score;

	switch (resource) {
	case GOLD_TERRAIN:	/* gold */
		score = 1.25;
		break;
	case HILL_TERRAIN:	/* brick */
		score = 1.1;
		break;
	case FIELD_TERRAIN:	/* grain */
		score = 1.0;
		break;
	case MOUNTAIN_TERRAIN:	/* rock */
		score = 1.05;
		break;
	case PASTURE_TERRAIN:	/* sheep */
		score = 1.0;
		break;
	case FOREST_TERRAIN:	/* wood */
		score = 1.1;
		break;
	case DESERT_TERRAIN:
	case SEA_TERRAIN:
	default:
		score = 0;
		break;
	}

	return score;
}

/* For each node I own see how much i produce with it. keep a
 * tally with 'produce'
 */

static void reevaluate_iterator(Node * n, void *rock)
{
	float *produce = (float *) rock;

	/* if i own this node */
	if ((n) && (n->owner == my_player_num())) {
		int l;
		for (l = 0; l < 3; l++) {
			Hex *h = n->hexes[l];
			float mult = 1.0;

			if (n->type == BUILD_CITY)
				mult = 2.0;

			if (h && h->terrain < NO_RESOURCE) {
				produce[h->terrain] +=
				    mult *
				    default_score_resource(h->terrain) *
				    dice_prob(h->roll);
			}

		}
	}

}

/*
 * Reevaluate the value of all the resources to us
 */

static void reevaluate_resources(resource_values_t * outval)
{
	float produce[NO_RESOURCE];
	int i;

	for (i = 0; i < NO_RESOURCE; i++) {
		produce[i] = 0;
	}

	for_each_node(&reevaluate_iterator, (void *) produce);

	/* Now invert all the positive numbers and give any zeros a weight of 2
	 *
	 */
	for (i = 0; i < NO_RESOURCE; i++) {
		if (produce[i] == 0) {
			outval->value[i] = default_score_resource(i);
		} else {
			outval->value[i] = 1.0 / produce[i];
		}

	}

	/*
	 * Save the maritime info too so we know if we can do port trades
	 */
	map_maritime_info(callbacks.get_map(), &outval->info,
			  my_player_num());
}


/*
 *
 */
static float resource_value(Resource resource,
			    const resource_values_t * resval)
{
	if (resource < NO_RESOURCE)
		return resval->value[resource];
	else if (resource == GOLD_RESOURCE)
		return default_score_resource(resource);
	else
		return 0.0;
}


/*
 * How valuable is this hex to me?
 */
static float score_hex(Hex * hex, const resource_values_t * resval)
{
	float score;

	if (hex == NULL)
		return 0;

	/* multiple resource value by dice probability */
	score =
	    resource_value(hex->terrain, resval) * dice_prob(hex->roll);

	/* if we don't have a 3 for 1 port yet and this is one it's valuable! */
	if (!resval->info.any_resource) {
		if (hex->resource == ANY_RESOURCE)
			score += 0.5;
	}

	return score;
}

/*
 * How valuable is this hex to others
 */
static float default_score_hex(Hex * hex)
{
	int score;

	if (hex == NULL)
		return 0;

	/* multiple resource value by dice probability */
	score =
	    default_score_resource(hex->terrain) * dice_prob(hex->roll);

	return score;
}

/* 
 * Give a numerical score to how valuable putting a settlement/city on this spot is
 *
 */
static float score_node(Node * node, int city,
			const resource_values_t * resval)
{
	int i;
	float score = 0;

	/* if not a node, how did this happen? */
	g_assert(node != NULL);

	/* if already occupied, in water, or too close to others  give a score of -1 */
	if (is_node_on_land(node) == FALSE)
		return -1;
	if (is_node_spacing_ok(node) == FALSE)
		return -1;
	if (city == 0) {
		if (node->owner != -1)
			return -1;
	}

	for (i = 0; i < 3; i++) {
		score += score_hex(node->hexes[i], resval);
	}

	return score;
}

/*
 * Road connects here
 */
static int road_connects(Node * n)
{
	int i;

	if (n == NULL)
		return 0;

	for (i = 0; i < 3; i++) {
		Edge *e = n->edges[i];

		if ((e) && (e->owner == my_player_num()))
			return 1;
	}

	return 0;
}


/** Find the best spot for a settlement
 * @param during_setup Build a settlement during the setup phase?
 *                     During setup: no connected road is required,
 *                                   and the no_setup must be taken into account
 *                     Normal play:  settlement must be next to a road we own.
 */
static Node *best_settlement_spot(gboolean during_setup,
				  const resource_values_t * resval)
{
	int i, j, k;
	Node *best = NULL;
	float bestscore = -1.0;
	float score;
	Map *map = callbacks.get_map();

	for (i = 0; i < map->x_size; i++) {
		for (j = 0; j < map->y_size; j++) {
			for (k = 0; k < 6; k++) {
				Node *n = map_node(map, i, j, k);
				if (!n)
					continue;
				if (during_setup) {
					if (n->no_setup)
						continue;
				} else {
					if (!road_connects(n))
						continue;
				}

				score = score_node(n, 0, resval);
				if (score > bestscore) {
					best = n;
					bestscore = score;
				}
			}

		}
	}

	return best;
}


/*
 * What is the best settlement to upgrade to a city?
 *
 */
static Node *best_city_spot(const resource_values_t * resval)
{
	int i, j, k;
	Node *best = NULL;
	float bestscore = -1.0;
	Map *map = callbacks.get_map();

	for (i = 0; i < map->x_size; i++) {
		for (j = 0; j < map->y_size; j++) {
			for (k = 0; k < 6; k++) {
				Node *n = map_node(map, i, j, k);
				if (!n)
					continue;
				if ((n->owner == my_player_num())
				    && (n->type == BUILD_SETTLEMENT)) {
					float score =
					    score_node(n, 1, resval);

					if (score > bestscore) {
						best = n;
						bestscore = score;
					}
				}
			}

		}
	}

	return best;
}

/*
 * Return the opposite end of this node, edge
 *
 */
static Node *other_node(Edge * e, Node * n)
{
	if (e->nodes[0] == n)
		return e->nodes[1];
	else
		return e->nodes[0];
}

/*
 *
 *
 */
static Edge *traverse_out(Node * n, node_seen_set_t * set, float *score,
			  const resource_values_t * resval)
{
	float bscore = 0.0;
	Edge *best = NULL;
	int i;

	/* mark this node as seen */
	nodeset_set(set, n);

	for (i = 0; i < 3; i++) {
		Edge *e = n->edges[i];
		Edge *cur_e = NULL;
		Node *othernode;
		float cur_score;

		if (!e)
			continue;

		othernode = other_node(e, n);
		g_assert(othernode != NULL);

		/* if our road traverse it */
		if (e->owner == my_player_num()) {

			if (!nodeset_isset(set, othernode))
				cur_e =
				    traverse_out(othernode, set,
						 &cur_score, resval);

		} else if (can_road_be_built(e, my_player_num())) {

			/* no owner, how good is the other node ? */
			cur_e = e;

			cur_score = score_node(othernode, 0, resval);

			/* umm.. can we build here? */
			/*if (!can_settlement_be_built(othernode, my_player_num ()))
			   cur_e = NULL;       */
		}

		/* is this the best edge we've seen? */
		if ((cur_e != NULL) && (cur_score > bscore)) {
			best = cur_e;
			bscore = cur_score;

		}
	}

	*score = bscore;
	return best;
}

/*
 * Best road to a road
 *
 */
static Edge *best_road_to_road_spot(Node * n, float *score,
				    const resource_values_t * resval)
{
	int bscore = -1.0;
	Edge *best = NULL;
	int i, j;

	for (i = 0; i < 3; i++) {
		Edge *e = n->edges[i];
		if (e) {
			Node *othernode = other_node(e, n);

			if (can_road_be_built(e, my_player_num())) {

				for (j = 0; j < 3; j++) {
					Edge *e2 = othernode->edges[j];
					if (e2 == NULL)
						continue;

					/* We need to look further, temporarily mark this edge as having our road on it. */
					e->owner = my_player_num();
					e->type = BUILD_ROAD;

					if (can_road_be_built
					    (e2, my_player_num())) {
						float score =
						    score_node(other_node
							       (e2,
								othernode),
							       0, resval);

						if (score > bscore) {
							bscore = score;
							best = e;
						}
					}
					/* restore map to its real state */
					e->owner = -1;
					e->type = BUILD_NONE;
				}
			}

		}
	}

	*score = bscore;
	return best;
}

/*
 * Best road to road on whole map
 *
 */
static Edge *best_road_to_road(const resource_values_t * resval)
{
	int i, j, k;
	Edge *best = NULL;
	float bestscore = -1.0;
	Map *map = callbacks.get_map();

	for (i = 0; i < map->x_size; i++) {
		for (j = 0; j < map->y_size; j++) {
			for (k = 0; k < 6; k++) {
				Node *n = map_node(map, i, j, k);
				Edge *e;
				float score;

				if ((n) && (n->owner == my_player_num())) {
					e = best_road_to_road_spot(n,
								   &score,
								   resval);
					if (score > bestscore) {
						best = e;
						bestscore = score;
					}
				}
			}
		}
	}

	return best;
}

/*
 * Best road spot
 *
 */
static Edge *best_road_spot(const resource_values_t * resval)
{
	int i, j, k;
	Edge *best = NULL;
	float bestscore = -1.0;
	node_seen_set_t nodeseen;
	Map *map = callbacks.get_map();

	/*
	 * For every node that we're the owner of traverse out to find the best
	 * node we're one road away from and build that road
	 *
	 *
	 * xxx loops
	 */

	for (i = 0; i < map->x_size; i++) {
		for (j = 0; j < map->y_size; j++) {
			for (k = 0; k < 6; k++) {
				Node *n = map_node(map, i, j, k);

				if ((n != NULL)
				    && (n->owner == my_player_num())) {
					float score = -1.0;
					Edge *e;

					nodeset_reset(&nodeseen);

					e = traverse_out(n, &nodeseen,
							 &score, resval);

					if (score > bestscore) {
						best = e;
						bestscore = score;
					}
				}
			}

		}
	}

	return best;
}


/*
 * Any road at all that's valid for us to build
 */

static void rand_road_iterator(Node * n, void *rock)
{
	int i;
	Edge **out = (Edge **) rock;

	if (n == NULL)
		return;

	for (i = 0; i < 3; i++) {
		Edge *e = n->edges[i];

		if ((e) && (can_road_be_built(e, my_player_num())))
			*out = e;
	}
}

/*
 * Find any road we can legally build
 *
 */
static Edge *find_random_road(void)
{
	Edge *e = NULL;

	for_each_node(&rand_road_iterator, &e);

	return e;
}


static void places_can_build_iterator(Node * n, void *rock)
{
	int *count = (int *) rock;

	if (can_settlement_be_built(n, my_player_num()))
		(*count)++;
}

static int places_can_build_settlement(void)
{
	int count = 0;

	for_each_node(&places_can_build_iterator, (void *) &count);

	return count;
}

/*
 * How many resource cards does player have?
 *
 */
static int num_assets(gint assets[NO_RESOURCE])
{
	int i;
	int count = 0;

	for (i = 0; i < NO_RESOURCE; i++) {
		count += assets[i];
	}

	return count;
}

static int player_get_num_resource(int player)
{
	return player_get(player)->statistics[STAT_RESOURCES];
}

/*
 * Does this resource list contain one element? If so return it
 * otherwise return NO_RESOURCE
 */
static int which_one(gint assets[NO_RESOURCE])
{
	int i;
	int res = NO_RESOURCE;
	int tot = 0;

	for (i = 0; i < NO_RESOURCE; i++) {

		if (assets[i] > 0) {
			tot += assets[i];
			res = i;
		}
	}

	if (tot == 1)
		return res;

	return NO_RESOURCE;
}

/*
 * Does this resource list contain just one kind of element? If so return it
 * otherwise return NO_RESOURCE
 */
static int which_resource(gint assets[NO_RESOURCE])
{
	int i;
	int res = NO_RESOURCE;
	int n_nonzero = 0;

	for (i = 0; i < NO_RESOURCE; i++) {

		if (assets[i] > 0) {
			n_nonzero++;
			res = i;
		}
	}

	if (n_nonzero == 1)
		return res;

	return NO_RESOURCE;
}

/*
 * What resource do we want the most?
 *
 * NOTE: If a resource is not available (players or bank), the
 * resval->value[resource] should be zero.
 */
static int resource_desire(gint assets[NO_RESOURCE],
			   const resource_values_t * resval)
{
	int i;
	int res = NO_RESOURCE;
	float value = 0.0;
	gint need[NO_RESOURCE];

	/* do i need just 1 more for something? */
	for (i = 0; i < G_N_ELEMENTS(build_preferences); i++) {
		if (should_buy(assets, build_preferences[i], resval, need))
			continue;
		res = which_one(need);
		if (res == NO_RESOURCE || resval->value[res] == 0)
			continue;
		return res;
	}

	/* desire the one we don't produce the most */
	res = NO_RESOURCE;
	for (i = 0; i < NO_RESOURCE; i++) {
		if ((resval->value[i] > value) && (assets[i] < 2)) {
			res = i;
			value = resval->value[i];
		}
	}

	return res;
}


static void findit_iterator(Node * n, void *rock)
{
	Node **node = (Node **) rock;
	int i;

	if (!n)
		return;
	if (n->owner != my_player_num())
		return;

	/* if i own this node */
	for (i = 0; i < 3; i++) {
		if (n->edges[i] == NULL)
			continue;
		if (n->edges[i]->owner == my_player_num())
			return;
	}

	*node = n;
}


/* Find the settlement with no roads yet
 *
 */

static Node *void_settlement(void)
{
	Node *ret = NULL;

	for_each_node(&findit_iterator, (void *) &ret);

	return ret;
}

/*
 * Game setup
 * Build one house and one road
 */
static void expert_setup_house(void)
{
	Node *node;
	resource_values_t resval;

	reevaluate_resources(&resval);

	if (stock_num_settlements() == 0) {
		ai_panic(N_("No settlements in stock to use for setup"));
		return;
	}

	node = best_settlement_spot(TRUE, &resval);

	if (node == NULL) {
		ai_panic(N_("There is no place to setup a settlement"));
		return;
	}

	/*node_add(player, BUILD_SETTLEMENT, node->x, node->y, node->pos, FALSE); */
	cb_build_settlement(node);
}


/*
 * Game setup
 * Build one house and one road
 */
static void expert_setup_road(void)
{
	Node *node;
	Edge *e = NULL;
	int i;
	resource_values_t resval;
	float tmp;

	reevaluate_resources(&resval);

	if (stock_num_roads() == 0) {
		ai_panic(N_("No roads in stock to use for setup"));
		return;
	}

	node = void_settlement();

	e = best_road_to_road_spot(node, &tmp, &resval);

	/* if didn't find one just pick one randomly */
	if (e == NULL) {
		for (i = 0; i < G_N_ELEMENTS(node->edges); i++) {
			if (is_edge_on_land(node->edges[i])) {
				e = node->edges[i];
				break;
			}
		}
		if (e == NULL) {
			ai_panic(N_("There is no place to setup a road"));
			return;
		}
	}

	cb_build_road(e);
}

/*
 * Determine if there are any trades that I can do which will give me
 * enough to buy something.
 */
static gboolean find_optimal_trade(gint assets[NO_RESOURCE],
				   const resource_values_t * resval,
				   gint ports[NO_RESOURCE],
				   gint * amount,
				   Resource * trade_away,
				   Resource * want_resource)
{
	int i;
	Resource res = NO_RESOURCE;
	Resource temp;
	gint need[NO_RESOURCE];
	BuildType bt = BUILD_NONE;

	for (i = 0; i < G_N_ELEMENTS(build_preferences); i++) {
		bt = build_preferences[i];

		/* If we should buy something, why haven't we bought it? */
		if (should_buy(assets, bt, resval, need))
			continue;

		/* See what we need, and if we can get it. */
		res = which_one(need);
		if (res == NO_RESOURCE || get_bank()[res] == 0)
			continue;

		/* See what we have left after we buy this (one value
		 * will be negative), and whether we have enough of something
		 * to trade for what's missing.
		 */
		leftover_resources(assets, bt, need);
		for (temp = 0; temp < NO_RESOURCE; temp++) {
			if (temp == res)
				continue;
			if (need[temp] > ports[temp]) {
				*amount = ports[temp];
				*trade_away = temp;
				*want_resource = res;
				return TRUE;
			}
		}
	}
	return FALSE;
}

/** I am allowed to do a maritime trade, but will I do it?
 * @param assets The resources I already have
 * @param resval The value of the resources
 * @retval amount The amount to trade
 * @retval trade_away The resource to trade away
 * @retval want_resource The resource I want to have
 * @return TRUE if I want to do the trade
 */
static gboolean will_do_maritime_trade(gint assets[NO_RESOURCE],
				       const resource_values_t * resval,
				       gint * amount,
				       Resource * trade_away,
				       Resource * want_resource)
{
	MaritimeInfo info;
	Resource res, want, discard;
	gint ports[NO_RESOURCE];

	map_maritime_info(callbacks.get_map(), &info, my_player_num());

	for (res = 0; res < NO_RESOURCE; res++) {
		if (info.specific_resource[res])
			ports[res] = 2;
		else if (info.any_resource)
			ports[res] = 3;
		else
			ports[res] = 4;
	}

	/* See if we can trade at all. */
	for (res = 0; res < NO_RESOURCE; res++) {
		if (assets[res] >= ports[res])
			break;
	}
	if (res == NO_RESOURCE)
		return FALSE;

	/* See if we can do a single trade that allows us to buy something. */
	if (find_optimal_trade(assets, resval, ports, amount, trade_away,
			       want_resource))
		return TRUE;

	/*
	 * We can trade, but we won't be able to buy anything.
	 *
	 * Try a simple heuristic - if there's a resource we can trade away
	 * and still have at least 1 left, and we need something (and we can
	 * get it), do the trade.  Try to use the best port for this.
	 */
	want = resource_desire(assets, resval);
	if (want == NO_RESOURCE || get_bank()[want] == 0)
		return FALSE;

	discard = NO_RESOURCE;
	for (res = 0; res < NO_RESOURCE; res++) {
		if (res == want)
			continue;
		if (assets[res] > ports[res] &&
		    (discard == NO_RESOURCE
		     || ports[discard] > ports[res]))
			discard = res;
	}

	if (discard != NO_RESOURCE) {
		*trade_away = discard;
		*want_resource = want;
		*amount = ports[discard];
		return TRUE;
	}

	return FALSE;
}

/** I can play the card, but will I do it?
 *  @param cardtype The type of card to consider
 *  @return TRUE if the card is to be played
 */
static gboolean will_play_development_card(DevelType cardtype)
{
	gint amount, cards, i;

	if (is_victory_card(cardtype)) {
		return TRUE;
	}

	switch (cardtype) {
	case DEVEL_SOLDIER:
		return TRUE;
	case DEVEL_YEAR_OF_PLENTY:
		/* only when the bank is full enough */
		amount = 0;
		for (i = 0; i < NO_RESOURCE; i++)
			amount += get_bank()[i];
		if (amount >= 2) {
			return TRUE;
		}
		break;
	case DEVEL_ROAD_BUILDING:
		/* don't if don't have two roads left */
		if (stock_num_roads() < 2)
			break;
		return TRUE;
	case DEVEL_MONOPOLY:
		/* don't unless there are enough cards out */
		for (i = 0, cards = 0; i < num_players(); i++)
			if (i != my_player_num())
				cards += player_get_num_resource(i);
		if (cards >= 6)
			return TRUE;
		break;
	default:
		break;
	}
	return FALSE;
}

/*
 * What to do? what to do?
 *
 */

static void expert_turn(void)
{
  setup_clips();
  write_clips("(assert (game-phase do-turn))");
  close_clips();
#if 0
	resource_values_t resval;
	int i;
	gint need[NO_RESOURCE], assets[NO_RESOURCE];

	if (!have_rolled_dice()) {
		cb_roll();
		return;
	}

	/* Don't wait before the dice roll, that will take too long */
	ai_wait();
	for (i = 0; i < NO_RESOURCE; ++i)
		assets[i] = resource_asset(i);

	reevaluate_resources(&resval);

	/* if can then buy city */
	if (should_buy(assets, BUILD_CITY, &resval, need)) {

		Node *n = best_city_spot(&resval);
		if (n != NULL) {
			cb_build_city(n);
			return;
		}
	}

	/* if can then buy settlement */
	if (should_buy(assets, BUILD_SETTLEMENT, &resval, need)) {

		Node *n = best_settlement_spot(FALSE, &resval);
		if (n != NULL) {
			cb_build_settlement(n);
			return;
		}

	}

	if (should_buy(assets, BUILD_ROAD, &resval, need)) {

		Edge *e = best_road_spot(&resval);

		if (e == NULL) {
			e = best_road_to_road(&resval);
		}

		if (e != NULL) {
			cb_build_road(e);
			return;
		}
	}

	/* if we can buy a development card and there are some left */
	if (should_buy(assets, DEVEL_CARD, &resval, need)) {
		cb_buy_develop();
		return;
	}

	/* if we have a lot of cards see if we can trade anything */
	if (num_assets(assets) >= 3) {
		if (can_trade_maritime()) {
			gint amount;
			Resource trade_away, want_resource;
			if (will_do_maritime_trade
			    (assets, &resval, &amount, &trade_away,
			     &want_resource)) {
				cb_maritime(amount, trade_away,
					    want_resource);
				return;
			}
		}
	}

	/* play development cards */
	if (can_play_any_develop()) {
		const DevelDeck *deck = get_devel_deck();
		gint num_victory_cards = 0;
		gint victory_point_target, my_points;

		for (i = 0; i < deck->num_cards; i++) {
			DevelType cardtype = deck_card_type(deck, i);

			/* if it's a vp card, note this for later */
			if (is_victory_card(cardtype)) {
				num_victory_cards++;
				continue;
			}

			/* can't play card we just bought */
			if (can_play_develop(i)) {
				if (will_play_development_card(cardtype)) {
					cb_play_develop(i);
					return;
				}
			}
		}

		/* if we have enough victory cards to win, then play them */
		victory_point_target = game_victory_points();
		my_points = player_get_score(my_player_num());
		if (num_victory_cards + my_points >= victory_point_target) {
			for (i = 0; i < deck->num_cards; i++) {
				DevelType cardtype =
				    deck_card_type(deck, i);

				if (is_victory_card(cardtype)) {
					cb_play_develop(i);
					return;
				}
			}
		}
	}
	cb_end_turn();
#endif
}

#define randchat(array,nochat_percent)				\
	do {							\
		int p = (G_N_ELEMENTS(array)*1000/nochat_percent);	\
		int n = (rand() % p) / 10;			\
		if (n < G_N_ELEMENTS(array) )			\
			ai_chat (array[n]);			\
	} while(0)

static const char *chat_turn_start[] = {
	N_("Ok, let's go!"),
	N_("I'll beat you all now! ;)"),
	N_("Now for another try..."),
};

static const char *chat_receive_one[] = {
	N_("At least I get something..."),
	N_("One is better than none..."),
};

static const char *chat_receive_many[] = {
	N_("Wow!"),
	N_("Ey, I'm becoming rich ;)"),
	N_("This is really a good year!"),
};
static const char *chat_other_receive_many[] = {
	N_("You really don't deserve that much!"),
	N_("You don't know what to do with that many resources ;)"),
	N_("Ey, wait for my robber and lose all this again!"),
};
static const char *chat_self_moved_robber[] = {
	N_("Hehe!"),
	N_("Go, robber, go!"),
};
static const char *chat_moved_robber_to_me[] = {
	N_("You bastard!"),
	N_("Can't you move that robber somewhere else?!"),
	N_("Why always me??"),
};
static const char *chat_discard_self[] = {
	N_("Oh no!"),
	N_("Grrr!"),
	N_("Who the hell rolled that 7??"),
	N_("Why always me?!?"),
};
static const char *chat_discard_other[] = {
	N_("Say good bye to your cards... :)"),
	N_("*evilgrin*"),
	N_("/me says farewell to your cards ;)"),
	N_("That's the price for being rich... :)"),
};
static const char *chat_stole_from_me[] = {
	N_("Ey! Where's that card gone?"),
	N_("Thieves! Thieves!!"),
	N_("Wait for my revenge..."),
};
static const char *chat_monopoly_other[] = {
	N_("Oh no :("),
	N_("Must this happen NOW??"),
	N_("Args"),
};
static const char *chat_largestarmy_self[] = {
	N_("Hehe, my soldiers rule!"),
};
static const char *chat_largestarmy_other[] = {
	N_("First robbing us, then grabbing the points..."),
};
static const char *chat_longestroad_self[] = {
	N_("See that road!"),
};
static const char *chat_longestroad_other[] = {
	N_("Pf, you won't win with roads alone..."),
};

static float score_node_hurt_opponents(Node * node)
{
	/* no building there */
	if (node->owner == -1)
		return 0;

	/* do I have a house there? */
	if (my_player_num() == node->owner) {
		if (node->type == BUILD_SETTLEMENT) {
			return -2.0;
		} else {
			return -3.5;
		}
	}

	/* opponent has house there */
	if (node->type == BUILD_SETTLEMENT) {
		return 1.5;
	} else {
		return 2.5;
	}
}

/*
 * How much does putting the robber here hurt my opponents?
 */
static float score_hex_hurt_opponents(Hex * hex)
{
	int i;
	float score = 0;

	if (hex == NULL)
		return -1000;

	/* don't move the pirate. */
	if (!can_robber_or_pirate_be_moved(hex)
	    || hex->terrain == SEA_TERRAIN)
		return -1000;

	for (i = 0; i < 6; i++) {
		score += score_node_hurt_opponents(hex->nodes[i]);
	}

	/* multiply by resource/roll value */
	score *= default_score_hex(hex);

	return score;
}

/*
 * Find the best (worst for opponents) place to put the robber
 *
 */
static void expert_place_robber(void)
{
	int i, j;
	float bestscore = -1000;

  setup_clips();
  write_clips("(assert (game-phase place-robber))");
  close_clips();
}

static void expert_steal_building(void)
{
	int i;
	int victim = -1;
	int victim_resources = -1;
	Hex *hex = map_robber_hex(callbacks.get_map());

	/* which opponent to steal from */
	for (i = 0; i < 6; i++) {
		int numres = 0;

		/* if has owner (and isn't me) */
		if ((hex->nodes[i]->owner != -1) &&
		    (hex->nodes[i]->owner != my_player_num())) {

			numres =
			    player_get_num_resource(hex->nodes[i]->owner);
		}

		if (numres > victim_resources) {
			victim = hex->nodes[i]->owner;
			victim_resources = numres;
		}
	}
	cb_rob(victim);
	randchat(chat_self_moved_robber, 15);
}

/*
 * A devel card game us two free roads. let's build them
 *
 */

static void expert_free_road(void)
{
	Edge *e;
	resource_values_t resval;

	reevaluate_resources(&resval);

	e = best_road_spot(&resval);

	if (e == NULL) {
		e = best_road_to_road(&resval);
	}

	if (e == NULL) {
		e = find_random_road();
	}

	if (e != NULL) {

		cb_build_road(e);
		return;

	} else {
		log_message(MSG_ERROR,
			    "unable to find spot to build free road\n");
		cb_disconnect();
	}
}

/*
 * We played a year of plenty card. pick the two resources we most need
 */

static void expert_year_of_plenty(const gint bank[NO_RESOURCE])
{
	gint want[NO_RESOURCE];
	gint assets[NO_RESOURCE];
	int i;
	int r1, r2;
	resource_values_t resval;

	ai_wait();
	for (i = 0; i < NO_RESOURCE; i++) {
		want[i] = 0;
		assets[i] = resource_asset(i);
	}

	/* what two resources do we desire most */
	reevaluate_resources(&resval);

	r1 = resource_desire(assets, &resval);

	/* If we don't desire anything anymore, ask for a road.
	 * This happens if we have at least 2 of each resource
	 */
	if (r1 == NO_RESOURCE)
		r1 = BRICK_RESOURCE;

	assets[r1]++;

	reevaluate_resources(&resval);

	r2 = resource_desire(assets, &resval);

	if (r2 == NO_RESOURCE)
		r2 = LUMBER_RESOURCE;

	assets[r1]--;

	/* If we want something that is not in the bank, request something else */
	/* WARNING: This code can cause a lockup if the bank is empty, but
	 * then the year of plenty must not have been playable */
	while (bank[r1] < 1)
		r1 = (r1 + 1) % NO_RESOURCE;
	while (bank[r2] < (r1 == r2 ? 2 : 1))
		r2 = (r2 + 1) % NO_RESOURCE;

	want[r1]++;
	want[r2]++;

	cb_choose_plenty(want);
}

/*
 * We played a monopoly card.  Pick a resource
 */

static gint other_players_have(Resource res)
{
	return game_resources() - get_bank()[res] - resource_asset(res);
}

static void expert_monopoly(void)
{
	gint assets[NO_RESOURCE];
	int i;
	int r, best;
	resource_values_t resval;

	ai_wait();
	for (i = 0; i < NO_RESOURCE; i++)
		assets[i] = resource_asset(i);

	/* order resources by preference */
	reevaluate_resources(&resval);

	/* try to get something we need */
	while (TRUE) {
		r = resource_desire(assets, &resval);
		if (r == NO_RESOURCE)
			break;
		if (other_players_have(r) > 0) {
			cb_choose_monopoly(r);
			return;
		}
		resval.value[r] = 0;
	}

	/* there's nothing we really need, so get what we can get most of. */
	best = 0;
	for (r = 1; r < NO_RESOURCE; r++) {
		if (other_players_have(r) > other_players_have(best))
			best = r;
	}
	cb_choose_monopoly(best);
}


/*
 * Of these resources which is least valuable to us
 *
 * Get rid of the one we have the most of
 * if there's a tie let resource_values_t settle it
 */

static int least_valuable(gint assets[NO_RESOURCE],
			  resource_values_t * resval)
{
	int ret = NO_RESOURCE;
	int res;
	int most = 0;
	float mostval = -1;

	for (res = 0; res < NO_RESOURCE; res++) {
		if (assets[res] > most) {
			if (resval->value[res] > mostval) {
				ret = res;
				most = assets[res];
				mostval = resval->value[res];
			}
		}
	}

	return ret;
}

/*
 * Which resource do we desire the least?
 */

static int resource_desire_least(gint my_assets[NO_RESOURCE],
				 resource_values_t * resval)
{
	int i;
	int res;
	gint assets[NO_RESOURCE];
	gint need[NO_RESOURCE];
	int leastval;

	/* make copy of what we got */
	for (res = 0; res != NO_RESOURCE; res++) {
		assets[res] = my_assets[res];
	}

	/* eliminate things we need to build stuff */
	for (i = 0; i < G_N_ELEMENTS(build_preferences); i++) {
		BuildType bt = build_preferences[i];
		if (should_buy(assets, bt, resval, need)) {
			cost_buy(cost_of(bt), assets);
		}
	}

	/* of what's left what do do we care for least */
	leastval = least_valuable(assets, resval);
	if (leastval != NO_RESOURCE)
		return leastval;

	/* otherwise least valuable of what we have in total */
	leastval = least_valuable(my_assets, resval);
	if (leastval != NO_RESOURCE)
		return leastval;

	/* last resort just pick something */
	for (res = 0; res < NO_RESOURCE; res++) {
		if (my_assets[res] > 0)
			return res;
	}

	/* Should never get here */
	g_assert_not_reached();
	return 0;
}


/*
 * A seven was rolled. we need to discard some resources :(
 *
 */
static void expert_discard(int num)
{
  setup_clips();

  write_clips("(assert (game-phase discard))");
  sprintf(buf,"(assert (num-to-discard %d))",num);
  write_clips(buf);

  close_clips();
}

/*
 * Domestic Trade
 *
 */
static int quote_next_num(void)
{
	return quote_num++;
}

static void expert_quote_start(void)
{
	quote_num = 0;
}

static int trade_desired(gint assets[NO_RESOURCE], gint give, gint take,
			 gboolean free_offer)
{
	int i, n;
	int res = NO_RESOURCE;
	resource_values_t resval;
	float value = 0.0;
	gint need[NO_RESOURCE];

	if (!free_offer) {
		/* don't give away cards we have only once */
		if (assets[give] <= 1) {
			return 0;
		}

		/* make it as if we don't have what we're trading away */
		assets[give] -= 1;
	}

	for (n = 1; n <= 3; ++n) {
		/* do i need something more for something? */
		if (!should_buy(assets, BUILD_CITY, &resval, need)) {
			if ((res = which_resource(need)) == take
			    && need[res] == n)
				break;
		}
		if (!should_buy(assets, BUILD_SETTLEMENT, &resval, need)) {
			if ((res = which_resource(need)) == take
			    && need[res] == n)
				break;
		}
		if (!should_buy(assets, BUILD_ROAD, &resval, need)) {
			if ((res = which_resource(need)) == take
			    && need[res] == n)
				break;
		}
		if (!should_buy(assets, DEVEL_CARD, &resval, need)) {
			if ((res = which_resource(need)) == take
			    && need[res] == n)
				break;
		}
	}
	if (!free_offer)
		assets[give] += 1;
	if (n <= 3)
		return n;

	/* desire the one we don't produce the most */
	reevaluate_resources(&resval);
	for (i = 0; i < NO_RESOURCE; i++) {
		if ((resval.value[i] > value) && (assets[i] < 2)) {
			res = i;
			value = resval.value[i];
		}
	}

	if (res == take && assets[give] > 2) {
		return 1;
	}

	return 0;
}

static void expert_consider_quote(G_GNUC_UNUSED gint partner,
				  gint we_receive[NO_RESOURCE],
				  gint we_supply[NO_RESOURCE])
{
	gint give, take, ntake;
	gint give_res[NO_RESOURCE], take_res[NO_RESOURCE],
	    my_assets[NO_RESOURCE];
	gint i;
	gboolean free_offer;

	free_offer = TRUE;
	for (i = 0; i < NO_RESOURCE; ++i) {
		my_assets[i] = resource_asset(i);
		free_offer &= we_supply[i] == 0;
	}

	for (give = 0; give < NO_RESOURCE; give++) {
		/* A free offer is always accepted */
		if (!free_offer) {
			if (we_supply[give] == 0)
				continue;
			if (my_assets[give] == 0)
				continue;
		}
		for (take = 0; take < NO_RESOURCE; take++) {
			/* Don't do stupid offers */
			if (!free_offer && take == give)
				continue;
			if (we_receive[take] == 0)
				continue;
			if ((ntake =
			     trade_desired(my_assets, give, take,
					   free_offer)) > 0)
				goto doquote;
		}
	}

	/* Do not decline anything for free, just take it all */
	if (free_offer) {
		cb_quote(quote_next_num(), we_supply, we_receive);
		log_message(MSG_INFO, "Taking the whole free offer.\n");
		return;
	}

	log_message(MSG_INFO, _("Rejecting trade.\n"));
	cb_end_quote();
	return;

      doquote:
	for (i = 0; i < NO_RESOURCE; ++i) {
		give_res[i] = (give == i && !free_offer) ? 1 : 0;
		take_res[i] = take == i ? ntake : 0;
	}
	cb_quote(quote_next_num(), give_res, take_res);
	log_message(MSG_INFO, "Quoting.\n");
}

static void expert_setup(unsigned num_settlements, unsigned num_roads)
{
	ai_wait();

  setup_clips();
  write_clips("(assert (game-phase initial-setup))");

  sprintf(buf, "(assert (settlements-to-place %d))", num_settlements);
  write_clips(buf);

  sprintf(buf, "(assert (roads-to-place %d))", num_roads);
  write_clips(buf);

  close_clips();
  /*
   if (num_settlements > 0)
		expert_setup_house();
	else if (num_roads > 0)
		expert_setup_road();
	else
		cb_end_turn();
    */
}

static void expert_roadbuilding(gint num_roads)
{
	ai_wait();
	if (num_roads > 0)
		expert_free_road();
	else
		cb_end_turn();
}

static void expert_discard_start(void)
{
	discard_starting = TRUE;
}

static void expert_discard_add(gint player_num, gint discard_num)
{
	if (player_num == my_player_num()) {
		randchat(chat_discard_self, 10);
		ai_wait();
		expert_discard(discard_num);
	} else {
		if (discard_starting) {
			discard_starting = FALSE;
			randchat(chat_discard_other, 10);
		}
	}
}

static void expert_gold_choose(gint gold_num, const gint * bank)
{
	resource_values_t resval;
	gint assets[NO_RESOURCE];
	gint want[NO_RESOURCE];
	gint my_bank[NO_RESOURCE];
	gint i;
	int r1;

	for (i = 0; i < NO_RESOURCE; i++) {
		want[i] = 0;
		assets[i] = resource_asset(i);
		my_bank[i] = bank[i];
	}

	for (i = 0; i < gold_num; i++) {
		reevaluate_resources(&resval);

		r1 = resource_desire(assets, &resval);
		/* If we don't want anything, start emptying the bank */
		if (r1 == NO_RESOURCE) {
			r1 = 0;
			/* Potential deadlock, but bank is always full enough */
			while (my_bank[r1] == 0)
				r1++;
		}
		want[r1]++;
		assets[r1]++;
		my_bank[r1]--;
	}
	cb_choose_gold(want);

}

static void expert_error(const gchar * message)
{
	gchar *buffer;

	buffer =
	    g_strdup_printf(_(""
			      "Received error from server: %s.  Quitting\n"),
			    message);
	cb_chat(buffer);
	g_free(buffer);
	cb_disconnect();
}

static void expert_game_over(gint player_num, G_GNUC_UNUSED gint points)
{
	if (player_num == my_player_num())
		ai_chat(N_("Yippie!"));
	else
		ai_chat(N_("My congratulations"));
	cb_disconnect();
}

/* functions for chatting follow */
static void expert_player_turn(gint player)
{
	if (player == my_player_num())
		randchat(chat_turn_start, 70);
}

static void expert_robber_moved(G_GNUC_UNUSED Hex * old, Hex * new)
{
	int idx;
	gboolean iam_affected = FALSE;
	for (idx = 0; idx < G_N_ELEMENTS(new->nodes); idx++) {
		if (new->nodes[idx]->owner == my_player_num())
			iam_affected = TRUE;
	}
	if (iam_affected)
		randchat(chat_moved_robber_to_me, 20);
}

static void expert_player_robbed(G_GNUC_UNUSED gint robber_num,
				 gint victim_num,
				 G_GNUC_UNUSED Resource resource)
{
	if (victim_num == my_player_num())
		randchat(chat_stole_from_me, 15);
}

static void expert_get_rolled_resources(gint player_num,
					const gint * resources,
					G_GNUC_UNUSED const gint * wanted)
{
	gint total = 0, i;
	for (i = 0; i < NO_RESOURCE; ++i)
		total += resources[i];
	if (player_num == my_player_num()) {
		if (total == 1)
			randchat(chat_receive_one, 60);
		else if (total >= 3)
			randchat(chat_receive_many, 20);
	} else if (total >= 3)
		randchat(chat_other_receive_many, 30);
}

static void expert_played_develop(gint player_num,
				  G_GNUC_UNUSED gint card_idx,
				  DevelType type)
{
	if (player_num != my_player_num() && type == DEVEL_MONOPOLY)
		randchat(chat_monopoly_other, 20);
}

static void expert_new_statistics(gint player_num, StatisticType type,
				  gint num)
{
	if (num != 1)
		return;
	if (type == STAT_LONGEST_ROAD) {
		if (player_num == my_player_num())
			randchat(chat_longestroad_self, 10);
		else
			randchat(chat_longestroad_other, 10);
	} else if (type == STAT_LARGEST_ARMY) {
		if (player_num == my_player_num())
			randchat(chat_largestarmy_self, 10);
		else
			randchat(chat_largestarmy_other, 10);
	}
}

// aoeu
void expert_init(G_GNUC_UNUSED int argc, G_GNUC_UNUSED char **argv)
{
	callbacks.setup = &expert_setup;
	callbacks.turn = &expert_turn;
	callbacks.robber = &expert_place_robber;
	callbacks.steal_building = &expert_steal_building;
	callbacks.roadbuilding = &expert_roadbuilding;
	callbacks.plenty = &expert_year_of_plenty;
	callbacks.monopoly = &expert_monopoly;
	callbacks.discard_add = &expert_discard_add;
	callbacks.quote_start = &expert_quote_start;
	callbacks.quote = &expert_consider_quote;
	callbacks.game_over = &expert_game_over;
	callbacks.error = &expert_error;

	/* chatting */
	callbacks.player_turn = &expert_player_turn;
	callbacks.robber_moved = &expert_robber_moved;
	callbacks.discard = &expert_discard_start;
	callbacks.gold_choose = &expert_gold_choose;
	callbacks.player_robbed = &expert_player_robbed;
	callbacks.get_rolled_resources = &expert_get_rolled_resources;
	callbacks.played_develop = &expert_played_develop;
	callbacks.new_statistics = &expert_new_statistics;

  /* signal handling */
  Signal(SIGCHLD, sigchld_handler);
}

/*
 * Signal - wrapper for the sigaction function
 */
handler_t *Signal(int signum, handler_t *handler)
{
  struct sigaction action, old_action;

  action.sa_handler = handler;
  sigemptyset(&action.sa_mask); /* block sigs of type being handled */
  action.sa_flags = SA_RESTART; /* restart syscalls if possible */

  if (sigaction(signum, &action, &old_action) < 0) {
    fprintf(stderr,"Signal error: %s\n", strerror(errno));
    exit(1);
  }
  return (old_action.sa_handler);
}


void sigchld_handler(int signal) {
  pid_t pid;
  int status;

  // Reap as many children as possible
  while ((pid = waitpid(-1, &status, WNOHANG)) > 0);

  // If waitpid did not error, return now
  if (pid != -1)
    return;

  // Check for errors other than ECHILD and EINTR
  if (errno != ECHILD && errno != EINTR)
    fprintf(stderr,"sigchld_handler: waitpid error: %s\n", strerror(errno));
}











/*
 * setup_clips(void)
 *
 * Creates the CLIPS environment and the I/O descriptors to CLIPS
 */
void setup_clips(void)
{
  int pid, nread;
  int err;

  err = pipe(fd0);
  if (err < 0) {
    fprintf(stderr,"Error! Could not setup pipe [fd0]\n");
    exit(-1);
  }

  err = pipe(fd1);
  if (err < 0) {
    fprintf(stderr,"Error! Could not setup pipe [fd1]\n");
    exit(-1);
  }

  if (!(cpid = fork())) {
    /* setup the input to clips */
    close(fd0[1]);
    dup2(fd0[0],0);
    close(fd0[0]);

    /* setup the output from clips */
    close(fd1[0]);
    dup2(fd1[1],1);
    close(fd1[1]);

    execlp("clips", "clips", (char*) NULL);
  }

  close(fd0[0]);

  /**********************************
  * CLIPS initialization goes here! *
  **********************************/

  /* Load any external files needed */
  write_clips("(load \"../colden2.clp\")");

  FILE *fp = fopen("../temp_facts2.clp", "w");

  /* Output the board state */
  Map * map = callbacks.get_map();

  Hex * hid;
  Node * nid;
  Edge * eid;
  int i,j,k,xpos,ypos,number,robber,facing;
  const char * resource;
  const char * port;
  char buf[512];
  for (i=0; i<map->x_size; i++) {
    for (j=0; j<map->y_size; j++) {
      if (map->grid[i][j] != NULL) {
        /* Information about each hex */
        hid = map->grid[i][j];
        xpos = i;
        ypos = j;
        resource = resource_mapping[hid->terrain];
        port = port_mapping[hid->resource];
        number = hid->roll;
        robber = hid->robber;

        fprintf(fp,"(hex (id %lu) (xpos %d) (ypos %d) (resource %s) (port %s) (number %d) (prob %d))\n",(unsigned long) hid,xpos,ypos,resource,port,number,(int) dice_prob(number));

        if (hid->robber)
          fprintf(fp, "(robber (hex %lu))\n", (unsigned long) hid);

        /* Information about each node */
        for (k = 0; k < 6; k++) {
          nid = hid->nodes[k];
          fprintf(fp, "(node (id %lu) (hexes %lu %lu %lu))\n", (unsigned long) nid, (unsigned long) nid->hexes[0], (unsigned long) nid->hexes[1], (unsigned long) nid->hexes[2]);

          /* Building information */
          if (nid->owner != -1)
            switch (nid->type) {
              case BUILD_SETTLEMENT:
                fprintf(fp, "(settlement (node %lu) (player %d))\n", (unsigned long) nid, nid->owner);
                break;
              case BUILD_CITY:
                fprintf(fp, "(city (node %lu) (player %d))\n", (unsigned long) nid, nid->owner);
                break;
              default:;
            }
        }

        /* Information about each edge */
        for (k = 0; k < 6; k++) {
          eid = hid->edges[k];
          fprintf(fp, "(edge (id %lu) (nodes %lu %lu))\n", (unsigned long) eid, (unsigned long) eid->nodes[0], (unsigned long) eid->nodes[1]);

          if (eid->owner != -1) {
            fprintf(fp, "(road (edge %lu) (player %d))\n", (unsigned long) eid, eid->owner);
          }
        }
      }
    }
  }

  /* Resource cards */
	for (i = 0; i < NO_RESOURCE; i++)
    fprintf(fp, "(resource-cards (kind %s) (amnt %d))\n", resource_mapping[i], resource_asset(i));

  /* Bank cards */
	for (i = 0; i < NO_RESOURCE; i++)
    fprintf(fp, "(bank-cards (kind %s) (amnt %d))\n", resource_mapping[i], get_bank()[i]);

  /* Development cards */
  const DevelDeck * deck = get_devel_deck();
  int devels[5][2] = { {0,0}, {0,0}, {0,0}, {0,0}, {0,0} };
  for (i = 0; i < deck->num_cards; i++) {
    int j;
    switch (deck->cards[i].type) {
      case DEVEL_CHAPEL:
      case DEVEL_UNIVERSITY:
      case DEVEL_GOVERNORS_HOUSE:
      case DEVEL_LIBRARY:
      case DEVEL_MARKET:
        j = 3;
        break;
      case DEVEL_SOLDIER:
        j = 4;
        break;
      default:
        j = deck->cards[i].type;
    }
    devels[j][0]++;
    devels[j][1] |= can_play_develop(i);
  }

  for (i = 0; i < 5; i++)
    fprintf(fp, "(devel-card (kind %s) (amnt %d) (can-play %d))\n", devel_mapping[i], devels[i][0], devels[i][1]);


  /* Output the player information */
  for (i = 0; i < num_players(); i++) {
    gint * stats = player_get(i)->statistics;

    fprintf(fp, "(player (id %d) (name %s) (score %d) (num-resource-cards %d) (num-devel-cards %d) (has-largest-army %d) (has-longest-road %d) (num-soldiers %d) (num-settlements %d) (num-cities %d))\n",
        i,
        player_name(i,0),
        player_get_score(i),
        stats[STAT_RESOURCES],
        stats[STAT_DEVELOPMENT],
        stats[STAT_LARGEST_ARMY],
        stats[STAT_LONGEST_ROAD],
        stats[STAT_SOLDIERS],
        stats[STAT_SETTLEMENTS],
        stats[STAT_CITIES]
        );
  }


  /* Miscellaneous information deffacts */

  /* Have the dice been rolled? */
  if (have_rolled_dice())
    fprintf(fp, "(dice-already-rolled)\n", buf);

  /* Number of players */
  fprintf(fp, "(num-players %d)\n", num_players());

  /* My player number */
  fprintf(fp, "(my-id %d)\n", my_player_num());

  /* ID of current player */
  fprintf(fp, "(current-player %d)\n", current_player());

  /* How many development cards are in the deck? */
  fprintf(fp, "(num-develop-in-deck %d)\n", stock_num_develop());

  /* END CLIPS INITIALIZATION */


  fclose(fp);
  write_clips("(reset)");
  write_clips("(load-facts \"../temp_facts2.clp\")");
}

/*
 * write_clips(char * message)
 *
 * Outputs a given message to the CLIPS environment
 *
 * Return value: Number of bytes written to CLIPS. If negative, then
 *   an error has occurred.
 */
int write_clips(char * message) {
  /* write to  fd0[1]
   * read from fd1[0]
   */
  int len = strlen(message);
  int r;
  char * buf = NULL;

  /* append a newline to the command if needed */
  if (message[len-1] != '\n') {
    buf = malloc(++len+1);

    strncpy(buf, message, len);
    buf[len-1] = '\n';
    buf[len] = 0;

    message = buf;
  }

  /* send the command to CLIPS */
  fprintf(stderr," > %s",message);
  r = write(fd0[1],message,len);

  if (buf)
    free(buf);

  return r;
}

/*
 * close_clips(void)
 *
 * Reads all input from the CLIPS environment, looking for special
 * output. When this output is encountered, it is parsed, and the
 * appropriate function is called.
 *
 * Return value: 0 if successful, -1 otherwise.
 */
int close_clips(void) {
  int i, nread, actlen;
  int flen = strlen(flag);
  int nactions = sizeof(actions)/sizeof(struct action);
  char * pch;

  write_clips("(run)");
  write_clips("(exit)");

  close(fd0[1]);
  close(fd1[1]);

  /* read all the output from clips */
  while (nread = get_line(buf, sizeof(buf), fd1[0])) {

    buf[nread-1] = 0; // chomp the newline

    fprintf(stderr," < %s\n",buf);

    /* if the line starts with the special code */
    if (!strncmp(buf, flag, flen)) {

      /* go through the functions looking for its match */
      for (i = 0; i < nactions; i++) {

        /* call the appropriate function, passing in the rest of the sting */
        actlen = strlen(actions[i].action);
        if (!strncmp(buf+flen, actions[i].action, actlen)) {
          (*actions[i].func)(buf+flen+actlen+1);
          close(fd1[0]);
          return;
        }
      }
    }
  }

  close(fd1[0]);
}

/*
 * get_line(char * buf, int size, int fd)
 *
 * Retrieve a single line of text from file descriptor fd, including
 * the newline but not including the NUL character, up to a maximum
 * of size bytes, and storing the result in buf.
 *
 * Return value: Number of bytes actually read from fd.
 */
size_t get_line(char * buf, int size, int fd) {
  size_t n = 0;
  while (read(fd, buf, 1) && --size > 0 && *(buf++) != '\n') n++;
  if (*(--buf) == '\n') n++;
  return n;
}



/**************************************************
 ************** CLIPS Input Handlers  *************
 *************************************************/
static void place_robber(char * args) {
  unsigned long besthex;

  sscanf(args, "%lu", &besthex);
  cb_place_robber((Hex*) besthex);
}

static void discard(char * args) {
  int i, len;
  char * pch;
  gint todiscard[NO_RESOURCE];

  // Initialize the resource count
  for (i = 0; i < NO_RESOURCE; i++)
    todiscard[i] = 0;

  // Parse each resource
  pch = strtok(args, " ");
  while (pch != NULL) {
    len = strlen(pch);

    // Reverse-lookup the index
    for (i = 0; i < NO_RESOURCE && strncmp(pch, resource_mapping[i], len) != 0; i++);

    if (i == NO_RESOURCE) {
      fprintf(stderr, "ERROR! \"%.*s\" is not a valid resource!\n", len, pch);
      exit(-1);
    }

    // Add one to the ones to discard
    todiscard[i]++;

    pch = strtok(NULL, " ");
  }

  cb_discard(todiscard);
}

static void build_settlement(char * args) {
  unsigned long node;

  sscanf(args, "%lu", &node);

  cb_build_settlement((Node*) node);
}

static void build_city(char * args) {
  unsigned long node;

  sscanf(args, "%lu", &node);

  cb_build_city((Node*) node);
}

static void build_road(char * args) {
  unsigned long edge;

  sscanf(args, "%lu", &edge);

  cb_build_road((Edge*) edge);
}

static void end_turn(char * args) {
  cb_end_turn();
}

static void roll_dice(char * args) {
  cb_roll();
}

static void buy_develop(char * args) {
  cb_buy_develop();
}

static void play_soldier(char * args) {
  const DevelDeck * deck = get_devel_deck();
  int i;

  for (i = 0; i < deck->num_cards; i++) {
    DevelType cardtype = deck_card_type(deck, i);

    if (cardtype == DEVEL_SOLDIER) {
      cb_play_develop(i);
      return;
    }
  }
}

static void play_victory(char * args) {
  const DevelDeck * deck = get_devel_deck();
  int i;

  for (i = 0; i < deck->num_cards; i++) {
    DevelType cardtype = deck_card_type(deck, i);

    if (cardtype == DEVEL_CHAPEL ||
        cardtype == DEVEL_UNIVERSITY ||
        cardtype == DEVEL_GOVERNORS_HOUSE ||
        cardtype == DEVEL_LIBRARY ||
        cardtype == DEVEL_MARKET) {
      cb_play_develop(i);
      return;
    }
  }
}

static void maritime_trade(char * args) {
  int i, num, ntrade, nget;
  char trade_res[20];
  char get_res[20];

  sscanf(args, "%d %s %s", &num, trade_res, get_res);

  for (i = 0; i < NO_RESOURCE; i++) {
    if (strncmp(trade_res, resource_mapping[i], strlen(resource_mapping[i])) == 0)
      ntrade = i;
    if (strncmp(get_res, resource_mapping[i], strlen(resource_mapping[i])) == 0)
      nget = i;
  }

  cb_maritime(num, ntrade, nget);
}
