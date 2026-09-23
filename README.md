# 嘉立创 AI 插件

简体中文 | [English](README.en.md)

这是 AgentDock 的嘉立创 EDA AI 插件聚合仓库，当前插件版本为 **2.10.1**。仓库本身只保存插件清单、MCP 启动配置、构建脚本和固定的组件提交；5 个 Skill 与 1 个 PCB MCP 均由独立的 GitHub 公开仓库维护，并通过 Git submodule 组合成完整插件。

## 本版改进

功能分组先于器件坐标，先试通关键控制与功率通道。MCP 增加整批候选几何阻断、原生旧值构造、只读对账与未执行余项、逐项执行/保存状态，以及已有审计工具内的分组质量统计。默认仍为 21 个工具。检查范围与未验证项目明确保留，不自动布局/寻路、不重审已确认原理图、不把具体板尺寸或面别写成默认规则。

2.10.1 将成员版本、双语文档和 AgentDock 插件发现摘要统一到同一发布状态，功能实现沿用已通过回归的 2.10.0 代码。

## 仓库结构

| 插件路径 | 版本 | 独立公开仓库 | 作用 |
| --- | ---: | --- | --- |
| `skills/easyeda-api` | 2.3.0 | [`easyeda-skill-api`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-api) | Bridge、Gateway Protocol、窗口与文档身份及公开 API 资料 |
| `skills/easyeda-eprj3` | 1.7.1 | [`easyeda-skill-eprj3`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-eprj3) | 离线 `.eprj3` 工程生成、编辑和校验 |
| `skills/easyeda-pcb-layout-routing` | 5.6.1 | [`easyeda-skill-pcb-layout-routing`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-pcb-layout-routing) | PCB 板框、布局、布线、铺铜、丝印与生产验收；圆形以原点为圆心，多边形以原点顶点锚定，长方形可让相邻两边落在 X/Y 轴上 |
| `skills/easyeda-pro-format-skill` | 1.0.2 | [`easyeda-skill-pro-format`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-pro-format) | 嘉立创底层格式文档、Schema 和格式校验器 |
| `skills/easyeda-schematic-net-fanout` | 2.1.4 | [`easyeda-skill-schematic-net-fanout`](https://github.com/A-m-o-r-F-a-t-i/easyeda-skill-schematic-net-fanout) | 原理图设计、需求补全、ECO 和 PCB 同步 |
| `mcp/easyeda-pcb` | 2.6.1 | [`easyeda-mcp-pcb`](https://github.com/A-m-o-r-F-a-t-i/easyeda-mcp-pcb) | 对当前 EasyEDA PCB 文档执行 21 个受保护生产操作；新板框使用圆心或多边形顶点原点锚定，并在元件、独立焊盘和过孔写入前后阻止跨对象焊盘重叠 |

父仓库通过 `.gitmodules` 固定每个组件的具体提交，因此插件发布可以复现。更新某个成员仓库后，需要在本仓库中更新对应 submodule 指针并再次提交，不能只依赖成员仓库的浮动 `main`。

## 克隆

全部 submodule 均为公开仓库，可直接递归克隆。

```powershell
git clone --recurse-submodules https://github.com/A-m-o-r-F-a-t-i/easyeda-ai-plugin.git
cd easyeda-ai-plugin
```

已经普通克隆时，补齐组件：

```powershell
git submodule sync --recursive
git submodule update --init --recursive
```

## 验证

验证脚本会检查插件清单、submodule 固定状态和必要文件，并执行 PCB Skill、eprj3、格式 Skill 与 PCB MCP 的测试：

```powershell
pwsh ./scripts/verify.ps1
```

## 构建插件包

构建脚本从每个 submodule 的**已提交 HEAD** 导出文件，不复制工作区中未提交的改动，也不会把 `.git` 目录打进插件。随后安装 PCB MCP 的生产依赖，并生成可安装目录和 ZIP 包：

```powershell
pwsh ./scripts/build-plugin.ps1
```

默认输出：

```text
dist/easyeda-plugin-2.10.1/
dist/easyeda-plugin-2.10.1.zip
```

## 更新组件

仅恢复父仓库固定版本：

```powershell
pwsh ./scripts/update-submodules.ps1
```

将所有组件更新到各自远端 `main` 后，必须复核差异、运行验证并提交新的 submodule 指针：

```powershell
pwsh ./scripts/update-submodules.ps1 -Remote
git diff --submodule=log
pwsh ./scripts/verify.ps1
git add .gitmodules skills mcp
git commit -m "chore: update EasyEDA plugin components"
```

## 与 API 插件的关系

本仓库是 **AgentDock AI 插件**，负责 Skill 和 MCP。嘉立创客户端内安装的 Enhanced API Gateway、Protocol、共享运行时和本机 Bridge 位于独立公开仓库 [`easyeda-api-plugin`](https://github.com/A-m-o-r-F-a-t-i/easyeda-api-plugin)。两者再由最上层 `easyeda-plugin-suite` 统一聚合。

## 许可证

该聚合仓库不为所有组件声明统一的开源许可证。每个 submodule 保留自己的许可证和上游归属；公开仓库属性不会改变其中 MIT、Apache-2.0 或其他第三方材料的原始权利。
