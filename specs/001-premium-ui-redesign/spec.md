# Feature Specification: Premium UI Redesign

**Feature Branch**: `001-premium-ui-redesign`  
**Created**: 2026-08-13  
**Status**: Draft  
**Input**: Redesign the completed LED Display application's visual layer into a premium dark mobile experience, using the supplied visual reference as design direction while preserving all existing behavior.

## Primary Visual Reference

The feature's authoritative visual-direction asset is [premium-ui-reference.png](../../docs/design/reference/premium-ui-reference.png). All current and future UI implementation work for `001-premium-ui-redesign` MUST review this asset before changing UI presentation.

The reference defines the intended visual language: screen composition, hierarchy, proportions, spacing rhythm, card composition, preview prominence, control density, compact navigation, dark surface layering, restrained borders/glow, mode-accent application, typography hierarchy, buttons, segmented controls, sliders, and switches.

It is a design direction, not a pixel-perfect source. The implementation MUST adapt it to the current functional behavior and to Godot's Control/Theme system. When a result intentionally differs from the reference, the implementation notes and validation evidence MUST name a concrete UX or technical reason.

Conflict order:

1. Preserve completed functionality, persisted behavior, and public contracts.
2. Follow the visual reference as closely as those constraints allow.
3. Document any necessary visual deviation with its concrete UX or technical reason.

## Mode Card Style Reference

[mode-cards-style-reference.png](../../docs/design/reference/mode-cards-style-reference.png) is the mandatory companion reference for Home ModeCards. It defines the approved static visual direction for generic, fictional mode imagery. It guides the preview composition only; [premium-ui-reference.png](../../docs/design/reference/premium-ui-reference.png) remains the primary reference for the whole interface.

## Clarifications

### Session 2026-08-13

- Q: How should Demo, Fullscreen, and Start/Stop be available on a mode detail screen? → A: A persistent bottom action bar with Demo, Fullscreen, and Start/Stop, with Start/Stop as the primary action.
- Q: What should be the primary visual strategy for mode cards on Home? → A: The approved original static assets in `assets/ui/mode_cards/`, rendered as the dominant ModeCard preview. This supersedes the earlier hybrid/procedural-artwork decision.
- Q: How should Favorites and History be organized after the redesign? → A: A compact list with a mode accent and mini-preview or icon.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choose a recognizable mode (Priority: P1)

As a user opening the application, I can understand what each available mode does from the home screen before I open it, and can select the desired signal, thematic mode, or advanced editor confidently.

**Why this priority**: Mode discovery is the entry point to every existing user journey. It must communicate the product's capabilities without relying on emoji or technical labels alone.

**Independent Test**: Open the home screen with all current modes present and ask a test participant to identify and open a requested mode using only the visible card content.

**Acceptance Scenarios**:

1. **Given** the user opens Home, **When** they view the mode collection, **Then** every existing mode is presented as a visually distinct, tappable card with a clear name and purpose.
2. **Given** two modes serve different purposes, **When** the user compares their cards, **Then** the cards have distinguishable visual identities while retaining a shared design system, using their corresponding approved original static asset as the dominant preview.
3. **Given** the user wants advanced customization, **When** they view Home, **Then** Advanced Editor remains visible and reachable alongside the existing modes.

---

### User Story 2 - Configure and start a mode without visual friction (Priority: P1)

As a user configuring a signal or thematic mode, I can see the mode identity and large live preview, adjust the controls available for that mode, and reach the main action without navigating a long, visually unstructured form.

**Why this priority**: The mode detail screen is the application's primary working surface. It must improve clarity without changing a mode's behavior.

**Independent Test**: Open each category of existing mode, adjust a setting, start and stop it, use Demo and Fullscreen, and verify that the same outcomes remain available through the redesigned interface.

**Acceptance Scenarios**:

1. **Given** the user opens an existing mode, **When** the screen loads, **Then** it presents a top navigation area, a prominent live preview, the mode identity, relevant grouped controls, and clear primary actions.
2. **Given** a mode has multiple control groups, **When** the user switches between them, **Then** the selected group is clearly indicated and unavailable groups are not shown as usable.
3. **Given** the user is at any scroll position in a mode, **When** they want to start, stop, demo, or enter fullscreen, **Then** they can use the persistent bottom action bar without scrolling through configuration content.
4. **Given** a user changes a control, **When** the change is applied, **Then** the live preview and mode behavior remain synchronized as before.

---

### User Story 3 - Edit a custom display with focused controls (Priority: P2)

As a user of Advanced Editor, I can reach text, background, radio, and project controls in a compact, understandable sequence that exposes only the detail needed for the current task.

**Why this priority**: Advanced Editor contains the highest density of controls; reducing visual noise improves usability while retaining its existing scope.

**Independent Test**: Perform a complete current editor workflow—edit text, adjust visual settings, manage a project, and use radio playback—without losing access to any existing action.

**Acceptance Scenarios**:

1. **Given** the user opens Advanced Editor, **When** they select a configuration area, **Then** its controls are grouped and labelled according to the task they support.
2. **Given** the user needs a less frequently used configuration area, **When** they reveal it, **Then** it is available without adding a new feature or obscuring the primary editing flow.
3. **Given** the user saves, loads, duplicates, or deletes a project, **When** the redesigned presentation is used, **Then** the existing outcome and confirmation behavior are preserved.

---

### User Story 4 - Navigate and manage preferences consistently (Priority: P2)

As a user, I can move among Home, Favorites, History, and Settings using clear, consistent navigation and understand selected, inactive, and disabled interface states.

**Why this priority**: Consistent navigation and preferences make the product feel cohesive across the entire application rather than polished only on the primary screens.

**Independent Test**: Navigate through all existing root destinations and return from every detail screen; toggle each existing setting and verify its current effect remains unchanged.

**Acceptance Scenarios**:

1. **Given** the user is on a root destination, **When** they use bottom navigation, **Then** the active destination is visually unmistakable and all current destinations remain reachable.
2. **Given** the user enters a detail screen or fullscreen display, **When** they go back or exit fullscreen, **Then** navigation returns to the same functional context as before.
3. **Given** the user opens Settings, **When** they interact with a preference, **Then** the control type and selected state clearly communicate the setting without changing the existing setting outcome.
4. **Given** the user opens Favorites or History, **When** they scan saved or recently used modes, **Then** each destination uses a compact list with the mode accent and a mini-preview or icon, including readable dates and long names.

### Edge Cases

- A mode with no siren, radio controls, optional text, or multiple patterns shows only the controls that currently apply, without empty cards or misleading selectable states.
- Long localized labels, a long project name, or a maximum-length user message remain readable, clipped, wrapped, or scrollable without overlapping controls.
- A mode accent with low contrast remains legible against the dark interface and does not make critical text or controls inaccessible.
- On a narrow phone, a large phone, and a tablet in portrait orientation, cards, controls, actions, and navigation remain fully usable without horizontal clipping.
- Fullscreen entry and exit preserve the current preview state and do not leave persistent navigation, action bars, or panels visible over the display.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The redesigned interface MUST retain every currently available mode, root destination, and Advanced Editor entry point.
- **FR-002**: The home screen MUST present each mode as a clear visual card with a mode name, purpose cue, and distinct visual identity; emoji MUST NOT be the primary visual asset. Each Home ModeCard MUST use its corresponding approved original static PNG or WebP asset from `assets/ui/mode_cards/` as the dominant preview.
- **FR-003**: The interface MUST use [premium-ui-reference.png](../../docs/design/reference/premium-ui-reference.png) as its primary visual direction and [mode-cards-style-reference.png](../../docs/design/reference/mode-cards-style-reference.png) as the Home ModeCard companion direction: deep dark surfaces, strong hierarchy, generous but efficient spacing, prominent previews, clear typography, compact navigation, restrained borders/glow, and commercial-grade visual cohesion. Neither reference authorizes copying protected branding, logos, or service identity.
- **FR-004**: Each mode MUST retain its existing accent color and apply that accent consistently to presentation details such as preview framing, selected controls, and relevant actions, without changing its behavior.
- **FR-005**: Signal and thematic modes MUST use one coherent detail-screen visual template, with their differences expressed through the controls that are currently available to each mode.
- **FR-006**: Each mode detail screen MUST show, in order of visual importance, navigation, a large live preview, mode identity, relevant controls, and primary actions.
- **FR-007**: Every mode detail screen MUST provide a persistent bottom action bar containing Demo, Fullscreen, and Start/Stop; Start/Stop MUST be the visually primary action and all three actions MUST remain usable while configuration content scrolls.
- **FR-008**: The interface MUST provide one consistent visual language for primary and secondary buttons, segmented selections, choice chips, switches, sliders, setting rows, section cards, dialogs, top navigation, bottom navigation, preview frames, and disabled states.
- **FR-009**: All interactive controls MUST provide a touch target of at least 44 dp in both dimensions where platform layout allows.
- **FR-010**: The Advanced Editor MUST preserve access to text editing, background settings, radio controls, and project management while presenting them with progressive disclosure and task-focused grouping.
- **FR-011**: The interface MUST preserve existing user-visible outcomes for Start, Pause, Stop, Demo, Fullscreen, Favorites, History, Radio, Projects, and Settings.
- **FR-012**: `LedBoard` MUST remain the sole source of truth for embedded live preview and fullscreen presentation in mode-detail, Advanced Editor, and fullscreen experiences; the redesign MUST NOT create a separate simulated live preview for those experiences. Home ModeCards are the explicit approved exception: they use their corresponding static PNG/WebP presentation asset from `assets/ui/mode_cards/` and do not require or simulate a live `LedBoard` preview.
- **FR-013**: The redesign MUST preserve the existing functional contracts, signals, configuration bindings, and persisted user data used by the completed application.
- **FR-014**: The interface MUST remain portrait-first and usable on both phones and tablets through responsive reflow rather than a separate tablet-only experience.
- **FR-015**: Home ModeCard visuals MUST be original static PNG or WebP production assets with confirmed rights for this product. Stock imagery or any image with unconfirmed rights MUST NOT be used. Official logos, crests, department names, emergency-service numbers, vehicle liveries, or other official identity MUST NOT appear.
- **FR-016**: The redesign MUST NOT introduce new modes, export options, monetization behavior, data-model changes, or new functional capabilities solely for visual effect.
- **FR-017**: Favorites and History MUST use compact mode lists with a mode accent and a mini-preview or icon; current favorite, history, date, and launch behavior MUST remain unchanged.
- **FR-018**: Emergency-themed Home visuals MUST remain generic and fictional; they MUST communicate a mode purpose without implying an official provider, unit, or affiliation.
- **FR-019**: Static ModeCard assets MUST be a presentation layer only. Godot Control/Theme components remain responsible for title, subtitle, borders, interaction states, accents, and navigation; assets MUST NOT alter `LedBoard`, playback, autoload, Router, or preset behavior.
- **FR-020**: Production ModeCard assets MUST be optimized for the actual rendered ModeCard size and target devices. Do not retain excessive source resolution in the production package when it provides no visible benefit; preserve the approved composition and adequate display quality when downscaling or recompressing.

### Key Entities

- **Mode**: An existing signal or thematic experience with a name, purpose, available controls, and visual accent identity.
- **Live display**: The existing rendered display state that is shown in both embedded preview and fullscreen contexts.
- **Control group**: A user-facing collection of controls that applies to a specific task or mode capability.
- **Project**: A saved collection of existing user display settings and content, with its current save, load, duplicate, and delete lifecycle.
- **User preference**: An existing application-level choice surfaced in Settings, Favorites, or History.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In a usability check with 5 representative users, at least 4 can identify and open a requested existing mode from Home within 10 seconds without assistance.
- **SC-002**: In a usability check, at least 4 of 5 users can start an opened mode and enter fullscreen within 15 seconds without being asked to scroll for the primary action.
- **SC-003**: All current signal modes, thematic modes, Advanced Editor workflows, root navigation destinations, and settings actions pass their existing Android smoke checks with no functional regression.
- **SC-004**: On a representative portrait phone and tablet, 100% of visible interactive controls meet the minimum 44 dp touch-target requirement or are placed in an equivalent row-level target with the same accessible action.
- **SC-005**: A visual consistency review finds no unstyled default control appearances and no screen whose navigation, controls, or accent treatment conflicts with the shared design system.
- **SC-006**: In review of all mode detail screens, each screen presents the live preview and a usable primary action before the user needs to scroll through non-essential configuration content.

## Assumptions

- The functional Android MVP and its current smoke-test expectations are the regression baseline for this work.
- The supplied image is a primary source of visual direction, not a source of assets, branding, text, or a required pixel-perfect layout.
- The in-repository reference file is the stable source for all UI review during this feature; any justified deviation is documented with the relevant validation evidence.
- Existing mode data supplies the current mode names, behavior, and accent colors; no new mode content is required.
- Home cards use the approved original static assets in `assets/ui/mode_cards/`; the preview image is separate from the existing live display and has no effect on playback or preset data.
- The product remains portrait-first; landscape-specific redesign is outside this feature.
- Accessibility is addressed through legible hierarchy, contrast-safe accent use, and touch-target sizing within the current product scope.

## Out of Scope

- New modes or new user-facing features.
- GIF, video, image, or other display export.
- Monetization changes.
- Changes to display behavior, audio behavior, animation behavior, data structure, persistence format, or application-wide functional contracts.
- Creating fake screenshots in place of working interface elements.
