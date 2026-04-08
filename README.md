# c4a8-code-reusable-actions

Reusable GitHub workflows for repositories in the c4a8 org.

# Table of contents

- [Publish NuGet package workflow](#publish_nuget)
  - [Calling the workflow](#nuget_calling)
  - [Inputs](#nuget_inputs)
- [Epoch Semantic Versioning workflow](#epoch_versioning)
  - [Calling the workflow](#epoch_semantic_calling)
  - [Inputs](#epoch_semantic_inputs)
  - [Outputs](#epoch_semantic_outputs)
  - [Bump rules](#epoch_semantic_bump)
- [Semantic Versioning workflow](#semantic_versioning)
  - [Calling the workflow](#semantic_calling)
  - [Inputs](#semantic_inputs)
  - [Outputs](#semantic_outputs)
  - [Bump rules](#semantic_bump)
  - [Commit message hook](#semantic_hook)
  - [Installation](#semantic_install)
    - [Windows](#semantic_windows)
    - [Mac / Linux](#semantic_linux)
  - [What it validates](#semantic_validate)
    - [Valid types](#semantic_types)
    - [Examples](#semantic_examples)
  - [Warnings](#semantic_warnings)

## Publish NuGet package workflow <a name="publish_nuget" id="publish_nuget"></a>

This workflow simplifies the process of publishing NuGet packages. Use this reusable workflow at `.github/workflows/publish-nuget-package-github.yml`. It is designed to be used for publishing packages in the package space of a GitHub organization.

### Calling the workflow <a name="nuget_calling" id="nuget_calling"></a>

```yaml
# .github/workflows/publish-nuget-package-github.yml in a consumer repository
name: Publish NuGet package

on:
  push:
    branches:
      - main

jobs:
  publish:
    uses: c4a8/c4a8-code-reusable-actions/.github/workflows/publish-nuget-package-github.yml@main
    with:
      dotnet_version: "10.x" # required: version of .NET SDK to use
      project_path: "project/project.csproj" # required: path to the .NET project file
      package_output: "project/bin/Release" # required: output directory for the NuGet package
      package_version: "0.0.1" # required: version of the NuGet package to publish
      assembly_version: "0.0.1" # optional: set specific assembly version
    secrets:
      github_pat: your-pat-token # required: GitHub Personal Access Token with 'write:packages' scope - use GitHub's secret vars for this
```

### Inputs <a name="nuget_inputs" id="nuget_inputs"></a>

- `dotnet_version` _(string, default: empty)_ – Version of .NET SDK to use (e.g., '10.x').
- `project_path` _(string, default: empty)_ – Path to the .NET project file (e.g., 'project/project.csproj').
- `package_output` _(string, default: empty)_ – Output directory for the NuGet package (e.g., 'project/bin/Release').
- `package_version` _(string, default: empty)_ – Version of the NuGet package to publish (e.g., '1.0.0').
- `assembly_version` _(string, default: package version)_ – (Optional) Set specific assembly version (e.g., '1.0.0'). If not set, it will default to package version. This version usually has the same value as the package_version.
- `github_pat` _(string, default: empty)_ – GitHub Personal Access Token with 'write:packages' scope. Use it as secret variable -> `${{ secrets.GITHUB_TOKEN }}`.

## Epoch Semantic Versioning workflow <a name="epoch_versioning" id="epoch_versioning"></a>

This workflow generates an epoch semantic version of the form `vYYYY.WW.P` (e.g. `v2026.8.2`), where `YYYY` is the ISO year, `WW` is the ISO calendar week, and `P` is the patch level.

The bump type is determined from commit messages (same rules as the [Semantic Versioning](#semantic_bump) workflow):

- **Release** — triggered by `feat:`, `feat(<scope>):`, `BREAKING CHANGE:`, or any type ending in `!:` (e.g. `fix!:`).
  - If the current calendar week/year **differs** from the previous stable tag: advance to the current year and week, reset patch to `0`.
  - If the current calendar week/year is the **same** as the previous stable tag: increment patch (behaves like a patch bump).
- **Patch** — any other commit message: increment the patch level and keep the year and week of the previous stable tag, regardless of the current date.
  Use the reusable workflow at `.github/workflows/epoch-semver-version.yml` to compute the next epoch semantic version, expose it as an output, and tag the current commit.

**Note:** This workflow is very similar to the [**Semantic Versioning workflow**](#semantic_versioning). So please fall back to that documentation for further information.

### Calling the workflow <a name="epoch_semantic_calling" id="epoch_semantic_calling"></a>

```yaml
# .github/workflows/epoch-semver-version.yml in a consumer repository
name: Release

on:
  push:
    branches:
      - main

jobs:
  version:
    uses: c4a8/c4a8-code-reusable-actions/.github/workflows/epoch-semver-version.yml@main
    with:
      prefix: license-module # optional: prefix for tags like license-module-vX.Y.Z
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

### Inputs <a name="epoch_semantic_inputs" id="epoch_semantic_inputs"></a>

- `prefix` _(string, default: empty)_ – Optional prefix prepended to generated tags (for example `license-module-vYYYY.WW.P`).
- `suppress_release` _(boolean, default: false)_ – When `true`, skips creating a GitHub release while still creating tags (unless suppressed below).
- `suppress_tag` _(boolean, default: false)_ – When `true`, skips creating both the Git tag and the GitHub release.
- `check_last_commit_only` _(boolean, default: false)_ – When `true`, only the most recent commit is inspected to determine the bump type instead of all commits since the previous tag.
- `is_prerelease` _(boolean, default: false)_ – When `true`, generates a prerelease version (for example `v2026.8.2-rc.1`).
- `prerelease_name` _(string, default: "prerelease")_ – Name for the prerelease identifier (for example `rc`, `alpha`, `beta`).

### Outputs <a name="epoch_semantic_outputs" id="epoch_semantic_outputs"></a>

- `version` – The calculated semantic version (for example `2026.8.2`).
- `tag` – The tag name that would be created (for example `v2026.8.2` or `module-v2026.8.2`).
- `bump_type` – The bump classification applied (`release` or `patch`).
- `previous_tag` – The most recent matching tag prior to this run, if any.
- `commit_subject` – The commit message subject that determined the bump decision.

### Bump rules <a name="epoch_semantic_bump" id="epoch_semantic_bump"></a>

The workflow inspects commit messages and applies the following precedence:

- **Release**: If any commit matches `feat:`, `feat(<scope>):`, `BREAKING CHANGE:`, or any type ending in `!:` (for example `feat!:`, `fix!:`, `chore!:`, `feat(scope)!:`).
- **Patch**: Any other commit message.

If no existing epoch-versioned tags are found, versioning starts from `{currentYear}.{currentWeek}.0` (for a release bump) or `{currentYear}.{currentWeek}.1` (for a patch bump).

Each run also publishes (or updates) a Git tag matching the new version. By default tags look like `vYYYY.WW.P`, but you can provide a `prefix` input (for example `license-module`) to emit tags such as `license-module-vYYYY.WW.P`. The workflow creates a GitHub release with auto-generated release notes for the generated tag. Existing tags or releases are detected and left untouched.

## Semantic Versioning workflow <a name="semantic_versioning" id="semantic_versioning"></a>

Use the reusable workflow at `.github/workflows/semver-version.yml` to compute the next semantic version, expose it as an output, and tag the current commit.

### Calling the workflow <a name="semantic_calling" id="semantic_calling"></a>

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
      prefix: license-module # optional: prefix for tags like license-module-vX.Y.Z
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

### Inputs <a name="semantic_inputs" id="semantic_inputs"></a>

- `prefix` _(string, default: empty)_ – Optional prefix prepended to generated tags (for example `license-module-vX.Y.Z`).
- `suppress_release` _(boolean, default: false)_ – When `true`, skips creating a GitHub release while still creating tags (unless suppressed below).
- `suppress_tag` _(boolean, default: false)_ – When `true`, skips creating both the Git tag and the GitHub release.
- `check_last_commit_only` _(boolean, default: false)_ – When `true`, only the most recent commit is inspected to determine the bump type instead of all commits since the previous tag.
- `is_prerelease` _(boolean, default: false)_ – When `true`, generates a prerelease version (for example `1.2.3-rc.1`).
- `prerelease_name` _(string, default: "prerelease")_ – Name for the prerelease identifier (for example `rc`, `alpha`, `beta`).

### Outputs <a name="semantic_outputs" id="semantic_outputs"></a>

- `version` – The calculated semantic version (for example `1.2.3`).
- `tag` – The tag name that would be created (for example `v1.2.3` or `module-v1.2.3`).
- `bump_type` – The bump classification applied (`major`, `minor`, or `patch`).
- `previous_tag` – The most recent matching tag prior to this run, if any.
- `commit_subject` – The commit message subject that determined the bump decision.

### Bump rules <a name="semantic_bump" id="semantic_bump"></a>

The workflow inspects the latest commit message and applies the following precedence:

- **MAJOR**: If the first word ends with `!:` (for example `feat!:`, `fix!:`, `chore!:`, `feat(scope)!:`).
- **MINOR**: If the subject starts with `feat:` or `feat(<scope>):`, case-insensitive.
- **PATCH**: Any other commit message.

If no existing tags matching `v*` are found, versioning starts from `0.0.0`.

Each run also publishes (or updates) a Git tag matching the new version. By default tags look like `vX.Y.Z`, but you can provide a `prefix` input (for example `license-module`) to emit tags such as `license-module-vX.Y.Z`. The workflow creates a GitHub release with auto-generated release notes for the generated tag. Existing tags or releases are detected and left untouched.

### Commit message hook <a name="semantic_hook" id="semantic_hook"></a>

A PowerShell-based Git commit-msg hook is available at `git/hooks/enforceConventionalCommits/commit-msg.ps1` to enforce the [Conventional Commits](https://www.conventionalcommits.org/) standard locally before commits are created.

### Installation <a name="semantic_install" id="semantic_install"></a>

#### Windows <a name="semantic_windows" id="semantic_windows"></a>

1. Copy **both** the `commit-msg.ps1` and `commit-msg` to your repository's `.git/hooks` directory

#### Mac / Linux <a name="semantic_linux" id="semantic_linux"></a>

1. Copy just the `commit-msg.ps1` to your repository's `.git/hooks` directory
1. Remove the .ps1 ending (so the final filename inside the `.git/hooks` directory is `commit-msg`)
1. Add execution permissions:

```bash
chmod +x .git/hooks/commit-msg
```

### What it validates <a name="semantic_validate" id="semantic_validate"></a>

The hook validates that commit messages follow the Conventional Commits format:

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

#### Valid types <a name="semantic_types" id="semantic_types"></a>

| Type       | Description                                               |
| ---------- | --------------------------------------------------------- |
| `feat`     | A new feature                                             |
| `fix`      | A bug fix                                                 |
| `docs`     | Documentation only changes                                |
| `style`    | Code style changes (formatting, missing semicolons, etc.) |
| `refactor` | Code change that neither fixes a bug nor adds a feature   |
| `perf`     | Performance improvements                                  |
| `test`     | Adding or correcting tests                                |
| `build`    | Changes to build system or dependencies                   |
| `ci`       | Changes to CI configuration files and scripts             |
| `chore`    | Other changes that don't modify src or test files         |
| `revert`   | Reverts a previous commit                                 |
| `deps`     | Dependency updates                                        |

#### Examples <a name="semantic_examples" id="semantic_examples"></a>

```
feat: add user authentication
fix(api): resolve null reference exception
feat(auth)!: change login flow (breaking change)
docs: update README with setup instructions
```

### Warnings <a name="semantic_warnings" id="semantic_warnings"></a>

The hook will display warnings (but not reject the commit) for:

- **Long subject lines**: Subject lines longer than 72 characters
- **Missing breaking change documentation**: When `!` is used but no `BREAKING CHANGE:` section is present in the body
