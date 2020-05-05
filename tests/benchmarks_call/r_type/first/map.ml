

let rec map x = (* x <= 3000 *)
  if x = 0
  then 0
  else 1 + map (x - 1) (* x < 0 && 0 < x <= 3000 *)

let main_p (n:int) =
    if n >= 0 then assert (map n = n)
    else ()

let main (w:unit) =
	let _ = main_p 30 in
(* let _ = 
    for i = 1 to 1000000 do
      main (Random.int 1000)
    done *)
	()

let _ = main ()
