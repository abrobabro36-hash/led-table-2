# Presentation Data Model

This redesign introduces no persisted domain entities, migrations, or changes to resource schemas. It consumes the following existing data as presentation inputs.

## Existing presentation inputs

### Mode

| Field | Source | Presentation use | Validation rule |
|---|---|---|---|
| Identifier | Existing signal/thematic preset | Stable routing and list identity | Preserve unchanged. |
| Display name | Existing preset | Card, title, and list label | Long names must not overlap controls. |
| Mode category | Existing preset type | Available control groups and route | Signal and thematic retain their current routes and behavior. |
| Accent color | Signal primary color or thematic primary palette color | Preview frame, selected controls, primary action, indicators | Must retain legible text/contrast on dark surfaces. |
| Existing visual behavior | Current live display/playback state | Optional live preview only | Must not be copied into a separate renderer. |

### Live display state

| Field | Source | Presentation use | Validation rule |
|---|---|---|---|
| Text | Existing live display | Embedded and fullscreen display | Remains a single source of truth. |
| LED settings | Existing settings resource | Live preview | No redesign-owned copy. |
| Text style and animation | Existing resources | Live preview and editor control state | Existing resource bindings remain intact. |
| Background | Existing background resource | Live preview and editor control state | Existing image/color/gradient behavior remains intact. |
| Playback state | Existing players | Start/Stop, Demo, and related state labels | UI reflects existing state transitions only. |

### Compact mode row

| Field | Source | Presentation use | Validation rule |
|---|---|---|---|
| Mode | Existing preset registry lookup | Accent, name, mini-preview/icon, route | No duplicated mode metadata. |
| Timestamp | Existing history entry; absent for Favorites | Secondary metadata | Visible only where available. |
| Favorite/history state | Existing app settings | List contents and empty states | Updates through existing signals. |

### Existing project and preference state

Projects, favorites, history, application settings, and radio state remain their current entities. The UI continues to read and invoke their existing manager interfaces; it does not store presentation-specific duplicates.

## State transitions relevant to presentation

```text
Inactive mode --Start/Demo--> Active mode --Stop/demo timeout--> Inactive mode
Embedded live display --Fullscreen--> Fullscreen live display --Exit--> Embedded live display
Root destination --Mode card/row--> Detail screen --Back--> Prior root destination
Collapsed editor section --Select--> Focused visible section --Select another--> Previous section hidden
```

All transitions keep their existing behavioral owner. The redesign changes only their visual entry points and presentation state.
