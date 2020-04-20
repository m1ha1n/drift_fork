

let rec loop lx ly =
    if lx <= 9 then
        loop (lx + 1) (ly+1)
    else 
        assert (ly >= 0)

let main (m:unit(*-:{v:Unit | unit}*)) = 
    let x = 0 in
    let y = 0 in
    loop x y

let _ = main ()