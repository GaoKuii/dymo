#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
data="$root/dataset"
out="$root/results"
timeout_s=1200
dataset=""
size=""
query=""
all=false

usage() {
  cat <<'EOF'
Usage: run_experiments.sh --dataset NAME [--size N] [--query qN]
       run_experiments.sh --all

Options:
  --dataset NAME       deezer5, email10, facebook10, or github10
  --size N             4, 6, 8, 10, 12, 14, or 16
  --query qN           Run one query, for example q1
  --all                Run all datasets and queries (long-running)
  --timeout SECONDS    Per-query timeout (default: 1200)
  --output DIR         Output directory (default: ./results)
  --help               Show this help
EOF
}

while (($#)); do
  case "$1" in
    --dataset) dataset=${2:?missing dataset}; shift 2;;
    --size) size=${2:?missing size}; shift 2;;
    --query) query=${2:?missing query}; shift 2;;
    --all) all=true; shift;;
    --timeout) timeout_s=${2:?missing timeout}; shift 2;;
    --output) out=${2:?missing output}; shift 2;;
    --help|-h) usage; exit 0;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2;;
  esac
done

if $all; then
  [[ -z "$dataset$size$query" ]] || { echo '--all cannot be combined with filters' >&2; exit 2; }
  datasets=(deezer5 email10 facebook10 github10)
else
  [[ -n "$dataset" ]] || { echo 'use --dataset or --all' >&2; exit 2; }
  datasets=("$dataset")
fi

for d in "${datasets[@]}"; do
  case "$d" in deezer5|email10|facebook10|github10);; *) echo "unknown dataset: $d" >&2; exit 2;; esac
done
[[ -z "$size" || "$size" =~ ^(4|6|8|10|12|14|16)$ ]] || { echo "invalid size" >&2; exit 2; }
[[ -z "$query" || "$query" =~ ^q[1-9][0-9]*$ ]] || { echo "invalid query" >&2; exit 2; }
[[ "$timeout_s" =~ ^[1-9][0-9]*$ ]] || { echo "timeout must be a positive integer" >&2; exit 2; }
command -v g++ >/dev/null || { echo 'g++ is required' >&2; exit 1; }
command -v timeout >/dev/null || { echo 'GNU timeout is required' >&2; exit 1; }

g++ -std=c++11 ${CXXFLAGS:--O} -o "$root/dymo" "$root/dymo.cpp"
run_dir="$out/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$run_dir/logs"
printf 'dataset,query_size,query_id,status,total_cost_ms,log_file\n' > "$run_dir/results.csv"

for d in "${datasets[@]}"; do
  sizes=(4 6 8 10 12 14 16)
  [[ -z "$size" ]] || sizes=("$size")
  for n in "${sizes[@]}"; do
    qdir="$data/$d/Q/$n"
    [[ -d "$qdir" ]] || { echo "missing directory: $qdir" >&2; exit 1; }
    if [[ -n "$query" ]]; then qs=("$qdir/$query"); else mapfile -t qs < <(find "$qdir" -maxdepth 1 -type f -name 'q[0-9]*' -print | sort -V); fi
    for q in "${qs[@]}"; do
      [[ -f "$q" ]] || { echo "missing query: $q" >&2; exit 1; }
      id=$(basename "$q")
      log="$run_dir/logs/${d}_Q${n}_${id}.log"
      set +e
      timeout "$timeout_s" "$root/dymo" -d "$data/$d/initial" -q "$q" -s "$data/$d/s" >"$log" 2>&1
      rc=$?
      set -e
      cost=$(sed -n 's/^Total cost (ms):[[:space:]]*//p' "$log" | tail -1)
      if ((rc == 124)); then status=timeout; elif ((rc == 0)); then status=completed; else status=error; fi
      printf '%s,%s,%s,%s,%s,%s\n' "$d" "$n" "$id" "$status" "$cost" "logs/$(basename "$log")" >> "$run_dir/results.csv"
    done
  done
done
echo "CSV summary: $run_dir/results.csv"

# Usage: run_experiments.sh --dataset github10 --size 4 --query q1
