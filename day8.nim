import strutils, sequtils, tables, sugar, strformat

type Node = array[3, char]

proc toNode(s: string): Node =
  assert(s.len == 3, "String is not a Node!")
  for i, c in s: result[i] = c

let instructions = stdin.readLine()

discard stdin.readLine()

type mappingType = Table[Node, tuple[L: Node, R: Node]]

proc createMappings(s: string): mappingType =
  for line in s.splitLines():
    if line == "": continue
    let des = line[0..2].toNode()                      # Described mapping
    let dir = (line[7..9].toNode, line[12..14].toNode) # Mapped directions
    result[des] = dir


let mappings = stdin.readAll.createMappings()

echo fmt"Mappings={mappings.len}"
# Part 1
echo "Part 1:"

var
  i, count = 0
  cur: Node = ['A','A','A']

while cur != ['Z','Z','Z']:
  let
    d = instructions[i]
    map = mappings[cur]
  if d == 'L': cur = map.L
  if d == 'R': cur = map.R
  inc(count)
  inc(i); if i == instructions.len: i = 0 # Increment or reset to cycle around

echo count

# Part 2
echo "Part 2:"
let ghostPaths = mappings.keys.toSeq.filter(s => s[2] == 'A')
echo "GhostPaths: ", ghostPaths

proc getPeriodToZ(n: Node): int =
  ## Returns the period to the end of the cycle (a Node with a 'Z' at the end)
  ## It is basically the code for part 1
  var
    i, count = 0
    cur: Node = n

  while cur[2] != 'Z':
    let d = instructions[i]
    let map = mappings[cur]
    if d == 'L': cur = map.L
    if d == 'R': cur = map.R
      
    inc(count)
    # Increment or reset to cycle around
    inc(i)
    if i == instructions.len: i = 0

  return count

let periods = ghostPaths.map(getPeriodToZ)
echo fmt"periods={periods}"

# Euclidean algorithm taken from
# `https://rosettacode.org/wiki/Greatest_common_divisor#Recursive_Euclid_algorithm_6`
proc getGCD(a,b: int): int =
  var a = a
  var b = b
  while b != 0:
    a = a mod b
    swap(a,b)
  return abs(a)  

let LCM = periods.foldl((a * b) div getGCD(a,b))

echo fmt"LCM={LCM}"
