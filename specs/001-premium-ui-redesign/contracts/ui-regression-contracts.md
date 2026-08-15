# UI Regression Contracts

## 0. Visual-reference contract

- All UI presentation work for this feature MUST be reviewed against [premium-ui-reference.png](../../../docs/design/reference/premium-ui-reference.png).
- Home ModeCard work MUST additionally be reviewed against [mode-cards-style-reference.png](../../../docs/design/reference/mode-cards-style-reference.png).
- The references govern visual direction, not a pixel-perfect replica or third-party branding source.
- Existing functional behavior and the contracts below take precedence. Any intentional visual deviation requires a concrete UX or technical reason in validation evidence.

## 1. Live display boundary

- `LedBoard` remains the only source for embedded live-preview and fullscreen display rendering in mode-detail and Advanced Editor experiences. Home ModeCards are the approved static-asset presentation exception and do not instance, require, or simulate `LedBoard`.
- Preserve its exported settings/text properties, preset lifecycle signals, and current playback/preset methods.
- Preserve the internal child paths used by its script; presentation frames wrap the board rather than reparenting or duplicating its runtime internals.

## 2. Playback and audio boundary

- Preserve the setup, activation/deactivation, and lifecycle signals of SignalPlayer, ThematicPlayer, TextAnimator, SirenPlayer, and AudioReactor.
- Presentation controls call existing handlers; UI styling must not alter blink, thematic, text-animation, siren, or audio-reactor behavior.
- Preserve AudioManager recording/playback/repeat/volume actions and state signals.

## 3. Navigation contract

- Preserve Router registration, push, pop, tab switch, stack depth, and stack-changed behavior.
- Preset detail and message detail scenes retain `setup(data)` and accept the existing preset payload.
- Bottom navigation retains indices: Home 0, Favorites 1, History 2, Settings 3; it continues to expose `tab_selected(index)` and `set_active(index)`.
- `AppShell` retains the ScreenHost and bottom-tab integration contract.

## 4. Mode card, static-asset, and compact-row contract

- `ModeCard` retains class identity, `accent_color`, `set_title`, `set_icon`, and `card_pressed`.
- Existing factories retain signal-to-detail and thematic-to-message routing with the current preset payload.
- Home ModeCards use only the corresponding approved original static PNG/WebP asset from `assets/ui/mode_cards/` as their dominant preview. The asset is presentation-only: Godot Control/Theme renders title, subtitle, border, accent, interaction state, and navigation separately.
- This static Home preview is the explicit exception to the live-display boundary: it is not a `LedBoard` preview and does not alter mode-detail, Advanced Editor, or fullscreen live rendering.
- Preserve the approved mapping in [plan.md](../plan.md#approved-home-modecard-asset-manifest), including Fire → `fire.png` and Advanced Editor → `advanced_editor.png`; it is a presentation mapping, not a new data model.
- No static asset may affect `LedBoard`, playback, Router, autoloads, preset data, or mode behavior. Do not render procedural artwork or a live preview over the approved asset unless this specification is explicitly revised.
- Do not introduce stock or unverified-rights images. Emergency visuals remain generic and fictional: official logos, crests, department names, service numbers, vehicle liveries, and other official identity are prohibited.
- Production asset resolution must be no greater than necessary for the largest rendered ModeCard preview on supported devices, subject to preserving the approved composition and perceptible quality.
- Compact Favorites/History rows use the same factory routing and existing history timestamp data; no new presentation data store is introduced.

## 5. Detail-screen action contract

- Preserve the detail controllers' required unique nodes or update their references atomically in the same change.
- Preserve favorite, text/font/color, show-text, pattern/animation, sliders, siren, radio, Demo, Start/Stop, fullscreen, double-tap, and color-picker behavior.
- The visual shell may move controls, but persistent action-bar buttons continue to invoke the existing Demo, fullscreen, and Start/Stop flows.
- Conditional controls remain conditional: siren/volume/police radio/pattern options appear only for currently supported modes.

## 6. Advanced Editor contract

- Preserve the board and panels currently wired by AdvancedEditorScreen, including panel exports, signals, `sync_ui`, and `set_text`.
- Preserve autosave subscriptions and restore behavior.
- Preserve existing text, background, color, recorder, project, play/pause/stop, banner, and fullscreen flows.

## 7. Persistence and refresh contract

- Preserve AppSettings favorite/history/settings signals and current setters.
- Preserve ProjectManager CRUD/autosave signals and current project data.
- Presentation refreshes in response to existing signals; it must not bypass or duplicate persisted state.
