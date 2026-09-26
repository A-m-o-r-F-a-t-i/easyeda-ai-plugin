# EasyEDA AI Plugin 4.1.1

Six pinned Git submodules: PCB MCP4.1.0, PCB Skill7.2.0, API Skill2.5.0 and three unchanged schematic/format Skills. The existing MIL-only refactor is retained with one 17-tool interface.

MCP adds physical-copper topology with holes and verified pours, existing path/layer/mandatory-via analysis, explicit cross-sections, copper corridors, rotated via arrays, pad-group orientation and durable request receipts. The model still chooses every placement and path. There is no autorouting, design gate, automatic copper deletion or native atomic-rollback claim.

Topology reports its geometric coverage. Cross-sections are not a global minimum-neck solver. Receipt queries and same-ID duplicate suppression never blindly replay an unknown native write. DRC, geometric connectivity and electrical/thermal validation remain distinct.

## Build and deployment

Requires Node.js >=22 and the existing local Bridge/client. Commit child repositories and parent pointers first, then run `pwsh scripts/verify.ps1` and `pwsh scripts/build-plugin.ps1`. Verification and packaging do not update or reset submodules. The working trees must be clean and pinned.

Output: `dist/easyeda-plugin-4.1.1.zip`. The package includes locked MCP production dependencies and their licenses, but no private settings, logs or PCB data. Use the same archive on Windows and Linux ARM64; retain each host's Bridge/environment settings. Reload this plugin's schema and verify the active versions and 17-tool surface.

No AgentDock or Gateway source changes are required. Synthetic tests, real-client read-only integration and actual test-copy writes are separate evidence. Production boards are not modified to test plugin updates.

[中文](README.md) · [Skill](skills/easyeda-pcb-layout-routing/SKILL.md) · [MCP](mcp/easyeda-pcb/README.md)

Version 4.1.1 changes PCB Skill guidance and release metadata only. MCP remains 4.1.0; API and other Skills retain their pinned commits. Static documentation checks do not demonstrate improved model layout quality.
