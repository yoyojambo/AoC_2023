import strutils, sequtils, sugar, zero_functional
from strformat import fmt

let times = stdin.readLine()[11..^1].split().filter(str => str != "").map(parseInt)
let distances = stdin.readLine()[11..^1].split().filter(str => str != "").map(parseInt)

# echo times
# echo distances
# echo ""

# # Part 1
# var res = 1
# for race in 0..high(times):
#   let time = times[race]
#   let possibilities = toSeq(0..time)
#   let winners = possibilities.filter(
#     hold => distances[race] < (time - hold) * hold
#   )
#   echo fmt"winners = {winners}"
#   res *= winners.len()

# echo fmt"pt1 = {res}"

# Part 2
# let timept2 = times.map(i => $i).foldl(a & b)
# let distancept2 = distances.map(i => $i).foldl(a & b)
let timept2 = times --> map(`$`).fold("", a & it).parseInt
let distancept2 = distances --> map(`$`).fold("", a & it).parseInt
echo fmt"time pt2 = {timept2}"
echo fmt"distance pt2 = {distancept2}"

var a,b = 0
for i in 0..distancept2:
  if distancept2 < (timept2 - i) * i:
    a = i; break;

echo fmt"a = {a}"

for i in countdown(timept2, 0):
  #if i > timept2: continue #overflow
  if distancept2 < (timept2 - i) * i:
    b = i; break;
echo fmt"b = {b}"

let res = b - a + 1

echo fmt"res pt2 = {res}"

