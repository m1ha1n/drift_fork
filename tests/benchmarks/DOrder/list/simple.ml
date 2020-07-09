
let rec mapfilter (f:int->int list) (l:int list) = match l with
	| [] -> []
	| h::t -> 
		let r = mapfilter f t in
		let x = f h in
		match x with
			| [] -> r
			| z::e -> (z::r)		

let pos y =
  if 0 < y then
    y::[]
  else
    []

let main (u:unit(*-:{v:Unit | unit}*)) = 
	let xs = [1;2;1] in
	let ys = mapfilter pos xs in
	assert(List.length ys = List.length xs)

(*
    let licons_earray env (vars : string list) = 
      let mult_lst = Util.extract 2 vars in
      let mult_const_lst = Util.arrange (ThresholdsSetType.elements !thresholdsSet) in
      let size = (List.length mult_lst * 4 * List.length mult_const_lst) in
      let thehold_ary = Lincons1.array_make env size in
      let idx2 = ref 0 in
      List.iter (fun lst -> 
        let lvar, rvar = List.nth lst 0, List.nth lst 1 in
        List.iter (fun lst' ->
          let lconst, rconst = List.nth lst' 0, List.nth lst' 1 in
          let eq = (string_of_int lconst)^" * "^lvar^" <= "^(string_of_int rconst)^" * "^rvar^" + "^(string_of_int rconst) in (* v <=  threshold_const *)
          Lincons1.array_set thehold_ary (!idx2) (Parser.lincons1_of_string env eq); 
          idx2 := !idx2 + 1;
          let eq = (string_of_int lconst)^" * "^lvar^" >= "^(string_of_int rconst)^" * "^rvar^" + "^(string_of_int rconst) in (* v >=  threshold_const *)
          Lincons1.array_set thehold_ary (!idx2) (Parser.lincons1_of_string env eq); 
          idx2 := !idx2 + 1;
          let eq = (string_of_int lconst)^" * "^lvar^" <= "^(string_of_int rconst)^" * "^rvar^" - "^(string_of_int rconst) in (* v <=  threshold_const *)
          Lincons1.array_set thehold_ary (!idx2) (Parser.lincons1_of_string env eq); 
          idx2 := !idx2 + 1;
          let eq = (string_of_int lconst)^" * "^lvar^" >= "^(string_of_int rconst)^" * "^rvar^" - "^(string_of_int rconst) in (* v >=  threshold_const *)
          Lincons1.array_set thehold_ary (!idx2) (Parser.lincons1_of_string env eq); 
          idx2 := !idx2 + 1;
        ) mult_const_lst
      ) mult_lst;
      thehold_ary
    let generate_threshold_earray env = 
      if Environment.size env = 0 then Lincons1.array_make env 0 
      (* else if Environment.mem_var env (Var.of_string "cur_v") then !licons_ref  *)
      else
        let int_vars, _ = Environment.vars env in
        let lst = Array.fold_left (fun lst item -> let var = Var.to_string item in
        if var = "cur_v" || String.sub var 0 1 = "l" || String.sub var 0 1 = "e" 
        || String.sub var 0 1 = "z" || String.sub var 0 1 = "n" || String.sub var 0 1 = "m"
        || String.length var > 4 && String.sub var 0 1 = "pref" then var :: lst
        else lst
        (* var :: lst *)
        ) [] int_vars in
        (* if Environment.mem_var env (Var.of_string "min") && Environment.mem_var env (Var.of_string "max") then
          (Environment.print Format.std_formatter env;
          licons_earray ary (Some "max"))
        else  *)
       licons_earray env lst
*)