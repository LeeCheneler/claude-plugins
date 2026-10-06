---
name: user-stories
description: Write agent-ready user stories — intent for humans plus testable acceptance criteria, examples, non-goals, and constraints a coding agent can implement and verify. Load when drafting a ticket or story that an AI agent will build.
---

# User Stories for the Agentic Era

A user story that used to be a *prompt for conversation* is now largely a
*contract for verification*. When the primary reader is a coding agent,
anything you leave unstated gets filled with a guess — and that guess ships
as a bug. Humans still need **what/why** to align and review; agents need
**how-to-verify and constraints** so they have something to check, not just
something to claim.

So: keep both, but split them deliberately. Intent stays lean and
human-readable; acceptance and boundaries carry the machine-checkable weight.

## Working method

Draft the story in this order. Each section earns its place — if it doesn't
change behaviour or stop the agent from guessing, cut it.

1. **Title + one-line outcome** — what "done" means in a sentence.
2. **Context / problem** — the *why* and user impact, for humans. Two or three
   sentences, no longer.
3. **User story** — `As a … I want … so that …`, kept short. It's an intent
   header, not a spec.
4. **Acceptance criteria** — the core. Testable Given/When/Then conditions
   with a defined check. See below.
5. **Examples** — concrete input → output pairs, plus the edge cases that
   matter. This is the single most habit-eliminating section.
6. **Non-goals / out-of-scope** — explicitly close doors the agent might walk
   through. As important as the in-scope list.
7. **Constraints & NFRs** — "must", "must not", security, latency, tech rules
   the agent can't infer.
8. **Tech notes** — only what the agent can't work out from the codebase
   (decided stack, architecture, gotchas). Point at code rather than
   re-describing it.
9. **Unknowns / open questions** — explicit items requiring a human answer, so
   the agent asks instead of guessing.

## Code references — stable anchors, not volatile facts

Tickets sit in a backlog; code drifts. A reference that names the *identity*
of something survives churn and stays useful as a discovery aid:

- Keep: the subsystem/module the change lives in, stable public contracts and
  signatures, names that are part of the system's vocabulary, and durable
  *decisions* ("reuse `X`'s retry logic" — the decision outlives `X` moving).
- Leave out: exact file paths, line numbers, current implementation snippets,
  call stacks, and internal names that are still changing.
- Remember a stale reference is worse than none — an agent follows it
  literally and may trust an outdated signature. Point the agent *where to
  start looking*, never at ground truth it should match.
- Verify against observable behaviour or stable integration points, never a
  mutable internal function. (This is the same rule as acceptance criteria:
  observable behaviour doesn't rot the way internal names do.)

## Acceptance criteria — the rules

Replace qualities the agent can *claim* with conditions it must *produce*:

- **Name a concrete condition, not a quality.** "Loads in under 200ms p95",
  not "is fast". "Returns HTTP 200 with the account JSON", not "works".
- **State observable external behaviour**, not implementation.
- **Attach a defined check** — a test name, an assertion, a metric, a
  behaviour you can point at. If you can't name how it'd be verified, the
  criterion isn't done.
- **Prefer Given/When/Then** — it forces input + action + result and maps
  onto an executable test. The principle matters more than the exact wording:
  when Given/When/Then is awkward, a crisp imperative ("Returns 404 for an
  unknown id") is fine, but still needs a check.
- **Use given/when/then that the verify step can run.** If the acceptance
  criteria read like they could be pasted into a test file, you're there.

## Complexity dial

Match effort to the task — don't over-specify a trivial change, and don't
under-specify a risky one.

- **Small/well-understood:** a lean story with a few crisp acceptance
  criteria and one or two examples is enough.
- **Large/ambiguous/security-sensitive:** invest in examples, edge cases,
  non-goals, and explicit constraints. This is where the agent most needs
  rails — and where guessing is most expensive.

## What stays with the human vs. what the agent figures out

- **Keep human-written:** the *why*, domain knowledge the agent can't infer,
  architectural/security decisions, and what "done" means.
- **Let the agent handle:** implementation detail, codebase structure,
  well-known conventions, and edge cases you invite it to enumerate.
- Never duplicate in the ticket what a good `CLAUDE.md`/`AGENTS.md` or the
  code already says — pointing there beats pasting.

## Template

```markdown
## Title
<One line: the outcome this story delivers>

## Context / problem
<Why are we doing this, and who does it help? Keep to 2–3 sentences.>

## User story
As a <role>, I want <capability>, so that <outcome>.

## Acceptance criteria
- Given <setup>, when <action>, then <observable result> (check: <test/assertion>)
- Given <setup>, when <action>, then <observable result> (check: <test/assertion>)

## Examples
- Input → output: <concrete pair>
- Edge case: <concrete pair>

## Non-goals / out of scope
- <explicitly NOT doing this — e.g. auth, migration, theming>

## Constraints & NFRs
- <must / must not / security / latency / stack rules the agent can't infer>

## Tech notes (only what the agent can't infer)
- <point at the codebase or reference files; don't repeat what's obvious>

## Unknowns / open questions
- <items requiring a human answer before the agent proceeds>
```
