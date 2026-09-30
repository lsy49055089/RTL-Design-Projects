#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd "$(dirname "$0")/.." && pwd)"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
iverilog -g2012 -I "$project_dir/rtl" -s tb_sort_reproduction \
  -o "$build_dir/sort.out" "$project_dir"/rtl/*.sv \
  "$project_dir/tb/tb_sort_reproduction.sv"
legacy_image="$project_dir/program/instruction_mem_sort.mem"
fixed_image="$project_dir/program/reproduction/bubble_sort_fixed.mem"
vvp "$build_dir/sort.out" +IMAGE="$legacy_image" \
  +WORDS="$(awk 'NF { n++ } END { print n }' "$legacy_image")" +LEGACY
vvp "$build_dir/sort.out" +IMAGE="$fixed_image" \
  +WORDS="$(awk 'NF { n++ } END { print n }' "$fixed_image")"
