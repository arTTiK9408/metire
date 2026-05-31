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

## Git Workflow

1. Ensure current branch is committed before starting new work
2. Never commit directly to `main` — use feature branches
3. Format: `<type>(<scope>): <description>` (English, imperative, no period)
4. Types: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`
5. Scopes: `pomodoro`, `ui`, `counter`, `release`
6. Tests (`test:`) precede production code (`feat:`/`fix:`) following TDD
7. Run `dart test` and `dart analyze` before every commit
8. Environment: `EDITOR=nvim` on this system. Always use `-m` for commits, or `git -c core.editor=true` for interactive commands

## TDD Workflow (strict)

1. Write/update a test describing expected behavior (it will fail)
2. Run `dart test` — confirm failure
3. Write minimal production code to make it pass
4. Run `dart test` — confirm pass
5. Run `dart analyze` — confirm no issues
6. Refactor if needed, keeping tests green

Never introduce or modify production code without corresponding test changes.

## Unit Testing Guidelines

### Naming
- Test names in **Portuguese**, descriptive of scenario + expected behavior
- Group format: `'{ClassName} -'` (e.g., `'Pomodoro -'`, `'TuiApp -'`)
- Instance variable: `{ClassName} {variável}` (e.g., `Pomodoro p`)
- Test name pattern: `'[cenário] → [comportamento esperado]'`
  - Examples: `'quando focus termina com menos de 4 ciclos → shortPause com 300s'`, `'tick() não deve decrementar se pausado'`

### Characteristics
- **Full isolation:** each test starts with clean state via `setUp()` creating a new instance
- **Zero external dependencies:** no filesystem, network, database, or external APIs
- **Behavioral focus:** exactly one assertion per test
- **Determinism:** same input → same output, no randomness or real timers
- **Speed:** execution in milliseconds (avoid `sleep()`, `Future.delayed()`)

### Edge Case Coverage
- Initial states: verify all default constructor values
- Boundary values: tests with 0, 1, and domain-specific limits
- Invalid states: ensure operations don't corrupt the object
- State transitions: cover all possible paths between model states
- Idempotent operations: verify multiple calls don't change result
- Underflow/overflow protection where applicable
- Operation validity: test behaviors in states where operation should have no effect

### Current Tests
- `test/src/models/pomodoro_test.dart` — 21 tests, group `'Pomodoro -'`, variable `Pomodoro p`
- `test/src/ui/tui_app_test.dart` — 4 tests, group `'TuiApp -'`, rendering and keyboard shortcuts

## Packaging & Distribution

Project structure for packaging:

```
dist/
├── Makefile                  # build, clean, deb, rpm
├── build-deb.sh              # Debian/Ubuntu .deb builder
├── arch/
│   └── PKGBUILD              # Arch Linux / AUR
├── debian/
│   ├── DEBIAN/control
│   └── usr/bin/
├── fedora/
│   └── metire.spec
└── windows/
    ├── metire.nuspec
    └── tools/chocolateyinstall.ps1

.github/workflows/
└── release.yml               # CI/CD: build Linux + Windows, create GitHub Release
```

### Makefile

```makefile
BINARY = metire

build:
	dart pub get
	dart compile exe bin/metire.dart -o $(BINARY)

clean:
	rm -f $(BINARY)

deb: build
	mkdir -p dist/debian/usr/bin
	cp $(BINARY) dist/debian/usr/bin/
	dpkg-deb --build dist/debian metire_1.0_amd64.deb

rpm: build
	rpmbuild -ba dist/fedora/metire.spec
```

### GitHub Actions (release.yml)

Triggered on tag push `v*`:

```yaml
on:
  push:
    tags: ['v*']

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - run: dart pub get
      - run: dart compile exe bin/metire.dart -o metire${{ runner.os == 'Windows' && '.exe' || '' }}
      - uses: actions/upload-artifact@v4
        with:
          name: metire-${{ runner.os }}
          path: metire${{ runner.os == 'Windows' && '.exe' || '' }}

  release:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
      - run: |
          mkdir release
          mv metire-Linux/metire release/metire-linux-x86_64
          mv metire-Windows/metire.exe release/metire-windows-x86_64.exe
      - uses: softprops/action-gh-release@v2
        with:
          files: release/*
          body: |
            **Metire v${{ github.ref_name }}**

            - Linux x86_64 binary (statically linked, no dependencies)
            - Windows x86_64 binary
```

### Docker (cross-compilation helper)

```dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY . .
RUN dart pub get && dart compile exe bin/metire.dart -o metire

FROM scratch
COPY --from=build /app/metire /metire
ENTRYPOINT ["/metire"]
```

### Package Descriptions

All packages use:

> **Description:** Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm

### Arch Linux (AUR) — PKGBUILD

`dist/arch/PKGBUILD` compiles from source during install:

```bash
pkgname=metire
pkgver=1.0
pkgrel=1
pkgdesc="Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm"
arch=('x86_64')
url="https://github.com/arTTiK9408/metire"
license=('MIT')
makedepends=('dart')
source=("$url/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
  dart pub get
  dart compile exe bin/metire.dart -o metire
}

package() {
  install -Dm755 metire "$pkgdir/usr/bin/metire"
}
```

### Debian/Ubuntu — .deb

`dist/debian/DEBIAN/control`:

```
Package: metire
Version: 1.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Vitor
Description: Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm
```

Build: `dpkg-deb --build dist/debian metire_1.0_amd64.deb`

### Fedora/RHEL — .rpm

`dist/fedora/metire.spec`:

```spec
Name: metire
Version: 1.0
Release: 1
Summary: Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm
License: MIT
URL: https://github.com/arTTiK9408/metire
Source0: %{url}/archive/v%{version}.tar.gz
BuildRequires: dart

%description
Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm.

%prep
%setup -q

%build
dart pub get
dart compile exe bin/metire.dart -o metire

%install
install -Dm755 metire %{buildroot}%{_bindir}/metire

%files
%{_bindir}/metire
```

### Windows

Option A — Chocolatey package (`dist/windows/metire.nuspec` + `tools/chocolateyinstall.ps1` downloading .exe from GitHub Release).

Option B — Release .zip (`metire-windows-x86_64.zip` containing `metire.exe`), generated by GitHub Actions.

## Release Workflow

### Versionamento

O projeto segue **SemVer** (`major.minor.patch`):
- **major** — mudanças incompatíveis ou reescrita significativa
- **minor** — novas funcionalidades sem quebra de compatibilidade
- **patch** — correções de bugs e pequenos ajustes

A versão atual encontra-se sincronizada em:
- `pubspec.yaml` — fonte da verdade
- `dist/debian/DEBIAN/control`
- `dist/arch/PKGBUILD`
- `dist/fedora/metire.spec`
- `dist/windows/metire.nuspec`

### Fase 1 — Preparação (manual, máquina local)

```
[ ] git checkout main && git pull
[ ] Verificar se todas as features desejadas estão mergeadas
[ ] dart test        — 25 testes, todos verdes
[ ] dart analyze     — zero issues
[ ] dart run         — smoke test visual rápido
[ ] CHANGELOG.md     — adicionar entry da nova versão com changelog
[ ] pubspec.yaml     — atualizar version
[ ] dist/*           — sincronizar version em todos os arquivos de packaging
[ ] git add -A && git commit -m "chore(release): bump version to X.Y.Z"
```

### Fase 2 — Tag e CI/CD (automático via GitHub Actions)

```
1. Criar a tag:      git tag -a vX.Y.Z -m "vX.Y.Z"
2. Push da tag:      git push origin vX.Y.Z
3. GitHub Actions executa automaticamente:
   a. Job build (matrix Linux + Windows):
      - setup-dart
      - dart pub get
      - dart compile exe → metire (Linux) / metire.exe (Windows)
      - upload como artifact
   b. Job release (após build):
      - download dos artifacts
      - organiza em release/
      - softprops/action-gh-release cria GitHub Release com:
        • metire-linux-x86_64
        • metire-windows-x86_64.exe
        • Body: "Metire vX.Y.Z — Linux x86_64 + Windows x86_64"
4. Verificar no GitHub:
   - Actions tab → workflow verde
   - Releases page → release publicada com artifacts
```

### Fase 3 — Pós-release (manual, opcional)

```
5. Build .deb local:     make deb     → metire_X.Y.Z_amd64.deb
6. Build .rpm local:     make rpm     (requer rpmbuild)
7. AUR (Arch Linux):     atualizar PKGBUILD com nova versão e hash
8. Chocolatey (Windows): atualizar checksum no chocolateyinstall.ps1
9. Publicar release nos canais desejados
```

### Checklist completo

```
[ ] dart test
[ ] dart analyze
[ ] CHANGELOG.md atualizado
[ ] Versão sincronizada: pubspec.yaml + dist/*
[ ] Commit "chore(release): bump version to X.Y.Z"
[ ] Tag vX.Y.Z criada e pushed
[ ] GitHub Actions verde
[ ] Release pública no GitHub
[ ] (opcional) .deb / .rpm / AUR / Chocolatey
```
