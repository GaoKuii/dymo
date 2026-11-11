# DyMO artifacts

This repository contains the C++ implementation and input artifacts for the DyMO continuous subgraph matching experiments.
Inputs are organized as `dataset/<name>/initial`, `dataset/<name>/s`, and `dataset/<name>/Q/<query-size>/q<id>`.

## Requirements

- Linux or another environment with a C++11 compiler
- `g++`, Bash, and GNU `timeout`

The paper's experiments used g++ 11.4 with `-O` on Ubuntu 22.04.
The runner defaults to `-O`; set `CXXFLAGS='-O3'` to choose another optimization level.

## Build and run

Build manually from the repository root:

```sh
g++ -std=c++11 -O -o dymo dymo.cpp
```

Run one query:

```sh
./dymo -d dataset/github10/initial \
       -q dataset/github10/Q/4/q1 \
       -s dataset/github10/s
```

The experiment runner builds the program and writes per-query logs and a CSV summary under `results/`.
Start with one query:

```sh
./run_experiments.sh --dataset github10 --size 4 --query q1
```

Run the queries for one dataset or all four datasets with:

```sh
./run_experiments.sh --dataset github10
./run_experiments.sh --all
```

Each query has a 20-minute timeout by default.
The complete workload can take substantial time, especially for large query graphs.
`./run_experiments.sh --help` shows available options.
The `all_bash` compatibility entry point starts the complete workload.

## Input formats

- `initial`: labeled undirected graph.
  Vertex records use `v <id> <label>` and edge records use `e <u> <v>`.
- `Q/<size>/q<id>`: query graph in the same format.
- `s`: update stream with `e <u> <v>` records.
  Positive endpoints encode an insertion; negative endpoints encode a deletion as `-id-1`.

## Data provenance and licensing

The paper describes these graph datasets and query pool as coming from the CaLiG benchmark [1].
The upstream source repository is <https://github.com/JackChuengQAQ/CaLiG>.
Neither that repository nor the included dataset files specify a license or redistribution terms.
The datasets remain subject to the rights of their respective owners; consult the upstream source and its maintainers for applicable terms.

No license is specified for the DyMO source code in this repository.
The publication license for the paper does not automatically apply to the code or datasets.
Contact the respective rights holders for permissions beyond access to these materials.

## Reference

[1] R. Yang, Z. Zhang, W. Zheng, and J. X. Yu, "Fast continuous subgraph matching over streaming graphs via backtracking reduction,"
*Proceedings of the ACM on Management of Data*, vol. 1, no. 1, 2023.

## Artifact scope

This package includes the DyMO implementation, four initial data graphs, four update streams, and the paper's query graphs (7 sizes x 50 queries per dataset).
It does not include implementations of RapidFlow or CaLiG, nor does it claim to reproduce those baselines.
Historical statistics, macOS `.DS_Store` files, and compiled binaries are excluded from version control.
