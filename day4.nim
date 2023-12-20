import sugar, sequtils, strutils, sets, threadpool
from strformat import fmt

{.experimental: "parallel".}

type
  Card = object
    id: int32
    winners: seq[int8]
    havers: seq[int8]
    points: uint8

const ignore = Whitespace + {'|'} + {':'}    
                                    
proc initCard(str: string): Card =
  assert str.len > 0, "Given empty string."
  # [5..^1] removes "Card "
  var splitStr = str[5..^1].split(ignore).filter(s => s != "")

  let id: int32 = splitStr[0].parseInt().int32
  let winners: seq[int8] = splitStr[1..10].mapIt(int8(parseInt(it)))
  let havers: seq[int8] = splitStr[11..35].mapIt(int8(parseInt(it)))

  result = Card(id: id, winners: winners, havers: havers, points: 0)

# Read all input
var strSeq: seq[string] = readAll(stdin).splitLines()
discard pop(strSeq) #Remove line with EOF
echo repr strSeq[0]

let cardSeq = strSeq.map(initCard)
let winnerSets = cardSeq.map(c => c.winners.toHashSet())
var points = 0

for i, card in cardSeq:
  var thisPoints = 0
  let winnerSet = winnerSets[i]
  
  for num in card.havers:
    if num notin winnerSet: continue
    #else
    thisPoints = thisPoints shl 1 # If it is not 0
    thisPoints = max(thisPoints, 1) # If it is 0

  points += thisPoints
  
echo fmt"points = {points}"

const t = 8 # threads
let unprocessed = cardSeq.distribute(t)
var totalCopiesRes = newSeq[int](t)

proc process(queue: sink seq[Card]): int =
  result = 0
  while len(queue) > 0:                                                     
    let processing = queue.pop()                                            
    let i = processing.id - 1 # Index in cardSeq for it                           
    var copies = 0 # Copies to be created                                         
                                                                                  
    for num in processing.havers:                                                 
      if num notin winnerSets[i]: continue                                        
      inc(copies)                                                                 
                                                                                  
    if copies > 0:                                                                
      if i+1 > high(cardSeq): continue                                            
      let upper = min(high(cardSeq), i+copies)                                    
      queue.add(cardSeq[i+1..upper])                                        
                                                                                  
    inc(result)                                                              


parallel:
  for i in 0..high(unprocessed):
    totalCopiesRes[i] = spawn process(unprocessed[i])
  
echo fmt"TotalCopiesRes (result) = {totalCopiesRes}" 
echo fmt"TotalCopiesRes (result) = {totalCopiesRes.foldl(a + b)}" 


