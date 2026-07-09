# init-workflow

目标：初始化 workflow 文件，不覆盖已有文件。

执行步骤：
1. 检查 workflow-repos.manifest.json 与 scripts/ 是否存在。
2. 缺失则创建；存在则跳过并报告。
3. 应用模板到当前仓库。
4. 识别技术栈并提醒更新 .ai/stack.env。
5. 输出首个试跑建议。
