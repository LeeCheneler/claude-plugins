---
name: merge
description: Merge a pull request after checking CI status and cleaning up, favoring squash merging. Invoke with /merge or /merge <pr-number-or-url> to merge.
---

# Skill: Merge Pull Request

Merge a pull request after verifying CI has passed, then cleanup the branch.

## Input

The user may provide a PR number or URL as an argument (e.g. `/merge 42` or `/merge https://github.com/org/repo/pull/42`). If provided, use it directly with `gh pr view <pr-number-or-url>` — this skips the need to discover the PR from the current branch and means Step 1 does not require being on the feature branch.

## Procedure

Work through each step sequentially. Do not skip steps.

### Step 1 — Pre-flight and PR Discovery

**If a PR number or URL was provided:**

Run in parallel:

```bash
git status
gh pr view <pr-number-or-url> --json number,url,title,baseRefName,headRefName,state
```

The only blocker here is uncommitted changes — inform the user and suggest `/commit` if found. You do NOT need to be on the feature branch since the PR is already identified.

**If no PR was provided (current branch mode):**

Run in parallel:

```bash
git status
git branch --show-current
gh pr view --json number,url,title,baseRefName,headRefName,state 2>/dev/null
```

Evaluate the results:

- **Uncommitted changes?** Inform the user and suggest `/commit`. Stop.
- **On `main` or `master`?** Inform the user they need to be on a feature branch. Stop.
- **No open PR found?** Ask the user if they want to create one first (invoke `/pr` if yes). Stop if no.

Save the PR number, base branch name, and head branch name from `gh pr view` output for later steps.

### Step 2 — Check CI Status

Run: `gh pr checks <pr-number>`

- **All passed**: Continue to Step 3.
- **Any failed**: **Stop immediately. Do NOT merge and do NOT ask the user whether to override.** Report each failed check by name along with its conclusion and details URL so the user can investigate. Example format:

  ```
  CI has failed — not merging. Failed checks:
  - <check name> (<conclusion>) — <details URL>
  - <check name> (<conclusion>) — <details URL>
  ```

  This is a hard stop. The user must fix the failures and re-run the skill.
- **In progress**: Poll every 30 seconds, up to 10 minutes. If still not complete, inform the user and stop.
- **No checks configured**: Warn the user and ask for confirmation before proceeding. (This is the one confirmation pause this skill keeps — merging with no CI at all is genuinely risky and worth the friction.)

### Step 3 — Merge

Run: `gh pr merge <pr-number> --squash --delete-branch`

If the merge fails, report the error to the user and stop. Do not attempt fallback merge strategies automatically.

### Step 4 — Local Cleanup

Run these commands sequentially in a **single bash call**:

```bash
git checkout <base-branch> && git pull origin <base-branch> && git branch -D <head-branch>
```

Use `-D` (force delete) because squash merge means the local branch won't show as fully merged. If the local branch doesn't exist (e.g. PR was provided by number/URL and never checked out locally), skip the `-D` step. If branch deletion fails, warn the user.

Report the successful merge and cleanup.

## Safety Rules

- **NEVER** merge if any CI checks have failed
- **ALWAYS** wait for in-progress CI before merging
- **ALWAYS** return to the base branch and pull after merging
