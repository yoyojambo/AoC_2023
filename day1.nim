import std/[strutils, enumerate]

## This program takes through stdin the input, and echoes each line
## with the interpreted hidden number within it. At the end it shows
## the sum as `Result: xxxx`.

## Example usage is `cat inputfile.txt | ./day1`
## or `nim c day1.nim && cat inputfile.txt | ./day1`

const numberStrs = @["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  
proc getSecretNum(str: string): int =
  var a,b: char = '\0' # init both as literal(0)
  var a_i, b_i = -1

  # Get first and last appearing digits
  for i in 0..<len(str):
    let chr = str[i]
    
    if chr.isDigit:
      if a == '\0': (a, a_i) = (chr, i)
      (b, b_i) = (chr, i)

  #[Comment this out for part 1's solution]#
      
  # Enumerate from 1
  for v, spelt in enumerate(1, numberStrs):
    let find_l = str.find(spelt)
    let find_r = str.rfind(spelt)
    
    # Conversion from int to the character representing the number.
    let char_val = char(48 + v)
    
    if find_l != -1 and find_l < a_i:
      (a, a_i) = (char_val, find_l)
    if find_r != -1 and find_r > b_i:
      (b, b_i) = (char_val, find_r)

  #[++++++++++++++++++++++++++++++++++++++++++++++++++++++++]#

  return parseInt(a & b)

var str = newString(10)
var res: int = 0

while stdin.readLine(str):
  let a = getSecretNum(str)
  echo str, "\t", a
  res += a

echo "Result: ", res
