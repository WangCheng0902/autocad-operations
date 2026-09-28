# Contributing

感谢改进`autocad-operations`。

## 工作方式

1. 从`main`创建主题分支，例如`feature/environment-check`或`fix/cad-timeout`。
2. 将一次Pull Request限制在一个清晰问题或能力范围内。
3. 修改Skill时说明触发场景、证据边界和不适用条件。
4. 新的故障经验先作为候选规则；至少在另一张DWG或另一台电脑验证后，再建议提升为默认规则。
5. 不提交DWG、客户资料、项目位号、用户名绝对路径、访问令牌或未经许可的截图。
6. 运行本地校验并在Pull Request中填写结果。

## 本地校验

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" ".\plugins\autocad-operations\skills\autocad-operations"
python "$env:USERPROFILE\.codex\skills\.system\plugin-creator\scripts\validate_plugin.py" ".\plugins\autocad-operations"
python -m py_compile .\scripts\check_environment.py
python -m py_compile .\plugins\autocad-operations\skills\autocad-operations\scripts\record_cad_event.py
python -m py_compile .\plugins\autocad-operations\skills\autocad-operations\scripts\summarize_cad_run.py
.\install.ps1 -DryRun -Yes
```

若本机没有内置校验脚本，请在Pull Request中说明，并依赖仓库自动检查。

## 经验记录最低要求

- 环境：Windows、AutoCAD、Codex和MCP版本；
- 症状：可直接观察的错误或错误结果；
- 范围：涉及的对象类型、操作和文件状态；
- 恢复：采取了什么措施；
- 核验：怎样确认恢复或修正有效；
- 限制：尚未确认的版本、图纸或场景。

## Pull Request审查

- `main`不接受未经审查的强制推送。
- 安装器、删除逻辑、DWG写入规则和权限边界属于高风险修改，应由维护者重点复核。
- 合并前需要通过Skill、插件、Python和敏感信息检查。
