(*
USED: PLDI2011 as mult
USED: PEPM2013 as mult
*)

let rec mult n m =
  if n <= 0 || m <= 0 then
    0
  else
    n + mult n (m - 1)

let main (n:int(*-:{v:Int | true}*)) =
    assert (n <= mult n n)
