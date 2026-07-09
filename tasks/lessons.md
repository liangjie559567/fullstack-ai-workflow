# Lessons

## Manifest upstreams must be verified per repository

Do not assume every workflow dependency lives under the same GitHub owner as the template repository. Verify each manifest URL and ref against the actual upstream before running install.

Current verified upstreams:
- `gsd`: `https://github.com/open-gsd/gsd-core.git` at `v1.6.1`
- `superpowers`: `https://github.com/obra/superpowers.git` at `v6.1.1`
- `fullstack-ai-workflow`: `https://github.com/liangjie559567/fullstack-ai-workflow.git` at `v0.1.0`
