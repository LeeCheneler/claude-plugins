---
name: dev-work-kickoff
description: Load the moment Lee asks for ANY code change in a repo, however it's phrased — "kick off work on X", "in <repo> I want to update/fix/change/add Y", "let's pick up <ticket>", a bug he describes, or a tweak that sounds too small to need process. If a repo or ticket is named and code will change, load this FIRST, before reading or writing any code — there is no change small enough to skip it. The full loop from locating the repo and creating a worktree, through commit-by-commit sign-off, to opening a PR — plus the house rules and git conventions that apply to all dev work.
---

# Dev Work Kickoff

Load and follow this the moment Lee asks for any code change in a repo — a ticket, a feature, a bug, a styling tweak, anything. He won't always announce it as "kicking off work"; "in `<repo>` I want to update X" is a kickoff. This is the default way to start coding work, and no change is small enough to bypass it.

Invoke sibling skills with Claude Code's Skill tool using their `dev:<skill-name>` identifiers (for example, `dev:software-design`). Their user-facing commands use `/dev:<skill-name>`.

## The loop, in order

### 1. Locate the repo, create a worktree

- Look for the repository **locally under `~/projects`** first. `new-worktree` takes a path like `./example-repo`, so find the local repo and use it.
- Create a fresh worktree for the work: `new-worktree <repo-dir> <feature-branch>` (it bootstraps install + `.env*` so the worktree is usable immediately). See the `dev:git-worktree-management` skill for the exact usage — in particular, don't try to pass a worktree name; it's derived from the branch.
- **If the repo can't be found locally, stop and say so** — "I can't find it locally." Do **not** go hunting for it on GitHub or cloning a remote.

### 2. Set the working directory

- Run every subsequent shell command from the new worktree (use `cd <worktree-dir> && …` in each Bash invocation), and target file operations at that worktree.

### 3. Investigate and plan, then feed back

- Look at the changes needed and formulate a plan. Load `dev:software-design` for implementation/refactoring and `dev:testing-methodology` when changing behaviour, fixing bugs, refactoring tested code, or changing tests. These supply the engineering method; this skill owns the lifecycle and approval gates.
- Establish where the behaviour belongs, the contracts/invariants to preserve, and the checks that will demonstrate the result. For consequential design choices, explain the simplest sufficient approach and its trade-offs. Keep routine changes lightweight; do not require an architecture document or speculative alternatives.
- Feed back **briefly**, in this exact structure (keep each section to 1–3 short bullets):

  ```text
  ## Understanding
  <1–3 sentences: what we're changing and why>

  ## Design / verification
  - <ownership, relevant contracts and design choice — proportionate to the change>
  - <behaviour/risk → relevant test or check; material verification gaps>

  ## Commit plan
  1. <scope> — <what>
  2. <scope> — <what>
  3. …
  n. docs — sweep documentation for the changes above (see *Documentation sweep*)

  ## Questions / assumptions
  - <question — and the approach I recommend>
  - <assumption — flagged as MY assumption, so it can be corrected>
  ```
- **When asking a question, always present your assumed/recommended approach.** If Lee just says "proceed", "approve", or similar, assume he's agreed with your assumptions and continue.

### 4. Build commit-by-commit, sign off each

- Do the work **one commit at a time**, in the order from the plan.
- Implement against the stated contracts and checks. For bug fixes, demonstrate a regression test failing for the intended reason before the fix when practical, then passing afterwards; be explicit when that evidence is unavailable.
- Before presenting changes, inspect the actual staged and unstaged diff plus intended new files and relevant surrounding code. Check correctness, responsibility/state boundaries, unnecessary abstractions, test strength and human readability. Simplify within scope: clear names, coherent files, logical spacing, discoverable main flow and straightforward expressions matter alongside passing tests. Do not turn this into unrelated cleanup.
- Run the relevant repository checks and rerun affected checks after simplification. Report actual outcomes and material gaps, distinguishing tests from type checks, lint and builds. If implementation exposes a materially wrong plan, revise it explicitly rather than silently drifting.
- **Before committing each commit, stop** and present what you've done in this shape (keep it to a couple of sentences; no ceremony):

  ```text
  ## Commit <n>: <short title>
  <what changed and why — 1–3 sentences>
  <verification: actual checks and outcomes, plus material gaps>
  ```
  Lee reviews and signs off the commit before it's made.

**The sign-off gate — no exceptions:**

- `git commit` is authorised by exactly one thing: Lee explicitly approving the presentation of the **current** changes ("approve", "commit", "lgtm", or similar). **One approval = one commit of exactly what was presented.**
- **Any reply that asks for changes is NOT approval** — it is a new instruction. That includes plan amendments like "roll commit 2 into this one", "also do X", or "fix Y first". The correct response is: do the requested work, then **present the updated changes again** (same shape as above) **and stop and wait**. The earlier presentation is void; the new combined state has never been signed off.
- **Never implement and commit in one move.** If you have written any code since the last presentation — however small — you must re-present and wait before committing. There is no amount of momentum, obviousness, or prior context that substitutes for the approval message.
- If unsure whether a reply was approval, **ask — don't commit.**

### 5. Commit and continue automatically

- When signed off, commit **exactly what was presented** — nothing more — and **move on to the next commit automatically; don't wait to be told.** ("Automatically" means *start implementing* the next commit unprompted — its commit still goes through the sign-off gate like every other.)

### 6. Ask about the PR

- Before presenting the last commit, inspect the whole intended change against the target base, including uncommitted work. Check that individually sound commits still form a coherent design and that the important behaviours have verification evidence. Resolve substantive issues within scope and rerun affected checks; additional edits still require fresh sign-off.
- A separate critical review is available through `dev:review-change` **on request**. Do not automatically spawn reviewers or treat opening a PR as a request for that skill. Routine self-review above remains required; a review verdict never substitutes for human approval.
- When presenting the **last** commit, also ask if Lee wants a PR opening.
- **Before opening the PR — the pre-PR gate, paramount and non-negotiable:** confirm every intended change is committed and pushed. A PR that's missing work is worse than no PR. Run and check, in order:
  1. `git status` — must be **clean**: no modified, staged, or untracked files that belong to the work. If anything intended is uncommitted, **stop, present it through the sign-off gate, and commit it first** — never leave it out and never fold it into a later "follow-up".
  2. `git log --oneline origin/<default>..HEAD` — the commits must match the commit plan (as amended); nothing planned is missing.
  3. `git diff origin/<default>...HEAD --stat` — the file list must cover everything the plan touched (docs sweep included).
  4. `git push -u origin <branch>` (or confirm the branch is already pushed and up to date) — the remote must have every local commit.
  Only when all four hold do you open the PR. If any fails, fix it, re-check, and only then proceed. Report the check as done ("tree clean, N commits, all pushed") when you provide the PR link.
- On approval, open the PR with this exact structure (concise — each section stays to 1–2 sentences or bullets; no filler):

  ```text
  ## What
  <what the PR does — 1–2 sentences>

  ## Why
  <why it's needed — 1–2 sentences>

  ## Changes
  - <key change>
  - <key change>

  ## Testing
  - <how it was verified — tests run, manual checks>

  ## Notes
  - <anything the reviewer should know; omit if nothing>
  ```
- When it's open, **provide the link**. Don't offer to watch it or wait on it — Lee will say what's next.

## House rules (apply throughout)

These hold in every repo, regardless of stack:

- **KISS.** Small functions, simple modules, clear intent. The boring solution is almost always the right one.
- **Read before writing.** Explore the relevant code before changing it.
- **Match the project.** Follow existing patterns, naming, file layout, and tooling. New patterns require justification. Filenames follow the repo's convention; where there's no precedent, favour kebab-case.
- **Make abstractions earn their place.** Extract coherent responsibilities or useful boundaries, not because a repetition count was reached. Avoid speculative generality and helpers that merely scatter the logic.
- **Write for human readers.** Use coherent files, meaningful names, logical whitespace and clear control flow. Keep related information close. Follow the formatter without mistaking formatting for readability; see `dev:software-design` for the cross-language method.
- **Handle errors at meaningful boundaries.** Recover, translate a contract or guarantee cleanup where appropriate; otherwise propagate. Avoid redundant catch/rethrow scaffolding and swallowed failures.
- **Comments.**
  - Exported/public APIs get a tight doc comment (JSDoc or the repo's equivalent): the contract — what it does, key params/returns, notable side effects. One or two lines, usually.
  - Non-obvious logic gets a brief *why* comment — a workaround, subtle constraint, ordering requirement. Don't narrate *what* the code does; names should do that.
  - **Never reference task context in comments** — no issue numbers, ticket ids, PR references, or "added for X". That context lives in the PR description and rots in code. Describe behaviour concretely instead.
- **Test behaviour, not implementation.** Aim assertions at conditional rendering, state changes, event wiring, async flows — not static content, styling/class names, or DOM ordering. In UI tests, query the way a user does (role, label, visible text); test ids and CSS selectors are escape hatches. Rule of thumb: if removing the assertion would let a real user-visible regression through, keep it; if it only fails when someone tweaks styling or reorders sections, drop it.
- **Keep docs in sync.** Stale docs are a defect, not an afterthought — see *Documentation sweep* below; it's the planned final commit of every piece of work.

## Git conventions

- **Conventional commits.** Subject ≤ 70 chars (e.g. `feat(runner): add script node executor`); body explains *why*, not *what*.
- **Branch naming:** `feat/<slug>`, `fix/<slug>`, `chore/<slug>` — include the ticket id when there is one (e.g. `feat/JN-3554-cleanup-env`).
- **Never commit directly to the default branch.** Work lands via a feature branch and PR — the worktree flow above gives you this for free. If you realise you've committed to it anyway, stop and propose a recovery plan that preserves local work before pushing anything. Do not reset until explicitly approved.
- **Never commit without Lee's sign off** (the commit-by-commit loop above).
- **Never open a PR with uncommitted or unpushed intended changes.** Run the pre-PR gate (step 6) every time — a clean `git status`, commits matching the plan, branch pushed. Ensuring all intended changes are committed before the PR is a paramount concern.
- Never force-push the default branch. Never rebase shared branches without explicit permission.
- Never commit `.env` files, secrets, credentials, or tokens.
- Never reference Claude, AI, or any AI tooling in commit messages, PR descriptions, or code comments.

## Documentation sweep — the final commit

Every piece of work ends with a documentation pass, **planned as the final commit** in the commit plan (skip the commit only if the sweep genuinely finds nothing to change — and say so when presenting the last code commit). Sweep every surface the repo has and fix anything the change has made wrong, incomplete, or misleading:

- **README** — features, usage, examples, setup steps.
- **CONTRIBUTING / contributor guides** — workflows, commands, conventions the change touched.
- **ADRs / architecture docs** — if the change alters a recorded decision, don't rewrite history: add a new ADR (or mark the old one superseded) per the repo's convention. Update living architecture/design docs in place.
- **Other docs** — CLI help/usage text, API docs, schema descriptions, changelogs, hosted docs/sites, in-app copy, scaffolded templates.
- **Code comments and doc comments** — comments near the changed code that now describe old behaviour are bugs; update or delete them. Check doc comments on any exported API whose contract changed.

Not every change touches every surface, but **check each one rather than assuming**. If docs-only fixes are trivial and tightly coupled to a code commit, folding them into that commit is fine — the final sweep then just verifies nothing was missed.

## After the PR

- Once the PR is merged or otherwise finished, tear the worktree down with `rm-worktree` (see `dev:git-worktree-management`).
