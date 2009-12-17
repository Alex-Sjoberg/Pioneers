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

static int quote_num;

static void expert_turn(void)
{
  setup_clips();
  write_clips("(assert (game-phase do-turn))");
  close_clips();
}

static void expert_place_robber(void)
{
  setup_clips();
  write_clips("(assert (game-phase place-robber))");
  close_clips();
}

static void expert_steal_building(void)
{
  setup_clips();
  write_clips("(assert (game-phase steal-building))");
  close_clips();
}

static void expert_year_of_plenty(const gint bank[NO_RESOURCE])
{

  setup_clips();
  write_clips("(assert (game-phase choose-plenty))");
  close_clips();
}

static void expert_monopoly(void)
{
  setup_clips();
  write_clips("(assert (game-phase choose-monopoly))");
  close_clips();
}

static void expert_discard(int num)
{
  setup_clips();

  write_clips("(assert (game-phase discard))");
  sprintf(buf,"(assert (num-to-discard %d))",num);
  write_clips(buf);

  close_clips();
}

static void expert_quote_start(void)
{
  quote_num = 0;
}

static void expert_consider_quote(G_GNUC_UNUSED gint partner,
				  gint we_receive[NO_RESOURCE],
				  gint we_supply[NO_RESOURCE])
{
  int i;

  setup_clips();
  write_clips("(assert (game-phase consider-quote))");

  for (i = 0; i < NO_RESOURCE; i++) {
    if (we_supply[i]) {
      sprintf(buf, "(assert (they-want %s))", resource_mapping[i]);
      write_clips(buf);
    }
    if (we_receive[i]) {
      sprintf(buf, "(assert (they-supply %s))", resource_mapping[i]);
      write_clips(buf);
    }
  }

  close_clips();
}

static void expert_setup(unsigned num_settlements, unsigned num_roads)
{
  setup_clips();
  write_clips("(assert (game-phase initial-setup))");

  sprintf(buf, "(assert (settlements-to-place %d))", num_settlements);
  write_clips(buf);

  sprintf(buf, "(assert (roads-to-place %d))", num_roads);
  write_clips(buf);

  close_clips();
}

static void expert_roadbuilding(gint num_roads)
{
  setup_clips();
  write_clips("(assert (game-phase road-building))");

  sprintf(buf, "(assert (free-roads %d))", num_roads);
  write_clips(buf);

  close_clips();
}

static void expert_discard_add(gint player_num, gint discard_num)
{
	if (player_num == my_player_num())
		expert_discard(discard_num);
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
	cb_disconnect();
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
	/*callbacks.player_turn = &expert_player_turn;
	callbacks.robber_moved = &expert_robber_moved;
	callbacks.discard = &expert_discard_start;
	callbacks.gold_choose = &expert_gold_choose;
	callbacks.player_robbed = &expert_player_robbed;
	callbacks.get_rolled_resources = &expert_get_rolled_resources;
	callbacks.played_develop = &expert_played_develop;
	callbacks.new_statistics = &expert_new_statistics;
  */

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
  write_clips("(load \"../colden.clp\")");
  write_clips("(load \"../weights.clp\")");

  char fbuf[64];
  sprintf(fbuf, "../temp_facts%d.clp", my_player_num());
  FILE *fp = fopen(fbuf, "w");

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

        fprintf(fp,"(hex (id %lu) (xpos %d) (ypos %d) (resource %s) (port %s) (number %d) (prob %d))\n",(unsigned long) hid,xpos,ypos,resource,port,number,(int) dice_prob[number]);

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

    fprintf(fp, "(player (id %d) (name %s) (score %d) (num-resource-cards %d) (num-devel-cards %d) (has-largest-army %d) (has-longest-road %d) (num-soldiers %d) (num-cities %d) (num-settlements %d) (num-roads %d))\n",
        i,
        player_name(i,0),
        player_get_score(i),
        stats[STAT_RESOURCES],
        stats[STAT_DEVELOPMENT],
        stats[STAT_LARGEST_ARMY],
        stats[STAT_LONGEST_ROAD],
        stats[STAT_SOLDIERS],
        stats[STAT_CITIES],
        stats[STAT_SETTLEMENTS],
        stock_num_roads()
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

  sprintf(buf, "(load-facts \"%s\")", fbuf);
  write_clips(buf);
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

    if (strncmp(buf, "Defining ", 9) != 0
        && strncmp(buf, "=j", 2) != 0
        && strncmp(buf, "+j", 2) != 0
        && strncmp(buf, "CLIPS> ", 7) != 0
        && strncmp(buf, "TRUE", 4) != 0
       )
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

static void play_plenty(char * args) {
  const DevelDeck * deck = get_devel_deck();
  int i;

  for (i = 0; i < deck->num_cards; i++) {
    DevelType cardtype = deck_card_type(deck, i);
    if (cardtype == DEVEL_YEAR_OF_PLENTY) {
      cb_play_develop(i);
      return;
    }
  }
}

static void choose_plenty(char * args) {
  char res1[20];
  char res2[20];
  gint want[NO_RESOURCE];
  int i;

  for (i = 0; i < NO_RESOURCE; i++)
    want[i] = 0;

  sscanf(args, "%s %s", res1, res2);

  for (i = 0; i < NO_RESOURCE; i++) {
    if (strncmp(res1, resource_mapping[i], strlen(resource_mapping[i])) == 0)
      want[i]++;
    if (strncmp(res2, resource_mapping[i], strlen(resource_mapping[i])) == 0)
      want[i]++;
  }

  cb_choose_plenty(want);
}

static void play_monopoly(char * args) {
  const DevelDeck * deck = get_devel_deck();
  int i;

  for (i = 0; i < deck->num_cards; i++) {
    DevelType cardtype = deck_card_type(deck, i);
    if (cardtype == DEVEL_MONOPOLY) {
      cb_play_develop(i);
      return;
    }
  }
}

static void choose_monopoly(char * args) {
  char res[20];
  int i;

  sscanf(args, "%s", res);

  for (i = 0; i < NO_RESOURCE; i++) {
    if (strncmp(res, resource_mapping[i], strlen(resource_mapping[i])) == 0) {
      cb_choose_monopoly(i);
      return;
    }
  }

}


static void play_road_building(char * args) {
  const DevelDeck * deck = get_devel_deck();
  int i;

  for (i = 0; i < deck->num_cards; i++) {
    DevelType cardtype = deck_card_type(deck, i);

    if (cardtype == DEVEL_ROAD_BUILDING) {
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

static void do_quote(char * args) {
  gint give_res[NO_RESOURCE];
  gint take_res[NO_RESOURCE];

  sscanf(args, "Supply brick %d grain %d ore %d wool %d lumber %d Receive brick %d grain %d ore %d wool %d lumber %d", &give_res[0], &give_res[1], &give_res[2], &give_res[3], &give_res[4], &take_res[0], &take_res[1], &take_res[2], &take_res[3], &take_res[4]);

  cb_quote(quote_num++, give_res, take_res);
}

static void reject_quote(char * args) {
  cb_end_quote();
}

static void steal_building(char * args) {
  gint victim;

  sscanf(args, "%d", &victim);

  cb_rob(victim);
}
