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
    with:
      prefix: license-module # optional prefix for tags like license-module-vX.Y.Z
      suppress_release: false # optional: set true to skip creating a GitHub release
      suppress_tag: false # optional: set true to skip both tag and release creation
      check_last_commit_only: false # optional: set true to only inspect the latest commit

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
          echo "Commit:  ${{ needs.version.outputs.commit_subject }}"
```

### Inputs

- `prefix` _(string, default: empty)_ – Optional prefix prepended to generated tags (for example `license-module-vX.Y.Z`).
- `suppress_release` _(boolean, default: false)_ – When `true`, skips creating a GitHub release while still creating tags (unless suppressed below).
- `suppress_tag` _(boolean, default: false)_ – When `true`, skips creating both the Git tag and the GitHub release.
- `check_last_commit_only` _(boolean, default: false)_ – When `true`, only the most recent commit is inspected to determine the bump type instead of all commits since the previous tag.

### Outputs

- `version` – The calculated semantic version (for example `1.2.3`).
- `tag` – The tag name that would be created (for example `v1.2.3` or `module-v1.2.3`).
- `bump_type` – The bump classification applied (`major`, `minor`, or `patch`).
- `previous_tag` – The most recent matching tag prior to this run, if any.
- `commit_subject` – The commit message subject that determined the bump decision.

### Bump rules

The workflow inspects the latest commit message and applies the following precedence:

- **MAJOR**: If the first word ends with `!:` (for example `feat!:`, `fix!:`, `chore!:`, `feat(scope)!:`).
- **MINOR**: If the subject starts with `feat:` or `feat(<scope>):`, case-insensitive.
- **PATCH**: Any other commit message.

If no existing tags matching `v*` are found, versioning starts from `0.0.0`.

Each run also publishes (or updates) a Git tag matching the new version. By default tags look like `vX.Y.Z`, but you can provide a `prefix` input (for example `license-module`) to emit tags such as `license-module-vX.Y.Z`. The workflow creates a GitHub release with auto-generated release notes for the generated tag. Existing tags or releases are detected and left untouched.
