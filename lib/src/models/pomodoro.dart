class Pomodoro {
  int secRemaining = 1500;
  bool isRunning = false;

  void start() {
    isRunning = true;
  }

  void pause() {
    isRunning = false;
  }
}
