open Obeam
open Bitstring
open Base

let extract_debug_info_buf layout =
  let {Beam.cl_abst=opt_abst; Beam.cl_dbgi=opt_dbgi; _} = layout in
  match opt_abst with
  | Some abst ->
     abst.Beam.abst_buf
  | None ->
     begin
       match opt_dbgi with
       | Some dbgi ->
          dbgi.Beam.dbgi_buf
       | None ->
          failwith "no debug info"
     end

let left_unit = Result.map_error ~f:(fun _ -> ())

let absform file =
  let open Result in
  let buf = bitstring_of_file file in
  Beam.parse_layout buf |> map_error ~f:(fun (e, _) -> e) >>= fun (layout, _) ->
  let debug_info_buf = extract_debug_info_buf layout in
  External_term_format.parse debug_info_buf |> map_error ~f:(fun (e, _) -> e) >>= fun (etf, _) ->
  let sf = Simple_term_format.of_etf etf in
  Abstract_format.of_sf sf |> map_error ~f:(fun e -> e |> Abstract_format.sexp_of_err_t |> Sexp.to_string_hum)

let () =
  if Array.length Sys.argv = 1 then
    begin
      Caml.print_endline "BEAM printer";
      Caml.print_endline "";
      Caml.print_endline "USAGE: beam-printer [BEAM]"
    end
  else
    let file = Sys.argv.(1) in
    Caml.Printf.printf "beam: %s\n" file;
    match absform file with
    | Ok absform -> absform |> Abstract_format.sexp_of_t |> Sexp.to_string_hum |> Caml.print_endline
    | Error e -> Caml.Printf.printf "error: %s" e
