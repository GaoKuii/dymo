# Dataset notes

The paper identifies these datasets and query graphs as coming from the public CaLiG benchmark and cites Yang et al. (2023).
The local copy contains:

| Directory | Initial graph | Update stream | Query sizes | Queries per size |
| --- | ---: | ---: | --- | ---: |
| `deezer5` | 2,101,374 bytes | 91,072 bytes | 4, 6, 8, 10, 12, 14, 16 | 50 |
| `email10` | 2,564,199 bytes | 119,145 bytes | 4, 6, 8, 10, 12, 14, 16 | 50 |
| `facebook10` | 2,435,856 bytes | 121,317 bytes | 4, 6, 8, 10, 12, 14, 16 | 50 |
| `github10` | 4,250,025 bytes | 210,463 bytes | 4, 6, 8, 10, 12, 14, 16 | 50 |

The curated input files total 12,178,614 bytes (about 11.6 MiB across 1,478 files).
`.DS_Store`, the empty `Q1` directory in `email10`, compiled binaries, and previous-run statistics are not needed for reproduction and are excluded from the clean package.

The upstream CaLiG source repository is <https://github.com/JackChuengQAQ/CaLiG>.
Its GitHub metadata does not identify a license, so public availability alone does not establish redistribution permission for these dataset files.

The local files arrived without a separate license or provenance manifest.
A citation to the paper alone does not establish redistribution rights; applicable terms should be checked with the benchmark maintainers.
