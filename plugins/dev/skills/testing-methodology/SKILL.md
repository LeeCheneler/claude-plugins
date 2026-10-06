---
name: testing-methodology
description: Plan, write and evaluate tests for code changes across languages. Load alongside dev:dev-work-kickoff when changing behaviour, fixing a bug, refactoring tested code, or changing tests; also load for test-quality reviews. Covers risk-based test selection, regression proof, test levels, restrained mocking, determinism and readable scenarios. Use repository tooling and preserve user-led browser testing.
---

# Testing Methodology

Tests are evidence that an observable contract holds, not a count of assertions
or a mirror of the implementation. Use this method proportionately and follow
the repository's tooling, permissions and development lifecycle.

## Decide what evidence is needed

Before implementation, identify expected behaviour, invariants and the plausible
ways the change could fail. Read nearby tests and test commands. Connect each
important requirement or risk to a concrete check; reuse existing coverage when
it genuinely proves the behaviour. Do not invent requirements from current code
or treat existing behaviour as correct when the task explicitly changes it.

Select relevant cases: normal operation, boundary values, invalid input,
permission denial, partial failure, retries, cancellation, cleanup and state
transitions. For concurrent or persistent work, consider races, ordering and
restart/round-trip behaviour. This is a risk menu, not a mandatory matrix for
every edit. Scale effort to consequences and uncertainty.

Clarify ambiguous expected results before encoding them as tests. Expected
values should come from the contract or an independent example—not from calling
the same implementation or copying its algorithm into the assertion.

## Prove regressions when practical

For a bug fix, first write or identify a regression test and observe it fail for
the intended reason before applying the fix, then observe it pass afterwards.
A syntax error or broken fixture is not evidence of the regression. When a
reproduction is impractical or the fix already exists, report that limit rather
than claiming a demonstrated red/green cycle. Do not destructively revert user
work to manufacture a failing run.

For refactoring, preserve observable behaviour and use existing tests or add
characterisation coverage at the relevant boundary first. Clearly distinguish
characterising existing behaviour from approving it as the desired contract.

Universal test-first development is not required. Establish expected behaviour
independently, keep the implementation/test feedback loop short, and verify the
final code after any subsequent simplification.

## Choose the lowest level that proves the behaviour

- Use unit tests for pure transformations, domain rules and isolated decisions.
- Use integration tests when correctness depends on real wiring, persistence,
  serialisation, queries, transactions or interactions between components.
- Use contract tests at compatibility boundaries where they provide useful
  assurance; keep fixtures representative of the actual contract.
- Use end-to-end tests selectively for critical complete journeys and risks
  that lower-level checks cannot establish.

Do not force every assertion into a unit test or duplicate an entire case matrix
at every layer. Test stable observable interfaces; internal call counts and
private helper names are usually implementation details. Some interactions,
such as preventing duplicate external writes, are themselves the contract and
can deserve precise assertions.

In UI tests, prefer roles, labels and visible text. Check interaction, state and
accessible behaviour rather than decorative copy, class names or incidental DOM
structure. Use the appropriate visual/browser surface for layout requirements.
Browser testing remains user-led by default: do not start servers, seek session
access or require an agent browser pass unless authorised. Record a material
manual verification gap without claiming the source proves visual correctness.

## Keep doubles honest and tests deterministic

Mock external, costly or nondeterministic boundaries where needed. Prefer real
in-process collaborators when they are cheap and reliable. Do not mock away the
interaction the test is supposed to verify. A fake should reflect the relevant
contract; use integration coverage where fidelity matters.

Control time, randomness and asynchronous completion through suitable test seams.
Avoid arbitrary sleeps; wait for observable completion using project tooling.
Isolate fixtures and mutable state, clean up resources, and avoid order-dependent
tests. Keep tests local and safe; never make real paid, destructive or production
calls merely to validate a change.

## Write tests as readable examples

Name the condition and expected outcome. Keep arrange, act and assert easy to
see, with whitespace separating meaningful phases. Use only the fixture data
needed to understand the case, with explicit names for important distinctions.

Prefer local setup over elaborate shared machinery that hides the scenario.
Extract helpers for coherent repeated concepts, not at a repetition quota.
Table-driven cases work well when they share a clear contract and failures
remain easy to diagnose; do not compress different behaviours into an opaque
parameter table. Assert the meaningful outcome, not every incidental detail.

## Challenge the tests, then report the evidence

Ask what plausible incorrect implementation could still pass: a constant
return, an omitted filter, an ignored failure, a skipped side effect, or a result
for the wrong user. Strengthen cases or assertions that cannot discriminate.
Use targeted mutation testing when justified and available—not a mandatory
mutation run or a blanket coverage-percentage target.

Run focused tests during implementation, then the relevant broader checks for
the affected boundaries. Use the repository's actual commands; inspect scripts
before executing them. Test changes require verification too. If a check fails,
diagnose it; distinguish an observed pre-existing failure from an assumption.
Never weaken a valid assertion merely to make the suite green.

Report what ran, outcomes, and important checks not run. Distinguish behavioural
tests, type checks, lint and builds: each supplies different evidence. A passing
build, high coverage number or passing mocked test does not establish complete
correctness. Re-run affected checks after fixes or readability refactoring.
