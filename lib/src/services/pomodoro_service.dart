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
    pomodoro.isRunning = false;
    pomodoro.secRemaining = 1500;
    pomodoro.mode = PomodoroMode.focus;
    pomodoro.cycleCount = 0;
  }

  int get remaining => pomodoro.secRemaining;
  PomodoroMode get mode => pomodoro.mode;
  bool get isRunning => pomodoro.isRunning;
  int get cycleCount => pomodoro.cycleCount;
  int get focusCount => session.focusCount;
  int get pauseCount => session.pauseCount;

  void tick() {
    final modoAnterior = pomodoro.mode;
    pomodoro.tick();
    if (pomodoro.mode != modoAnterior) {
      if (modoAnterior == PomodoroMode.focus) {
        session.registerFocus();
      } else {
        session.registerPause();
      }
    }
  }
}
