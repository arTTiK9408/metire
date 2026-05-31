# Changelog

## [1.0.0] - 2026-05-31

### Added
- TUI Pomodoro timer with Braille 8-dot counter
- Three display modes: full (16 rows), half (8 rows), text fallback
- Cycle indicators (4) with active/inactive icons
- Keyboard shortcuts: Space (start/pause), R (reset), Q (quit)
- Tokyo Night color scheme
- Distribuição: Arch Linux (AUR/PKGBUILD), Debian/Ubuntu (.deb), Windows (Chocolatey)
- CI/CD: GitHub Actions release workflow (Linux + Windows binaries)

### Changed
- Refined shutdown sequence with terminal restoration safety layers
- Inline Pomodoro initialization (removed late final)
- Conditional setState for performance
- Cycle indicator colors and top panel layout

### Fixed
- Terminal echo/lineMode not restored on exit
- Colon braille spacing in full font
- build-deb.sh variable case bug
