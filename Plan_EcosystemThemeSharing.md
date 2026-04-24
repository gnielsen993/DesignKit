# Plan: Ecosystem-Shared Theme Library

Forward-looking plan. Not wired now — per-app storage is correct for v1.
Execute when 2+ apps ship and cross-app theme sharing becomes a real want.

---

## 0) Trigger conditions — when to execute this plan

Act on this when **any** of:

- User/test feedback: "I made a pink theme in FitnessTracker, why isn't it in HabitTracker?"
- Marketing angle: pitching the apps as a coherent ecosystem ("your vibe, everywhere")
- A 2nd app ships `DKThemePicker` and diverges visually from FT
- You add iCloud / cross-device theme sync (that path naturally demands shared storage)

If none hit, leave per-app. Shared state is harder to untangle than to add.

---

## 1) Current state (v1, shipped)

- `DesignKit.ThemeManager` uses `UserDefaultsThemeStorage()` which defaults to
  `UserDefaults.standard`.
- `UserDefaults.standard` is **per-app** (scoped to bundle ID).
- Saved customs, mode, preset, and overrides all live in that per-app sandbox.
- Keys used: `designkit.theme.mode`, `designkit.theme.preset`,
  `designkit.theme.overrides`, `designkit.theme.customs`.
- Widget extensions do NOT share theme state with the host app unless they
  already use an App Group for other data.

## 2) Target state (v2, shared)

- All ecosystem apps + their widget extensions read/write theme state from a
  shared App Group `UserDefaults(suiteName:)`.
- Saving a theme in FitnessTracker makes it appear in HabitTracker,
  PantryPlanner, and their widgets on the same device.
- Per-app *active* selection (mode/preset/overrides) can still be shared OR
  isolated — see §4 decision point.

## 3) What's already plumbed

- `UserDefaultsThemeStorage.init` already takes `defaults: UserDefaults`.
- `UserDefaultsThemeStorage.init` already takes every persistence key as an
  overridable string.
- All payload types (`ThemeOverridesPayload`, `CustomThemePayload`) are
  `Codable` + hex-based — cross-app-safe, no SwiftUI.Color pointer issues.

So the SDK side is ready. The work is in the *app targets*, not DesignKit.

## 4) Decision point — shared *library* only, or shared *active* too?

**Option A — Shared library, per-app active (recommended).**
- `customThemes` lives in the shared suite. Your library travels.
- `mode` / `preset` / `overrides` stay per-app (each app picks from the shared
  library independently).
- Rationale: FitnessTracker might be on "Barbie" and HabitTracker on "Matcha"
  at the same time. Library is shared, outfit-of-the-day is per-app.

**Option B — Fully shared.**
- Everything in the shared suite. Changing theme in one app changes all.
- Simpler mental model but loses per-app mood flexibility.

Default to **A** unless user feedback says otherwise.

## 5) Implementation steps

### Step 1 — App Group entitlement
- In Xcode: each app target + its widget extension → Signing & Capabilities →
  App Groups → add `group.com.lauterstar.designkit` (or chosen suite name).
- Commit the updated `.entitlements` files.
- Repeat for every ecosystem app (FitnessTracker, HabitTracker, PantryPlanner).

### Step 2 — Wire shared storage in each app
In each app's `App` struct init (where ThemeManager is constructed):

```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.lauterstar.designkit")!
let storage = UserDefaultsThemeStorage(
    defaults: sharedDefaults,
    // Option A: only share customs. Override per-app keys to keep active
    // selection local to the app's standard defaults if desired.
    customsKey: "designkit.theme.customs"
)
let manager = DesignKit.ThemeManager(storage: storage)
```

For Option A (recommended), introduce a small composite storage that reads
customs from `sharedDefaults` and mode/preset/overrides from `.standard`.
Add to DesignKit:

```swift
public final class SplitThemeStorage: ThemeStorage {
    // mode/preset/overrides -> local
    // customThemes -> shared
}
```

### Step 3 — Migrate existing per-app customs
Each app, on first launch after upgrade, runs a one-time migration:

```swift
// in App init, before constructing ThemeManager
let local = UserDefaults.standard
let shared = UserDefaults(suiteName: "group.com.lauterstar.designkit")!
let migrationKey = "designkit.theme.customs.migratedToShared"
if !local.bool(forKey: migrationKey),
   let existing = local.data(forKey: "designkit.theme.customs") {
    // Merge into shared list (dedupe by CustomTheme.id).
    mergeCustomsData(existing, into: shared)
    local.removeObject(forKey: "designkit.theme.customs")
    local.set(true, forKey: migrationKey)
}
```

Skip merge if shared already has a version newer than local.

### Step 4 — Widget extension support
- Widgets share the App Group → can read live theme state.
- Widget `TimelineProvider.snapshot` / `getTimeline` use the same `ThemeManager`
  construction path as the app, but read-only is fine (widgets don't save).
- Watch out: widgets' process is separate — UserDefaults changes are observed
  via `DistributedNotificationCenter` or darwin notifications if you need live
  updates. Usually fine to let the system refresh on the next timeline tick.

### Step 5 — Tests
Add a DesignKit test that verifies:
- `UserDefaultsThemeStorage(defaults: suite).saveCustomThemes(x).loadCustomThemes()` round-trips cross-instance.
- `SplitThemeStorage` routes customs to one suite and active state to another.

### Step 6 — Optional: iCloud sync
Once shared-local works, swap `UserDefaults` for `NSUbiquitousKeyValueStore`
on the customs key — themes follow the iCloud account, not the device.
~1MB limit fits thousands of `CustomTheme` payloads. Expose as:

```swift
public final class CloudThemeStorage: ThemeStorage { ... }
```

Users opt in via a Settings toggle ("Sync themes across my devices").

---

## 6) Risks / edge cases

- **Bundle ID change** — if any app's bundle ID changes, the local-pre-migration
  data is lost. Migration step must run pre-change or cover fallback.
- **Entitlement drift** — forgetting to add the App Group to a widget target is
  the classic footgun. Widget will silently read empty data. Add a startup
  assertion in DEBUG:
  ```swift
  #if DEBUG
  assert(sharedDefaults.object(forKey: "__anything__") != nil || sharedDefaults.dictionaryRepresentation().isEmpty == false, "App Group not reachable")
  #endif
  ```
  (adjust the check — the real test is that write-then-read within the suite works).
- **Conflicting writes** — two apps save the same theme UUID simultaneously.
  Unlikely; last-write-wins is acceptable. For active state conflicts (Option B
  only), throttle saves and debounce.
- **App uninstall** — App Group container survives until all member apps are
  uninstalled. User reinstalling FitnessTracker alone keeps their themes. Good.

## 7) Out of scope (note for future plans)

- Theme marketplace (share custom themes with friends via link/QR).
- Theme versioning / undo history.
- Per-feature theme overrides (e.g. dark mode only for widgets).
- Seasonal / time-based auto-switching themes.

---

## 8) Rollout order (when executed)

1. Land `SplitThemeStorage` in DesignKit + tests. **[DesignKit repo]**
2. Land App Group entitlement + wiring + migration in FitnessTracker. Ship. **[FT repo]**
3. Repeat for HabitTracker. **[HT repo]**
4. Repeat for PantryPlanner. **[PP repo]**
5. If demanded: add `CloudThemeStorage` + Settings toggle.

Each step is independently revertable. No coordinated release required.
