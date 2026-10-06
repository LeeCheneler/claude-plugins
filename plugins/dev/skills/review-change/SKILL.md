---
name: review-change
description: Review a diff, branch or PR on explicit request, including pre-PR review. Assess correctness, architectural simplicity, human readability and test adequacy with concrete evidence. Read-only by default; does not automatically trigger from implementation or PR creation. Use the main conversation by default and optional read-only delegated reviewers only when appropriate and permitted.
---

# Review a Change

Find actionable problems in the actual change, not reasons to endorse its
summary. A review request authorises inspection, not fixes, commits, pushes or
PR creation. Follow repository rules and existing permissions. Agent review
never substitutes for human sign-off or project checks.

Invoke `dev:software-design` and `dev:testing-methodology` with Claude Code's Skill tool for their review criteria. Load
other specialist guidance only when relevant. Do not start the implementation
or worktree lifecycle for a read-only review.

## Establish the scope

Identify the requirements, acceptance criteria, repository guidance and relevant
design invariants. Determine the target base and head rather than assuming the
default branch is the intended base. Inspect status and distinguish committed,
staged, unstaged and untracked work. Agree whether dirty work belongs in scope
when that is ambiguous; do not silently omit intended changes or include
unrelated work.

Record the reviewed revisions and any working-tree scope. Review the whole
change against the appropriate base, not just its last commit. Later edits can
invalidate earlier conclusions; do not claim an old review covers new code.

## Read independently and follow the consequences

Read the actual diff plus relevant surrounding implementation, callers and
tests. Use the author's summary as context, not evidence. Check the proposed
behaviour against requirements and contracts, not merely against its own tests.

Look for:

- **Correctness:** incorrect assumptions, boundary cases, error paths, partial
  writes, resource leaks, compatibility breaks and misleading success states.
- **Design:** misplaced responsibilities, unclear state ownership, dependency
  violations, duplicate state, excessive indirection and speculative machinery.
- **Readability:** hard-to-find main flow, misleading names, tangled conditions,
  dense or poorly grouped code, and fragmentation that obscures an operation.
- **Tests:** missing discriminating cases, mocks that hide the risk, flaky setup,
  weak assertions and integration behaviour not established by isolated tests.
- **Change-specific risks:** permissions, security, concurrency, migrations,
  accessibility or performance when the change actually touches them.

Seek a counterexample: what plausible input or sequence breaks the contract?
Trace the path and distinguish a supported finding from a suspicion. Do not
expand into a general repository audit or request unrelated architectural work.
Run safe relevant existing checks when authorised and useful; inspect commands
first and avoid generators, snapshot updates or other tracked-file mutations
in a read-only review. Do not start servers or make real external side effects.
State when reproduction needs work outside the review's authority.

## Use delegation selectively

The main conversation is the default reviewer. A fresh review subagent can help a substantial
review when independent context or a separable specialist risk justifies it;
respect any applicable preference against delegated reviews. Do not create a
mandatory reviewer swarm or assume multiple agreeing agents prove correctness.

When delegation is appropriate, supply the requirements, repository location,
base/head, dirty-work scope, risk area and evidence standard. Explicitly require
read-only work. Do not assume a review subagent is isolated: identify whether
it shares the checkout or has an isolated worktree, and require read-only
review either way. Do not assign a reviewer concurrent implementation ownership or
coach it toward the author's preferred conclusion. Freeze the review scope or
identify changes that occurred while it ran.

Require findings tied to actual code, counterexamples, uncertainties and checks
performed. The main reviewer must adjudicate, deduplicate and selectively verify weak
or consequential claims; a subagent verdict is not an approval. Use targeted
follow-up for unresolved evidence rather than repeating every investigation.

## Report actionable findings, not noise

Lead with findings ordered by consequence. Each finding should include:

- Severity: blocking/high, medium, or low, justified by concrete impact.
- File and line/range in the reviewed code.
- The violated behaviour or constraint, triggering conditions and consequence.
- Supporting reasoning, reproduction or missing test where practical.
- A proportionate correction or direction, without prescribing an unnecessary
  rewrite.

Separate confirmed defects from unresolved risks and optional improvements.
Do not inflate personal style preferences into defects. Readability findings
must identify a real comprehension obstacle and a clearer alternative; cosmetic
churn alone is not a useful finding. Drop a suspected issue when source evidence
refutes it rather than filling a finding quota.

If there are no actionable findings, say so and name material limitations.
Never imply the absence of findings proves correctness. Keep the report concise,
with the reviewed scope, checks and unresolved risks; create a durable report
only when requested or genuinely useful under applicable user and repository instructions.

## Close the loop without exceeding authority

For review-only requests, stop with findings. If fixes are already authorised,
apply accepted corrections through the development lifecycle; otherwise await
that instruction. Do not automatically implement every reviewer suggestion.

After fixes, rerun affected checks and re-review changed areas and connected
contracts. Broaden the review if the correction alters the design or scope.
Keep unresolved findings visible with their disposition: fixed, accepted risk,
deferred, or rejected with evidence. Stop when substantive issues are resolved;
do not cycle indefinitely through cosmetic preferences.

Present any edits for fresh human sign-off before committing. Review completion
is not permission to commit, push, open a PR or override an existing gate.
