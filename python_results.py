#python_results.py
#parses the results of the server dump

import re

parse_regex = re.compile('player (.{1,20}?) won', re.DOTALL)
infile = open('server_dump.txt', 'r')
instring = infile.read()
winlist = parse_regex.findall(instring)

print winlist

windict = {}
for player in winlist:
    if player not in windict.keys():
        windict[player] = 1
    else:
        windict[player] = windict[player] + 1

print "PLAYER WINS"
print "-" * 20
for player in windict.keys():
    print player, windict[player]

win_percentage = float(windict["alex"]) / float(len(winlist)) * 100.0
print "OUR WIN PERCENTAGE: ", win_percentage, "%"
