---
name: pr
description: Create a pull request with GitHub issue integration and a well-structured description. Auto-loads when creating pull requests. Invoke with /pr to create a PR for the current branch.
---

# Skill: Create a Pull Request

Create a pull request for the current branch with a well-structured description and optional GitHub
issue linking.

## Tools Required

- `gh` CLI (for creating the PR and issues on GitHub)

## Procedure

Work through each step sequentially. Do not skip steps.

### Step 1 — Pre-flight Checks

1. Run `git status` to check for uncommitted changes (staged, unstaged, untracked).
2. Run `git branch --show-current` to confirm you're on a feature branch.

**If there are uncommitted changes:**

The user has work that needs committing first. Inform them that there are uncommitted changes and
suggest they commit first using `/commit`. Stop here — do not create a PR with uncommitted work.

**If on `main` or `master`:**

You cannot create a PR from main to main. Inform the user and stop. They need to be on a feature
branch.

### Step 2 — Gather Context

Run the following to understand the full scope of changes in the PR:

1. `git log main..HEAD --oneline` — all commits on this branch since diverging from main.
2. `git diff main...HEAD` — the full diff against main.
3. `git log main..HEAD` — full commit messages for context.

If the branch has no commits ahead of main, inform the user there's nothing to open a PR for and
stop.

### Step 3 — Check for PR Templates

Search for a pull request template. Template filenames vary in casing across repos (e.g.
`PULL_REQUEST_TEMPLATE.md` vs `pull_request_template.md`), so you MUST use a case-insensitive
search. Use a Glob pattern like `**/*pull_request_template*` or search with the Grep tool using
the `-i` flag. Check these standard locations:

- `.github/PULL_REQUEST_TEMPLATE.md` (or lowercase variant)
- `.github/pull_request_template.md`
- `docs/pull_request_template.md`
- `PULL_REQUEST_TEMPLATE.md` (root, or lowercase variant)

If a template is found, read it and use it as the structure for the PR body. Fill in the template
sections using context from the branch's commits and diff. Apply good judgement:

- Fill sections that are relevant to this PR.
- Leave out or mark as N/A any sections that don't apply (e.g. "Screenshots" for a backend-only
  change).
- Do not invent content for sections where there's nothing meaningful to say.

If no template is found, use the default structure from Step 5.

### Step 4 — GitHub Issue Linking

Use `AskUserQuestion` to ask the user about GitHub issue linking. You MUST present exactly these
three options in exactly this order — do not omit, reorder, or rephrase any option:

- **1. Yes** — provide an existing GitHub issue URL or number
- **2. No, create one** — create a GitHub issue for the work being carried out
- **3. No** — skip issue linking entirely

**If "Yes":**

Note the issue number. Include it in the PR description.

**If "No, create one":**

Use the `gh` CLI to create a GitHub issue for the work being carried out. Derive the issue title and
body from the branch's commits and diff. Once created, note the issue number for inclusion in the PR
description.

**If "No":**

Continue without any issue reference.

### Step 5 — Draft the PR

**Title:** Follow conventional commit format: `<type>(<scope>): <subject>`

- **type**: one of `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`, `perf`, `style`,
  `build` — match the nature of the changes in the PR.
- **scope**: optional, a short identifier for the area of code affected (e.g. `auth`, `api`,
  `search`). Use one if the changes are clearly scoped to a module or feature. Omit if the changes
  are broad or a scope would be forced.
- **subject**: imperative mood, lowercase, no period at the end. Keep the full title under 72
  characters. Summarise _what_ changed and _why_ in a single line.

Derive the type and subject from the branch name and commit messages.

**Body:** The PR description should provide genuine value to the reviewer. Structure it as follows
(unless a project PR template from Step 3 dictates otherwise):

```markdown
## Summary

[1-3 sentences explaining what this PR does and why.]

## GitHub Issue

[Issue number and link (e.g. `Closes #42`), or "N/A" if no issue was linked. Use `Closes` when the
PR fully resolves the issue, `Refs` when it is related but does not close it.]

## What Changed

[A narrative description of the changes. Group related changes together. Explain the approach taken
and any decisions made. Do NOT list every file changed — the PR diff shows that. DO call out
anything surprising, non-obvious, or that a reviewer should pay special attention to.]

## Notes for Reviewers

[Optional. Include only if there are specific things reviewers should know — e.g. "The migration is
backwards-compatible", "This feature is behind a flag", "I considered X approach but chose Y
because...". Omit this section entirely if there's nothing noteworthy.]
```

**Do NOT include in the PR description:**

- Arbitrary checklists unless the project template requires them
- File-by-file change lists
- References to AI, Claude, or any AI tool
- Generic boilerplate that adds no value

If a project PR template was found in Step 3, fill in that template instead of the default structure
above. Apply the same principles: be substantive, skip irrelevant sections, don't pad with filler.

### Step 6 — Review and Confirm

Present the full PR (title + body) to the user. Ask if they want to change anything. Iterate until
approved.

### Step 7 — Push and Create

1. Push the branch to the remote: `git push -u origin <branch-name>`.
2. Create the PR using `gh pr create` with the approved title and body. Use a HEREDOC to pass the
   body for correct formatting.
3. Report the PR URL to the user.
