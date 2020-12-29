## Hash functions based on flatty, hash any nested object.

import flatty, hashes

export Hash

proc hash*(x: Hash): Hash = x

{.push overflowChecks: off.}

proc ryan64nim*(p: pointer, len: int): int =
  let
    bytes = cast[ptr UncheckedArray[uint8]](p)
    ints = cast[ptr UncheckedArray[int]](p)
    intSize = sizeof(int)
  var h: Hash
  for i in 0 ..< len div intSize:
    let c = ints[i]
    h = h !& c.hash()
  let last = (len div intSize) * intSize
  for i in 0 ..< last + len mod intSize:
    let c = bytes[i].int
    h = h !& c.hash()
  result = !$h

proc ryan64sdbm*(p: pointer, len: int): int =
  let
    bytes = cast[ptr UncheckedArray[uint8]](p)
    ints = cast[ptr UncheckedArray[int]](p)
    intSize = sizeof(int)
  for i in 0 ..< len div intSize:
    let c = ints[i]
    result = c + (result shl 6) + (result shl 16) - result
  let last = (len div intSize) * intSize
  for i in 0 ..< last + len mod intSize:
    let c = bytes[i].int
    result = c + (result shl 6) + (result shl 16) - result

proc sdbm*(p: pointer, len: int): int =
  let bytes = cast[ptr UncheckedArray[uint8]](p)
  for i in 0 ..< len:
    let c = bytes[i].int
    result = c.int + (result shl 6) + (result shl 16) - result

proc sdbm*(s: string): int =
  for c in s:
    result = c.int + (result shl 6) + (result shl 16) - result

proc ryan64djb2*(p: pointer, len: int): int =
  result = 53810036436437415.int # Usually 5381
  let
    bytes = cast[ptr UncheckedArray[uint8]](p)
    ints = cast[ptr UncheckedArray[int]](p)
    intSize = sizeof(int)
  for i in 0 ..< len div intSize:
    let c = ints[i]
    result = result * 33 + c
  let last = (len div intSize) * intSize
  for i in 0 ..< last + len mod intSize:
    let c = bytes[i].int
    result = result * 33 + c

proc djb2*(p: pointer, len: int): int =
  result = 53810036436437415.int # Usually 5381
  let bytes = cast[ptr UncheckedArray[uint8]](p)
  for i in 0 ..< len:
    let c = bytes[i].int
    result = result * 33 + c.int

proc djb2*(s: string): int =
  result = 53810036436437415.int # Usually 5381
  for c in s:
    result = result * 33 + c.int

proc hashy*[T](x: T): Hash =
  ## Takes structures and turns them into binary string.
  let s = x.toFlatty()
  ryan64djb2(s[0].unsafeAddr, s.len)

{.pop.}
