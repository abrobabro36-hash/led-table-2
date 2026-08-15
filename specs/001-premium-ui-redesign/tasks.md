---

description: "Actionable implementation tasks for Premium UI Redesign"
---

# Tasks: Premium UI Redesign

**Input**: Design documents from `/specs/001-premium-ui-redesign/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [ui-regression-contracts.md](./contracts/ui-regression-contracts.md), [quickstart.md](./quickstart.md)

**Tests**: No automated test suite or TDD requirement exists for this Godot UI redesign. Each story includes a mandatory editor/device smoke validation task based on the quickstart guide.

**Visual references**: Before implementing or accepting any UI task in this file, review [premium-ui-reference.png](../../docs/design/reference/premium-ui-reference.png). For Home ModeCard tasks, also review [mode-cards-style-reference.png](../../docs/design/reference/mode-cards-style-reference.png) and use only approved original assets from `assets/ui/mode_cards/`. Follow the direction without pixel-perfect copying; preserve current functionality and public contracts first, and record a concrete UX or technical reason for each necessary deviation.

**Organization**: Tasks are grouped by user story so every increment remains independently demonstrable and regression-testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel after its stated prerequisites are complete and does not edit the same file.
- **[Story]**: Maps a task to a user story in [spec.md](./spec.md).
- Every task includes the exact files to change or validate.

## Mandatory Milestone Validation Gate

Each phase validation task (T001, T009, T015, T022, T028, T035, and T039) MUST record factual evidence for every applicable item below before it may be marked complete:

1. `git diff --check` with no unresolved whitespace errors.
2. Godot parse/import validation with no unresolved errors.
3. Project startup with no unresolved errors.
4. Affected UI review in Android phone portrait, including layout, touch-target, clipping/overflow, and approved-reference checks appropriate to the phase.
5. Android export and physical-device smoke check when the environment is available. If unavailable, record it as deferred/blocked; never represent it as passed.
6. Preserved-function regression smoke checks from the applicable part of `quickstart.md` and `ui-regression-contracts.md`.

A failed required check blocks completion and blocks the next phase until resolved. After each visually significant phase, completion also requires explicit user visual approval before the next phase may start. `[P]` permits parallel work only within the currently approved phase; it never bypasses this gate or Constitution IX.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish a safe baseline and the implementation constraints before changing UI presentation.

- [ ] T001 Reopen the pre-redesign editor and Android smoke baseline record from `specs/001-premium-ui-redesign/quickstart.md` and `specs/001-premium-ui-redesign/contracts/ui-regression-contracts.md`. Historical evidence currently records a headless scene/class scan and headless project startup; it does not record the complete Mandatory Milestone Validation Gate. Record `git diff --check`, parse/import, portrait, regression, and Android/export/device evidence where factually available, and record unavailable checks as deferred/blocked without representing them as passed.
- [X] T003 [P] Inspect and document all current Theme overrides in `theme/app_theme.tres`, `scenes/**/*.tscn`, and `scenes/components/accent_theme.gd` before token migration.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the shared presentation system and compatibility boundary required by all screens.

**⚠️ CRITICAL**: Complete this phase before migrating any user-facing screen. Component ownership and exact foundational paths are defined in `specs/001-premium-ui-redesign/plan.md` under “UI Component Ownership”.

- [X] T004 Expand semantic dark design tokens and base control states in `theme/app_theme.tres` for surfaces, borders, text hierarchy, spacing, radii, elevation, and disabled/pressed/hover/focus states.
- [X] T005 [P] Create reusable presentation scenes `scenes/components/AppTopBar.tscn`, `scenes/components/LedPreviewFrame.tscn`, `scenes/components/SectionCard.tscn`, `scenes/components/SettingRow.tscn`, `scenes/components/SegmentedControl.tscn`, `scenes/components/ChoiceChip.tscn`, `scenes/components/SliderRow.tscn`, and `scenes/components/PrimaryActionBar.tscn`; add only their required companion scripts `scenes/components/app_top_bar.gd` and `scenes/components/led_preview_frame.gd`.
- [X] T006 [P] Evolve visual accent helpers in `scenes/components/accent_theme.gd` to style only presentation variants from existing preset accent data.
- [X] T007 Create portrait phone/tablet size-category and safe action-bar inset helpers in `scenes/components/responsive_layout.gd`; all screen migrations consume this helper instead of defining competing breakpoint logic.
- [X] T008 Preserve and verify the live-display boundary in `scenes/components/LedBoard.tscn` and `scenes/components/led_board.gd` against `specs/001-premium-ui-redesign/contracts/ui-regression-contracts.md`; do not change its public API or internal runtime paths.
- [ ] T009 Reopen and validate the new Theme and reusable components in an isolated editor scene or `scenes/components/` previews. Record factual measurements that all applicable controls meet 44 dp targets, phone-portrait component layout evidence (including clipping/overflow), and comparison with `docs/design/reference/premium-ui-reference.png` with each justified deviation. Complete the Mandatory Milestone Validation Gate before marking this task complete.

**Checkpoint**: Shared design system is ready only after T009 passes its Mandatory Milestone Validation Gate; existing runtime contracts remain intact. No new phase progression may begin from this checkpoint until it is complete.

---

## Phase 3: User Story 1 - Choose a Recognizable Mode (Priority: P1) 🎯 MVP

**Goal**: Make every existing mode and Advanced Editor understandable and selectable from a premium Home screen without altering factory routes or public ModeCard behavior.

**Independent Test**: Launch Home; identify and open a requested signal mode, thematic mode, and Advanced Editor from the redesigned cards; verify correct routes, titles, accents, and no emoji-as-primary visuals.

- [X] T010 [US1] Redesign `scenes/components/ModeCard.tscn` and `scenes/components/mode_card.gd` as an API-compatible premium card retaining `accent_color`, `set_title`, `set_icon`, and `card_pressed`.
- [X] T011 [US1] Update `scenes/components/mode_card_factory.gd` to supply card subtitles and map every existing mode to its approved original static asset in `assets/ui/mode_cards/`, while preserving current Router destinations and preset payloads.
- [X] T012 [US1] Recompose `scenes/screens/HomeScreen.tscn` for a responsive visual card collection, clear hierarchy, and persistent Advanced Editor entry.
- [X] T013 [US1] Update `scenes/screens/home_screen.gd` only as needed to populate the redesigned Home presentation without changing preset availability or route behavior.
- [X] T014 [US1] Integrate the approved original static assets in `assets/ui/mode_cards/` as the ModeCard preview layer; preserve aspect ratio, render Godot title/subtitle/borders/states separately, and reject procedural overlays, stock/unverified-rights imagery, and official emergency-service identity.
- [ ] T041 [US1] **Conditional asset correction.** T015 MUST measure and record the maximum rendered ModeCard preview width and height across supported phone/tablet layouts. T041 is required only when a source asset exceeds twice both dimensions of that measured maximum preview and downscaling does not visibly reduce approved visual quality at normal viewing distance. Correct only resolution and/or compression in the corresponding approved files under `assets/ui/mode_cards/`; preserve filenames, composition, aspect ratio, visual quality, and all existing behavior. Compression/downscaling MUST introduce no visible artifacts at normal viewing distance. Do not redraw, replace, or redesign the approved images. Re-run the affected T015 checks before T015 can pass.
- [ ] T015 [US1] Validate Home in the Godot editor and Android build using `specs/001-premium-ui-redesign/quickstart.md`: card recognition, static asset-to-mode mapping, aspect-preserving preview composition, responsive two-or-more-column layout, current asset-size suitability, route payloads, and alignment with both UI references; record each justified deviation and the measured maximum rendered ModeCard preview width and height across supported phone/tablet layouts. If a source asset exceeds twice both measured dimensions and downscaling preserves approved visual quality at normal viewing distance, T041 is required before this task can pass; otherwise T041 is not required. Complete the Mandatory Milestone Validation Gate. **Blocked:** local Godot Editor Settings has no configured Java SDK path for Android export; physical-device validation remains pending.

**Historical pre-gate implementation record**: T010–T014 were completed before T009 was reopened under Constitution v2.0.0. Their completed status preserves the historical implementation record only; it is not evidence that T009 or T015 has passed the current Mandatory Milestone Validation Gate.

**Checkpoint / explicit approval gate**: Home provides a polished, independently usable mode-selection journey only after T015 passes its Mandatory Milestone Validation Gate. T009 and T015 must now pass before any new Phase 4+ progression. Phase 4 and every later phase are locked until the user explicitly grants visual approval for this Phase 3 Home milestone; failed or deferred required validation cannot be bypassed.

---

## Phase 4: User Story 2 - Configure and Start a Mode Without Visual Friction (Priority: P1)

**Goal**: Give all signal and thematic modes a shared premium detail shell with live preview, mode identity, clear grouped controls, and persistent actions.

**Independent Test**: Open one signal and one thematic mode; configure each available option, start/stop and demo it, enter/exit fullscreen, favorite it, and confirm existing behavior remains synchronized with the live display.

- [ ] T016 [US2] Recompose the shared detail-screen presentation hierarchy in `scenes/screens/PresetDetailScreen.tscn` while retaining all controller-required unique nodes and the live `LedBoard` instance.
- [ ] T017 [P] [US2] Recompose the shared detail-screen presentation hierarchy in `scenes/screens/MessageDetailScreen.tscn` while retaining all controller-required unique nodes and the live `LedBoard` instance.
- [ ] T018 [US2] Update `scenes/screens/preset_detail_screen.gd` to bind the preserved Demo, Fullscreen, Start/Stop, tabs, sliders, favorite, color, and police radio handlers to the new persistent action-bar and grouped presentation nodes.
- [ ] T019 [US2] Update `scenes/screens/message_detail_screen.gd` to bind the preserved Demo, Fullscreen, Start/Stop, animation controls, favorite, color, and grouped presentation nodes to the same visual-shell behavior.
- [ ] T020 [US2] Apply existing signal and thematic accent sources consistently to preview frames, selected segmented controls, micro-details, and primary Start/Stop actions in `scenes/screens/preset_detail_screen.gd`, `scenes/screens/message_detail_screen.gd`, and `scenes/components/accent_theme.gd`.
- [ ] T021 [US2] Implement scroll insets, safe-area handling, and fullscreen restoration for the persistent action bar in `scenes/screens/PresetDetailScreen.tscn`, `scenes/screens/MessageDetailScreen.tscn`, `scenes/screens/preset_detail_screen.gd`, and `scenes/screens/message_detail_screen.gd`.
- [ ] T022 [US2] Validate signal and thematic detail flows on editor and Android using `specs/001-premium-ui-redesign/quickstart.md`, including conditional siren/volume/radio controls, Demo timeout, fullscreen/double-tap, history/favorites updates, and alignment with `docs/design/reference/premium-ui-reference.png`. Complete the Mandatory Milestone Validation Gate.

**Checkpoint / explicit approval gate**: Signal and thematic detail flows share a coherent presentation and preserve all current mode controls and playback results only after T022 passes its Mandatory Milestone Validation Gate and the user explicitly approves this Phase 4 milestone. Phase 5+ remain locked until then.

---

## Phase 5: User Story 3 - Edit a Custom Display With Focused Controls (Priority: P2)

**Goal**: Reduce Advanced Editor visual density through task-focused progressive disclosure while preserving every panel API and editor workflow.

**Independent Test**: Edit text/background settings, use radio, save/load/duplicate/delete a project, trigger Play/Pause/Stop, and enter/exit fullscreen with identical functional outcomes.

- [ ] T023 [US3] Recompose `scenes/screens/AdvancedEditorScreen.tscn` into a premium editor shell with top navigation, framed live preview, focused section navigation, and safe action/banner spacing.
- [ ] T024 [P] [US3] Restyle and re-present `scenes/panels/TextEditorPanel.tscn` and `scenes/panels/text_editor_panel.gd` as a focused text/animation section while retaining its signals and public methods.
- [ ] T025 [P] [US3] Restyle and re-present `scenes/panels/BackgroundPanel.tscn`, `scenes/panels/background_panel.gd`, `scenes/panels/ColorPickerPanel.tscn`, and `scenes/panels/color_picker_panel.gd` with the shared control system and preserved picker behavior.
- [ ] T026 [P] [US3] Restyle and re-present `scenes/panels/RecorderPanel.tscn`, `scenes/panels/recorder_panel.gd`, `scenes/panels/ProjectsPanel.tscn`, and `scenes/panels/projects_panel.gd` as compact focused sections while retaining manager bindings and confirmations.
- [ ] T027 [US3] Update `scenes/screens/advanced_editor_screen.gd` only as needed to coordinate progressive disclosure and new presentation nodes while preserving panel assignments, autosave watchers, banner behavior, and fullscreen behavior.
- [ ] T028 [US3] Validate Advanced Editor flows on editor and Android using `specs/001-premium-ui-redesign/quickstart.md`, including recording permission/state, project lifecycle, autosave restoration, fullscreen/banner restoration, and alignment with `docs/design/reference/premium-ui-reference.png`. Complete the Mandatory Milestone Validation Gate.

**Checkpoint / explicit approval gate**: Advanced Editor is compact and task-focused without a functional rewrite only after T028 passes its Mandatory Milestone Validation Gate and the user explicitly approves this Phase 5 milestone. Phase 6+ remain locked until then.

---

## Phase 6: User Story 4 - Navigate and Manage Preferences Consistently (Priority: P2)

**Goal**: Complete the consistent premium navigation and secondary-screen experience across Favorites, History, and Settings.

**Independent Test**: Switch every bottom tab, use Back from a detail screen, toggle every existing setting, and verify Favorites/History compact rows retain correct contents, dates, and routes.

- [ ] T029 [US4] Redesign `scenes/components/BottomTabBar.tscn` and `scenes/components/bottom_tab_bar.gd` with icon-led active/inactive states while retaining four indices, `tab_selected`, and `set_active`.
- [ ] T030 [US4] Update `scenes/AppShell.tscn` and `scenes/app_shell.gd` only as required to integrate the redesigned navigation safely with Router stack visibility behavior.
- [ ] T031 [US4] Create an API-compatible compact mode-row component and factory support in `scenes/components/` and `scenes/components/mode_card_factory.gd` for Favorites/History mode accent, mini-preview/icon, and optional timestamp.
- [ ] T032 [P] [US4] Recompose `scenes/screens/FavoritesScreen.tscn` and `scenes/screens/favorites_screen.gd` to use compact rows and preserve empty-state refresh behavior.
- [ ] T033 [P] [US4] Recompose `scenes/screens/HistoryScreen.tscn` and `scenes/screens/history_screen.gd` to use compact rows, readable timestamps, and current history routing.
- [ ] T034 [US4] Recompose and restyle `scenes/screens/SettingsScreen.tscn` and `scenes/screens/settings_screen.gd` with shared setting rows, switches, segmented choices, and unchanged preference effects.
- [ ] T035 [US4] Validate root navigation, compact lists, settings persistence, Back behavior, portrait phone/tablet layouts, and alignment with `docs/design/reference/premium-ui-reference.png` using `specs/001-premium-ui-redesign/quickstart.md`. Complete the Mandatory Milestone Validation Gate.

**Checkpoint / explicit approval gate**: Every root destination shares the same navigation and control language, with existing state and routes preserved only after T035 passes its Mandatory Milestone Validation Gate and the user explicitly approves this Phase 6 milestone. Phase 7 remains locked until then.

---

## Phase 7: Polish & Cross-Cutting Validation

**Purpose**: Resolve system-wide visual, responsive, performance, and regression concerns after all user-story increments are complete.

- [ ] T036 [P] Audit all modified scenes under `scenes/` against `specs/001-premium-ui-redesign/contracts/ui-regression-contracts.md` and fix any broken unique-node, signal, public API, or resource-binding contract.
- [ ] T037 [P] Audit `theme/app_theme.tres` and all modified `scenes/**/*.tscn` against `docs/design/reference/premium-ui-reference.png` for default-control leakage, composition, contrast-safe accents, restrained borders/glow, consistent typography/spacing/radii/elevation, and 44 dp touch targets; document any justified deviation.
- [ ] T038 Perform final/global optimization of static Home ModeCard assets under `assets/ui/mode_cards/` for mobile delivery after all UI phases: remove remaining unnecessary source resolution and avoid excessive texture-memory/overdraw cost while preserving approved composition, quality at the actual rendered card size, filenames, and unchanged `LedBoard` runtime behavior. This does not replace the conditional Phase 3 correction in T041 when T015 finds a blocking asset issue.
- [ ] T039 Validate scene loading and run the full phone/tablet Android smoke suite in `specs/001-premium-ui-redesign/quickstart.md`; record any device-specific findings in `specs/001-premium-ui-redesign/quickstart.md`. Complete the Mandatory Milestone Validation Gate, including the cross-phase visual-reference and 44 dp evidence.
- [ ] T040 Run `git diff --check` and update `specs/001-premium-ui-redesign/checklists/requirements.md` with final acceptance evidence.

**Checkpoint / explicit approval gate**: Phase 7 acceptance requires T039 to pass its Mandatory Milestone Validation Gate and explicit user approval. No further implementation or release acceptance may proceed while a required check is failed or deferred.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Starts immediately.
- **Phase 2 (Foundational)**: Depends on T001 and T003 and blocks all screen migration.
- **Phase 3 (US1)**: Depends on T004–T009, including a passed T009 validation gate; delivers the mode-discovery MVP.
- **Phase 4 (US2)**: Depends on completed Phase 3 work (T010–T015 and conditional T041 when triggered), a passed T015 validation gate, and explicit user visual approval for Phase 3. It MUST NOT start while any Phase 3 check is failed, blocked, or deferred.
- **Phase 5 (US3)**: Depends on completed Phase 4 work (T016–T022), a passed T022 validation gate, and explicit user visual approval for Phase 4. It MUST NOT start while any Phase 4 check is failed, blocked, or deferred.
- **Phase 6 (US4)**: Depends on completed Phase 5 work (T023–T028), a passed T028 validation gate, and explicit user visual approval for Phase 5. It MUST NOT start while any Phase 5 check is failed, blocked, or deferred.
- **Phase 7 (Polish)**: Depends on completed Phase 6 work (T029–T035), a passed T035 validation gate, and explicit user visual approval for Phase 6. It MUST NOT start while any Phase 6 check is failed, blocked, or deferred.

### User Story Dependencies

- **US1 — Mode discovery**: May start after the shared presentation-components validation gate passes.
- **US2 — Mode detail**: Must wait for Phase 3 validation and explicit visual approval; uses existing mode cards only for entry.
- **US3 — Advanced Editor**: Must wait for Phase 4 validation and explicit visual approval.
- **US4 — Navigation and preferences**: Must wait for Phase 5 validation and explicit visual approval.

### Parallel Opportunities

- Parallel work is allowed only within the active phase after all prior phase validation and explicit-approval gates have passed. It must never bypass Constitution IX.
- T005, T006, and T007 can proceed in parallel after the Theme token foundation direction is agreed.
- T016 and T017 can proceed in parallel only after Phase 4 is unlocked; their controller rewiring T018–T021 must follow their respective scene work.
- T024, T025, and T026 modify independent editor panel groups and can proceed in parallel only after Phase 5 is unlocked.
- T032 and T033 can proceed in parallel after T031 and only after Phase 6 is unlocked.
- T036 and T037 can run in parallel only after Phase 7 is unlocked.

## Parallel Example: Detail Screens

```text
Task: "Recompose scenes/screens/PresetDetailScreen.tscn while preserving controller-required nodes."
Task: "Recompose scenes/screens/MessageDetailScreen.tscn while preserving controller-required nodes."
```

## Parallel Example: Advanced Editor Panels

```text
Task: "Restyle scenes/panels/TextEditorPanel.tscn and text_editor_panel.gd."
Task: "Restyle scenes/panels/BackgroundPanel.tscn, background_panel.gd, ColorPickerPanel.tscn, and color_picker_panel.gd."
Task: "Restyle scenes/panels/RecorderPanel.tscn, recorder_panel.gd, ProjectsPanel.tscn, and projects_panel.gd."
```

## Implementation Strategy

### MVP First

1. Complete the shared design system and compatibility checkpoint (Phase 2).
2. Complete US1 Home mode discovery (Phase 3).
3. Pass T015, resolve every required validation check, and obtain explicit Home visual approval before migrating any additional screen.

### Incremental Delivery

1. Shared components and tokens establish a stable visual foundation.
2. Home delivers immediate discoverability value, then stops for validation and visual approval.
3. Each later visually significant phase starts only after the prior phase’s validation-and-approval gate, while preserving playback.
4. Advanced Editor and root navigation follow the same gated sequence.
5. Cross-cutting device validation closes the release gate without bypassing unresolved checks.

## Notes

- Every implementation task must preserve the UI regression contracts; moving a scene node without updating its controller in the same task is unsafe.
- Do not create tasks for new modes, export, monetization, or behavior changes: they are outside the approved specification.
- Commit after a completed logical UI increment and validate on Android before declaring an increment done.
