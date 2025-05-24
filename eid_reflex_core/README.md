# ✨ EID Reflex IP-Core

![CI](https://github.com/<ton-org>/<repo>/actions/workflows/ci.yml/badge.svg)

Bloc **"réflexe entropique"** : calcule `dH/dt`, le rapport `μ = α/β`
et lève **`alarm`** si :

| Outil | Version testée | Statut |
|-------|----------------|--------|
| Verilator | 5.020 | ✅ |
| Vivado    | 2023.2 | ✅ |
| Quartus   | 22.1 | ✅ |

## How to run locally

```bash
make -C eid_reflex_core gen
make -C eid_reflex_core sim
make -C eid_reflex_core check
```


