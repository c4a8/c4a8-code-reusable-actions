This contrib file uses the [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119) requrement levels.

# Commits

- Commits on the main branch **MUST** follow the [conventional commits guidelines](https://www.conventionalcommits.org/en/v1.0.0/#summary).
- Commits on feature branches **SHOULD** follow the [conventional commits guidelines](https://www.conventionalcommits.org/en/v1.0.0/#summary).
- Commits with breaking changes **MUST** use the `!` notation. Example: `feat!: Awesome feature that breaks stuff`

# Branches

- You **MUST** new branches for every feature/fix/chore etc. you are implementing.
- You **MAY** group multiple minor fixes into one fix branch. Feature branches **SHOULD** always be single feature only.
- Your branchens **SHOULD** begin with the [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/#summary) type you are planning to implement followed by a `/` (e.g. `feat/some-feature`, `fix/some-bug`, `docs/some-docs`)

# Contributing

- To get your changes on the main branch you **MUST** create a PR.
- The title of the PR **SHOULD** start with the same types as outlined in the [conventional commits guidelines](https://www.conventionalcommits.org/en/v1.0.0/#summary).
- When merging the PR you **MUST** squash.
- When merging the PR you **MUST** make sure that the commit message created follows the [conventional commits guidelines](https://www.conventionalcommits.org/en/v1.0.0/#summary).
