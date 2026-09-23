# EasyEDA AI Plugin

[简体中文](README.md) | English

This is the aggregate AgentDock plugin repository for the EasyEDA AI toolchain. The current plugin version is **2.10.0**. The parent repository stores only plugin manifests, the MCP launch configuration, build scripts, and pinned component commits. Five Skills and one PCB MCP are maintained in separate public GitHub repositories and assembled through Git submodules.

## Changes in this release

Functional grouping and constrained trial routes precede extensive copper. The MCP adds whole-plan modeled preflight, native old-state construction, read-only reconciliation and unapplied remainders, separate operation/save receipts, and group metrics inside the existing audit tool. The production profile remains 21 tools. Coverage limits stay explicit; no auto-placement/routing, schematic re-review, or board-specific defaults are introduced.

## Repository layout

| Plugin path | Version | Public component repository | Responsibility |
| --- | ---: | --- | --- |
| `skills/easyeda-api` | 2.3.0 | [`easyeda-skill-api`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-api) | Bridge, Gateway Protocol, window/document identity, and public API references |
| `skills/easyeda-eprj3` | 1.7.1 | [`easyeda-skill-eprj3`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-eprj3) | Offline `.eprj3` generation, editing, and validation |
| `skills/easyeda-pcb-layout-routing` | 5.6.0 | [`easyeda-skill-pcb-layout-routing`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-pcb-layout-routing) | Board outlines, placement, routing, pours, silkscreen, and release criteria; circles use the origin as center, polygons use an origin vertex, and rectangles may place adjacent edges on the X/Y axes |
| `skills/easyeda-pro-format-skill` | 1.0.2 | [`easyeda-skill-pro-format`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-pro-format) | Low-level EasyEDA format documentation, schemas, and validator |
| `skills/easyeda-schematic-net-fanout` | 2.1.4 | [`easyeda-skill-schematic-net-fanout`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-schematic-net-fanout) | Schematic design, requirement expansion, ECO handling, and PCB synchronization |
| `mcp/easyeda-pcb` | 2.6.0 | [`easyeda-mcp-pcb`](https://github.com/A-m-o-r-F-a-t-i/easyeda-mcp-pcb) | Twenty-one guarded production operations; anchors new outlines by circle center or polygon vertex and blocks cross-object pad overlap before and after component, standalone-pad, and via writes |

`.gitmodules` pins every component to an exact commit, making plugin releases reproducible. After changing a component repository, update and commit the corresponding submodule pointer here; do not rely on a floating remote `main` branch.

## Clone

All submodules are public and can be cloned recursively without private-repository credentials.

```powershell
git clone --recurse-submodules https://github.com/A-m-o-r-F-a-t-i/easyeda-ai-plugin.git
cd easyeda-ai-plugin
```

For an existing non-recursive clone:

```powershell
git submodule sync --recursive
git submodule update --init --recursive
```

## Verify

The verification script checks manifests, pinned submodule state, required files, and the available PCB Skill, eprj3, format Skill, and PCB MCP test suites:

```powershell
pwsh ./scripts/verify.ps1
```

## Build the plugin

The build script exports the **committed HEAD** of every submodule. It does not copy uncommitted working-tree changes or any `.git` directory. It then installs production dependencies for the PCB MCP and creates an installable directory and ZIP archive:

```powershell
pwsh ./scripts/build-plugin.ps1
```

Default outputs:

```text
dist/easyeda-plugin-2.10.0/
dist/easyeda-plugin-2.10.0.zip
```

## Update components

Restore the versions pinned by the parent repository:

```powershell
pwsh ./scripts/update-submodules.ps1
```

To move every component to its remote `main`, review the changes, run verification, and commit the new submodule pointers:

```powershell
pwsh ./scripts/update-submodules.ps1 -Remote
git diff --submodule=log
pwsh ./scripts/verify.ps1
git add .gitmodules skills mcp
git commit -m "chore: update EasyEDA plugin components"
```

## Relationship to the API plugin

This repository is the **AgentDock AI plugin** and owns Skills plus the MCP. The Enhanced API Gateway extension, Protocol, shared runtime, and local Bridge installed with EasyEDA Pro are maintained in the separate public [`easyeda-api-plugin`](https://github.com/A-m-o-r-F-a-t-i/easyeda-api-plugin) repository. The top-level `easyeda-plugin-suite` repository aggregates both parents.

## Licensing

This aggregate repository does not impose one blanket open-source license on every component. Each submodule retains its own license and upstream attribution. Public visibility does not alter MIT, Apache-2.0, or other third-party rights contained in those components.
