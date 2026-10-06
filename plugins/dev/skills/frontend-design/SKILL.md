---
name: frontend-design
description: Design and build high-quality web interfaces and product UI/UX. Load for websites, home and landing pages, frontend components, dashboards, forms, navigation, responsive layouts, visual polish, interaction design, accessibility improvements, and UI reviews—even when the request just says make this look better. Covers distinctive visual direction, existing design systems, and complete user flows. Works from source, references, and user feedback; browser testing is user-led by default. Not for backend-only changes or frontend logic with no user-facing effect. For repository code changes, load dev:dev-work-kickoff first; this skill supplements it.
---

# Frontend Design

Bring a strong design point of view to working software. Make interfaces clear,
coherent, distinctive where appropriate, and satisfying to use. Visual craft,
interaction design, content, and accessibility belong together—not in separate
polishing passes.

This is design guidance, not a browser-testing workflow. Work effectively from
the brief, source code, existing components, supplied references, and Lee's
feedback. Lee normally drives browser testing, especially authenticated flows.
Do not make preview access a prerequisite, seek credentials or session access,
or start a run–inspect–refine cycle by default. Use the browser when Lee asks
for it and suitable access is available; otherwise get on with the design work.

## Understand before inventing

Identify the user, their primary task, and what success looks like. A marketing
page, checkout, and daily-use workspace have different design priorities; they
should not all become a hero above a grid of cards.

Read the relevant components, styles/tokens, assets, content conventions, and
adjacent flows. Follow the existing product's visual language unless a redesign
is requested. Reuse its components and patterns, but do not reproduce known
accessibility defects. Inspect actual APIs and installed dependencies rather
than prescribing a framework or UI library by habit.

Ask only when missing information materially changes the result. Otherwise
make a sensible assumption and proceed. Match effort to the request: a small
polish fix needs good judgment, not a design contract, audit, or redesign.
Design-only requests produce designs; review-only requests produce findings,
not unsolicited code changes. Repository instructions and development rules
still apply.

## Choose a direction

For substantial new UI, settle the hierarchy, composition, density, typography,
color roles, and interaction model before writing it. Keep the rationale short:
what should the user understand first, what should they do next, and what gives
this interface its character? Sketch only when it helps resolve a real choice.

For a new identity or expressive redesign, derive the visual direction from
the subject, audience, and content. Consider genuinely different approaches,
then recommend one—not several versions of the same layout with different
accent colors. If the composition, typography, and imagery could be reused
unchanged for an unrelated product, sharpen the idea before building.

Put expression where it earns its place: a meaningful illustration, useful
visualization, distinctive composition, or confident type treatment. Keep core
controls familiar. An internal operations tool does not need a memorable hero;
its craft can be clarity, speed, and precision. In an established app,
continuity may be the strongest design choice.

## Make the hierarchy do the work

The user's task should dominate, not the chrome. Establish hierarchy through
position, type, spacing, and contrast before reaching for more containers.
Group related content through proximity and alignment. Cards suit distinct
units, not every paragraph or metric.

Give the current task a clear primary action. Keep frequent actions discoverable
and disclose secondary complexity progressively. Preserve location and spatial
memory in repeated-use tools. Do not hide essential actions exclusively behind
hover or unexplained icons.

Choose density for the work. Tables support comparison; lists support scanning;
forms support decisions. A dense professional tool need not become airy to look
considered. Let whitespace explain relationships rather than simply making
everything bigger.

Design responsive transformations, not just smaller desktop layouts. Preserve
content priority, meaningful order, and reachable actions. Do not turn a useful
table into unrelated mobile cards if that destroys comparison; consider column
priority or a clearly scoped scrolling region instead of page-wide overflow.
Account for long labels, translated text, large values, missing images, text
zoom, and empty/full datasets in the layout and implementation.

## Typography, color, and craft

Reuse the product's typography first. For a new system, choose a legible family
with suitable weights, glyph coverage, licensing, and loading behavior; add a
second only for a clear role. Familiar families and system fonts are valid.
Establish a deliberate type scale, readable body text, comfortable line lengths
and leading, and consistent weight and spacing. Tiny low-contrast metadata is
not sophistication.

Use a compact, coherent set of tokens rather than isolated magic values.
Distinguish surface, text, action, and status roles. Plan contrast against the
actual background colors and across interaction states; account for overlays
and imagery rather than assuming a palette guarantees legibility. Status must
remain understandable without color alone.

Pay attention to alignment, spacing rhythm, icon size/stroke, radii, borders,
and elevation. These small relationships often matter more than another visual
effect. Shadows and borders should explain grouping or layering, not add noise.

Avoid unexplained template habits: gradients everywhere, oversized empty
heroes, identical metric cards, decorative numbering, all-caps micro-labels,
arbitrary accent words, or animation on every element. None is universally
banned. Keep a treatment when the brief and content justify it—not because it
is fashionable, and don't reject it merely because it is familiar.

## Design the interaction, not just the resting state

Think through what happens before, during, and after the action. Cover relevant
loading, empty, no-results, error/retry, success, disabled, and permission states
as part of the component design—not as a mandatory matrix for every small edit.
Avoid briefly showing an empty-state CTA while data is still loading.

Give actions clear feedback. Distinguish pending from completed, protect against
duplicate submissions, preserve recoverable input, and provide a useful way
back or out. Prefer undo for safe reversible actions and proportionate
confirmation for irreversible ones. Do not obstruct cancellation, conceal costs,
or use manipulative consent patterns.

Every enabled control should work within the agreed scope. Label prototype-only
behavior and omitted integrations; do not imply a save reached a backend when
only a local mock changed. Do not invent backend capabilities or expand scope
just to complete a visual idea.

Use semantic HTML and suitable existing accessible components. Design for
keyboard use, visible focus, meaningful names, persistent labels, clear errors,
and sensible focus entry/return for overlays. Prefer native behavior to custom
widgets; custom controls need their established keyboard/focus patterns.

Motion should explain an action, continuity, or attention—not decorate every
transition. Avoid scroll hijacking, gratuitous entrances, and making users wait
for animation before controls work. Honor reduced motion while retaining
understandable feedback.

## Accessibility baseline

Aim for WCAG 2.2 AA in the implementation. A few useful design constraints:

- Text contrast is at least 4.5:1, or 3:1 for large text (18 pt, or 14 pt bold).
  Necessary visual control/state cues need 3:1 against adjacent colors, subject
  to the criteria's exceptions; decorative borders need not all meet that ratio.
- Pointer targets should be at least 24 × 24 CSS px, unless an applicable
  spacing or other WCAG exception is met. Prefer generous hit areas for important
  controls; 44 × 44 is a stronger touch-usability recommendation, not the AA minimum.
- Support text resizing to 200%. Vertically scrolling content should reflow at
  320 CSS px width without lost information or two-dimensional scrolling,
  except parts genuinely requiring a two-dimensional layout, such as some tables.
- Keep focused controls visible, maintain logical reading/focus order, associate
  labels and errors with inputs, and provide alternatives to drag-only actions.
  Do not prevent password-manager use or pasting into authentication fields.

These constraints supplement the semantic and interaction guidance above;
they are not an exhaustive audit. Reduced-motion support is a design baseline
here, not a blanket AA requirement. Do not claim accessibility conformance from
source review or a checklist, and do not turn these principles into a mandatory
browser-testing process.

## Words and assets are design material

Write in the user's language, not the system's internal terminology. Use
specific action labels such as “Save changes” rather than “Submit”, and keep
that action name consistent through feedback. Placeholders supplement labels;
they do not replace them. Errors explain what happened and how to recover.
Empty states explain why they are empty and suggest a relevant next step.

Use realistic content early so the layout serves it. Mark synthetic data as
fixtures/demo content. Never invent testimonials, customer claims, or production
metrics to make a page persuasive. Use approved assets and respect their rights;
a UI task does not authorize paid asset generation. Follow supplied visual
references faithfully where requested without copying others' branding or
assets without permission.

## Apply judgment as you build

Keep implementation simple and consistent with the repo. Reuse before extending;
avoid styling specificity battles, inaccessible visual-order tricks, unrelated
refactors, or a new design-system framework for one screen. Accessibility and
performance are implementation concerns, not optional finishing touches.

Review your choices against the brief and the code you actually have: is the
hierarchy clear, does the interaction make sense, are the states handled, and
does the result belong in this product? Correct concrete problems; don't add
effects or churn a sound direction merely to demonstrate refinement. Run the
project's relevant available tests, type checks, lint, or builds as appropriate
under its development rules. Browser inspection is not a completion gate this
skill adds to ordinary implementation work.

When Lee supplies a screenshot or feedback, use it to make specific improvements.
Separate visible problems from inferred behavior: a screenshot can reveal weak
hierarchy, but cannot establish keyboard behavior. For reviews, state the issue,
user impact, and useful correction; distinguish defects from taste preferences.
Do not turn every handoff into a test plan. Mention a targeted browser check
only where it materially helps Lee verify the change, and be truthful about
what was actually checked without repeatedly treating absent browser access as
a blocker.

## Sources

This skill is self-contained. These sources informed its guidance; they are
provenance, not required reading or additional instructions to load:

- [Anthropic frontend-design skill](https://github.com/anthropics/skills/blob/41bbe19d1a1a7eaab5e7bb9050a417e5c6cffc8f/skills/frontend-design/SKILL.md): intentional visual direction and restraint.
- [Nielsen's usability heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/): clarity, feedback, control, and recovery.
- [GOV.UK component guidance](https://design-system.service.gov.uk/get-started/extending-and-modifying-components/): reuse and considered adaptation.
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/) and [WAI ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/): accessibility requirements and informative interaction patterns.
