class Session {
  String name;
  int focusCount = 0;
  int pauseCount = 0;
  bool isActive = false;
  final DateTime startTime;

  Session({required this.name})
      : startTime = DateTime.now();

  void rename(String newName) {
    name = newName.isEmpty ? 'Unnamed Session' : newName;
  }

  void registerFocus() {
    focusCount++;
  }

  void registerPause() {
    pauseCount++;
  }

  void begin() {
    isActive = true;
  }

  void end() {
    isActive = false;
  }
}
