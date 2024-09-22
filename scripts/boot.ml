#!/usr/bin/env ocaml

#use "topfind"

#require "unix"

let run_command cmd =
  let ic = Unix.open_process_in cmd in
  let rec read_all_lines ic acc =
    try
      let line = input_line ic in
      read_all_lines ic (line :: acc)
    with End_of_file -> acc
  in
  let output = List.rev (read_all_lines ic []) in
  let status = Unix.close_process_in ic in
  (output, status)

let () =
  let cmd =
    [
      {|  ./qemu/build/qemu-system-x86_64 |};
      {|  -enable-kvm |};
      {|  -cpu host |};
      {|  -kernel linux/build/arch/x86_64/boot/bzImage |};
      {|  -append "console=ttyS0  root=/dev/vda devtmpfs.mount=1" |};
      {|  -drive format=raw,file=buildroot/output/images/rootfs.ext2,if=virtio |};
      {|  -m 1024M |};
    ]
  in
  let output, status = run_command (cmd |> String.concat " ") in
  List.iter print_endline output;
  match status with
  | Unix.WEXITED code -> Printf.printf "Process exited with code: %d\n" code
  | Unix.WSIGNALED signal ->
      Printf.printf "Process killed by signal: %d\n" signal
  | Unix.WSTOPPED signal ->
      Printf.printf "Process stopped by signal: %d\n" signal
