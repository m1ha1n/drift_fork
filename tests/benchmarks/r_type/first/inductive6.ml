

let f g x =
  if x > 0 then
    g x
  else
    1

let decr dx = dx - 1
	
let main (n:unit(*-:{v:Unit | unit}*)) = 
	assert(f decr 3 > 0)