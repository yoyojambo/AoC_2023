import strutils, sequtils, sugar, strformat, zero_functional

type RecordType = seq[int]

# Ultra easy processing!!
let records: seq[RecordType] = stdin.readAll().splitLines()[0..^2].map(s => s.split(' ').map(parseInt))

proc getDifferences(s: RecordType): RecordType =
  result = newSeqOfCap[int](s.high) # One fewer element.
  for i in 0..<s.high: # From first to second-to-last.
    result.add(s[i+1] - s[i])


proc createLayers(s: RecordType): seq[RecordType] =
  result = @[s]
  while result[^1].any(i => i != 0):
    result.add(result[^1].getDifferences())


proc extrapolate(a: var RecordType, b: RecordType) =
  ## Extrapolates *and adds* next value in
  ## record ``a`` based on record ``b``.
  a.add(a[^1] + b[^1])


proc extrapolate(layers: seq[RecordType]): seq[RecordType] =
  result = layers
  for i in countdown(layers.high-1, 0):
    result[i].extrapolate(result[i+1])


proc extrapolateBackwards(a: var RecordType, b: RecordType) =
  ## Extrapolates backwards *and adds* next value in
  ## record ``a`` based on record ``b``.
  a.insert(a[0] - b[0])


proc extrapolateBackwards(layers: seq[RecordType]): seq[RecordType] =
  result = layers
  for i in countdown(layers.high-1, 0):
    result[i].extrapolateBackwards(result[i+1])


let layered = records.map(createLayers)

let extrapolated = layered.map(extrapolate)
let extrapolatedBackwards = layered.map(extrapolateBackwards)

echo fmt"res={foldl(extrapolated, a + b[0][^1], 0)}"
echo fmt"resPart2={foldl(extrapolatedBackwards, a + b[0][0], 0)}"


