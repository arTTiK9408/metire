# Metire

Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm.

- **Run:** `dart run` (from project root) — entrypoint `bin/metire.dart`
- **Test:** `dart test` — uses `package:test`
- **Lint:** `dart analyze`
- **Build binary:** `dart compile exe bin/metire.dart -o metire`
- **Deps:** `nocterm`; dev deps: `lints`, `test`
- **SDK:** Dart ^3.12.0
- **Library root:** `lib/metire.dart` exports `Pomodoro`

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

## Install Script

The project provides a universal installer inspired by starship.rs:

```bash
# Install
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/install.sh | sh

# Uninstall
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/uninstall.sh | sh
```

The `install.sh` script:
- Detects OS (Linux/macOS) and architecture (x86_64/aarch64)
- Fetches the latest release tag from GitHub API (no manual version bumps)
- Downloads the correct binary from GitHub Releases
- Installs to `/usr/local/bin` (uses `sudo` if needed)
- Validates ELF/Mach-O header before installation
- Supports `INSTALL_DIR=~/.local/bin curl ...` for custom paths

The `uninstall.sh` script:
- Searches common install paths (`/usr/local/bin`, `/usr/bin`, `~/.local/bin`, `~/bin`)
- Removes the binary with `sudo` if needed

## Release Workflow

### Versionamento

O projeto segue **SemVer** (`major.minor.patch`):
- **major** — mudanças incompatíveis ou reescrita significativa
- **minor** — novas funcionalidades sem quebra de compatibilidade
- **patch** — correções de bugs e pequenos ajustes

A versão atual está em `pubspec.yaml`.

### Fase 1 — Preparação (manual, máquina local)

```
[ ] git checkout main && git pull
[ ] Verificar se todas as features desejadas estão mergeadas
[ ] dart test        — 25 testes, todos verdes
[ ] dart analyze     — zero issues
[ ] dart run         — smoke test visual rápido
[ ] CHANGELOG.md     — adicionar entry da nova versão com changelog
[ ] pubspec.yaml     — atualizar version
[ ] git add -A && git commit -m "chore(release): bump version to X.Y.Z"
```

### Fase 2 — Tag e CI/CD (automático via GitHub Actions)

```
1. Criar a tag:      git tag -a vX.Y.Z -m "vX.Y.Z"
2. Push da tag:      git push origin vX.Y.Z
3. GitHub Actions executa automaticamente:
   a. Job build (Linux):
      - setup-dart
      - dart pub get
      - dart compile exe → metire
      - upload como artifact
   b. Job release (após build):
      - download dos artifacts
      - organiza em release/
      - softprops/action-gh-release cria GitHub Release com:
        • metire-linux-x86_64
        • Body: "Metire vX.Y.Z — Linux x86_64"
4. Verificar no GitHub:
   - Actions tab → workflow verde
   - Releases page → release publicada com artifacts
```

### Checklist completo

```
[ ] dart test
[ ] dart analyze
[ ] CHANGELOG.md atualizado
[ ] pubspec.yaml versionado
[ ] Commit "chore(release): bump version to X.Y.Z"
[ ] Tag vX.Y.Z criada e pushed
[ ] GitHub Actions verde
[ ] Release pública no GitHub
```
