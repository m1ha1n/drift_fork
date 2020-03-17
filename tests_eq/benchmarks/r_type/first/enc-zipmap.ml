(*
USED: PLDI2011 as l-zipmap
USED: PEPM2013 as l-zipmap
*)
let main n =
  let rec zip x y =
    if x = 0 then
      if y = 0 then
        x
      else
        (assert(false); y)
    else
      if y = 0 then
        (assert(false); x)
      else
        1 + zip (x - 1) (y - 1)
  in

  let rec map x =
    if x = 0 then x else 1 + map (x - 1)
  in
  assert (map (zip n n) = n)
in main 31