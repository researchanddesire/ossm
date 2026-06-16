# AGENTS.md - OSSM

Guidance for agents working in this product repository.

## Documentation Ownership

- Assembly documentation lives in `assembly-docs/` and publishes to Ohai.
- Developer documentation lives in `developer-docs/docs/` and publishes to dev docs.
- End-user documentation lives in the separate `simple-docs` repository.
- Product-level BOM data lives in `hardware/bom.csv` and is human-owned.
- Hardware source folders are `hardware/cad/`, `hardware/pcb/`, and
  `hardware/cables/`.

Do not commit generated assembly-site output to this repo. The assembly docs
aggregator renders `hardware/bom.csv` into the copied `assembly-docs/bom.md`
page at build time.

## Ohai Assembly Package

An Ohai-eligible product repo must keep these files present and non-placeholder:

- `assembly-docs/site.yml`
- `assembly-docs/nav.yml`
- `assembly-docs/index.md`
- `assembly-docs/pcb-overview.md`
- `assembly-docs/cable-harnesses.md`
- `assembly-docs/bom.md`
- `assembly-docs/assembly-guide.md`

Only add or keep the GitHub topic `ohai-assembly-docs` after the package has
real metadata and local assembly/build checks pass.

## BOM And Cable Rules

When editing any `hardware/**/bom.csv`, follow the RAD BOM standard:

- Use the fixed 12-column header exactly.
- Use only canonical category codes.
- Use the en dash `–` for empty values; do not leave blank cells.
- Do not hand-edit `.github/workflows/scripts/bom.schema.json`.
- Run `python .github/workflows/scripts/bom_lint.py` after BOM changes.

Product BOMs list cable harnesses as top-level assemblies. Detailed cable BOMs
belong to Wireviz output. Link generated `.bom.tsv` artifacts from assembly
docs; do not copy child cable BOM details into `hardware/bom.csv`.

Full reference: https://dev.researchanddesire.com/meta/bom-standard/

## Workflow

- Do not auto-commit changes unless explicitly asked.
- Keep changes reviewable and scoped to the request.
- Do not commit `.DS_Store`, `cable-export/`, or generated cable render outputs.
- Prefer existing project patterns over new abstractions.
- If you learn lasting project-specific context, add it here.
