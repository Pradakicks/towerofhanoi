# Tower of Hanoi (bash demo)

A tiny bash script that animates the Tower of Hanoi with ASCII graphics.

## Run

```sh
./toh.sh        # 3 disks (default)
./toh.sh 5      # 5 disks
```

Disk count must be 1–7.

## What to look at

- `# --- RECURSION ---` in `toh.sh` marks the classic recursive solver.
- `# --- ITERATION ---` marks the rendering loop that iterates over peg heights and pegs.
