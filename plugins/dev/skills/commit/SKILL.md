---
name: commit
description: Commit changes following conventional commit conventions with branch naming guards and GitHub issue linking. Auto-loads when committing code. Invoke with /commit to commit current changes.
---

# Skill: Commit Changes

Commit staged and unstaged changes following conventional commit conventions with branch safety
guards and optional GitHub issue linking.

## Procedure

Work through each step sequentially. Do not skip steps.

### Step 1 — Check for Changes

Run `git status` and `git diff` (staged + unstaged) to understand what has changed. If there are no
changes to commit, inform the user and stop.

### Step 2 — Branch Safety

Run `git branch --show-current` to get the current branch name.

**If on `main` or `master`:**

You must NOT commit directly to main/master. Create a new branch first:

1. Analyse the staged/unstaged changes to understand the nature of the work (feat, fix, chore,
   docs, refactor, test, ci, perf, style, build).
2. Use `AskUserQuestion` to ask about GitHub issue linking. You MUST present exactly these three
   options in exactly this order — do not omit, reorder, or rephrase any option:
   - **1. Yes** — provide an existing GitHub issue URL or number
   - **2. No, create one** — create a GitHub issue for the work being carried out
   - **3. No** — skip issue linking entirely
3. **If "Yes":** Note the issue number and incorporate it into the branch name.
4. **If "No, create one":** Use the `gh` CLI to create a GitHub issue for the work being carried
   out. Derive the issue title and body from the staged/unstaged changes. Once created, note the
   issue number for incorporation into the branch name.
5. **If "No":** Continue without any issue reference.
6. Propose a branch name following the convention below and confirm with the user.
7. Create and switch to the new branch with `git checkout -b <branch-name>`.

**If on an existing branch** that is NOT main/master, continue to Step 3. Do not rename or
re-create the branch — respect the user's current branch.

### Step 3 — GitHub Issue Linking

If this step has not already been handled as part of Step 2 (branch safety on main/master), ask the
user about GitHub issue linking now.

Use `AskUserQuestion` to ask about GitHub issue linking. You MUST present exactly these three
options in exactly this order — do not omit, reorder, or rephrase any option:

- **1. Yes** — provide an existing GitHub issue URL or number
- **2. No, create one** — create a GitHub issue for the work being carried out
- **3. No** — skip issue linking entirely

Handle each response:

1. **If "Yes":** Note the issue number for the commit message.
2. **If "No, create one":** Use the `gh` CLI to create a GitHub issue for the work being carried
   out. Derive the issue title and body from the staged/unstaged changes. Once created, note the
   issue number for the commit message.
3. **If "No":** Continue without any issue reference.

### Step 4 — Branch Naming Validation (informational)

Check the current branch name against the expected convention:

```
<type>/<issue-number>-<short-description>   # with GitHub issue
<type>/<short-description>                  # without issue
```

Where `<type>` is one of: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`, `perf`,
`style`, `build`.

Examples:

- `feat/42-add-user-search`
- `fix/resolve-login-timeout`
- `chore/update-dependencies`

If the branch name does not follow convention, note it to the user as a warning but **do not
block**. The user may have intentionally chosen a different name.

### Step 5 — Stage Changes

Review the unstaged and untracked changes. Stage the appropriate files using `git add`. Prefer
adding specific files by name rather than `git add -A` or `git add .` — avoid accidentally staging
sensitive files (.env, credentials, secrets).

If there are files that look like they shouldn't be committed (e.g. `.env`, credentials, large
binaries), flag them and ask the user before staging.

### Step 6 — Review Staged Diff

Run `git diff --staged` and present a concise summary of what will be committed. Group changes
logically (e.g. "Added new search component", "Updated API route handler", "Added tests for search
feature").

### Step 7 — Write Commit Message

Draft a commit message following conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Rules:**

- **type**: one of `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`, `perf`, `style`,
  `build` — match the nature of the change.
- **scope**: optional, a short identifier for the area of code affected (e.g. `auth`, `api`,
  `search`). Use one if the change is clearly scoped to a module or feature. Omit if the change is
  broad or a scope would be forced.
- **subject**: imperative mood, lowercase, no period at the end. Keep under 72 characters.
  Summarise _what_ changed and _why_ in a single line.
- **body**: only include if the subject line alone doesn't tell the full story. Use the body for:
  - _Why_ the change was made (if not obvious from the subject)
  - Important implementation decisions worth noting
  - Breaking changes or migration notes
  - Context that a reviewer would need

  Not every commit needs a body. Simple, self-explanatory changes (renaming a file, fixing a typo,
  adding a straightforward test) should be subject-only. Use your judgement.
- **footer**: if a GitHub issue was linked in Step 2 or Step 3, include a `Closes #<number>` or
  `Refs #<number>` line as appropriate. Use `Closes` when the commit fully resolves the issue, and
  `Refs` when it is related but does not close it. Omit the footer if no issue was linked.

**Do NOT include in the commit message:**

- References to AI, Claude, or any AI tool
- File-by-file changelogs (the diff provides this)
- `Co-Authored-By` trailers

### Step 8 — Confirm and Commit

Present the full commit message to the user. Ask for confirmation or changes. Once approved, run the
commit.

If a pre-commit hook fails, diagnose the issue, fix it, re-stage, and create a **new** commit (do
NOT amend).

### Step 9 — Verify

Run `git log --oneline -1` and `git status` to confirm the commit was created successfully. Report
the result to the user.
