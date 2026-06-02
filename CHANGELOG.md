# Changelog

## [1.1.0] - 2026-06-02

### Added
- Windows build support in GitHub Actions CI/CD
- `install.bat` — Windows installation script via CMD

### Changed
- Release workflow now builds for Linux x86_64 and Windows x86_64

### Fixed
- Windows CMD high-CPU hang: upgraded nocterm to 0.6.0 (native Windows Console API support)

## [1.0.0] - 2026-05-31

### Added
- TUI Pomodoro timer with 8-dot Braille counter
- Three display modes: full (16 rows), half (8 rows), text fallback
- Cycle tracking: focus (25min) → short break (5min) up to 3x → long break (15min) on 4th cycle
- Keyboard controls: Space (start/stop), R (reset), Q (quit)
- Tokyo Night color scheme
- Automatic terminal state restoration on exit
- Installation scripts: Linux/macOS (`install.sh`), Windows (`install.bat`)
