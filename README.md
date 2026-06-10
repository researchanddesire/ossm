# OSSM — Open Source Sex Machine

Monorepo for OSSM **firmware + hardware** under [CERN-OHL-S v2](LICENSES/CERN-OHL-S-2.0.txt).

**Status:** Skeleton — assets and firmware migration from [KinkyMakers/OSSM-hardware](https://github.com/KinkyMakers/OSSM-hardware) and [OSSM-Software](https://github.com/researchanddesire/OSSM-Software) are in progress by the RAD team.

| Resource | Location |
|----------|----------|
| User docs | [docs.researchanddesire.com/ossm](https://docs.researchanddesire.com/ossm) |
| Developer docs | [dev.researchanddesire.com/ossm](https://dev.researchanddesire.com/ossm) |
| Operational repo (today) | [KinkyMakers/OSSM-hardware](https://github.com/KinkyMakers/OSSM-hardware) |

## Layout

```
hardware/ossm/
├── bom.csv          # Bill of materials (Opulo-style CSV)
├── cad/             # Onshape → STEP per component + ossm-asm.step
├── cables/          # Wireviz source YAML
└── pcb/             # PCB design files
src/                 # Firmware (placeholder until migration)
developer-docs/      # MkDocs source → dev.researchanddesire.com/ossm
```

## Hardware

- **No STLs** in this repository
- **CAD:** one STEP per release component; `ossm-asm.step` for the tagged assembly
- **Cables:** Wireviz `.yml` in `hardware/ossm/cables/`; release workflow renders PDF harness diagrams

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
