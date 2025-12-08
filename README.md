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
      is_prerelease: false # optional: set true to generate a prerelease version
      prerelease_name: prerelease # optional: name for prerelease identifier (e.g., 'rc', 'alpha', 'beta')

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
- `is_prerelease` _(boolean, default: false)_ – When `true`, generates a prerelease version (for example `1.2.3-rc.1`).
- `prerelease_name` _(string, default: "prerelease")_ – Name for the prerelease identifier (for example `rc`, `alpha`, `beta`).

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

## Commit message hook

A PowerShell-based Git commit-msg hook is available at `git/hooks/commit-msg.ps1` to enforce the [Conventional Commits](https://www.conventionalcommits.org/) standard locally before commits are created.

### Installation

Copy the hook script to your repository's `.git/hooks` directory (if you are using linux or macOS: copy it without the `.ps1` extension or wrap it in a shell script that calls PowerShell):

**On macOS and Linux you have to make the file executable after copying:**
```bash
chmod +x .git/hooks/commit-msg
```

### What it validates

The hook validates that commit messages follow the Conventional Commits format:

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

#### Valid types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Code style changes (formatting, missing semicolons, etc.) |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvements |
| `test` | Adding or correcting tests |
| `build` | Changes to build system or dependencies |
| `ci` | Changes to CI configuration files and scripts |
| `chore` | Other changes that don't modify src or test files |
| `revert` | Reverts a previous commit |
| `deps` | Dependency updates |

#### Examples

```
feat: add user authentication
fix(api): resolve null reference exception
feat(auth)!: change login flow (breaking change)
docs: update README with setup instructions
```

### Warnings

The hook will display warnings (but not reject the commit) for:

- **Long subject lines**: Subject lines longer than 72 characters
- **Missing breaking change documentation**: When `!` is used but no `BREAKING CHANGE:` section is present in the body
