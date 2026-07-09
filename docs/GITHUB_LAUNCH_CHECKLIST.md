# GitHub Launch Checklist

## Repository Setup
- [ ] Choose final repository name
- [ ] Set repository description
- [ ] Add suggested topics
- [ ] Choose visibility: internal or public
- [ ] Set default branch to `main`

## Governance
- [ ] Replace placeholder usernames in `CODEOWNERS`
- [ ] Enable branch protection on `main`
- [ ] Require pull request before merge
- [ ] Require status checks to pass
- [ ] Require Code Owner review

## Security
- [ ] Review `SECURITY.md`
- [ ] Confirm no internal URLs remain in docs/templates
- [ ] Replace all placeholder mirror URLs
- [ ] Verify example files contain no real secrets

## Release Setup
- [ ] Confirm `VERSION`
- [ ] Update `CHANGELOG.md`
- [ ] Review `docs/releases/RELEASE_NOTES_v0.1.0.md`
- [ ] Create Git tag `v0.1.0`
- [ ] Enable GitHub Releases

## CI / Automation
- [ ] Confirm `.github/workflows/validate-template.yml` passes
- [ ] Optionally enable Release Drafter
- [ ] Optionally sync labels from `.github/labels.yml`

## Downstream Adoption
- [ ] Copy `workflow-repos.manifest.example.json` to downstream project
- [ ] Replace approved mirror URLs
- [ ] Run bootstrap scripts in test project
- [ ] Validate templates are applied without overwriting files
