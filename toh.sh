#!/usr/bin/env bash
# toh.sh - Tower of Hanoi demo with simple ASCII graphics.
# Usage: ./toh.sh [num_disks]   (default 3, max 7)

N=${1:-3}
if ! [[ "$N" =~ ^[1-9]$ ]] || ((N > 7)); then
  echo "Please pass a disk count between 1 and 7." >&2
  exit 1
fi

# Pegs: each is a space-separated stack, bottom-first.
A=""
B=""
C=""
WIDTH=$((2 * N + 1)) # widest disk + a little padding for centering
DELAY=0.5
MOVE=0

# --- ITERATION ---
# draw_state iterates over peg heights (rows) and over the three pegs (cols)
# to render each frame. Pure iteration: no recursion here.
draw_state() {
  local pegs=(A B C)
  local -a rows=()
  local row=""
  local h disk pad

  for h in $( # iterate from top row to bottom
    seq "$N" -1 1
  ); do
    row=""
    for p in "${pegs[@]}"; do # iterate over the three pegs
      # read the disk at height h on peg p (1 = bottom)
      local stack=${!p}
      local arr=($stack)
      disk=${arr[$((h - 1))]:-0}
      if ((disk == 0)); then
        # empty slot: just the peg
        pad=$(((WIDTH - 1) / 2))
        row+="$(printf '%*s' "$pad" '')|$(printf '%*s' "$pad" '')  "
      else
        local dw=$((2 * disk - 1))
        pad=$(((WIDTH - dw) / 2))
        local bar=$(printf '%*s' "$dw" '' | tr ' ' '#')
        row+="$(printf '%*s' "$pad" '')$bar$(printf '%*s' "$pad" '')  "
      fi
    done
    rows+=("$row")
  done

  clear
  echo "Tower of Hanoi  (N=$N, moves=$MOVE)"
  echo
  for row in "${rows[@]}"; do
    echo "$row"
  done
  # base line + labels
  local base=$(printf '%*s' "$WIDTH" '' | tr ' ' '=')
  echo "${base}  ${base}  ${base}"
  local lpad=$(((WIDTH - 1) / 2))
  printf "%*sA%*s  %*sB%*s  %*sC%*s\n" \
    "$lpad" '' "$lpad" '' "$lpad" '' "$lpad" '' "$lpad" '' "$lpad" ''
}

move_disk() {
  local from=$1 to=$2
  local farr=(${!from})
  local last=$((${#farr[@]} - 1))
  local top=${farr[$last]}
  unset "farr[$last]"
  eval "$from=\"\${farr[*]}\""
  eval "$to=\"\${$to} $top\""
  MOVE=$((MOVE + 1))
  draw_state
  sleep "$DELAY"
}

# --- RECURSION ---
# Classic recursive Tower of Hanoi solver.
#   hanoi n from to via
#     1) recurse: move top n-1 disks from 'from' onto 'via' (out of the way)
#     2) move disk n directly from 'from' to 'to'
#     3) recurse: move the n-1 disks from 'via' onto 'to'
# Base case: n == 0 does nothing (stops the recursion).
hanoi() {
  local n=$1 from=$2 to=$3 via=$4
  ((n == 0)) && return
  hanoi $((n - 1)) "$from" "$via" "$to" # recursive call #1
  move_disk "$from" "$to"               # the actual move
  hanoi $((n - 1)) "$via" "$to" "$from" # recursive call #2
}

# Build initial stack on peg A: disks N (bottom) .. 1 (top).
for i in $(seq "$N" -1 1); do
  A="$A $i"
done
A="${A# }"

draw_state
sleep "$DELAY"

hanoi "$N" A C B

echo
echo "Solved in $MOVE moves (optimal: $(((1 << N) - 1)))."
