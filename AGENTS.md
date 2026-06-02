# Metire

Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm.

- **Run:** `dart run` (from project root) — entrypoint `bin/metire.dart`
- **Test:** `dart test` — uses `package:test`
- **Lint:** `dart analyze`
- **Build binary:** `dart compile exe bin/metire.dart -o metire`
- **Deps:** `nocterm`; dev deps: `lints`, `test`
- **SDK:** Dart ^3.12.0
- **Library root:** `lib/metire.dart` exports `Pomodoro` and `TuiApp`

## Architecture

### Models

- `lib/src/models/pomodoro.dart` — `PomodoroMode` enum, `Pomodoro` class with:
  - Fields: `secRemaining` (1500), `isRunning` (false), `mode` (focus), `cycleCount` (0), `focusCount` (0)
  - Methods: `start()`, `pause()`, `tick()`, `reset()`
  - Cycle: focus 1500s → shortPause 300s (up to 3x) → longPause 900s (4th cycle, resets `cycleCount`)
  - `tick()` decrements `secRemaining` by 1, triggers `_handleCycleEnd()` when reaching 0
  - `reset()` returns all fields to initial values
  - Both `start()` and `pause()` are idempotent

### Widgets

- `lib/src/ui/widgets/counter.dart` — `TimerCounter` widget rendering digits in Braille (8-dot):
  - Uses `LayoutBuilder` for responsive sizing
  - `_full` (16 rows, h > 18 && w > 64) — detailed Braille art
  - `_half` (8 rows, h > 10 && w > 44) — compact Braille art
  - Fallback to plain text when too small
  - Receives dynamic `Color` from parent for active/inactive state

### UI

- `lib/src/ui/tui_app.dart` — `TuiApp` component:
  - **Layout:** cycle indicators (4 icons 󱓻/󱓼), mode row (FOCUS/PAUSE), Braille counter, shortcut bar
  - **Colors (Tokyo Night):** `_mainBg` #1f2335, `_altBg` #292e42
  - **Timer:** `Timer.periodic` every 1s, calls `p.tick()` + `setState()` only when running
  - **Keyboard:** Space (start/pause), R (reset), Q (quit with `_shutdown()`)
  - **Mode row colors:** green (focus running), yellow (short pause), red (long pause), blue `0x7aa2f7` (paused)

## Commands

```bash
dart run          # Run the TUI
dart test         # Run all tests (25 total)
dart analyze      # Static analysis
dart compile exe bin/metire.dart -o metire  # Build native binary
```

## Install Scripts

### Linux / macOS

```bash
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/install.sh | sh
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/uninstall.sh | sh
```

The `install.sh` script:
- Detects OS (Linux/macOS) and architecture (x86_64/aarch64)
- Fetches the latest release tag from GitHub API
- Downloads the correct binary from GitHub Releases
- Installs to `/usr/local/bin` (uses `sudo` if needed)
- Validates ELF/Mach-O header before installation
- Supports `INSTALL_DIR=~/.local/bin curl ...` for custom paths

The `uninstall.sh` script:
- Searches common install paths (`/usr/local/bin`, `/usr/bin`, `~/.local/bin`, `~/bin`)
- Removes the binary with `sudo` if needed

### Windows

```cmd
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/install.bat | cmd
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/uninstall.bat | cmd
```

The `install.bat` script:
- Detects architecture (x86_64/aarch64)
- Fetches the latest release tag via PowerShell
- Downloads `metire-windows-x86_64.exe` from GitHub Releases
- Installs to `%USERPROFILE%\.metire\bin\metire.exe`
- Adds the directory to the user PATH

The `uninstall.bat` script:
- Removes `metire.exe` and the `.metire\bin` directory
- Removes the directory from the user PATH

## Release Workflow

### Versioning

The project follows **SemVer** (`major.minor.patch`):
- **major** — incompatible changes or significant rewrites
- **minor** — new features without breaking compatibility
- **patch** — bug fixes and small tweaks

The current version is in `pubspec.yaml`.

### Phase 1 — Preparation (manual, local machine)

```
[ ] git checkout main && git pull
[ ] Verify all desired features are merged
[ ] dart test        — 25 tests, all green
[ ] dart analyze     — zero issues
[ ] dart run         — quick visual smoke test
[ ] CHANGELOG.md     — add new version entry with changelog
[ ] pubspec.yaml     — update version
[ ] git add -A && git commit -m "chore(release): bump version to X.Y.Z"
```

### Phase 2 — Tag and CI/CD (automatic via GitHub Actions)

```
1. Create tag:     git tag -a vX.Y.Z -m "vX.Y.Z"
2. Push tag:       git push origin vX.Y.Z
3. GitHub Actions runs automatically:
   a. Build jobs (matrix: Linux + Windows):
      - setup-dart
      - dart pub get
      - dart compile exe → binary
      - rename to asset (metire-linux-x86_64 / metire-windows-x86_64.exe)
      - upload as artifact
   b. Release job (after all builds succeed):
      - download all artifacts
      - merge into release/
      - softprops/action-gh-release creates GitHub Release with:
        • metire-linux-x86_64
        • metire-windows-x86_64.exe
        • Body: "Metire vX.Y.Z\n\n- Linux x86_64 binary\n- Windows x86_64 binary"
4. Verify on GitHub:
   - Actions tab → green workflow
   - Releases page → release published with both artifacts
```

### Full checklist

```
[ ] dart test
[ ] dart analyze
[ ] CHANGELOG.md updated
[ ] pubspec.yaml versioned
[ ] Commit "chore(release): bump version to X.Y.Z"
[ ] Tag vX.Y.Z created and pushed
[ ] GitHub Actions green
[ ] Release published on GitHub
```
