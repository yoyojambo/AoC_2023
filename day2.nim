import std/[strutils, sequtils, sugar]

const
  red = 12
  green = 13
  blue = 14

var str = newString(10)
var i = 1
var res, power = 0

while stdin.readLine(str):
  echo str
  # Eliminate "Game XX:"  
  str = str[find(str, ": ")+2..high(str)]

  var r,g,b = 0
  var val = 0

  # Splits by both ',' and ';'.
  let onlyValues = str
                  .split({',', ';'} + Whitespace)
                  .filter(x => x != "")

  for el in onlyValues:
    if el[0].isDigit:
      val = parseInt(el)
      continue
      
    case el[0]
    of 'r':
      r = max(r, val)
    of 'g':
      g = max(g, val)
    of 'b':
      b = max(b, val)
    else:
      echo "Se obtuvo ", el[0]
      doAssert(false, "No deberia de llegarse aqui!")

  if r > red or g > green or b > blue: echo "Descartado!"
  else:
    echo "Valido!"
    res += i

  # Only change for part 2
  power += (r * g * b)

  inc(i)

echo "Result: ", res
echo "Power: ", power
