# EasyEDA AI Plugin 4.1.2

Six pinned Git submodules: PCB MCP4.1.0, PCB Skill7.2.0, API Skill2.5.0 and three unchanged schematic/format Skills. The existing MIL-only refactor is retained with one 17-tool interface.

MCP adds physical-copper topology with holes and verified pours, existing path/layer/mandatory-via analysis, explicit cross-sections, copper corridors, rotated via arrays, pad-group orientation and durable request receipts. The model still chooses every placement and path. There is no autorouting, design gate, automatic copper deletion or native atomic-rollback claim.

Topology reports its geometric coverage. Cross-sections are not a global minimum-neck solver. Receipt queries and same-ID duplicate suppression never blindly replay an unknown native write. DRC, geometric connectivity and electrical/thermal validation remain distinct.

## Build and deployment

Requires Node.js >=22 and the existing local Bridge/client. Commit child repositories and parent pointers first, then run `pwsh scripts/verify.ps1` and `pwsh scripts/build-plugin.ps1`. Verification and packaging do not update or reset submodules. The working trees must be clean and pinned.

Output: `dist/easyeda-plugin-4.1.2.zip`. Packaging installs production dependencies from the lockfiles for both the API Skill and PCB MCP, runs import probes, and includes those dependencies and licenses in the archive. The same archive runs on Windows and Linux ARM64; each host retains its Bridge and environment settings. Reload this plugin's schema and verify the active versions and 17-tool surface.

Version 4.1.2 changes no submodule, AgentDock, Gateway, or PCB source. It fixes the aggregate package omission of `easyeda-api/node_modules/ws`, which caused a fresh or replacement phone installation to report “EasyEDA Bridge dependency is not installed” until `npm ci` was run manually. The packaged Bridge now starts without device-side dependency repair.

Synthetic tests, real-client read-only integration and actual test-copy writes remain separate evidence. Production boards are not modified to test plugin updates.

[中文](README.md) · [Skill](skills/easyeda-pcb-layout-routing/SKILL.md) · [MCP](mcp/easyeda-pcb/README.md)
