(*
let rec gib a b n =
  if n=0 then a
  else if n=1 then b
  else gib a b (n-1) + gib a b (n-2)

let main n =
  assert (gib 0 1 n >= 0)
*)

let rec gib a b n =
  if n=0 then a
  else if n=1 then b
  else gib a b (n-1) + gib a b (n-2)

let main (n:int(*-:{v:Int | true}*)) (a:int(*-:{v:Int | true}*)) (b:int(*-:{v:Int | true}*)) = 
	if a >= 0 && b >= 0 && n >= 0 then
		assert(gib 0 1 n >= 0)