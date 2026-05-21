class Pomodoro {
  bool isRunning = false;
  int secRemaining = 1500;
  int pauseCount = 0;
  int cycleCount = 0;

  void start() {
    isRunning = true;
  }

  void pause() {
    isRunning = false;
  }
}
