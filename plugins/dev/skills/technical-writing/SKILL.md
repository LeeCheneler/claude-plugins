---
name: technical-writing
description: >-
  Write and edit concise, evidence-backed technical documents for human readers:
  ADRs, RFCs, design proposals, technical articles, engineering guides, and
  explanations. Load when drafting or substantially revising these documents,
  or reviewing technical prose for clarity, substance, and filler. Not for
  ordinary chat, code comments, or user stories alone; use user-stories for
  tickets and acceptance criteria.
---

# Technical Writing

Write the shortest complete explanation that lets the intended reader
understand, decide, or act. Concise means no wasted attention, not missing
reasoning. Substance, accuracy, and readability matter more than sounding
polished. This skill guides writing; it does not authorise publishing,
repository changes, or recording a decision as approved.

## Establish the brief

Use the request and existing material to identify:

- **Reader:** who they are and what they already know.
- **Purpose:** the decision, understanding, or action the document enables.
- **Core point:** the answer or recommendation in one sentence.
- **Constraints:** document type, destination, length, terminology, and any
  existing template or house style.

Infer routine details from context. Ask only when a missing answer changes
scope or substance. If the central decision is unknown, do not invent it.
Offer a clearly labelled proposal or ask for the decision. Do not make the
reader complete a questionnaire before a straightforward edit.

Read an existing draft and relevant sources before rewriting. Preserve supported
meaning and the writer's useful voice, not factual errors. Correct claims that
conflict with the evidence; flag unsupported conclusions rather than polishing
them into facts. Disclose substantive factual corrections in a brief editorial
note outside the document. Do not silently change requirements, commitments,
or decisions in the name of style.

## Build substance before sentences

1. Identify the core point and the evidence that supports it.
2. Keep only the context the reader needs to follow that reasoning.
3. Arrange the material in the order the reader needs it: answer first,
   explanation next, supporting detail where it becomes useful.
4. Draft plainly. When revising, fix the argument and structure before polishing
   sentences: move buried decisions forward, merge repeated reasoning, and cut
   sections that do not serve the reader. Then edit for clarity and economy.

An outline is a working aid, not a mandatory deliverable. For a short piece,
a paragraph may be the whole document. For a longer one, use headings that
name the topic or conclusion, not a procession of generic sections. Each
section must answer a distinct reader question. Do not print the writing
process, editorial checklist, or review scores unless requested.

## Evidence and intellectual honesty

- Verify claims about code, APIs, configurations, and behaviour against the
  relevant material. Do not manufacture plausible symbols or capabilities.
- Distinguish observed facts, inferences, estimates, proposals, and unresolved
  questions. Put qualifications next to the claim they limit.
- Numbers require a source, calculation, or an explicitly labelled estimate
  with its basis. A precise-looking number is not evidence.
- Cite consequential or contestable claims close to where they appear. Use
  identifiable sources and dates or versions when these affect the conclusion.
  Do not turn every ordinary explanation into a citation exercise.
- Examples must be correct and consistent with the explanation. Label
  hypothetical scenarios and illustrative values; never present them as
  measurements. Do not claim an example was tested unless it was.
- Explain causality: the mechanism, assumption, and consequence. Do not leap
  from a correlation or preference to a universal recommendation.
- Address meaningful counterarguments fairly. Compare viable alternatives
  against the same relevant criteria; do not invent weak options to make the
  recommendation look inevitable.
- State material limits without burying the answer in hedging. If evidence is
  insufficient, narrow the claim or identify the missing evidence.

## Choose the shape that serves the document

Follow a supplied or established template. Otherwise use the shapes below as
content guides, not compulsory headings. Omit empty or irrelevant sections.

### ADR: record a decision and its consequences

Make it possible for a future engineer to understand why this choice was made.
Include the decision status and date when known, the problem and constraints,
the decision, the reasons, and the consequences. Include rejected alternatives
only when they explain a real trade-off.

- Separate a proposed decision from an accepted one. Never invent approval,
  an owner, a date, or an ADR identifier.
- Say what the decision changes and what it deliberately does not change.
- Record costs and disadvantages as plainly as benefits. Capture assumptions
  or revisit conditions when their failure would change the decision.
- Preserve accepted decisions as historical records. A later reversal normally
  needs a superseding ADR and a link, not a rewrite that hides the old rationale.

### RFC: enable a reviewable decision

Lead with the proposed outcome and the decision or feedback needed. Explain
the problem, goals and non-goals, proposed behaviour or design, and why this
approach fits the constraints. Cover viable alternatives and material risks.

Include operational details only where they affect feasibility or review:
interfaces and compatibility, failure handling, security, rollout or migration,
rollback, observability, and how success will be verified. Separate settled
facts from proposals. Make open questions specific and consequential; do not
append speculative questions to look thorough. Do not assign owners, deadlines,
or approval status without evidence.

### Technical article: teach one coherent idea

State the main insight early. Explain the mechanism in a logical progression,
using a concrete example where it reduces abstraction. Supply necessary
prerequisites without a generic history lesson. Keep examples tied to the
point, explain their important behaviour, and expose relevant limitations.

Finish when the reader has the insight and its practical implications. A
conclusion earns its place by adding a useful synthesis or next action, not
by repeating each section. Do not turn an article into an RFC by default.

### Engineering guide: let the reader complete a task

State the outcome and prerequisites, then provide ordered, executable steps.
Put expected results and checks beside the steps that need them. Include
likely failure cases and recovery where useful. Clearly distinguish required
steps from optional choices. Verify commands and warn about destructive or
irreversible effects before the relevant action.

## Write for a human

- Prefer concrete nouns, direct verbs, and explicit actors. Use the team's
  actual vocabulary; explain unfamiliar terms once.
- Use active voice when ownership matters. Passive voice is fine when the
  actor is irrelevant or unknown. Clarity beats a mechanical grammar rule.
- Put conditions and exceptions beside the rule they modify. Distinguish
  requirements from recommendations and possibilities.
- Keep one main idea per paragraph. Vary sentence length naturally; split a
  sentence when its clauses make the reader hold too much at once.
- Use prose for reasoning, bullets for genuinely enumerable items, tables for
  comparisons on common dimensions, and diagrams for relationships that are
  harder to explain in words. Do not render the same content in every format.
- Prefer a specific example to another abstract paragraph. Examples supplement
  contracts; they do not silently define missing behaviour.
- Keep technical precision. Do not replace an accurate term with a vague
  synonym merely to avoid repetition, or remove a necessary caveat to shorten
  the piece. Avoid arbitrary sentence lengths and reading-level targets.

## Filter filler and synthetic-sounding prose

Edit for meaning, not to pass an AI detector or imitate a personality. A banned
word list is not a substitute for judgement. A familiar phrase is acceptable
when it says something specific and useful.

Remove or rewrite:

- Throat-clearing: “In today's rapidly evolving landscape”, “It is important
  to note”, and introductions that delay the actual subject.
- Empty praise and promotional claims: “powerful”, “seamless”, “robust”,
  “elegant”, or “game-changing” without a concrete property and evidence.
- Inflated verbs and nominalisations: “utilise”, “facilitate the implementation
  of”, “conduct an evaluation of” when “use”, “implement”, or “evaluate” works.
- Repeated conclusions, padded transitions, rhetorical questions with obvious
  answers, and a summary that merely restates the introduction.
- Decorative contrasts such as “not just X, but Y”, forced three-part lists,
  and symmetrical sections that add rhythm without adding information.
- Generic assurances about scalability, security, maintainability, or best
  practices. Name the mechanism, constraint, failure mode, or check instead.
- False certainty, vague attribution (“experts agree”), and qualifiers that
  conceal an absent source (“typically”, “generally”) rather than express a
  real limit.
- Invented anecdotes, personal experience, quotations, measurements, or casual
  asides added to make the text seem human. Do not manufacture a human voice.

Do not strip warmth, useful signposting, or genuine nuance. The test is whether
removing or replacing the passage improves the reader's understanding.

### Examples of the editorial standard

**Filler → direct statement**

> It is important to note that this approach facilitates the implementation
> of a more streamlined deployment process.

If the source supports the specific effect:

> This removes the manual approval step from deployments.

If it does not, ask what actually changes; do not invent an effect to rescue
an empty sentence.

**Unsupported benefit → mechanism and limit**

> Caching ensures optimal performance and seamless scalability.

A hypothetical explanation, not a measured claim:

> Caching repeated reads reduces database queries. It does not help cache
> misses, and cached results may be stale until they expire.

**Buried decision → reviewable proposal**

Hypothetical draft; its concrete facts are the supplied source material:

> **Context:** As reporting evolves, we need a robust foundation that balances
> flexibility and operational simplicity. There are several paths forward.
>
> **Architecture:** Reports run in the API service. A separate worker would
> allow independent scaling. Our deployment tooling does not yet support
> operating a second service.
>
> **Benefits:** A pragmatic approach would streamline operations and provide
> a solid foundation for future enhancements.
>
> **Next steps:** We propose keeping reports in the API service for now.
> Report load will continue to compete with request handling. Revisit the
> decision when the tooling supports a separate deployment.

Revised:

> **Proposal: keep reports in the API service for now.**
>
> Our deployment tooling does not yet support operating a second service.
> Keeping reports in the API service avoids that requirement, but report load
> will still compete with request handling and cannot scale independently.
>
> Revisit when the tooling supports a separate deployment.

The edit moves the proposal first, retains its constraint, downside, and
revisit condition, and removes empty sections. It neither invents a stronger
rationale nor turns a proposal into an accepted decision.

## Final editorial pass

Before delivering, check the document itself:

1. **Point:** can the intended reader find the answer, proposal, or insight
   near the start, without reading the whole piece?
2. **Completeness:** can they follow the reasoning and act or review it? Are
   the material constraints, disadvantages, and unknowns visible?
3. **Truth:** do claims, examples, numbers, citations, and decision status
   agree with the available evidence? Did an edit strengthen a claim unfairly?
4. **Economy:** does every paragraph add information? Delete repetition and
   sections whose absence would not change understanding or action.
5. **Readability:** are actors, terminology, transitions, and references clear?
   Read for flow, not just grammar. Replace vague abstractions with specifics.
6. **Consistency:** do the summary, body, examples, and conclusion agree?
   Resolve contradictions instead of polishing around them.

Deliver the requested document, not commentary about how well it was written.
For an editorial review, report consequential problems with their location,
reader impact, and a suggested correction; distinguish factual problems from
style preferences. Flag unresolved evidence gaps rather than polishing them
into apparent facts. Never claim a subjective checklist guarantees quality.
