

let rec rev n m =
  if n = 0
  then m
  else rev (n - 1) (m + 1)

let main (mn:int(*-:{v:Int | true}*)) =
    if mn > 0 then assert (rev mn 0 >= mn)
	else assert(true)

let _ = main 300