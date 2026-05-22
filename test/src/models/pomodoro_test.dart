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
    test('mode deve ser focus ao iniciar', () {
      expect(pomodoro.mode, equals(PomodoroMode.focus));
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

    test('tick() deve decrementar secRemaining em 1', () {});
    test('tick() não decrementa se pausado', () {});
    test('quando secRemaining chega a 0, cycleCount incrementa', () {});
    test('quando ciclo pause termina, secRemaining reseta para 1500', () {});
    test('quando ciclo focus termina, isRunning vira false', () {});

    test(
      'Quando o foco chega a 0 pela primeira vez, deve mudar para pausaCurta com 300s',
      () {},
    );
    test(
      'Após completar o 4º ciclo de foco, a próxima pausa deve ser Longa (900s)',
      () {},
    );
    test('Quando a pausa acaba, deve retornar para o modo Foco (1500s)', () {});
  });
}
