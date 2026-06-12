# Contributing to OSSM

## Repositories

| What | Where |
|------|--------|
| This repo (skeleton → product monorepo) | `researchanddesire/ossm` |
| Operational firmware/hardware today | [KinkyMakers/OSSM-hardware](https://github.com/KinkyMakers/OSSM-hardware) |
| Developer docs source | `developer-docs/` here → [dev.researchanddesire.com/ossm](https://dev.researchanddesire.com/ossm) |
| User docs | [simple-docs](https://github.com/researchanddesire/simple-docs) — human-written |

## License

Everything in this repo is **CERN-OHL-S v2** (strongly reciprocal). Do not introduce MPL-licensed firmware patterns from other RAD products.

## Hardware contributions

- CAD: Onshape exports only (`hardware/cad/*.step`, `ossm-asm.step`)
- Update `hardware/bom.csv` with release — follow the [BOM standard](https://dev.researchanddesire.com/meta/bom-standard/) (fixed columns, closed category codes, `–` for empty cells). **Anyone is welcome to edit `bom.csv` directly and push/PR — as long as `bom-lint` passes, it's good.** Only the schema is vendored read-only at `.github/workflows/scripts/bom.schema.json` (do not hand-edit).
- Wireviz: add YAML under `hardware/cables/`
