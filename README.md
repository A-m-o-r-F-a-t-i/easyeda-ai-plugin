# 嘉立创 EDA AI 插件 3.0.0

聚合可独立维护的 API Skill、PCB Skill、原理图/格式 Skill 与 PCB MCP。MCP 优先将常见 API 操作封装为简洁接口，AI 自主设计，Skill 提供方法和建议工作流。

| 成员 | 版本与职责 |
| --- | --- |
| PCB MCP | 3.0.0：默认21工具，直接大批量编辑、完整元件网络朝向读取、整体/局部 SVG |
| PCB Skill | 6.0.0：MCP 优先、设计经验、按需分析，无强制准备链或设计门控 |
| API Skill | 2.4.0：原生能力资料、Bridge、扩展开发和明确封装缺口诊断 |
| 其他三个 Skill | 保持现有版本，原理图和格式能力不受本次改造影响 |

普通编辑使用位号、U1.12 端点、层名和毫米；未填写字段保持原值。MCP 内部处理对象和参数转换、批量分片、原生返回与部分成功。没有自动布局、寻路或隐藏几何优化。检查工具返回事实，不决定编辑权限。

读取总览区分真实本体、装配图形、丝印和焊盘包络。SVG 提供可读的引脚/网络标识，辅助标注不写入板上丝印。未知原生外形和未覆盖几何如实列出。

## 安装与开发

需要 Node.js >=22、已授权 Bridge 和嘉立创客户端。安装本仓库构建的 ZIP，插件保持一个默认 MCP 服务。更新后加载新的工具 Schema；旧会话中的 mode/guard 请求不属于3.0接口。

仓库用六个 Git 子模块固定组件提交。提交子仓库修改并更新本仓库指针后执行：

~~~powershell
pwsh scripts/verify.ps1
pwsh scripts/build-plugin.ps1
~~~

构建输出 dist/easyeda-plugin-3.0.0.zip。构建使用子模块的已提交 HEAD，不会把未提交源文件误当发布内容。源码回滚不会恢复已修改的 PCB。

自动化测试、真实只读和真实写入分别报告。本次默认不在生产板上写测试对象；只读成功不意味着全部写操作实机通过。

组件清单见 components.json，操作示例见 [PCB Skill](skills/easyeda-pcb-layout-routing/SKILL.md)。[English](README.en.md)
