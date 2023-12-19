import std/[strutils, sequtils, syncio]
from strformat import fmt
from sugar import `=>`

const
  #width = 140
  ignored: set[char] = {'.'} + Digits

type
  SearchArea = object
    val: int
    corners: array[2,tuple[y,x:int]]

# Can be accessed as strSeq[y][x]
var strSeq: seq[string] = stdin
                            .readAll()
                            .splitLines()
discard strSeq.pop() # Remove remaining "" from EOF
let width = strSeq[0].len()

proc createSearchArea(strSeq: seq[string], y,x: Natural): SearchArea =
  assert(strSeq[y][x].isDigit, "Passed start for rectangle is not a digit!")
  let a = (y-1, x-1)
  
  var i: int = x
  while i < width and strSeq[y][i].isDigit: inc(i)
  # i increments 1 beyond the last digit
  let b = (y+1, i)
  let val = parseInt(strSeq[y][x..i-1])

  result = SearchArea(val:val, corners: [a,b])

proc isTouchingSymbol(strSeq: seq[string], rect: SearchArea): bool =
  let a = rect.corners[0]
  let b = rect.corners[1]
  result = false
  
  for y in a.y..b.y:
    if y < 0 or y > strSeq.high: continue
    # else
    for x in a.x..b.x:
      if x < 0 or x > strSeq[y].high: continue
      # Cycling through only the perimeters
      if y != (a.y + 1) or x == a.x or x == b.x:
        let ch = strSeq[y][x]
        if ch notin ignored: return true

proc strSliceToInt(str: string, sl: Slice[int]): int =
  let numStr: string = str[sl]
  #echo fmt"parsing {numStr}"
  let parsed = parseInt(numStr)
  #echo fmt"parsed {parsed}"
  return parsed

proc addGearRatio(strSeq: seq[string], gearSum: var int, y,x: int) =
  var adjacent: seq[int]
  var chkArray: array[8,bool]

  if y == 0:
    chkArray[0] = true # Array layout is:
    chkArray[1] = true # 012             
    chkArray[2] = true # 3*4             
  if y == strSeq.high: # 567             
    chkArray[5] = true
    chkArray[6] = true
    chkArray[7] = true
  if x == 0:
    chkArray[0] = true
    chkArray[3] = true
    chkArray[5] = true
  if x == strSeq[0].high:
    chkArray[2] = true
    chkArray[4] = true
    chkArray[7] = true

  # Sides are easier/cleaner, so they go first
  #[L]#
  if not chkArray[3] and strSeq[y][x-1].isDigit:
    var i = x - 1
    var strSlice = i..i
    
    while i >= 0 and strSeq[y][i].isDigit:
      strSlice.a = i
      dec(i)

    let parsed = strSeq[y].strSliceToInt(strSlice)
    adjacent.add(parsed)
    
  #[R]#
  if not chkArray[4] and strSeq[y][x+1].isDigit:
    var i = x + 1
    var strSlice = i..i
    
    while i < width and strSeq[y][i].isDigit:
      strSlice.b = i
      inc(i)

    let parsed = strSeq[y].strSliceToInt(strSlice)
    adjacent.add(parsed)
    
  #[UL]#
  if not chkArray[0] and strSeq[y-1][x-1].isDigit:
    # To the left
    var i = x - 1
    var strSlice = i..i

    while i >= 0 and strSeq[y-1][i].isDigit:
      strSlice.a = i
      dec(i)
      
    # (Not guarateed) search to the right
    if strSeq[y-1][x].isDigit:
      i = x # `i` needs to come back from the left
      chkArray[1] = true # UC
      while i < width and strSeq[y-1][i].isDigit:
        if i == x+1: chkArray[2] = true # UR
        strSlice.b = i
        inc(i)

    let parsed = strSeq[y-1].strSliceToInt(strSlice)
    adjacent.add(parsed)

  #[UC]#
  if not chkArray[1] and strSeq[y-1][x].isDigit:
    # Directly to the right, can now ignore UL
    var i = x
    var strSlice = i..i
    
    if strSeq[y-1][x+1].isDigit:
      chkArray[2] = true # UR
      while i < width and strSeq[y-1][i].isDigit:
        strSlice.b = i
        inc(i)

    let parsed = strSeq[y-1].strSliceToInt(strSlice)
    adjacent.add(parsed)

  #[UR]#
  if not chkArray[2] and strSeq[y-1][x+1].isDigit:
    # Directly to the right, can now ignore UL
    var i = x+1
    var strSlice = i..i
    
    while i < width and strSeq[y-1][i].isDigit:
      strSlice.b = i
      inc(i)

    let parsed = strSeq[y-1].strSliceToInt(strSlice)
    adjacent.add(parsed)

  #[LL]#
  if not chkArray[5] and strSeq[y+1][x-1].isDigit:
    # To the left
    var i = x - 1
    var strSlice = i..i

    while i >= 0 and strSeq[y+1][i].isDigit:
      strSlice.a = i
      dec(i)
      
    # (Not guarateed) search to the right
    if strSeq[y+1][x].isDigit:
      i = x # `i` needs to come back from the left
      chkArray[6] = true # LC
      while i < width and strSeq[y+1][i].isDigit:
        if i == x+1: chkArray[7] = true # UR
        strSlice.b = i
        inc(i)

    let parsed = strSeq[y+1].strSliceToInt(strSlice)
    adjacent.add(parsed)

  #[LC]#
  if not chkArray[6] and strSeq[y+1][x].isDigit:
    var i = x
    var strSlice = i..i
    
    if strSeq[y+1][x+1].isDigit:
      chkArray[7] = true # LR
      while i < width and strSeq[y+1][i].isDigit:
        strSlice.b = i
        inc(i)

    let parsed = strSeq[y+1].strSliceToInt(strSlice)
    adjacent.add(parsed)

  #[LR]#
  if not chkArray[7] and strSeq[y+1][x+1].isDigit:
    var i = x+1
    var strSlice = i..i
    
    while i < width and strSeq[y+1][i].isDigit:
      strSlice.b = i
      inc(i)

    let parsed = strSeq[y+1].strSliceToInt(strSlice)
    adjacent.add(parsed)

  #assert(chkArray.all(b => b), "Not all sides checked!")
  # finally #
  echo fmt"adjacent.len = {adjacent.len}"
  for i, gear in adjacent:
    echo fmt"gear({y},{x}) #{i} = {gear}"

  if adjacent.len == 2: gearSum += adjacent[0] * adjacent[1]

     #[ end of addGearRatio ]#

var rectangleCount, res, gearSum = 0

for y in 0..<len(strSeq):
  var x = 0
  while x < width:
    let ch = strSeq[y][x]

    if ch.isDigit:
      let rect = strSeq.createSearchArea(y,x)

      inc(rectangleCount)
      if strSeq.isTouchingSymbol(rect):
        res += rect.val
        
      x = rect.corners[1].x - 1

    if ch == '*':
      strSeq.addGearRatio(gearSum, y, x)
    inc(x)

echo fmt"Lines = {strSeq.len()}"
echo fmt"Result = {res}"
echo fmt"Rects = {rectangleCount}"
echo fmt"gearSum = {gearSum}"

