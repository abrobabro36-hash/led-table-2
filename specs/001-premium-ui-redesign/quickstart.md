# Validation Quickstart: Premium UI Redesign

## Prerequisites

- Godot installed with the project importable from repository root.
- A representative Android phone and a portrait-oriented tablet available for final smoke testing.
- A device state that can grant microphone permission for the existing Police radio and Party audio behavior.
- Review [premium-ui-reference.png](../../docs/design/reference/premium-ui-reference.png) before every visual validation pass. For Home ModeCards also review [mode-cards-style-reference.png](../../docs/design/reference/mode-cards-style-reference.png).

## Run the application

1. Open the project in Godot from the repository root.
2. Run the main scene in the editor to check scene loading and layout behavior.
3. Export/install the existing Android build configuration on each test device.
4. Run the following smoke scenarios; see [UI regression contracts](./contracts/ui-regression-contracts.md) and [presentation data](./data-model.md) for preserved boundaries.

## Phase 1–3 validation record

- Pre-redesign baseline: the completed MVP had no automated suite; its existing editor/device flows in this guide are the regression baseline.
- Completed in the development environment: headless scene/class scan and headless project startup with isolated temporary Godot user directories.
- Android export was attempted with isolated temporary Godot, Java SDK, and Gradle settings. It reached the Android export pipeline but no APK was produced in this environment; the Gradle wrapper dependency requires an externally available build cache/network. Physical-device checks remain deferred: touch-target measurement, visual review, device performance, and real mode-card recognition. These are not simulated by a fake screenshot.
- Reopened evidence gaps: this artifact has no factual pre-redesign record for `git diff --check`, a complete Godot parse/import pass, phone-portrait layout review, or the full regression smoke suite. These checks remain unverified/deferred for T001 and MUST NOT be represented as passed without recorded evidence.

## Phase 3 validation record — 2026-08-14

- `git diff --check` completed without reported whitespace errors.
- Godot 4.7 headless import completed, and isolated headless project startup exited successfully. These checks did not report project parse/startup errors.
- Android debug export was attempted for the `Android` preset and failed: Godot reports that a valid Java SDK path is required in Editor Settings. No current APK was produced.
- A USB-debuggable device was detected by ADB as `R3CT7065M1R` with status `device`, but no APK was installed and no device smoke/UI review was performed because the required current debug export failed. Do not substitute an existing APK as validation evidence for the current workspace.
- T009 and T015 remain open and blocked. No phone/tablet visual-reference, touch-target, asset-size, or device-layout claim is accepted from this incomplete validation pass.

## Phase 3 device validation record — 2026-08-14

- ADB detected `R3CT7065M1R` (`SM_S908B`) with status `device`. A new debug APK was exported from the current working tree to `/tmp/phase3-current-debug.apk` and installed successfully with `adb install -r`; SHA-256: `b8ebbaf541e8d1b4b0b2eb66be609c0d1150daf920dbe72ef006caaa163d8bc4`.
- The installed `com.example.leddisplay` launch activity obtained foreground focus and rendered Home in portrait at `1440x3088`. The current factual capture is `/tmp/phase3-home-device.png`.
- The capture shows a two-column grid for the eleven standard modes, the approved static previews rendered without geometric stretching, and the Advanced Editor as a full-width card. All twelve approved assets are visibly represented. The BottomTabBar is visible at the viewport bottom.
- `adb logcat` filtered to `AndroidRuntime:E` and `Godot:E` after launch contained no crash/runtime-error entries.
- **Failure — 44 dp touch target:** the fixed BottomTabBar measures 64 physical px high in the device capture. The device reports 600 dpi (3.75 px/dp), so the bar and its tab targets are approximately 17.1 dp high, below the required 44 dp. T009 cannot pass.
- **Failure — Home composition/scroll validation:** the device capture has a substantial empty lower region after the Advanced Editor card and no Home overflow to exercise scrolling. Therefore scroll-versus-fixed-tab behavior and the expected vertically scrollable, reference-aligned phone composition are not validated; T015 cannot pass.
- Device-only preview measurements are approximately `660x130 px` for a standard ModeCard and `1360x110 px` for the full-width Advanced Editor preview. All source assets are `1536x1024 px`. The 2x T041 determination is not complete across supported phone/tablet layouts, and the required no-visible-quality-loss comparison for downscaling was not performed. T041 remains conditional and open; no asset was changed.

## Phase 3 corrective device validation record — 2026-08-14

- The corrective build sets Godot's portrait design viewport to `412x915` with `canvas_items` stretching. `godot --headless --path . --import --quit` completed with exit code `0` and no project parse/import failure; `git diff --check` completed without reported whitespace errors. The sandboxed headless terminal did emit unrelated host socket/ADB-editor-settings persistence diagnostics, so the successful physical-device launch is the authoritative startup evidence.
- A new Android debug APK was exported from the current working tree as `/tmp/phase3-home-layout-v2.apk` (SHA-256: `12bb226c41a7218ca04af4d84f0d1daea7c36cf8362bb9bcafdb3eb56db1732b`), installed successfully with `adb install -r`, and launched on ADB device `R3CT7065M1R` (`SM_S908B`, status `device`). The application retained foreground focus at `com.example.leddisplay/com.godot.game.GodotAppLauncher` without a crash.
- Factual device screenshots: Home top `/tmp/phase3-home-device-v2.png`; scrolled grid `/tmp/phase3-home-device-v2-scrolled.png`; bottom with the full-width Advanced Editor `/tmp/phase3-home-device-v2-bottom.png`; return-to-Home after a root-tab navigation round trip `/tmp/phase3-home-device-v2-nav-return.png`. All captures are portrait `1440x3088`.
- Visual inspection of those captures confirms a strict two-column regular-mode grid, visible vertical overflow, a fixed BottomTabBar while the content scrolls, and a full-width Advanced Editor reachable after the grid. The final card and its subtitle remain above the fixed navigation; no clipping, overlap, or artificial blank Home region was observed.
- The twelve approved `1536x1024` static PNGs are shown across the top/scrolled/bottom captures. Their 3:2 TextureRect frame preserves aspect ratio: Police, Ambulance, Fire, Warning, SOS, Taxi, Security, Party, Love, Birthday, Christmas, and Advanced Editor remain readable with no observed crop of the main subject or text-heavy composition. Godot still renders the card title, subtitle, accent, and navigation separately.
- The fixed bar is approximately `270 px` high in the capture. At the device's reported `600 dpi` (`3.75 px/dp`), this is approximately `72 dp`; each of its four Button controls has a configured `56` logical-unit minimum height (approximately `56 dp` under the `412x915` design viewport), satisfying the `>=44 dp` navigation touch-target requirement. Regular ModeCards are larger than that minimum as well.
- The largest observed preview is the full-width Advanced Editor frame at approximately `1200x800 px` (`320x213 dp`) on this phone. Each source is `1536x1024 px`, which is below twice both dimensions of this measured maximum (`2400x1600 px`). Therefore T041 is **not triggered by the current phone measurement**. Tablet maximum-preview measurement remains required before T015 can be completed; no approved asset was changed or recompressed.
- `adb logcat -d -v brief AndroidRuntime:E Godot:E '*:S'` returned no AndroidRuntime or Godot error/crash entries after launch and the root-navigation round trip.
- T009 and T015 deliberately remain open: the user requested visual approval before either task is closed, and the required representative-tablet measurement has not yet been recorded. This correction does not authorize Phase 4.

## Phase 3 final Home-polish validation attempt — 2026-08-14

- Source-level validation completed: `git diff --check` exited `0`; `godot --headless --path . --import --quit` exited `0` and registered `BottomTabBar` and `ModeCard` without a project parse/import failure. The sandbox again emitted unrelated host socket/ADB-editor-settings persistence diagnostics.
- Android export freshness **failed**. `godot --headless --path . --export-debug Android /tmp/phase3-home-polish-v3.apk` did not produce `/tmp/phase3-home-polish-v3.apk`. The only available `builds/leddisplay-debug.apk` has modification timestamp `2026-08-10 22:28:56 +0300`, predating this corrective work, so it is not a build from the current working tree.
- That stale APK was installed only to verify the condition and launched successfully, but its Home contains the earlier emoji/solid-color card presentation. Captures `/tmp/phase3-home-polish-v3-top.png` and `/tmp/phase3-home-polish-v3-scroll.png` are therefore explicitly **invalid as visual evidence** for this pass and must not be used for approval or to close T009/T015.
- No current-tree device screenshot, fixed-bottom-navigation proof, final touch-target confirmation, clipping/overflow review, or final logcat claim was recorded for the polish pass. Do not begin Phase 4; resolve fresh Android export before rerunning the physical-device validation.

## Phase 3 final Home visual-polish device record — 2026-08-14

- A fresh current-tree Gradle APK was produced at `android/build/build/outputs/apk/standard/debug/android_debug.apk`: timestamp `2026-08-14 19:30:14 +0300`, size `188596133` bytes, SHA-256 `7fdb4d4dca2465eac48647f7d920f7c48fac338c6abcdb6f61369ec2a8464681`. This is the authoritative Android artifact, not the stale `builds/leddisplay-debug.apk`.
- The APK installed with `adb install -r` and launched into `com.example.leddisplay/com.godot.game.GodotAppLauncher` on `R3CT7065M1R` (`SM_S908B`, physical portrait `1440x3088`, density `600`). `adb logcat -d -v brief AndroidRuntime:E Godot:E '*:S'` returned no runtime-error or crash entry.
- Fresh captures are `/tmp/phase3-home-final-top.png` and `/tmp/phase3-home-final-bottom.png`. Together they show the strict two-column grid, all twelve approved static previews with no observed aspect distortion or primary-content crop, neutral ModeCard perimeters, compact title/subtitle rhythm, and the `СОЗДАТЬ СВОЁ` separation before the full-width Advanced Editor.
- The bottom capture proves that the full Advanced Editor card, including title and subtitle, remains reachable above the opaque fixed BottomTabBar. During the scroll, the BottomTabBar stays fixed and no clipping, overlap, artificial bottom gap, or card overflow was observed.
- Each root destination retains a `56` logical-unit Button touch region (above the `>=48 dp` requirement); its visible active pill is only `78x44` logical units around icon and label. The design viewport remains `412x915` under `canvas_items`, so no physical-pixel-to-dp assumption is used for the interaction target.
- `git diff --check` passed; `godot --headless --path . --import --quit` exited `0` without a project parse/import failure. Its sandbox-only socket/ADB-editor-settings persistence diagnostics remain non-product environment noise.
- T009 and T015 remain open by user instruction, pending visual approval. This evidence does not authorize Phase 4.

## Smoke scenarios

### Home and root navigation

1. Launch the app: all signal modes, thematic modes, and Advanced Editor are visible and recognizable; each Home ModeCard loads its corresponding approved original static asset from `assets/ui/mode_cards/` as the dominant preview.
2. Confirm the preview preserves aspect ratio, fills the intended preview area without obscuring its primary composition, and has no procedural/live-art overlay. Confirm Godot renders title, subtitle, accent border, state, and navigation separately from the image.
3. Confirm Home ModeCards use this approved static presentation exception only: they do not instance, require, or simulate a live `LedBoard` preview. `LedBoard` remains the sole live preview/fullscreen source in mode-detail and Advanced Editor experiences.
4. Confirm no Home asset is stock/unverified-rights content or includes official logos, crests, department names, service numbers, vehicle liveries, or other official emergency-service identity; emergency visuals remain generic and fictional.
5. Measure and record the maximum rendered ModeCard preview width and height across supported phone/tablet layouts. If a source asset exceeds twice both measured dimensions, downscale or recompress it only when the approved composition, aspect ratio, and visual quality remain unchanged at normal viewing distance and no visible compression/downscaling artifacts appear; otherwise record that T041 is not required.
6. Open every root tab and confirm selected state, empty states, and Back behavior.
7. Verify Favorites and History use compact accent-led rows; timestamps and long labels remain readable.

### Signal and thematic mode detail

1. Open at least one signal and one thematic mode. Verify title/accent, live preview, relevant control groups, and persistent bottom action bar.
2. Change each available control type and confirm the existing preview/behavior response.
3. Use Demo and confirm it stops after its existing duration. Start, stop, favorite, and reopen via Favorites/History.
4. Enter fullscreen from the action bar and by double-tapping the preview; exit and confirm layout/state restoration.
5. For Police, test record, playback, repeat, and Android permission behavior. For a siren-capable preset, test volume; confirm unsupported controls are absent.

### Advanced Editor and Settings

1. Edit text and visual settings; verify live display updates. Test Play, Pause, and Stop.
2. Open focused editor sections for text, background, radio, and projects; save, load, duplicate, and delete a project.
3. Pause/relaunch to verify autosave restoration. Test editor fullscreen entry/exit and banner restoration.
4. Toggle all Settings options; verify selected state and existing persistence behavior.

### Responsive and visual quality

1. Repeat navigation and primary-action checks on phone and tablet portrait layouts.
2. Verify no horizontal clipping, overlapping labels, inaccessible action bars, or controls smaller than the minimum touch target.
3. Review every screen for default-looking controls, inconsistent component states, insufficient contrast, emoji-as-primary-icon usage, and unauthorized official-service imagery.
4. On a representative phone, scroll Home and ensure static preview textures remain crisp, aspect-preserving, and free of visual clipping or unnecessary memory-heavy source resolution.
5. Compare the implemented screen against the primary visual reference for composition, hierarchy, proportions, spacing, card/preview emphasis, control density, navigation, dark surfaces, restrained border/glow, accent use, and typography. For Home cards compare against the mode-card style reference as well; record any necessary deviation with a concrete UX or technical reason.

## Expected outcome

All existing workflows complete with the same functional results, the live display remains synchronized in embedded and fullscreen contexts, and the application reads as one consistent premium dark mobile interface across phone and tablet layouts.
