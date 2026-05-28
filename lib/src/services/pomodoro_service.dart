import 'package:metire/src/models/pomodoro.dart';
import 'package:metire/src/models/session.dart';

class PomodoroService {
  final Pomodoro pomodoro;
  final Session session;

  PomodoroService({required this.pomodoro, required this.session});

  void start() => pomodoro.start();
  void pause() => pomodoro.pause();

  void toggle() {
    if (pomodoro.isRunning) {
      pomodoro.pause();
    } else {
      pomodoro.start();
    }
  }

  void restart() {
    pomodoro.reset();
  }

  int get remaining => pomodoro.secRemaining;
  PomodoroMode get mode => pomodoro.mode;
  bool get isRunning => pomodoro.isRunning;
  int get cycleCount => pomodoro.cycleCount;
  int get focusCount => session.focusCount;
  int get pauseCount => session.pauseCount;

  void tick() {
    final lastMode = pomodoro.mode;
    pomodoro.tick();
    if (pomodoro.mode != lastMode) {
      if (lastMode == PomodoroMode.focus) {
        session.registerFocus();
      } else {
        session.registerPause();
      }
    }
  }
}
