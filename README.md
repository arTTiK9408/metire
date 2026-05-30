# Metire

CLI Pomodoro timer with Braille counter, built with Dart and `nocterm`.

## Usage

```bash
dart run
```

Controls: `Espaço` start/pause, `R` reset, `q` quit.

## Project structure

- `bin/metire.dart` — entrypoint
- `lib/src/models/pomodoro.dart` — Pomodoro model
- `lib/src/ui/widgets/counter.dart` — Braille timer counter
- `lib/src/ui/tui_app.dart` — TUI layout and keyboard handling
- `test/` — unit tests (25 total)

## Testing

```bash
dart test
dart analyze
```
