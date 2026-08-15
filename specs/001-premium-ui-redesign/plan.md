# Implementation Plan: Premium UI Redesign

**Branch**: `001-premium-ui-redesign` | **Date**: 2026-08-13 | **Spec**: [spec.md](./spec.md)

## Summary

Redesign the completed LED Display application into a cohesive premium dark mobile interface while preserving all completed product behavior. The work is presentation-led: establish a semantic dark design system, compose the existing live display inside new visual framing, replace prototype-like screen composition and controls, and retain every existing functional boundary, route, signal, resource binding, and persisted state.

The approved interaction decisions are: a persistent bottom action bar on every mode detail screen; Home ModeCards using approved original static visuals from `assets/ui/mode_cards/`; and compact accent-led Favorites and History lists.

## Visual Reference Gate

Before implementing, reviewing, or accepting any UI task for this feature, review [premium-ui-reference.png](../../docs/design/reference/premium-ui-reference.png). It is the primary visual reference for composition, hierarchy, proportions, spacing, cards, preview treatment, control density, navigation, dark surfaces, border/glow restraint, accents, typography, buttons, segmented controls, sliders, and switches. For Home ModeCards also review [mode-cards-style-reference.png](../../docs/design/reference/mode-cards-style-reference.png), the mandatory companion reference for the approved original static imagery.

Do not reproduce it pixel-for-pixel or reuse its branding. Adapt the direction to the existing app and Godot's Control/Theme capabilities. If an implementation must differ, record a concrete UX or technical reason in the affected task's validation evidence. Existing functionality and the contracts in [ui-regression-contracts.md](./contracts/ui-regression-contracts.md) always take priority.

## Technical Context

**Language/Version**: GDScript on Godot 4.7 (project feature declaration).

**Primary Dependencies**: Godot built-in Control, Container, Theme, StyleBoxFlat, shader, Tween, audio, and Android platform APIs; bundled Inter, Manrope, and Nunito Sans fonts.

**Storage**: Existing Godot resources and user-local saved settings, projects, autosave, and radio recording. No storage changes.

**Testing**: Existing project has no automated test suite. Validate scene loading, existing manual Android smoke flows, portrait phone/tablet layouts, touch-target review, and visual consistency review.

**Target Platform**: Android, portrait-first, with Godot desktop editor used for layout and scene validation.

**Project Type**: Mobile application.

**Performance Goals**: Maintain fluid interaction and a responsive live display during normal configuration on representative Android phones; keep static Home preview textures appropriately sized for their rendered ModeCard dimensions and avoid unnecessary texture-memory cost.

**Constraints**: Preserve `LedBoard` as the single live preview/fullscreen source; do not alter playback, audio, animation, autoload, persistence, or public UI contracts. Home cards use only approved original static PNG/WebP assets from `assets/ui/mode_cards/` as presentation; Godot renders surrounding labels, states, borders, and navigation. Reject stock/unverified-rights assets and official emergency-service identity; retain 44 dp minimum touch targets; keep phone and tablet layouts container-based.

**Scale/Scope**: One existing Godot application with 7 signal presets, 4 thematic presets, Advanced Editor, four root navigation destinations, and all current setting/project/radio workflows.

## Constitution Check

Active constitution: [LED Display Constitution v2.0.0](../../.specify/memory/constitution.md). This feature is evaluated against every active principle; “Pass” describes planning compliance only and is not implementation acceptance.

| Constitution principle | Factual feature assessment |
| --- | --- |
| I. Existing Architecture First | **Pass.** The plan begins from the existing scene/script/autoload inventory, assigns presentation ownership to composition-oriented components, and retains existing router, card-factory, and controller contracts rather than introducing duplicate systems. |
| II. Protected Runtime Boundaries | **Pass.** The scope and UI regression contract preserve `LedBoard`, playback services, autoload APIs, persistence, and preset data. Presentation work is constrained to wrappers, themes, and compatible scene/controller bindings. |
| III. Spec-Driven Changes | **Pass.** The approved feature specification, research decisions, implementation plan, task list, and regression contract define the permitted redesign. No new functional behavior or breaking change is planned. |
| IV. Android-First UI and UX | **Pass, pending evidence.** Phone portrait is the primary layout; the plan requires shared theme/components, responsive containers, and 44 dp touch targets. T009 and the later phase validation gates must provide factual layout and target-size evidence. |
| V. Approved Visual References | **Pass, pending validation evidence.** Both approved references are mandatory task inputs. Implementations must adapt—not copy—them, and validation must record a concrete UX or technical reason for any necessary deviation. |
| VI. Visual Asset Provenance and Separation | **Pass.** Home preview layers are limited to approved original static assets in `assets/ui/mode_cards/`; Godot renders surrounding UI separately. Stock/unverified assets and official emergency-service identity are excluded, and asset sizing is a required performance consideration. |
| VII. Mobile Performance First | **Pass.** The plan favors appropriately sized static Home textures over decorative live previews and requires asset/memory validation without changing the live `LedBoard` runtime boundary. |
| VIII. Evidence-Based Validation | **Gate pending.** Phase validation tasks require factual `git diff --check`, Godot parse/import, startup, portrait, regression, and available Android checks. T001 and T009 are reopened because their current records lack the required evidence; T015 remains blocked until Android/export evidence is available. |
| IX. Incremental, Approval-Gated Delivery | **Pass as a delivery rule; Phase 4 is locked.** Tasks prohibit Phase 4+ until Phase 3 validation passes and the user explicitly approves the Home milestone. Equivalent validation-and-approval gates separate every later visually significant phase. |
| X. No Unapproved Feature Expansion | **Pass.** The plan is limited to existing UI presentation and validation; new modes, settings, monetization, export formats, data models, and UX flows remain out of scope. |

**Post-design re-check**: Planning compliance is recorded above. Implementation acceptance remains blocked by the applicable milestone evidence and explicit visual approvals; the plan introduces no new persisted entities, external services, or functional system changes.

## Project Structure

### Documentation (this feature)

```text
specs/001-premium-ui-redesign/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui-regression-contracts.md
└── tasks.md                 # Created later by speckit-tasks
```

### Source Code (repository root)

```text
autoload/
├── app_settings.gd
├── audio_manager.gd
├── project_manager.gd
└── router.gd

resources/
├── presets/
├── presets_thematic/
└── palettes/

assets/
└── ui/
    └── mode_cards/          # Approved original static Home ModeCard PNG/WebP assets

scenes/
├── AppShell.tscn
├── app_shell.gd
├── components/
│   ├── LedBoard.tscn
│   ├── led_board.gd
│   ├── ModeCard.tscn
│   ├── BottomTabBar.tscn
│   └── accent_theme.gd
├── panels/
└── screens/

theme/
├── app_theme.tres
└── fonts/

shaders/
└── dot_matrix.gdshader
```

**Structure Decision**: Retain the existing Godot scene structure. Add or evolve only presentation-oriented components and Theme resources under `scenes/components/` and `theme/`. Existing runtime, panel, screen, and autoload files remain the functional source of truth; any scene/controller changes must preserve the contract documented in [contracts/ui-regression-contracts.md](./contracts/ui-regression-contracts.md).

## UI Component Ownership

The following files are owned by the foundational design-system work. Screen migration tasks consume these components and must not create competing implementations.

| Owner | Files | Responsibility |
|---|---|---|
| Theme foundation | `theme/app_theme.tres` | Semantic dark tokens and all common control-state styles. |
| Accent presentation | `scenes/components/accent_theme.gd` | Runtime application of existing preset accents to supported presentation variants only. |
| Mode-card presentation | `scenes/components/ModeCard.tscn`, `scenes/components/mode_card.gd`, `scenes/components/mode_card_factory.gd`, `assets/ui/mode_cards/` | Maps each existing mode to its approved static asset and composes that asset behind Godot-rendered title, subtitle, accent, and interaction state; it does not own mode behavior. |
| Shared navigation and framing | `scenes/components/AppTopBar.tscn`, `scenes/components/app_top_bar.gd`, `scenes/components/LedPreviewFrame.tscn`, `scenes/components/led_preview_frame.gd` | Top-level navigation chrome and visual framing around an unchanged `LedBoard` instance. |
| Shared control presentation | `scenes/components/SectionCard.tscn`, `scenes/components/SettingRow.tscn`, `scenes/components/SegmentedControl.tscn`, `scenes/components/ChoiceChip.tscn`, `scenes/components/SliderRow.tscn`, `scenes/components/PrimaryActionBar.tscn` | Reusable visual composition for grouped settings, selections, sliders, and persistent detail actions; existing control semantics remain the owner of behavior. |
| Responsive presentation | `scenes/components/responsive_layout.gd` | Portrait phone/tablet size categories and common safe action-bar inset calculations. |

### Approved Home ModeCard asset manifest

The asset-to-mode mapping below is the source of truth for Home presentation tasks. It is not mode data and must not change routing or playback behavior.

| Existing mode | Approved asset |
|---|---|
| Police | `assets/ui/mode_cards/police.png` |
| Ambulance | `assets/ui/mode_cards/ambulance.png` |
| Fire | `assets/ui/mode_cards/fire.png` |
| Warning | `assets/ui/mode_cards/warning.png` |
| SOS | `assets/ui/mode_cards/sos.png` |
| Taxi | `assets/ui/mode_cards/taxi.png` |
| Security | `assets/ui/mode_cards/security.png` |
| Party | `assets/ui/mode_cards/party.png` |
| Love | `assets/ui/mode_cards/love.png` |
| Birthday | `assets/ui/mode_cards/birthday.png` |
| Christmas | `assets/ui/mode_cards/christmas.png` |
| Advanced Editor | `assets/ui/mode_cards/advanced_editor.png` |

### Pre-migration presentation audit

- The original Theme covered only generic panels and buttons; inputs, options, check controls, and sliders inherited prototype-like defaults.
- Original screens relied on local scene margins and two-column grids; no shared responsive size-category policy existed.
- Original mode cards used an emoji icon panel and one accent fill; their route and signal API were retained as the compatibility boundary for the redesign.
- The original `AccentTheme` helper only tinted selected/active buttons. It is now extended as the presentation-only accent layer; it does not own mode behavior or playback state.

## Implementation Approach

1. Establish semantic design tokens and reusable component variants before migrating screens, so colors, spacing, typography, states, and touch targets cannot drift between views.
2. Build presentation shells around the unchanged live display and existing input controls; controls retain existing signals, values, and action handlers.
3. Migrate Home using approved static ModeCard assets and compact secondary lists while keeping ModeCard factory routes and navigation indices compatible.
4. Migrate both detail screen types into one visual shell with a fixed app bar, scrollable mode-specific groups, and the approved persistent action bar.
5. Re-present Advanced Editor with progressive disclosure around its preserved panel APIs, then align Settings, dialogs, and navigation with the same system.
6. Validate after each migration against the UI regression contract and run final Android smoke checks on phone and tablet.
7. At each visual checkpoint, compare the implemented screen with the primary visual reference and record any justified deviation.

## Complexity Tracking

No constitution violations or complexity exceptions require justification.
