import strutils, sequtils, zero_functional, sugar, strformat, algorithm, tables

type
  Hand = array[5, int8]
  HandJoker = distinct Hand

  HandType {.size: 1.} = enum
    HighCard,
    OnePair,
    TwoPair,
    ThreeOAK,
    FullHouse,
    FourOAK,
    FiveOAK

# Part 1
    
proc `<`(x, y: Hand): bool =
  for i in 0..<5:
    if x[i] != y[i]: return x[i] < y[i]

proc toHandAndBid(s: string): (Hand, int) =
  let ss = split(s, ' ')
  var nHand: Hand
  assert(ss[0].len() == 5, "First part isn't a hand!")
  for i, c in ss[0]:
    if c in '2'..'9':
      nHand[i] = c.int8 - 49
    elif c == 'T':
      nHand[i] = 9
    elif c == 'J':
      nHand[i] = 10
    elif c == 'Q':
      nHand[i] = 11
    elif c == 'K':
      nHand[i] = 12
    elif c == 'A':
      nHand[i] = 13
    else: raise new(ObjectConversionDefect)

  #sort(nHand)

  return (nHand, ss[1].parseInt)

# Read and eval input
let Hands2Bids: Table[Hand, int] = toTable(
  stdin.readAll().splitLines().filter(s => s != "").map(toHandAndBid)
)
  
let Hands = Hands2Bids.keys.toSeq

# for i in 0..3:
#   echo fmt"{Hands[i]} : {Hands2Bids[Hands[i]]}"

# echo "------------"

# for k, v in Hands2Bids:
#   echo fmt"({k} : {v})"

proc `+`(a, b: HandType): HandType =
  result = b
  if a == HighCard or b == FiveOAK:
    return b
  elif a == OnePair and b == OnePair:
    return TwoPair
  elif a == ThreeOAK and b == OnePair or
       b == ThreeOAK and a == OnePair:
    return FullHouse

proc getPlay(h: Hand): HandType =
  result = HighCard
  
  var
    c = h[0]     # Card
    count = 0    # Card count
      
  for i, cc in h.sorted:
    if cc == c:
      inc(count)
    if cc != c or i == h.high:
      if count == 2:
        result = result + OnePair
      if count == 3:
        result = result + ThreeOAK
      if count == 4:
        result = result + FourOAK
      if count == 5:
        result = FiveOAK
      # Next cycle it commences the next count
      count = 1
      c = cc

# Part 2
proc CT2Hand(play: CountTable[int8]): Hand =
  ## CountTable to Hand
  var res = newSeqOfCap[int8](5)
  for k, c in play: res.add(repeat(k, c))
  assert(res.len == 5, "Generated hand of more than 5 cards!")
  # O(n) copy to the array
  for i in 0..<5:
    result[i] = res[i]
  sort(result)

proc getPlayWithJoker(h: Hand): HandType =
  var play: CountTable[int8] = h.toCountTable
  if not play.hasKey(10): return getPlay(h) # Guard clause
  
  # Get and delete all jokers
  let jokers = play[10]
  if jokers == 5: return FiveOAK
  play.del(10)
  let (largestOAK, _) = play.largest()
  # Add jokers to count of current biggest OAK
  play.inc(largestOAK, jokers)
  return getPlay(CT2Hand(play))

proc `[]`(h: HandJoker, i: Natural): int8 = cast[Hand](h)[i]
proc `==`(x, y: HandJoker): bool = cast[Hand](x) == cast[Hand](y)
  
proc `<`(x, y: HandJoker): bool =
  for i in 0..<5:
    var a = x[i]
    var b = y[i]
    if a == 10: a = 0
    if b == 10: b = 0
    if a != b: return a < b
  
let rankedpt1 = Hands.mapIt( (it.getPlay, it) ).sorted

let rankedpt2 = Hands.mapIt( (it.getPlayWithJoker, HandJoker(it)) ).sorted()

var res = 0
for i, (p, h) in rankedpt1:
  #echo fmt"[{i}] '{h}' = {p}"
  res += (i+1) * Hands2Bids[h]

echo fmt"Part 1: {res}"

res = 0
for i, (p, h) in rankedpt2:
  #echo fmt"[{i}] '{h}' = {p}"
  res += (i+1) * Hands2Bids[ cast[Hand](h) ]

echo fmt"Part 2: {res}"

# echo "========================"
# for h in Hands:
#   let p = h.getPlay
#   if p == FiveOAK: echo h
# echo Hands[0], Hands[0].foldl(a & $b, "")
# echo Hands[988], Hands[988].foldl(a & $b, "")
