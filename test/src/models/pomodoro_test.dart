import 'package:test/test.dart';
import 'package:metire/src/models/pomodoro.dart';

void main() {
  group('Pomodoro -', () {
    late Pomodoro p;
    setUp(() {
      p = Pomodoro();
    });

    group('estado inicial -', () {
      test('secRemaining deve ser 1500 ao iniciar', () {
        expect(p.secRemaining, equals(1500));
      });
      test('isRunning deve ser false ao iniciar', () {
        expect(p.isRunning, isFalse);
      });
      test('cycleCount deve ser 0 ao iniciar', () {
        expect(p.cycleCount, equals(0));
      });
      test('mode deve ser focus ao iniciar', () {
        expect(p.mode, equals(PomodoroMode.focus));
      });
    });

    group('operações -', () {
      test('start() deve alternar isRunning para true', () {
        p.start();
        expect(p.isRunning, isTrue);
      });
      test('pause() deve alterar isRunning para false', () {
        p.start();
        p.pause();
        expect(p.isRunning, isFalse);
      });
      test('start() é idempotente', () {
        p.start();
        p.start();
        expect(p.isRunning, isTrue);
      });
      test('pause() é idempotente', () {
        p.start();
        p.pause();
        p.pause();
        expect(p.isRunning, isFalse);
      });
    });

    group('tick -', () {
      test('tick() deve decrementar secRemaining em 1', () {
        p.start();
        p.tick();
        expect(p.secRemaining, equals(1499));
      });
      test('tick() não deve decrementar se pausado', () {
        p.tick();
        expect(p.secRemaining, equals(1500));
      });
      test('tick() decrementa corretamente em múltiplas chamadas', () {
        p.start();
        p.tick();
        p.tick();
        p.tick();
        expect(p.secRemaining, equals(1497));
      });
    });

    group('transições de ciclo -', () {
      group('focus → pause', () {
        test('quando secRemaining chega a 0, cycleCount incrementa', () {
          p.secRemaining = 1;
          p.start();
          p.tick();
          expect(p.cycleCount, equals(1));
        });
        test('quando ciclo focus termina, isRunning vira false', () {
          p.secRemaining = 1;
          p.start();
          p.tick();
          expect(p.isRunning, isFalse);
        });
        test(
          'quando focus termina com menos de 4 ciclos → shortPause com 300s',
          () {
            p.secRemaining = 1;
            p.start();
            p.tick();
            expect(p.mode, equals(PomodoroMode.shortPause));
            expect(p.secRemaining, equals(300));
          },
        );
        test(
          'quando terminar o 4º ciclo de focus, a próxima pausa deve ser longa (900s)',
          () {
            p.cycleCount = 3;
            p.secRemaining = 1;
            p.start();
            p.tick();
            expect(p.mode, equals(PomodoroMode.longPause));
            expect(p.secRemaining, equals(900));
            expect(p.cycleCount, equals(0));
          },
        );
      });

      group('pause → focus', () {
        test('quando pausa curta termina, volta para focus com 1500s', () {
          p.mode = PomodoroMode.shortPause;
          p.secRemaining = 1;
          p.start();
          p.tick();
          expect(p.mode, equals(PomodoroMode.focus));
          expect(p.secRemaining, equals(1500));
        });
        test(
          'quando pausa longa termina, volta para focus com 1500s e zera cycleCount',
          () {
            p.mode = PomodoroMode.longPause;
            p.secRemaining = 1;
            p.start();
            p.tick();
            expect(p.mode, equals(PomodoroMode.focus));
            expect(p.secRemaining, equals(1500));
            expect(p.cycleCount, equals(0));
          },
        );
        test('após pausa curta, cycleCount não é zerado', () {
          p.cycleCount = 2;
          p.mode = PomodoroMode.shortPause;
          p.secRemaining = 1;
          p.start();
          p.tick();
          expect(p.mode, equals(PomodoroMode.focus));
          expect(p.cycleCount, equals(2));
        });
      });
    });
  });
}
