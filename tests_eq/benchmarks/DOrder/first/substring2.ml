
let main k from = 
    let rec loop lk li lj = 
        if (li < lk) then
            loop lk (li+1) (lj+1)
        else lj < 101
    in
  
    if (k >= 0 && k <= 100 && from >= 0 && from <= k) then
        (let i = from in
        let j = 0 in
        loop k i j)
    else false
in assert (main 5 20 = false)