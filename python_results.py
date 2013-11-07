#python_results.py
#parses the results of the server dump

import re

parse_regex = re.compile('player (.{1,20}?) won', re.DOTALL)
infile = open('server_dump.txt', 'r') #open server dump file
instring = infile.read()
winlist = parse_regex.findall(instring) #get all the players

print winlist

windict = {}
#count all of the wins for each player
for player in winlist:
    if player not in windict.keys():
        windict[player] = 1
    else:
        windict[player] = windict[player] + 1

print "PLAYER WINS"
print "-" * 20
#print out the number of wins for each play
for player in windict.keys():
    print player, windict[player]

#print our win pecentage of our AI
win_percentage = float(windict["alex"]) / float(len(winlist)) * 100.0
print "OUR WIN PERCENTAGE: ", win_percentage, "%"
