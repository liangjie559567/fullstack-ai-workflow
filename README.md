# fullstack-ai-workflow-template-repo

一套可发布、可复用的 **AI 全栈开发工作流模板仓库**。

它的目标不是绑定某个单一工具，而是把以下能力统一起来：
- **安装工作流仓库**：如 GSD / Superpowers / gstack-like / 内部模板仓库
- **初始化项目模板**：CLAUDE.md、Cursor Rules、Codex Workflow、测试说明、PRD / SLICE 等
- **统一流程入口**：Discuss -> Plan -> Slice -> Execute -> Verify -> Ship
- **统一执行入口**：通过 `workflow-dispatch.sh` 与 Claude Code / Cursor / Codex 三种宿主集成

---

## 仓库结构

```text
.
├── README.md
├── CHANGELOG.md
├── VERSION
├── LICENSE
├── workflow-repos.manifest.example.json
├── scripts/
│   ├── bootstrap-workflow.sh
│   ├── bootstrap-workflow.ps1
│   ├── apply-workflow-templates.sh
│   ├── apply-workflow-templates.ps1
│   ├── workflow-dispatch.sh
│   ├── workflow-dispatch.ps1
│   ├── workflow-bootstrap-all.sh
│   ├── workflow-bootstrap-all.ps1
│   ├── verify-vendor-deps.sh
│   ├── verify-vendor-deps.ps1
│   ├── upgrade-workflow-templates.sh
│   └── upgrade-workflow-templates.ps1
├── templates/
│   ├── CLAUDE.md
│   ├── AGENTS.md
│   ├── testing.instructions.md
│   ├── stack.env
│   ├── STATE.md
│   ├── CONTEXT.md
│   ├── PRD.md
│   ├── SLICE.md
│   ├── claude/
│   │   ├── workflow.md
│   │   ├── init-workflow.md
│   │   ├── create-slice.md
│   │   └── pre-commit-check.sh
│   ├── codex/
│   │   ├── WORKFLOW.md
│   │   └── PROMPTS.md
│   └── cursor-rules/
│       ├── shared.mdc
│       ├── frontend.mdc
│       ├── backend-api.mdc
│       ├── database.mdc
│       └── deployment.mdc
└── docs/
    └── PUBLISHING.md
```

---

## 发布定位

这个仓库用于被业务项目 **拉取 / vendor / fork / 镜像**，而不是直接作为业务代码仓库使用。

本仓库角色是 **TEMPLATE_SOURCE**：
- `templates/` 是发布模板的唯一权威源
- 不建议在本仓库根目录执行 `init`
- 业务项目通过 manifest + bootstrap 消费本仓库
- 如需自举测试，请使用单独业务项目或示例项目

推荐使用方式：

### 方式 A：作为内部模板仓库
团队维护这个仓库，业务项目通过：
- `workflow-repos.manifest.json`
- `scripts/bootstrap-workflow.sh`
- `scripts/apply-workflow-templates.sh`

把模板拉到项目里。

### 方式 B：作为受控镜像源
把 GSD / Superpowers / gstack-like / 本仓库都镜像到内部 Git 服务，再统一由 manifest 管理版本。

---


## GitHub 发布附加文件

本仓库已经补齐以下 GitHub 直接发布所需文件：
- `.gitignore`
- `.editorconfig`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `.github/ISSUE_TEMPLATE/*`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/workflows/validate-template.yml`

这意味着你可以把它直接推到 GitHub，作为团队模板仓库或公开模板仓库使用。

## 快速开始

### 1. 在业务项目中准备 manifest
复制本仓库中的：

```text
workflow-repos.manifest.example.json
```

并重命名为：

```text
workflow-repos.manifest.json
```

然后把其中的占位 URL 改成团队批准地址。

### 2. 拉取模板仓库与工作流仓库
在业务项目中执行：

```bash
bash scripts/workflow-dispatch.sh install
```

### 3. 应用模板到当前项目

```bash
bash scripts/workflow-dispatch.sh init
```

### 4. 一键执行

```bash
bash scripts/workflow-bootstrap-all.sh
```

### Windows (PowerShell)

```powershell
.\scripts\workflow-dispatch.ps1 install
.\scripts\workflow-dispatch.ps1 init
```

或一键执行：

```powershell
.\scripts\workflow-bootstrap-all.ps1
```

---

## 与 Claude Code / Cursor / Codex 的关系

### Claude Code
- 使用 `.claude/commands/workflow.md` 作为统一入口
- 推荐调用：
  - `/workflow install`
  - `/workflow init`
  - `/workflow status`
  - `/workflow next`
  - `/workflow slice`
  - `/workflow review`
  - `/workflow ship`

### Cursor
- 使用 `.cursor/rules/*.mdc` 与 `AGENTS.md`
- 通过规则约束计划、切片、验证和回滚说明

### Codex
- 使用 `.ai/codex/WORKFLOW.md` 与 `.ai/codex/PROMPTS.md`
- 把实现行为绑定到统一流程骨架

---

## 版本管理建议

- `VERSION`：当前模板版本
- `CHANGELOG.md`：记录模板更新
- Manifest 中固定 `ref` 为 tag 或发布分支
- 对业务项目，推荐通过固定版本升级而非始终跟随 `main`
- `init` / upgrade apply 后会写入 `.ai/template-version`
- 升级已有业务项目时先运行 dry-run/diff，再决定是否覆盖

---

## 安全建议

- 不要让 Skill 直接执行未知远程安装脚本
- 只从团队批准地址拉取仓库
- 在 manifest 中固定版本号或 tag
- 模板应用脚本默认 **只创建缺失文件，不覆盖已有文件**
- 使用 `scripts/verify-vendor-deps.*` 校验外部 vendor tag 与本地安装状态
- 内部镜像场景只替换 manifest `url`，保持 `ref` 不变

---

## 升级与校验

Vendor 依赖校验：

```bash
bash scripts/verify-vendor-deps.sh workflow-repos.manifest.json
```

```powershell
.\scripts\verify-vendor-deps.ps1 workflow-repos.manifest.json
```

模板升级：

```bash
bash scripts/upgrade-workflow-templates.sh --dry-run
bash scripts/upgrade-workflow-templates.sh --diff
bash scripts/upgrade-workflow-templates.sh --apply-safe
bash scripts/upgrade-workflow-templates.sh --apply --backup
```

```powershell
.\scripts\upgrade-workflow-templates.ps1 -DryRun
.\scripts\upgrade-workflow-templates.ps1 -Diff
.\scripts\upgrade-workflow-templates.ps1 -ApplySafe
.\scripts\upgrade-workflow-templates.ps1 -Apply -Backup
```

详见：
- `docs/UPGRADE.md`
- `docs/VENDOR_COMPATIBILITY.md`
- `REPOSITORY_ROLE.md`

## 推荐发布流程

1. 在本仓库更新模板文件
2. 更新 `CHANGELOG.md`
3. 更新 `VERSION`
4. 打 tag
5. 在业务项目 manifest 中升级 `ref`
6. 通过 `bootstrap-workflow.sh` 拉取新版本



## GitHub 首发完整套件

本仓库额外提供以下首发所需文件：
- `CODEOWNERS`
- `REPOSITORY_METADATA.md`
- `.github/release-drafter.yml`
- `.github/workflows/release-drafter.yml`
- `.github/labels.yml`
- `.github/workflows/label-check.yml`
- `docs/releases/RELEASE_NOTES_v0.1.0.md`
- `docs/GITHUB_LAUNCH_CHECKLIST.md`

这意味着你可以直接将本仓库作为 GitHub 首发模板仓库进行发布、打 tag、配置 Release 和治理规则。
