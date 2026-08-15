<!--
Sync Impact Report
- Version change: 1.1.0 → 2.0.0
- Modified principles: Functional Contract Preservation; Reference-Guided Presentation;
  Asset Provenance and Factual Presentation; Android-First Responsive Quality; and
  Deliberate, Scope-Bound Change → the ten project-wide principles below.
- Added sections: Project Architecture and Runtime Boundaries; Validation and Delivery Gates.
- Removed sections: none.
- Follow-up TODOs: none.
-->

# LED Display Constitution

## Core Principles

### I. Existing Architecture First

The existing production architecture and public APIs are the source of truth. Before changing
code, contributors MUST inspect the affected scenes, scripts, autoloads, resources, and public
contracts. Working architecture MUST NOT be rewritten merely for conceptual cleanliness; prefer
composition over replacement and do not create duplicate managers, services, or systems.

### II. Protected Runtime Boundaries

The public APIs and behavior of `LedBoard`, SignalPlayer, ThematicPlayer, TextAnimator,
SirenPlayer, AudioReactor, AudioManager, ProjectManager, Router, and AppSettings are protected.
Persistence contracts and preset data structures are protected as well. Any change to one of
these boundaries requires a separately approved specification and an explicit regression plan.

### III. Spec-Driven Changes

New functionality and breaking changes MUST have a separate approved specification. Implementation
MUST NOT expand the approved scope. When a solution or design decision changes, update the
applicable specification, research, plan, and tasks before code; implementation MUST conform to
the current approved specification.

### IV. Android-First UI and UX

Android phone portrait is the primary UX target. UI MUST use the shared design system and reusable
components, with touch targets of at least 44 dp where layout permits. Random mixing of default
Godot styles is prohibited. Visual implementation MUST follow approved references; a change in
visual direction requires a specification update before implementation.

### V. Approved Visual References

UI work MUST review [premium-ui-reference.png](../../docs/design/reference/premium-ui-reference.png).
Home ModeCard work MUST also review
[mode-cards-style-reference.png](../../docs/design/reference/mode-cards-style-reference.png).
These assets define design direction, not pixel-perfect copying or permission to reuse branding.
Any intentional deviation MUST record a concrete UX or technical reason in validation evidence.

### VI. Visual Asset Provenance and Separation

Only approved original static PNG or WebP assets, or assets with confirmed rights, MAY be used in
production. Stock or unverified-rights images are prohibited. Emergency visuals MUST remain
generic and fictional; official logos, crests, department names, service numbers, vehicle
liveries, and other official identity are prohibited. Godot MUST render UI text, states, borders,
and navigation separately from preview assets. Production asset resolution MUST match the actual
rendered target and avoid unnecessary package, memory, and texture cost.

### VII. Mobile Performance First

Mobile performance and memory use take precedence over decorative complexity. Do not use heavy
live previews where a static preview is sufficient, and do not add continuous off-screen
processing without a demonstrated product need. Any rendering work added to a mobile screen MUST
be bounded and validated on the relevant device class.

### VIII. Evidence-Based Validation

After every significant implementation milestone, run Godot parse/import validation and start the
project. Run Android export when the environment is available, review the affected UI in phone
portrait, and execute regression smoke checks for preserved functions. A validation task MUST NOT
be marked complete without the corresponding factual check; unavailable device or export checks
MUST be recorded as deferred, never represented as passed.

### IX. Incremental, Approval-Gated Delivery

Implementation proceeds in approved phases. After a visually significant milestone, stop for
visual approval before starting the next phase. A failed validation blocks automatic progression.
If the user requests a stop at Phase N, Phase N+1 and later MUST NOT be implemented until the
user explicitly authorizes continuation.

### X. No Unapproved Feature Expansion

Do not add new modes, settings, monetization, export formats, or UX flows without an explicit
approved specification. Improvements proposed by a contributor are prohibited when they alter
scope; present them for approval instead of implementing them.

## Project Architecture and Runtime Boundaries

- The project uses Godot 4.7, GDScript, Android as the primary platform, and Google Play as the
  target distribution platform.
- `LedBoard` remains the single source of truth for embedded and fullscreen live display output.
  UI composition wraps it without duplicating or simulating its runtime behavior.
- Existing Resources remain the source of preset, palette, configuration, and project data.
  Existing autoloads remain the source of shared state; no parallel data model is permitted.
- Independent components use existing signals or documented interfaces rather than new hard
  dependencies. Scene/controller changes MUST preserve dependent unique-node and signal paths or
  update all dependent references atomically.

## Validation and Delivery Gates

- Each implementation pass MUST have approved scope, explicit completion criteria, and a safe
  return point before a material change. Significant stages MUST be committed separately.
- Do not mix independent feature changes in a single implementation pass. Before a large change,
  establish a safe rollback point through the current Git history.
- Run all relevant available checks, including `git diff --check`, before reporting a milestone.
  Report changed files, performed checks, results, and remaining risks or deferred validation.
- An implementation phase may proceed only as authorized by the user and its approved plan. It
  MUST NOT automatically advance after failed validation or after an explicit user stop request.

## Governance

This constitution is the permanent project-wide governance for LED Display and applies to every
feature, plan, task list, implementation, and review. It is subordinate only to higher-priority
system instructions and explicit user instructions. Specifications and implementation evidence
MUST be reviewed for constitutional compliance before code changes and before acceptance.

Amendments require an explicit rationale, impact review of affected planning artifacts, and a
semantic version change: MAJOR for incompatible principle removal or redefinition, MINOR for a
new or materially expanded rule, and PATCH for clarifications that preserve the current meaning.
The ratification date remains the original adoption date; `Last Amended` changes with each
amendment.

**Version**: 2.0.0 | **Ratified**: 2026-08-14 | **Last Amended**: 2026-08-14
