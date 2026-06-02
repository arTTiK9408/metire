# Metire

**Metire** is a TUI Pomodoro timer with an 8-dot Braille counter, built with Dart and Nocterm. Following the original principles created by Francesco Cirillo.

## About

This is a study project developed with assistance from **opencode** (and free models), exploring TUI concepts with Nocterm, TDD, multi-platform packaging and CI/CD with GitHub Actions.

## Install

### Linux / macOS

```bash
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/install.sh | sh
```

### Windows

```bash
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/install.bat | cmd
```

## Uninstall

### Linux / macOS

```bash
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/uninstall.sh | sh
```

### Windows

```bash
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/uninstall.bat | cmd
```

## Usage

| Key | Action |
|-------|------|
| `Space` | Start/Stop |
| `R` | Reset |
| `Q` | Quit |

### Cycles

- **Focus:** 25 minutes (1500s)
- **Short pause:** 5 minutes (300s) — up to 3 cycles
- **Long pause:** 15 minutes (900s) — 4th cycle, then resets

The original technique has six steps:
> 1. Deciding on the task to be done
> 2. Setting the Pomodoro timer (typically for 25 minutes)
> 3. Working on the task
> 4. Ending work when the timer rings and taking a short break (typically 5–10 minutes)
> 5. Going back to Step 2 and repeating until one completes four pomodori
> 6. After four pomodori are done, one takes a long break (typically 20 to 30 minutes) instead of a short break. Once the long break is finished, one returns to step 2

For the purposes of the technique, a pomodoro is an interval of work time (and pomodori is the plural form)

## Roadmap

- [ ] **Persistent sessions** — save and restore timer state across runs, with accumulated statistics of completed cycles and total focus time
- [ ] **Configuration file** — customize colors, mode durations and keyboard shortcuts via YAML/JSON file (`~/.config/metire/config.yaml`)
- [ ] **Notifications and sound alerts** — signal at the end of each mode (focus, short pause, long pause), with system notification and terminal beep support
- [ ] **Customizable durations** — allow adjusting focus, short pause and long pause durations from the interface or config file
- [ ] **History log** — local record of completed sessions with date, duration and mode, exportable in CSV/JSON
- [ ] **Multiple profiles** — support for different configurations (e.g., work, study, exercise) switchable at runtime
- [ ] **Light/dark mode** — alternative light theme for better readability in bright environments
- [ ] **Optional Nerd Font icons** — textual fallback for terminals without Nerd Font installed
