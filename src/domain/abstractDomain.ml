
open Apron
open Syntax
open Util
open Config

(*
 *******************************
 ** Abstract domain for value **
 *******************************
 *)
type var = string
type loc = int
(* Define Abstract Domain Functor*)
module type ManagerType =
  sig
    type t
    val man: t Manager.t
  end

module type AbstractDomainType =
  sig
    type t
    val lc_env: t -> t -> t * t
    val leq: t -> t -> bool
    val init_c: int -> t
    val top: t
    val join: t -> t -> t
    val meet: t -> t -> t
    val alpha_rename: t -> var -> var -> t
    val forget_var: var -> t -> t
    val equal_var: t -> var -> var -> t
    val widening: t -> t -> t
    val operator: var -> var -> binop -> t -> t
    val print_abs: Format.formatter -> t -> unit
    val print_env: Format.formatter -> t -> unit
  end

module MakeAbstractDomainValue (Man: ManagerType): AbstractDomainType =
  struct
    type t = Man.t Abstract1.t (*Could be parsed constraints or given initial*)
    let init_c c = let var_v = "cur_v" |> Var.of_string in
        let env = Environment.make [|var_v|] [||] in
        let expr = "cur_v=" ^ (string_of_int c) in
        let tab = Parser.lincons1_of_lstring env [expr] in
        (* Creation of abstract value v = c *)
        Abstract1.of_lincons_array Man.man env tab
    let lc_env v1 v2 = 
      let env1 = Abstract1.env v1 in
      let env2 = Abstract1.env v2 in
      let env = Environment.lce env1 env2 in
      let v1' = Abstract1.change_environment Man.man v1 env false in
      let v2' = Abstract1.change_environment Man.man v2 env false in
      (v1', v2')
    let leq v1 v2 = 
      let v1',v2' = lc_env v1 v2 in
      Abstract1.is_leq Man.man v1' v2'
    let join v1 v2 = 
      let v1',v2' = lc_env v1 v2 in
      Abstract1.join Man.man v1' v2'
    let meet v1 v2 = 
      let v1',v2' = lc_env v1 v2 in
      Abstract1.meet Man.man v1' v2'
    let alpha_rename v prevar var =
        (if !debug then
        begin
          Format.pp_print_string Format.std_formatter "\n\nA rename";
          Format.pp_print_string Format.std_formatter ("\n" ^ prevar ^ " -> " ^ var ^ "\n");
          Abstract1.print Format.std_formatter v;
          Format.pp_print_string Format.std_formatter ("\nEnv: ");
          Environment.print Format.std_formatter (Abstract1.env v);
          Format.pp_print_string Format.std_formatter "\n";
        end
        );
        let (int_vars, real_vars) = Environment.vars (Abstract1.env v) in
        let pre_b = Array.fold_left (fun b x -> prevar = Var.to_string x || b) false int_vars in
        if pre_b = false then v
        else
        begin
        let v_b = Array.fold_left (fun b x -> var = Var.to_string x || b) false int_vars in
        let v' = if v_b = true then 
          begin
            let int_vars_new = Array.fold_left (fun ary x -> if prevar <> Var.to_string x then Array.append ary [|x|] else ary) [||] int_vars in
            let env' = Environment.make int_vars_new real_vars in
            Abstract1.change_environment Man.man v env' true
          end
        else
        begin
        let var_V = Var.of_string var in
        let int_vars_new = Array.map (fun x -> if prevar = Var.to_string x then var_V else x) int_vars in
        Abstract1.rename_array Man.man v int_vars int_vars_new
        end
        in
        (if !debug then 
        begin
          Format.pp_print_string Format.std_formatter ("Result: ");
          Abstract1.print Format.std_formatter v';
        end);
        v'
        end
    let forget_var var v =
        let vari = var |> Var.of_string in
        let arr = [|vari|] in
        let v' = Abstract1.forget_array Man.man v arr false in
        (if !debug then
        begin
          Format.printf "\n\nProjection %s\n" var;
          Format.printf "result: " ;
          Abstract1.print Format.std_formatter v';
          Format.printf "\n";
        end);
        v'
    let top = let env = Environment.make [||] [||] in
        Abstract1.top Man.man env
    let equal_var v vl vr = let var_l = vl |> Var.of_string and var_r = vr |> Var.of_string in
        let env = Environment.make [|var_l; var_r|] [||] in
        let expr = vl ^ "=" ^ vr in
        let tab = Parser.lincons1_of_lstring env [expr] in
        (* Creation of abstract value vl = vr *)
        (if !debug then
        begin
          Format.printf "\n\n = operation \n";
          Format.printf "%s \n" expr;
          Format.printf "Before: " ;
          Abstract1.print Format.std_formatter v;
          Format.printf "\n";
        end);
        let env_v = Abstract1.env v in
        let env' = Environment.lce env env_v in
        let v' = Abstract1.change_environment Man.man v env' false in
        let res = Abstract1.meet_lincons_array Man.man v' tab in
        (if !debug then
        begin
          Format.printf "result: " ;
          Abstract1.print Format.std_formatter res;
          Format.printf "\n";
        end);
        res
    let widening v1 v2 = let v1',v2' = lc_env v1 v2 in
      Abstract1.widening Man.man v1' v2'
    let make_var var = 
      try let _ = int_of_string var in None
      with e -> Some (var |> Var.of_string)
    let operator vl vr op v = 
      (if !debug then
      begin
        Format.printf "\nOperator abs\n";
        Format.printf "%s %s %s\n" vl (string_of_op op) vr
      end);
      let var_v = "cur_v" |> Var.of_string in
      let env = match (make_var vl, make_var vr) with
      | None, Some var_r -> Environment.make [|var_v;var_r|] [||]
      | Some var_l, None -> Environment.make [|var_l;var_v|] [||]
      | Some var_l, Some var_r -> Environment.make [|var_v;var_l; var_r|] [||]
      | None, None -> Environment.make [|var_v|] [||]
      in
      (if !debug then 
      begin
        Format.printf "Env: ";
        Environment.print Format.std_formatter env;
        Format.printf "\n";
        Format.printf "Before: " ;
        Abstract1.print Format.std_formatter v;
        Format.printf "\n";
      end);
      let temp = string_of_op op in
      
      let env_v = Abstract1.env v in
      let env' = Environment.lce env env_v in
      let v' = Abstract1.change_environment Man.man v env' false in
      let res = 
        if cond_op op = true then
          (
            let expr = vl ^ temp ^ vr in
          let tab = Parser.tcons1_of_lstring env [expr] in
          Abstract1.meet_tcons_array Man.man v' tab)
        else
          (let expr = "cur_v=" ^ vl ^ temp ^ vr in
            let tab = Parser.lincons1_of_lstring env [expr] in
          Abstract1.meet_lincons_array Man.man v' tab)
      in
      (* Creation of abstract value vl op vr *)
      (if !debug then
        begin
          Format.printf "result: " ;
          Abstract1.print Format.std_formatter res;
          Format.printf "\n";
        end);
      res
    let print_abs ppf a = Abstract1.print ppf a
    let print_env ppf a = let env = Abstract1.env a in
        Environment.print ppf env
  end

(*Domain Specification*)
module BoxManager: ManagerType =
  struct
    type t = Box.t
    let man = Box.manager_alloc ()
  end

module OctManager: ManagerType =
  struct
    type t = Oct.t
    let man = Oct.manager_alloc ()
  end

module PolkaManager: ManagerType =
  struct
    type t = Polka.strict
    let man = Polka.manager_alloc_strict() |> Polka.manager_of_polka_strict
  end

let parse_domain = function
  | "Box" -> (module (MakeAbstractDomainValue(BoxManager)): AbstractDomainType)
  | "Oct" -> (module (MakeAbstractDomainValue(OctManager)): AbstractDomainType)
  | "Polka_strict" -> (module (MakeAbstractDomainValue(PolkaManager)): AbstractDomainType)
  | _ -> raise (Invalid_argument "Incorrect domain specification")

module AbstractValue = (val (!domain |> parse_domain))
