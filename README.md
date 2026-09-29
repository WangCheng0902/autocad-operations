# autocad-operations

面向Codex桌面版的AutoCAD工程操作插件。它提供任务范围读取、对象级修改、视觉核验、故障降级和结构化问题记录工作流。

## 首版支持范围

- Windows 11
- AutoCAD 2023
- Codex桌面版
- 外部MCP依赖：[AnCode666/multiCAD-mcp](https://github.com/AnCode666/multiCAD-mcp)
- Computer Use为推荐依赖，不是对象级CAD操作的强制依赖

## 当前状态

版本`0.1.0-alpha.1`为首个可安装预览版。它包含完整Skill经验库、一键安装、环境自检和协作基础设施，但仍需在第二台Windows 11＋AutoCAD 2023电脑完成干净安装验证。

- 作者：Kristin_W
- 许可证：MIT
- 源码仓库：https://github.com/WangCheng0902/autocad-operations

## 设计原则

- 插件不包含个人绝对路径、访问令牌、项目DWG或企业敏感资料。
- 公共工作流与每台电脑的AutoCAD/MCP配置分离。
- 一键配置必须先探测现状、备份配置并报告变更。
- 无法获得视觉证据时，不把对象核验表述为视觉核验。
- 未经任务明确授权，不修改或保存DWG。

## AutoCAD窗口视觉访问与经验保存

在一次Windows／AutoCAD 2023检查中，某个Computer Use入口只列出浏览器，AutoCAD截图路径也报告找不到窗口；但已安装Computer Use技能提供的原生`@oai/sky`入口找到了同一AutoCAD窗口。窗口最初处于最小化状态，激活后成功取得并查看图纸截图。因此，单一入口找不到窗口不能直接判定AutoCAD或全部Computer Use不可用；视觉访问是否成功应以实际截图为准。

复用步骤写在[原生窗口视觉访问指引](plugins/autocad-operations/skills/autocad-operations/references/native-window-visual-access.md)，由插件的`SKILL.md`在视觉检查或截图失败时引导读取。指引要求先检查当前安装的Computer Use版本，再按实际窗口标题选择目标；不会固定使用某个DWG名称或窗口ID。

这项经验维护在本仓库的`plugins/autocad-operations/`源目录中，因为Codex安装后的插件缓存可能在重新安装或升级时重建。只修改缓存无法保证经验留存；从本仓库安装或更新插件时，应以这里的源文件为准。

## 计划的安装流程

1. 检查Windows、AutoCAD 2023、Python和Codex桌面版。
2. 查找现有`multiCAD-mcp`；缺失时自动从上游GitHub克隆。
3. 创建或复用Python虚拟环境并验证MCP启动。
4. 备份Codex配置，生成本机MCP配置并展示变更。
5. 安装插件并提示用户新建聊天进行验证。
6. 运行只读自检，输出`READY`或降级状态。

## 安装前检查

正式安装前请确认：

- Windows 11；
- AutoCAD 2023；
- Python 3.10或更高版本；
- Git；
- Codex桌面版，并且PowerShell中可以运行`codex --version`；
- 已安装或准备自动下载`multiCAD-mcp`；
- 能够访问GitHub和Python软件包源。

可在PowerShell中执行：

```powershell
python --version
git --version
codex --version
Test-Path "C:\Program Files\Autodesk\AutoCAD 2023\acad.exe"
```

## 最安全、最稳定的安装方法

如果电脑已经安装了`multiCAD-mcp`，建议始终明确传入它的实际目录。这样可以避免安装器因无法发现非标准路径而重新克隆一份源码。

### 1. 克隆本插件

```powershell
git clone https://github.com/WangCheng0902/autocad-operations.git
cd autocad-operations
Set-ExecutionPolicy -Scope Process Bypass
```

### 2. 确认现有multiCAD-mcp路径

以下仅为示例，请换成实际位置：

```powershell
$MultiCadPath = "D:\GitHub\multiCAD-mcp"
Test-Path "$MultiCadPath\pyproject.toml"
Test-Path "$MultiCadPath\src\server.py"
```

两个检查结果都应为`True`。如果不是，请先找出正确路径，不要继续正式安装。

### 3. 先进行无修改模拟

```powershell
.\install.ps1 -DryRun -Yes -MultiCadPath $MultiCadPath
```

模拟模式只显示计划执行的步骤，不会修改Codex配置、MCP或插件安装状态。检查输出中的`multiCAD-mcp`路径是否正确。

### 4. 进行首次正式安装

```powershell
.\install.ps1 -MultiCadPath $MultiCadPath
```

首次安装不建议使用`-Yes`。如果Codex中已经存在名为`multicad`的MCP配置，安装器会提示是否替换。确认路径和备份信息正确后再输入`y`。

安装器会：

1. 备份`%USERPROFILE%\.codex\config.toml`；
2. 复用指定的`multiCAD-mcp`源码；
3. 在`%LOCALAPPDATA%\autocad-operations\venvs\multicad`创建独立虚拟环境；
4. 在隔离环境中安装`multiCAD-mcp`依赖；
5. 通过Codex CLI重新登记`multicad` MCP；
6. 注册本地Marketplace并安装插件；
7. 运行只读环境诊断。

### 5. 重启并核验

安装完成后完全退出并重新启动Codex桌面版，然后新建聊天。可在PowerShell中核验：

```powershell
codex mcp get multicad --json
codex plugin list --json
python .\scripts\check_environment.py --multi-cad $MultiCadPath
```

诊断结果为`DEGRADED_OBJECT_ONLY`是正常的：它表示AutoCAD对象接口已配置，但Computer Use视觉能力仍需在新的Codex聊天中单独验证。

## 避免重复安装

- **AutoCAD和系统Python不会被重复安装。** 安装器只检查它们是否可用。
- **明确使用`-MultiCadPath`可避免重复克隆源码。** 如果没有指定路径，安装器只会自动查找插件仓库的同级目录和插件管理目录。
- **独立虚拟环境属于有意的隔离设计。** 即使现有`multiCAD-mcp`已经有自己的`.venv`，插件仍会创建专用环境，避免破坏同事原有环境。
- **已有`multicad` MCP不会并列重复登记。** 安装器会在备份配置后询问是否替换同名配置。
- **相同Marketplace路径会直接复用。** 重复运行安装器可用于修复或刷新安装。
- 无人值守安装可使用`.\install.ps1 -Yes -MultiCadPath $MultiCadPath`，但只建议在已经完成首次交互式安装后使用。

## 未安装multiCAD-mcp时

如果没有现有源码，可以直接运行：

```powershell
.\install.ps1
```

安装器会将上游项目克隆到`%LOCALAPPDATA%\autocad-operations\dependencies\multiCAD-mcp`。此路径仍需在第二台干净电脑上完成正式验证，因此公开预览阶段更推荐使用明确的现有`-MultiCadPath`。

## 安装失败时

- 不要连续重复执行安装命令；先阅读`%LOCALAPPDATA%\autocad-operations\logs`中的最新日志。
- Codex配置备份位于`%USERPROFILE%\.codex`，文件名包含`config.toml.autocad-operations`和时间戳。
- 如果失败发生在替换MCP之后，可根据日志恢复最近备份，或重新运行安装器并指定正确的`-MultiCadPath`。
- AutoCAD与Codex应尽量以相同权限级别运行，避免一个使用管理员权限、另一个使用普通权限导致COM访问失败。

## 卸载

```powershell
.\uninstall.ps1
```

默认只移除插件和Marketplace。使用`-RemoveMcp`可同时移除MCP注册；使用`-RemoveDependencies`可删除由插件管理的依赖与日志，删除前仍会确认。

## 环境自检

```powershell
python .\scripts\check_environment.py --multi-cad "C:\path\to\multiCAD-mcp"
```

自检不修改系统。Computer Use必须在Codex会话内单独验证，因此命令行自检最高先报告对象操作就绪，视觉能力在实际会话确认后才能升级为完整`READY`。

## 上游声明

`multiCAD-mcp`是独立的第三方项目。本插件计划只探测、配置或引导安装该依赖，不复制其源码，也不代表上游项目维护者。

## 共同维护

欢迎通过Issue和Pull Request补充CAD操作经验、安装兼容性和故障解决方法。候选经验必须提供可观察事实和验证范围，不能把单张DWG中的临时办法直接提升为全局规则。

- 日常提交要求：[CONTRIBUTING.md](CONTRIBUTING.md)
- 新图种Skill、经验分级、复验、发布与同事更新流程：[MAINTENANCE_GUIDE.md](MAINTENANCE_GUIDE.md)

## 日志位置

默认运行日志计划保存在Windows用户数据目录，不自动写入工程项目。只有用户或项目规则明确要求留档时，才将脱敏后的检查记录复制到项目目录。
