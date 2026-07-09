# Security Policy

## Supported Versions

| Version | Supported |
| --- | --- |
| 0.1.x | Yes |

## Reporting a Vulnerability

请不要在公开 issue 中直接披露安全问题。

建议流程：
1. 私下联系维护者或内部安全渠道
2. 提供受影响文件、触发条件、影响范围
3. 标注是否涉及：
   - 远程脚本执行
   - 未经批准的仓库来源
   - 模板覆盖风险
   - 密钥 / 凭据泄露
4. 在修复和验证完成后再公开摘要

## Security Principles
- 不允许默认执行未知远程安装脚本
- manifest 中的仓库地址必须可审计
- 模板应用默认不覆盖已有文件
- 示例配置不得包含真实密钥
