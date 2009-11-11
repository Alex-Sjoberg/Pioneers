/* Pioneers - Implementation of the excellent Settlers of Catan board game.
 *   Go buy a copy.
 *
 * Copyright (C) 2003 Bas Wijnen <shevek@fmf.nl>
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

#ifndef _expert_h
#define _expert_h

#include <unistd.h>
#include <assert.h>
#include <sys/signal.h>
#include <sys/wait.h>
#include <sys/errno.h>

typedef void handler_t(int);
handler_t* Signal(int, handler_t*);
void sigchld_handler(int);
void setup_clips(void);
int write_clips(char*);
int close_clips(void);

void Func1(char*);
void Func2(char*);

struct action {
  char* action;
  void (*func)(char*);
};

const char* flag = "ACTION: ";
const struct action actions[] = {
                 /* 0 */   {"Place Robber", &Func1},
                 /* 1 */   {"Build Settlement", &Func2}
                          };
const int nactions = 2;
int fd0[2],fd1[2],cpid;
char buf[4096];

#endif
