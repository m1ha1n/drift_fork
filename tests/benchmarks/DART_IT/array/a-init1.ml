(*
USED: PLDI2011 as a-init
*)


let rec init idx tn (ia: int array) =
  if idx < 0 then init 0 tn ia
  else if idx >= tn then ()
    else (Array.set ia idx 1; init (idx + 1) tn ia)

let main (k(*-:{v:Int | true}*)) (n(*-:{v:Int | true}*)) (i(*-:{v:Int | true}*)) =
    if i >= k && i >= 0 && i < n then
        (let a = Array.make n 0 in
        init k n a;
        let item = Array.get a i in
        assert(item >= 1))
    else ()

