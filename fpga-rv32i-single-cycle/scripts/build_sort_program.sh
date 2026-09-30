#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd "$(dirname "$0")/.." && pwd)"
source_dir="$project_dir/program/reproduction"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
tool_prefix="${RISCV_PREFIX:-riscv64-unknown-elf-}"
"${tool_prefix}gcc" -march=rv32i -mabi=ilp32 -O0 -mno-relax \
  -ffreestanding -fno-builtin -fno-stack-protector -nostdlib \
  -Wl,--no-relax -Wl,-T,"$source_dir/link.ld" \
  "$source_dir/start.S" "$source_dir/bubble_sort_fixed.c" -o "$build_dir/sort.elf"
"${tool_prefix}objcopy" -O binary -j .text "$build_dir/sort.elf" "$build_dir/sort.bin"
python3 - "$build_dir/sort.bin" "$source_dir/bubble_sort_fixed.mem" <<'PY'
import pathlib
import sys
data = pathlib.Path(sys.argv[1]).read_bytes()
if len(data) % 4 or len(data) // 4 > 512:
    raise SystemExit("Program must consist of at most 512 RV32I instructions")
words = [int.from_bytes(data[i:i + 4], "little") for i in range(0, len(data), 4)]
pathlib.Path(sys.argv[2]).write_text("".join(f"{word:08x}\n" for word in words))
print(f"Generated {len(words)} instructions: {sys.argv[2]}")
PY
