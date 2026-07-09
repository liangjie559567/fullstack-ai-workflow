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

## 升级原则
- 小改动：patch
- 模板结构扩展：minor
- 破坏兼容：major

## 兼容性说明
- scripts/apply-workflow-templates.sh 默认不覆盖已有文件
- 如需升级已有模板，建议先比较 diff，再人工合并
