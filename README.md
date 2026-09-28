# autocad-operations

面向Codex桌面版的AutoCAD工程操作插件。它提供任务范围读取、对象级修改、视觉核验、故障降级和结构化问题记录工作流。

## 首版支持范围

- Windows 11
- AutoCAD 2023
- Codex桌面版
- 外部MCP依赖：[AnCode666/multiCAD-mcp](https://github.com/AnCode666/multiCAD-mcp)
- Computer Use为推荐依赖，不是对象级CAD操作的强制依赖

## 当前状态

版本`0.1.0`正在开发。插件骨架已经建立，Skill迁移、一键安装、自检和公开发布资料尚未完成，当前版本不应作为正式安装包分发。

- 作者：Kristin_W
- 许可证：MIT
- 源码仓库：https://github.com/WangCheng0902/autocad-operations

## 设计原则

- 插件不包含个人绝对路径、访问令牌、项目DWG或企业敏感资料。
- 公共工作流与每台电脑的AutoCAD/MCP配置分离。
- 一键配置必须先探测现状、备份配置并报告变更。
- 无法获得视觉证据时，不把对象核验表述为视觉核验。
- 未经任务明确授权，不修改或保存DWG。

## 计划的安装流程

1. 检查Windows、AutoCAD 2023、Python和Codex桌面版。
2. 查找现有`multiCAD-mcp`；缺失时自动从上游GitHub克隆。
3. 创建或复用Python虚拟环境并验证MCP启动。
4. 备份Codex配置，生成本机MCP配置并展示变更。
5. 安装插件并提示用户新建聊天进行验证。
6. 运行只读自检，输出`READY`或降级状态。

## 上游声明

`multiCAD-mcp`是独立的第三方项目。本插件计划只探测、配置或引导安装该依赖，不复制其源码，也不代表上游项目维护者。

## 日志位置

默认运行日志计划保存在Windows用户数据目录，不自动写入工程项目。只有用户或项目规则明确要求留档时，才将脱敏后的检查记录复制到项目目录。
