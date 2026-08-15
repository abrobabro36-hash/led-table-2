# Research: Premium UI Redesign

## Visual reference constraints

**Decision**: Treat [premium-ui-reference.png](../../docs/design/reference/premium-ui-reference.png) as the mandatory primary visual-direction asset for all current and future UI work in this feature. Treat [mode-cards-style-reference.png](../../docs/design/reference/mode-cards-style-reference.png) as the mandatory companion reference for Home ModeCard imagery and composition.

**Rationale**: Stable in-repository references prevent drift between the approved interface target, Home-card visual direction, implementation decisions, and review.

**Adaptation rule**: Preserve existing functionality and public contracts first, follow the reference closely second, and document any deviation with a concrete UX or technical reason. The reference is not a pixel-perfect copy target and does not authorize use of its branding or assets.

## Decision 1: Use a tokenized semantic dark Theme with component variants

**Decision**: Centralize background, surface, border, text hierarchy, spacing, radii, elevation, control height, and interaction-state styling in the Theme and reusable presentation components. Apply per-mode accents at runtime only to accent-capable component variants.

**Rationale**: The current Theme styles only generic panels and buttons, while scenes add one-off overrides. A semantic system prevents drift and allows the visual language to cover buttons, inputs, switches, sliders, segmented controls, chips, rows, cards, dialogs, and navigation consistently.

**Alternatives considered**:

- Add `StyleBoxFlat` definitions independently in every scene — rejected because visual states will drift and review cost rises quickly.
- Replace native controls with custom-drawn interaction logic — rejected because it risks changing established behavior and input handling.

## Decision 2: Keep the live display unchanged and compose it in a presentation frame

**Decision**: Treat `LedBoard` as an immutable functional boundary. Put visual chrome such as aspect, clipping, surface, border, accent glow, and fullscreen affordance in a presentation wrapper around an existing `LedBoard` instance.

**Rationale**: `LedBoard` owns the rendering pipeline and all playback components. Composition retains the single source of truth demanded by the specification and avoids duplicate previews.

**Alternatives considered**:

- Render static/mock screenshots — rejected because the preview would no longer be live.
- Duplicate the LED renderer for cards or fullscreen — rejected because state and behavior could diverge.

## Decision 3: Use a stable detail-shell hierarchy

**Decision**: Each signal and thematic detail screen uses a fixed top app bar, prominent live preview, scrollable configuration content, and a persistent bottom action bar containing Demo, Fullscreen, and Start/Stop. Start/Stop is the primary visual action. Scrollable content reserves a bottom inset equal to the action bar plus safe spacing.

**Rationale**: This implements the accepted UX decision and keeps primary actions reachable from all scroll positions while providing a unified template for both mode categories.

**Alternatives considered**:

- Place all actions in scroll content — rejected because key actions disappear on long screens.
- Pin only Start/Stop — rejected because the accepted requirement includes Demo and Fullscreen in the persistent bar.

## Decision 4: Derive mode accents from existing preset data

**Decision**: Continue using the signal preset primary color, thematic preset palette primary color, and current Advanced Editor blue as presentation accents. Restrict accent use to preview framing, selected segments, primary actions, and small indicators.

**Rationale**: Existing resources already define the intended color identity. Limiting accent coverage preserves hierarchy and does not alter LED playback output.

**Alternatives considered**:

- Use a universal app accent — rejected because it erases mode recognition.
- Recolor display output from UI styling — rejected because it changes behavior and resource-driven settings.

## Decision 5: Use approved original static assets for Home ModeCards

**Decision**: Keep `ModeCard` and its public API, but render the corresponding approved original static PNG or WebP from `assets/ui/mode_cards/` as each card's dominant preview. Use a `TextureRect` that preserves aspect ratio and only crops safe edges where necessary. Godot Control/Theme separately renders title, subtitle, accent border, interaction state, and navigation. The asset is presentation-only and never changes `LedBoard`, playback, autoloads, routing, or preset data.

**Rationale**: This supersedes the earlier hybrid/procedural decision with the user-approved direction, gives modes a consistent premium recognition cue, and avoids the battery and thermal cost of multiple live card previews.

**Alternatives considered**:

- Emoji-only cards — rejected because they do not meet the premium visual requirement.
- Original abstract procedural artwork — rejected because the approved static asset direction supersedes it.
- Full live animated previews on every card — rejected because the shader, glow, and animation can compound mobile rendering work.
- Stock, unverified-rights, or official-service imagery — rejected because it introduces licensing, affiliation, and brand risk. Emergency visuals remain generic and fictional: no logos, crests, department names, service numbers, vehicle liveries, or official identity.

## Decision 11: Optimize static production assets for ModeCard display size

**Decision**: Keep only the asset resolution needed to render sharply at the actual largest production ModeCard preview on supported phone/tablet layouts. Validate composition and readability after downscaling/recompression; do not modify the approved creative content or substitute a new visual.

**Rationale**: The approved files are static presentation assets. Unneeded source pixels increase Android package size, texture memory, upload cost, and rendering pressure without improving the card at its rendered size.

**Alternatives considered**:

- Keep maximum source resolution in the production package by default — rejected because it wastes package and texture memory when no visible benefit exists.
- Generate new lower-resolution artwork — rejected because the approved original asset content must remain unchanged.

## Decision 6: Use compact reusable list rows for Favorites and History

**Decision**: Present Favorites and History using compact mode rows with a mode accent, mini-preview or icon, title, and date where applicable, while retaining existing route payloads and history data.

**Rationale**: The accepted list pattern supports fast scanning of dates and long names better than reusing large Home cards.

**Alternatives considered**:

- Reuse the Home card grid — rejected because it wastes vertical space and weakens history scanning.
- Create a separate data store for list presentation — rejected because existing preset and history data already provide the necessary information.

## Decision 7: Preserve native control semantics and restyle them

**Decision**: Keep existing Button toggle groups, CheckButton booleans, HSlider ranges, OptionButton choices, and signals. Present them through semantic variants such as segmented control, choice chip, switch, and slider row.

**Rationale**: The existing controller code remains compatible, while the result removes default Godot appearances from the user experience.

**Alternatives considered**:

- Introduce new custom input APIs — rejected because that changes public contracts and increases regression risk.

## Decision 8: Use container-first responsive layouts

**Decision**: Keep portrait-first Container and anchor layouts. On narrow phones use one-column detail content and two-column Home cards; on wider portrait/tablet widths constrain readable content and increase card columns or split dense groups only after layout validation. Use size categories rather than device-model-specific scenes.

**Rationale**: This follows the current stretch mode and avoids divergent phone/tablet screen implementations.

**Alternatives considered**:

- Fixed-coordinate layouts — rejected because they clip and fail on tablets.
- Separate phone and tablet scene trees — rejected because behavior and styling would drift.

## Decision 9: Apply progressive disclosure to existing Advanced Editor panels

**Decision**: Preserve Text Editor, Background, Recorder, and Projects panels and their APIs, while wrapping or presenting them as compact, context-based sections that expose focused controls on demand.

**Rationale**: This reduces the dense continuous form without moving business logic into a new editor model.

**Alternatives considered**:

- Merge panel controllers into a new editor controller — rejected because it is a functional rewrite outside scope.

## Decision 10: Validate with manual Android regression and visual quality gates

**Decision**: Use scene-load checks plus the documented phone/tablet Android smoke flows for every migration stage. Check visual consistency, touch targets, contrast, content overflow, persistent actions, preview synchronization, and battery-sensitive preview behavior.

**Rationale**: No automated test suite exists, while the product is explicitly verified on real Android hardware.

**Alternatives considered**:

- Restrict validation to editor screenshots — rejected because it cannot prove audio, fullscreen, persistence, or device behavior.
