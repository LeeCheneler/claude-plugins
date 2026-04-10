---
name: patch-dependencies
description: Patch Dependabot security vulnerabilities across one or more GitHub repositories. Accepts repos as arguments (owner/repo, local paths, or a file listing repos) or prompts for them. Opens safe PRs with lockfile-only changes. Invoke with /patch-dependencies.
---

# Skill: Patch Security Dependencies

Patch Dependabot security alerts across one or more GitHub repositories. One PR per repo. Minimum
viable change — overrides/resolutions and lockfile only.

---

## Hard Constraints

These are non-negotiable. If you find yourself about to violate one, stop and reassess.

### 1. Minimum viable change

The ONLY files you may modify are:

- `package.json` (overrides/resolutions section, and `dependencies`/`devDependencies` ONLY when
  the vulnerable package is a direct dependency — see below)
- The lockfile (`pnpm-lock.yaml`, `yarn.lock`, or `package-lock.json`)

If `git diff --stat` shows ANY other file changed, you have made a mistake. Revert and redo.

**Transitive vulnerabilities** (the vulnerable package is NOT in `dependencies`/`devDependencies`):
fix via overrides/resolutions only. Do NOT bump direct deps to try to pull in a transitive fix —
this introduces unrelated changes from the new version of the direct dep (new features, behaviour
changes, API shifts) that have nothing to do with the security patch.

**Direct vulnerabilities** (the vulnerable package IS in `dependencies`/`devDependencies`): bump
that specific package to the patched version. Stay within the same major version. Do not bump any
other packages.

You MUST NOT:

- Run `pnpm update`, `yarn upgrade`, or `npm update` without targeting a specific vulnerable
  package (these bump everything indiscriminately)
- Modify source code, config files, test files, or CI files
- Delete or regenerate the lockfile (no `--force`, no deleting the lockfile and reinstalling)

### 2. Overrides must be scoped to the same major version

Every override/resolution MUST constrain its output to the same major version line as the
vulnerable range. This is the single most common cause of build failures.

**Correct** — stays within major:

```
"brace-expansion@<1.1.13": ">=1.1.13 <2.0.0"
"brace-expansion@>=2.0.0 <2.0.3": ">=2.0.3 <3.0.0"
"picomatch@<2.3.2": ">=2.3.2 <3.0.0"
"picomatch@>=4.0.0 <4.0.4": ">=4.0.4 <5.0.0"
"yaml@>=1.0.0 <1.10.3": ">=1.10.3 <2.0.0"
"yaml@>=2.0.0 <2.8.3": ">=2.8.3 <3.0.0"
```

**Wrong** — crosses major version boundary:

```
"brace-expansion": ">=2.0.3"          # forces v2+ on v1 consumers
"picomatch": ">=4.0.4"                # forces v4 on v2 consumers
"yaml@>=1.0.0 <1.10.3": ">=1.10.3"   # could resolve to v2
```

When `pnpm audit --fix` generates overrides, it frequently produces unbounded ranges that cross
major versions. You MUST review and fix every generated override before proceeding.

### 3. Pin frameworks, range libraries

- **Frameworks** (Next.js, React, Angular, etc.): pin to the exact patched version.
  `"next@>=14.0.0 <14.2.25": "14.2.25"` — not `>=14.2.25`.
  Frameworks frequently ship behaviour changes in patches.
- **Libraries** (handlebars, flatted, etc.): use `>=patch <next-major`.
  `"handlebars@>=4.0.0 <=4.7.8": ">=4.7.9 <5.0.0"`

### 4. No AI references

Do not mention AI, Claude, Anthropic, or any AI tool in commit messages, PR titles, PR bodies,
or branch names.

---

## Input

The user provides repositories in one or more of these forms:

- **GitHub slugs:** `owner/repo` (e.g. `octocat/hello-world`)
- **Bare repo names:** `hello-world` — derive owner from git remote of the current directory
- **Local paths:** `./hello-world` or `/abs/path/to/repo` — derive `owner/repo` via
  `git -C <path> remote get-url origin`
- **A file listing repos:** `./repos.md` — read the file and extract GitHub URLs or
  `owner/repo` patterns

If nothing is provided, use `AskUserQuestion`:

> Which repositories should I patch? Provide GitHub slugs (`owner/repo`), local paths to cloned
> repos, or a file that lists them.

---

## Procedure

### Phase 1 — Resolve Repositories

1. Parse the user's input into a list of `owner/repo` slugs using the rules above.
2. For each repo, check if a local clone exists in or near the working directory.
3. Present the resolved list to the user and confirm before proceeding.

### Phase 2 — Fetch Dependabot Alerts

For each repository, fetch open alerts:

```bash
gh api repos/<owner>/<repo>/dependabot/alerts \
  --jq '[.[] | select(.state == "open") | {
    number,
    package: .security_vulnerability.package.name,
    ecosystem: .security_vulnerability.package.ecosystem,
    severity: .security_advisory.severity,
    summary: .security_advisory.summary,
    vulnerable_range: .security_vulnerability.vulnerable_version_range,
    patched: .security_vulnerability.first_patched_version.identifier
  }]'
```

Present a summary table. Skip repos with zero alerts.

### Phase 3 — Detect Package Manager

For each repo with alerts, determine the package manager:

1. Check `package.json` for `"packageManager"` field.
2. If absent, check for lockfiles: `pnpm-lock.yaml` -> pnpm, `yarn.lock` -> yarn,
   `package-lock.json` -> npm.

If a repo is not cloned locally, ask the user where it is or whether to clone it.

### Phase 4 — Patch Each Repository

Use **parallel agents** (one per repo) for efficiency. Each agent receives the full Hard
Constraints section and follows the steps below.

**Include the entire Hard Constraints section verbatim in every agent prompt.** Do not summarise
or paraphrase it.

#### Step 1: Branch setup

- Check current branch with `git branch --show-current`.
- If NOT on `main`/`master`, use a git worktree to avoid disrupting the user's branch:
  ```bash
  git fetch origin main
  git worktree add ../<repo>-security-patch origin/main
  cd ../<repo>-security-patch
  ```
- If on `main`, pull latest: `git fetch origin main && git pull origin main`
- Create branch: `git checkout -b chore/patch-dependencies-<YYYY-MM-DD>`

#### Step 2: Audit

Run the appropriate audit command to get the current vulnerability list:

- pnpm: `pnpm audit`
- yarn: `yarn audit`
- npm: `npm audit`

Record which packages need patching and what the patched versions are.

#### Step 3: Add overrides/resolutions

**pnpm:** Add entries to `pnpm.overrides` in `package.json`. You MAY run `pnpm audit --fix` as a
starting point, but you MUST then review every generated override against Hard Constraint #2 and
fix any that cross major versions before continuing.

**yarn (v1):** Add `"resolutions"` entries to `package.json`. Use `"**/package": "version"` syntax.
Pin to exact versions: `"**/handlebars": "4.7.9"`.

**npm:** Add `"overrides"` entries to `package.json`.

For every override you write, verify:

- [ ] Left side specifies the vulnerable range
- [ ] Right side stays within the same major version
- [ ] Frameworks are pinned to the exact patched version
- [ ] No duplicate or overlapping entries for the same package

#### Step 4: Install

Run the package manager install to update the lockfile:

- pnpm: `pnpm install`
- yarn: `yarn install`
- npm: `npm install`

Do NOT use `--force`, `--frozen-lockfile=false`, or delete the lockfile.

#### Step 5: Verify audit

Run audit again. Record remaining vulnerabilities. If issues remain and a patched version exists,
add more overrides and repeat from Step 4.

#### Step 6: Validate changed files

Run `git diff --stat`. The output MUST only show:

- `package.json` (and any workspace `package.json` files where overrides/resolutions or direct
  vulnerability bumps were applied)
- The lockfile

If any other file appears, something went wrong. Revert with `git checkout -- <file>` and
investigate. If `package.json` changes include anything beyond overrides/resolutions and direct
vulnerability version bumps, revert those changes too.

#### Step 7: Run unit tests

Run the repo's unit tests to catch breakage before pushing. Do NOT run integration, browser,
end-to-end, or Playwright tests — those depend on deployed infrastructure and are not appropriate
for a local pre-push check.

**Find the test script.** Check these locations in order:

1. `package.json` `"scripts"` — look for keys named `test`, `test:unit`, `unit`, `test:ci`,
   or `vitest`/`jest` (skip any named `test:e2e`, `test:integration`, `test:playwright`,
   `test:browser`, `e2e`, `integration`, `playwright`)
2. In monorepos, check root `package.json` and workspace `package.json` files for the same keys
3. If the repo uses `turbo`/`nx`, check for `turbo run test` or `nx run-many --target=test`

**Run the unit test command.** Common patterns:

- pnpm: `pnpm test`, `pnpm run test:unit`, `pnpm vitest run`
- yarn: `yarn test`, `yarn test:unit`
- npm: `npm test`, `npm run test:unit`

If tests **pass**: proceed to commit.

If tests **fail**: this likely means an override broke something. Do NOT commit. Investigate which
override caused the failure, fix or remove it, re-run `pnpm install`/`yarn install`, and repeat
from Step 5. If the failure is clearly pre-existing (i.e. the same test fails on `main` without
your changes), note it and proceed.

If **no unit test script exists**: note this in the PR body and proceed to commit.

#### Step 8: Commit and push

```bash
git add package.json <lockfile>  # add specific files, not -A
git commit -m "chore: patch dependency security vulnerabilities"
git push -u origin chore/patch-dependencies-<YYYY-MM-DD>
```

Do NOT use `--no-verify`. Do NOT mention AI in the commit message.

#### Step 9: Open PR

```bash
gh pr create --title "chore: patch dependency security vulnerabilities" --body "$(cat <<'EOF'
## Summary

Patches open Dependabot security vulnerabilities via dependency overrides/resolutions.
Only package.json overrides and the lockfile are modified.

## Patches Applied

| Package | Severity | Vulnerable Range | Patched To | Method |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

## Remaining (if any)

- List any that could not be patched and why

## Test Plan

- [ ] CI passes (build, lint, unit tests, integration tests)
- [ ] No runtime behaviour changes
EOF
)"
```

Fill in the table with actual packages. Do NOT mention AI/Claude.

#### Step 10: Cleanup

- If a worktree was used: return to the original repo dir, remove the worktree, verify the
  user's original branch is still checked out.
- If working directly: `git checkout main`.

### Phase 5 — Report Results

Present a final summary table with PR URLs:

| Repository | PR  | Alerts Fixed | Remaining | Notes |
| ---------- | --- | ------------ | --------- | ----- |

List PR URLs on separate lines for easy copy-paste.
