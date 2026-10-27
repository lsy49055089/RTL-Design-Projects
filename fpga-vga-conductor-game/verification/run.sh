#!/usr/bin/env bash
set -euo pipefail
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT
iverilog -g2012 -s tb_xy_detection -o "$build/xy.vvp" \
  "$base/rtl/xy_detection.sv" "$base/tb/tb_xy_detection.sv"
vvp "$build/xy.vvp"
