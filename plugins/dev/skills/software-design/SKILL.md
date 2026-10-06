---
name: software-design
description: Design and implement maintainable, human-readable software across languages. Load alongside dev:dev-work-kickoff for implementation or refactoring, and for architecture/design reviews. Covers responsibility boundaries, state ownership, dependencies, error handling, abstractions, file organisation, naming, spacing and control flow. Scale depth to the change; do not impose a framework or expand scope.
---

# Software Design

Make the simplest sufficient design easy for a human to understand and change.
Correct behaviour and readable structure are both requirements. This skill
supplements development rules; it does not authorise implementation during a
review, unrelated cleanup, or a different commit/approval process.

## Understand the change before choosing its shape

Read the relevant implementation, callers, tests and repository guidance. Trace
the path from input to observable result, including state and side effects.
Identify the existing owner of the behaviour, contracts to preserve and design
invariants the change touches. Verify actual APIs rather than inventing them.

For a small change, a few sentences of reasoning are enough. For consequential
choices, compare plausible approaches and recommend one with its trade-offs.
Do not manufacture alternatives or a design document for routine edits. Ask
when an unresolved decision materially affects behaviour, compatibility or
scope; otherwise state a reasonable assumption.

Repository instructions own concrete boundaries and conventions. Follow sound
existing patterns, but do not copy a known defect merely for consistency. Flag
an out-of-scope problem rather than silently turning a feature into a rewrite.

## Choose clear responsibilities and boundaries

- Give each module a coherent responsibility and each mutable state a clear
  owner. Derive values instead of maintaining synchronised copies when practical.
- Keep dependencies directional and explicit. Avoid circular dependencies,
  hidden global state and reaching through another module's private details.
- Separate policy from transport, persistence and presentation when that makes
  the design clearer or independently testable. Do not create a framework of
  interfaces and layers for a simple operation.
- Keep side effects visible and localised. Prefer pure transformations where
  useful without forcing an unnatural functional style on the language.
- Define relevant contracts: inputs, outputs, invalid states, compatibility,
  ordering and failure semantics. Make impossible states difficult to represent
  using the language's idioms rather than proliferating ambiguous flags.
- Consider concurrency, cancellation, retries, idempotency and resource cleanup
  when the operation actually involves them. Do not add speculative machinery.

Handle errors where recovery, contract translation or cleanup is possible.
Otherwise propagate them to the appropriate boundary. Preserve useful context;
avoid swallowing failures, catching at every layer, or presenting partial work
as success. Cleanup must also work when the main operation fails.

## Make abstractions earn their place

Extract a concept when it has a meaningful name and responsibility, hides a
useful implementation detail, or removes substantial repeated reasoning.
Repetition is a signal to inspect, not a threshold that mandates abstraction.
Similar syntax can represent different policies and should sometimes stay
separate. A stable boundary can be useful on its first occurrence.

Prefer composition and straightforward data flow. Avoid generic frameworks,
configuration surfaces, inheritance hierarchies and extension points for
hypothetical future needs. Do not replace a readable local operation with a
chain of one-line helpers solely to reduce its line count. Conversely, do not
keep unrelated responsibilities together merely to minimise the diff.

## Write files people can navigate

A file should tell a coherent story. Follow the repository and language's
import, declaration and export conventions. Within those constraints, make the
main operation easy to find and keep related supporting definitions close.
Choose a consistent reading order rather than scattering related behaviour.

Split files when responsibilities or reasons to change diverge—not at an
arbitrary line limit. Avoid both grab-bag modules and fragmentation that makes
a reader visit many tiny files to understand one operation. File and directory
names should communicate purpose; avoid vague dumping grounds such as a new
miscellaneous utility module when a domain name is available.

Declare values near their use, keep scopes narrow, and make dependencies visible.
Keep important behaviour near the context needed to understand it rather than
making readers reconstruct it from distant helpers or shared mutable setup.

## Use spacing and syntax to reveal meaning

Whitespace should mark logical groups, not decorate the code. Separate distinct
phases such as validation, preparation, the main operation and result handling
when those phases exist. Keep tightly related statements together. Avoid both
walls of code and a blank line after every statement.

Let the project's formatter own indentation, wrapping and mechanical layout.
Do not fight it with manual alignment or disable it for a preferred appearance.
Within its rules, favour layouts where conditions, arguments and data structures
are easy to scan. Never compress code simply to reduce its line count.

Use named intermediate values when they explain a non-obvious expression.
Avoid nested ternaries, tangled boolean conditions, surprising precedence and
side effects hidden inside expressions. A short idiomatic expression is fine
when it reads more clearly than expanded scaffolding.

Prefer guard clauses when they reduce nesting and make the normal path clear.
Keep success, failure and cleanup paths understandable. Extract a helper when
its name captures a useful concept, not merely to move complexity elsewhere.

## Make names and comments useful

Use domain vocabulary and distinguish important concepts. Make units and
transformations clear. Avoid unexplained abbreviations, vague names and boolean
arguments whose meaning is obscure at a call site. Small conventional names
are fine in genuinely small familiar scopes; verbosity is not clarity.

Use comments for contracts, constraints and non-obvious reasoning. Do not
narrate obvious statements or retain commented-out code. If a comment is needed
to explain what a block does, consider a clearer name or boundary first—but do
not extract a pointless helper just to eliminate a useful comment. Follow the
repository's public API documentation requirements.

## Inspect the result as a maintainer

Before handoff, read the actual diff and relevant surrounding code. Can a reader
find the entry point, follow the normal path, identify state changes and failure
behaviour, and understand why each helper exists? Look for unnecessary layers,
duplicate state, misleading names, dense expressions and poorly grouped code.

Correct concrete comprehension obstacles within scope, then rerun affected
checks. Preserve reviewability: do not mix broad reformatting or unrelated file
moves into a behavioural change. A review finding should name the obstacle and
its impact, not merely call the code unclean. Distinguish maintainability risks
from personal taste; no universal file, function or line-length quota substitutes
for judgment.

Record consequential durable decisions in the repository's architecture docs
or ADR convention when appropriate. Keep routine reasoning in the task rather
than creating documents nobody needs to maintain.
