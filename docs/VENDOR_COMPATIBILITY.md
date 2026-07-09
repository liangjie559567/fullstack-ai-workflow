# Vendor Compatibility

This matrix records vendor versions tested with each template release.

| Template version | gsd | superpowers | fullstack-ai-workflow | Notes |
| --- | --- | --- | --- | --- |
| 0.1.0 | v1.6.1 | v6.1.1 | v0.1.0 | Default manifest combination |

## Verification

Run:

```bash
bash scripts/verify-vendor-deps.sh workflow-repos.manifest.json
```

```powershell
.\scripts\verify-vendor-deps.ps1 workflow-repos.manifest.json
```

The report uses:

- `OK`: remote tag exists and local vendor matches.
- `MISSING_TAG`: manifest ref is not present upstream.
- `CLONE_FAILED`: local vendor directory is missing.
- `VERSION_MISMATCH`: local vendor version does not match the manifest ref.

For internal mirrors, keep `ref` unchanged and replace `url` with the approved Git mirror.
