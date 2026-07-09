# Publishing Guide

## 目标
把本仓库作为团队级 AI 开发流程模板仓库发布，并供业务项目通过 manifest 拉取。

## 发布步骤
1. 更新 templates/ 与 scripts/
2. 更新 VERSION
3. 更新 CHANGELOG.md
4. 在 Git 仓库打 tag，例如 v0.1.0
5. 更新业务项目中的 workflow-repos.manifest.json
6. 在业务项目中执行 bootstrap/update

## 维护者 checklist
- `CHANGELOG.md` 必须标注 breaking changes。
- 如果模板路径、初始化目标路径或 manifest 字段变化，更新 `docs/UPGRADE.md`。
- 如果 vendor 版本变化，更新 `workflow-repos.manifest.example.json` 与 `docs/VENDOR_COMPATIBILITY.md`。
- 发布前运行模板校验 workflow，至少覆盖 shell/PowerShell 脚本语法检查。
- 对业务项目升级，先运行 upgrade dry-run/diff，再决定是否 `--apply-safe` 或 `--apply --backup`。

## 升级原则
- 小改动：patch
- 模板结构扩展：minor
- 破坏兼容：major

## 兼容性说明
- scripts/apply-workflow-templates.sh 默认不覆盖已有文件
- 如需升级已有模板，建议先比较 diff，再人工合并
- Windows 用户使用 `scripts/workflow-dispatch.ps1` 与 `scripts/workflow-bootstrap-all.ps1`
