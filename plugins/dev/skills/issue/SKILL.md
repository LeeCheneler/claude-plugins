---
name: issue
description: Create a well-structured GitHub issue. Supports user stories, bug reports, and technical chores with appropriate templates and labelling. Invoke with /issue.
---

# Skill: Create a GitHub Issue

Create a GitHub issue with a well-structured description using the appropriate template for the type
of work.

## Tools Required

- `gh` CLI (for creating the issue on GitHub)

## Procedure

Work through each step sequentially. Do not skip steps.

### Step 1 — Issue Type

Use `AskUserQuestion` to ask the user what type of issue they want to create. You MUST present
exactly these three options in exactly this order — do not omit, reorder, or rephrase any option:

- **1. User story** — a new feature or enhancement from the user's perspective
- **2. Bug report** — a defect or unexpected behaviour
- **3. Technical chore** — maintenance, upgrades, refactoring, or other non-user-facing work

### Step 2 — Gather Details

Ask the user to describe the issue. Use follow-up questions if needed to fill in the template
sections. Don't over-ask — use your judgement to fill in what you can from the context and only ask
about what's genuinely missing.

### Step 3 — Draft the Issue

Draft the issue using the template for the chosen type below.

---

#### User Story

**Title:** `feat: <short description>`

**Labels:** `enhancement`

**Body:**

```markdown
## User Story

As a [type of user],
I want [action/feature],
so that [benefit/value].

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Additional Context

[Optional. Designs, edge cases, constraints, or anything else relevant. Omit this section entirely
if there's nothing to add.]
```

---

#### Bug Report

**Title:** `bug: <short description>`

**Labels:** `bug`

**Body:**

```markdown
## Description

[Clear, concise description of the bug.]

## Steps to Reproduce

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Expected Behaviour

[What should happen.]

## Actual Behaviour

[What happens instead.]

## Environment

[Relevant environment details — browser, OS, version, deployment, etc. Omit this section if not
applicable.]

## Additional Context

[Optional. Screenshots, logs, error messages, or anything else relevant. Omit this section entirely
if there's nothing to add.]
```

---

#### Technical Chore

**Title:** `chore: <short description>`

**Labels:** `chore`

**Body:**

```markdown
## Summary

[What needs to be done and why.]

## Scope

- [Item 1]
- [Item 2]
- [Item 3]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Additional Context

[Optional. Links to docs, related issues, or anything else relevant. Omit this section entirely if
there's nothing to add.]
```

---

### Step 4 — Labelling

Apply the primary label from the template above (`enhancement`, `bug`, or `chore`).

If additional labels are clearly applicable, add them. Common labels to consider:

- `documentation` — docs-only changes
- `security` — security-related issues
- `performance` — performance-related issues
- `breaking-change` — introduces a breaking change
- `good first issue` — simple and well-scoped, suitable for new contributors

Do not invent labels. Only use labels that already exist on the repository. Run
`gh label list --limit 100` to check what labels are available before applying any. If a label from
the template (e.g. `chore`) does not exist on the repo, skip it rather than creating it — flag this
to the user.

### Step 5 — Review and Confirm

Present the full issue (title, labels, body) to the user. Ask if they want to change anything.
Iterate until approved.

### Step 6 — Create

Create the issue using `gh issue create` with the approved title, labels, and body. Use a HEREDOC to
pass the body for correct formatting.

Report the issue URL to the user.
