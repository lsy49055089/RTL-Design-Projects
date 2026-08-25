#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
out_dir="$(mktemp -d)"

iverilog -g2012   -I "$repo_root/fpga-rv32i-single-cycle/rtl"   -s top_rv32i_soc   -o "$out_dir/rv32i.out"   "$repo_root"/fpga-rv32i-single-cycle/rtl/*.sv

iverilog -g2012   -s toptop   -o "$out_dir/stopwatch.out"   "$repo_root"/fpga-stopwatch-watch/src/*.v

echo "PASS: RV32I and Stopwatch RTL elaboration"
