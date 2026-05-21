import 'package:test/test.dart';
import 'package:metire/src/models/pomodoro.dart';

// commit 11c23cf - pinguino app
// https://github.com/minhosong88/flutter_Pomodoro_app/blob/main/lib/screens/home_screen.dart

void main() {
  group('pomodoro -', () {
    late Pomodoro pomodoro;
    setUp(() {
      pomodoro = Pomodoro();
    });

    test('secRemaining deve ser 1500 ao iniciar', () {
      expect(pomodoro.secRemaining, equals(1500));
    });
    test('isRunning deve ser false ao inciar', () {
      expect(pomodoro.isRunning, isFalse);
    });
    test('pauseCount deve ser 0 ao iniciar', () {
      expect(pomodoro.pauseCount, equals(0));
    });
    test('cycleCount deve ser 0 ao iniciar', () {
      expect(pomodoro.cycleCount, equals(0));
    });

    test('start() deve alternar isRunning para true', () {
      pomodoro.start();
      expect(pomodoro.isRunning, isTrue);
    });
    test('pause() deve alterar isRunning para false', () {
      pomodoro.start();
      pomodoro.pause();
      expect(pomodoro.isRunning, isFalse);
    });
  });
}
