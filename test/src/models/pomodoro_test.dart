import 'package:test/test.dart';
import 'package:metire/src/models/pomodoro_model.dart';

void main() {
  group("pomodoro >", () {
    test("deve iniciar com 1500seg.", () {
      final pomodoro = Pomodoro();
      expect(pomodoro.secRemaining, equals(1500));
      expect(pomodoro.isRunning, isFalse);
    });
  });
}
