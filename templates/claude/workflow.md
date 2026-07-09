# workflow

支持动作：install / init / status / next / slice / review / ship

规则：
1. install 调用 scripts/workflow-dispatch.sh install
2. init 调用 scripts/workflow-dispatch.sh init
3. status 调用 scripts/workflow-dispatch.sh status
4. next 调用 scripts/workflow-dispatch.sh next
5. slice 参考 create-slice.md
6. review 输出结构化 review 清单
7. ship 输出结构化 ship 清单

每次执行后都输出：
- 当前阶段
- 本次动作
- 结果摘要
- 风险与待确认
- 下一步建议
