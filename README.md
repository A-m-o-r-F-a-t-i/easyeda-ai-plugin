# 嘉立创 EDA AI 插件 4.1.1

聚合五个独立 Skill 和一个 PCB MCP 子仓。沿用 MIL-only 重构，只保留一套 17 工具接口。AI 决定布局、铜宽、路径、过孔和分析时机，MCP 封装显式操作与实际反馈，不自动布线、不增加设计门控。

| 组件 | 版本 | 本次职责 |
| --- | --- | --- |
| PCB MCP | 4.1.0 | 实际铜拓扑、孔洞、端点换层/必经孔、指定截面、连续铜带、孔阵列、焊盘组朝向和持久执行回执 |
| PCB Skill | 7.2.0 | 完整通道、参考层职责、回流孔布置、拓扑定向刷新与结果范围 |
| API Skill | 2.5.0 | 同步17工具MIL-only路由，保留既有Bridge/Gateway实现 |
| 原理图和格式三个Skill | 保持原版本 | 本次不改动其业务能力 |

普通编辑统一使用 pcb_edit。新操作 orient、copper_path、via_array 只执行给定几何，不寻找路线或删除旧铜。pcb_read 的 topology 模式分析现有铜连接，sections 只测指定截面，未知形状和成铜单位保留coverage缺口。

requestId 可用于相同请求的持久去重，receipt/receipts 模式读取回执。派发结果未知时不重放，不承诺原生原子事务或自动回滚。SVG修复复合孔洞、圆弧边界和纯铜修改区域反馈。位号隐藏保留元件身份及功能文字。

## 安装与开发

需要Node.js >=22、现有本地Bridge及嘉立创客户端。仓库以六个Git子模块固定组件提交。先提交组件和主仓指针，再执行：

```powershell
pwsh scripts/verify.ps1
pwsh scripts/build-plugin.ps1
```

构建只读取已提交且干净、与主仓指针匹配的源码，不自动更新或重置子模块。发行包为 dist/easyeda-plugin-4.1.1.zip，包含锁定的MCP生产依赖及其许可证，不包含私有配置、日志或PCB设计文件。

两设备使用同一包，保留各自Bridge与MCP环境配置。更新后刷新该插件工具Schema并核对17工具和版本。只读联调、模拟写入与实板写入分别报告；工具维护不修改生产PCB。

4.1.1仅更新PCB Skill与发行元数据，MCP仍为4.1.0，API与其他Skill保持原提交。没有修改AgentDock或Gateway，也不增加全局最小铜颈搜索、自动回流布线、原生事务回滚和电流/阻抗仿真。文档回归不等同于实际布板效果验证。

[English](README.en.md) · [PCB Skill](skills/easyeda-pcb-layout-routing/SKILL.md) · [MCP](mcp/easyeda-pcb/README.zh-CN.md)
