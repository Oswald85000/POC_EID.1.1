# ✨ EID Reflex IP-Core

![CI](https://github.com/owner/repo/actions/workflows/ci.yml/badge.svg)

Bloc **"réflexe entropique"** : calcule `dH/dt`, le rapport `μ = α/β` et lève **`alarm`** si la dérive dépasse un seuil.

## Build & Test support

| Outil     | Version testée | Statut |
|-----------|----------------|--------|
| Verilator | 5.020          | ✅ |
| Vivado    | 2023.2         | ✅ |
| Quartus   | 22.1           | ✅ |

## Quick-start

```bash
make -C eid_reflex_core gen      # vecteurs de référence SHA-256
make -C eid_reflex_core sim      # simulation Verilog + VCD
make -C eid_reflex_core wave     # ouvre GTKWave
```

## Interface RTL

Le coeur expose un paramètre `LAT=3` (latence pipeline) et un port `cfg_rd_data[31:0]` pour lire les coefficients.

### Registers AXI-Lite
- `0x00` α
- `0x04` β
- `0x08` γ
- `0x0c` δ
- `0x10` λ+
- `0x14` λ-

## Licence & Royalty model

SPDX-License-Identifier: Apache-2.0
Royalty: $0.25 / port
