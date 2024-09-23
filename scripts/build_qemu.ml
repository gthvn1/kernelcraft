#!/usr/bin/env ocaml

#use "topfind"

#require "unix"

open Unix

let build_qemu () =
  let commands =
    [
      {| mkdir -p qemu/build |};
      {| cd qemu/build && ../configure --target-list=x86_64-softmmu |};
      {| cd qemu/build && make -j 8 |};
    ]
  in
  List.iter
    (fun cmd ->
      Printf.printf "Running: %s\n%!" cmd;
      let status = system cmd in
      match status with
      | WEXITED 0 -> ()
      | _ -> failwith ("Command failed: " ^ cmd))
    commands

let () = build_qemu ()
