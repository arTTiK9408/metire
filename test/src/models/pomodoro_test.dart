import 'package:test/test.dart';
import 'package:metire/src/models/pomodoro.dart';

void main() {
  group("pomodoro >", () {
    test(
      "deve iniciar com secRemaining 1500 e isRunning false ao executar",
      () {
        final pomodoro = Pomodoro();
        expect(pomodoro.secRemaining, equals(1500));
        expect(pomodoro.isRunning, isFalse);
      },
    );
    test("deve alternar isRunning para true com start()", () {
      final pomodoro = Pomodoro();
      pomodoro.start();
      expect(pomodoro.isRunning, isTrue);
    });
    test("deve alternar isRunning para false com pause()", () {
      final pomodoro = Pomodoro();
      pomodoro.start();
      pomodoro.pause();
    });
  });
}
