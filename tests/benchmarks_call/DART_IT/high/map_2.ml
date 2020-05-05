

let rec map1 (f1: int -> int) x1 =
  if x1 <= 0
  then x1
  else x1 + (f1 (map1 f1 (x1 - 1)))

let rec map2 (f2: int -> int) x2 =
  if x2 <= 0
  then x2
  else x2 + (f2 (map2 f2 (x2 - 1)))

let id ix = ix

let succ sx = sx + 1

let main_p (n:int) =
	if n > 0 then
		assert(map1 id n >= n)
	else
    let m = 0 - n in
    assert(map2 succ m >= 2 * m)

let main (w:unit) =
	let _ = main_p 4 in
    let _ = main_p 12 in
    let _ = main_p (-20) in
(* let _ = 
    for i = 1 to 1000000 do
      main (Random.int 1000)
    done *)
	()

let _ = main ()
