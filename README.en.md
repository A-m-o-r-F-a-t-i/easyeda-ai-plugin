# EasyEDA AI Plugin 3.0.1

An aggregate of six independent Git submodules. PCB MCP 3.0.1 is the preferred wrapper for common native actions; PCB Skill 6.0.1 guides design, and API Skill 2.4.1 routes normal PCB work through the mil-default MCP while covering explicit capability gaps and Bridge development. Other schematic/format components are unchanged.

The default 21-tool interface accepts direct bulk operations with designators and pin endpoints. Editing coordinates, overview/pin data, picking, SVG regions and pick-and-place export default to mil; metric input/output is explicit. There are no ordinary guard/prepare parameters, tiny public batch caps or design-approval gates. The model owns layout, explicit routes and analysis timing. MCP handles native adapters, transport slicing, factual results and overall/local SVG feedback.

Complete component/footprint/pin-net orientation data includes size provenance and unknown fields. SVG labels are inspection overlays, not manufacturing text. DRC and other analyses are optional factual tools. Raw APIs are not a routine bypass of existing MCP wrappers.

Requires Node.js >=22 and an authorized EasyEDA Bridge. Commit component changes and update submodule pins before running scripts/verify.ps1 and scripts/build-plugin.ps1. Output: dist/easyeda-plugin-3.0.1.zip. Register only the default service.

Offline tests and real-client read-only integration do not certify every live write combination. Production boards are not modified to validate this release. Code rollback does not restore board contents.

[中文](README.md) · [PCB Skill](skills/easyeda-pcb-layout-routing/SKILL.md) · [MCP](mcp/easyeda-pcb/README.md)
