import sequtils, sugar, strutils, zero_functional, algorithm, threadpool
from strformat import fmt

{.experimental: "parallel".}

let seeds = (stdin.readline()[7..^1]).split(" ").map(parseInt)
echo fmt"seeds = {seeds}"

let part2seeds: seq[Slice[int]] = collect:
  var i = 0
  while i < high(seeds):
    let start = seeds[i]
    let length = seeds[i+1]
    inc(i, 2)
    Slice[int](a: start, b:pred(start + length))
echo fmt"seedspt2 = {part2seeds}"

var strSeq = stdin.readAll().splitLines().filter(str => str != "")

type
  mapArr = array[3, int]
  mappingsType = seq[seq[ mapArr ]]

# Build the whole sequence of maps, in order
proc buildMappings(strSeq: seq[string]): mappingsType =
  result = newSeqOfCap[seq[ mapArr ]](7)
  var curMap = newSeqOfCap[ mapArr ](10)
  for s in strSeq:
    if s[0].isDigit:
      let ints: seq[int] = s.split(" ").map(parseInt)
      var arr: mapArr = [0,0,0]
      for i, v in ints: arr[i] = v
      curMap.add(arr)
    else:
      if curMap.len == 0: continue
      result.add(curMap)
      curMap = newSeqOfCap[ mapArr ](10)
  result.add(curMap)
# built

let mapSeq: mappingsType = buildMappings(strSeq)

# For part 2. A smarter bruteforce!
proc reverseMappings(mappings: mappingsType): mappingsType =
  proc reversedSandD(map: mapArr): mapArr = [map[1], map[0], map[2]]

  # Invert order of mappings
  result = mappings.reversed()
  # Invert placement of source and destination
  for mapping in result.mitems():
    mapping.apply(reversedSandD)

proc findDestination(mapping: seq[mapArr], source: int): int =
  result = source # by default, it is mapped to the source number if
                  # not explicitly mapped.
  for arr in mapping:
    let mapDest = arr[0]
    let mapSource = arr[1]
    let mapLength = arr[2]
    let mapRange = mapSource..<(mapSource + mapLength)
    if source in mapRange: return mapDest + (source - mapSource)
  
proc processMap(mapSeq: seq[seq[mapArr]], seed: int): int =
  ## Returns location, given the sequence of mappings and the initial
  ## seed. Crazy stuff.

  var source = seed # First "source" is seed.
  for mapping in mapSeq:
    source = findDestination(mapping, source)
    
  return source # At the end of following all mappings


var res = high(int)

for seed in seeds:
  res = min(mapSeq.processMap(seed), res)
  #if res == 111627841: echo seed
echo fmt"pt1 result = {res}"

# Part 2
let inverseMapSeq = mapSeq.reverseMappings()

proc anyFinalDestination(mappings: mappingsType, destRanges: seq[Slice[int]], source: int): bool =
  let dest = mappings.processMap(source)
  proc destInRange(ran: Slice[int]):bool =
    dest in ran

  destRanges.any(destInRange)

#echo fmt"test = {inverseMapSeq.processMap(111627841)}"

#i = mapSeq.processMap(min(part2seeds.map(sl => sl.a)))
# i = 3000000000
# while not anyFinalDestination(inverseMapSeq, part2seeds, i):
#   if i mod 1000000 == 0: echo fmt"i (progress) {i}"
#   inc(i)

# echo fmt"i = {i}"

proc pt2Brute(mappings: mappingsType, sl: Slice[int]): int =
  result = high(int)
  echo fmt"Starting work on {sl.b - sl.a} iterations ({sl})"

  var i = sl.a
  while i <= sl.b:
    result = min(mappings.processMap(i), result)
    inc(i)
  echo fmt"Range {sl} finished!"
  echo fmt"Result = {result}"
  echo fmt"i = {i}"

var help = newSeq[int](part2seeds.len())
# Total bruteforce but I don't care
parallel:
  for i, seedRange in part2seeds:
    help[i] = spawn pt2Brute(mapSeq, seedRange)
  
echo fmt"pt2 result = {min(help)}"

# proc splitSlice(sl: Slice[int], p: int): seq[Slice[int]] =
#   result = newSeqOfCap(p)
  
