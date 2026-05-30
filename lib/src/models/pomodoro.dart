enum PomodoroMode { focus, shortPause, longPause }

class Pomodoro {
  PomodoroMode mode = PomodoroMode.focus;
  bool isRunning = false;
  int secRemaining = 10; // 1500
  int cycleCount = 0;
  int focusCount = 0;

  void start() {
    isRunning = true;
  }

  void pause() {
    isRunning = false;
  }

  void reset() {
    isRunning = false;
    secRemaining = 1500;
    mode = PomodoroMode.focus;
    cycleCount = 0;
  }

  void tick() {
    if (!isRunning) return;
    secRemaining--;
    if (secRemaining <= 0) {
      _handleCycleEnd();
    }
  }

  void _handleCycleEnd() {
    isRunning = false;
    if (mode == PomodoroMode.focus) {
      focusCount++;
      cycleCount++;
      if (cycleCount >= 4) {
        mode = PomodoroMode.longPause;
        secRemaining = 9; // 900
        cycleCount = 0;
      } else {
        mode = PomodoroMode.shortPause;
        secRemaining = 3; // 300
      }
    } else {
      mode = PomodoroMode.focus;
      secRemaining = 10; //1500
    }
  }
}
