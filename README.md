# c4a8-code-reusable-actions

Reusable GitHub workflows for repositories in the c4a8 org.

## Semantic versioning workflow

Use the reusable workflow at `.github/workflows/semver-version.yml` to compute the next semantic version, expose it as an output, and tag the current commit.

### Calling the workflow

```yaml
# .github/workflows/release.yml in a consumer repository
name: Release

on:
  push:
    branches:
      - main

jobs:
  version:
    uses: c4a8/c4a8-code-reusable-actions/.github/workflows/semver-version.yml@main

  publish:
    runs-on: ubuntu-latest
    needs: version
    steps:
      - name: Show generated version
        run: |
          echo "Version: ${{ needs.version.outputs.version }}"
          echo "Tag:     ${{ needs.version.outputs.tag }}"
          echo "Bump:    ${{ needs.version.outputs.bump_type }}"
          echo "Prev tag:${{ needs.version.outputs.previous_tag }}"
```

### Bump rules

The workflow inspects the latest commit message and applies the following precedence:

- **MAJOR**: If the first word ends with `!:` (for example `feat!:`, `fix!:`, `chore!:`, `feat(scope)!:`).
- **MINOR**: If the subject starts with `feat:` or `feat(<scope>):`, case-insensitive.
- **PATCH**: Any other commit message.

If no existing tags matching `v*` are found, versioning starts from `0.0.0`.

Each run also publishes (or updates) a Git tag matching the new version (`vX.Y.Z`) and creates a GitHub release with auto-generated release notes for that tag. Existing tags or releases are detected and left untouched.
