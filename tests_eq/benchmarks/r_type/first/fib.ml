
let rec fib n =
  if n <= 1 then 1 else
    fib (n - 1) + fib (n - 2)

let main mn =
    assert (fib mn >= mn)

let _ = main 34