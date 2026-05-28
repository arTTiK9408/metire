import 'package:test/test.dart';
import 'package:metire/src/models/pomodoro.dart';
import 'package:metire/src/models/session.dart';
import 'package:metire/src/services/pomodoro_service.dart';

void main() {
  group('PomodoroService -', () {
    late Pomodoro p;
    late Session s;
    late PomodoroService svc;

    setUp(() {
      p = Pomodoro();
      s = Session(name: 'teste');
      svc = PomodoroService(pomodoro: p, session: s);
    });

    group('delegação -', () {
      test('start() delega para pomodoro.start()', () {
        svc.start();
        expect(p.isRunning, isTrue);
      });

      test('pause() delega para pomodoro.pause()', () {
        p.start();
        svc.pause();
        expect(p.isRunning, isFalse);
      });

      test('toggle() inicia quando parado', () {
        svc.toggle();
        expect(p.isRunning, isTrue);
      });

      test('toggle() pausa quando rodando', () {
        p.start();
        svc.toggle();
        expect(p.isRunning, isFalse);
      });

      test('restart() reseta para estado inicial', () {
        p.start();
        p.secRemaining = 300;
        p.mode = PomodoroMode.shortPause;
        p.cycleCount = 2;
        svc.restart();
        expect(p.isRunning, isFalse);
        expect(p.secRemaining, equals(1500));
        expect(p.mode, equals(PomodoroMode.focus));
        expect(p.cycleCount, equals(0));
      });
      test('toggle() é idempotente (2x volta ao estado inicial)', () {
        svc.toggle();
        svc.toggle();
        expect(p.isRunning, isFalse);
      });
      test('restart() a partir de longPause', () {
        p.mode = PomodoroMode.longPause;
        p.secRemaining = 900;
        p.cycleCount = 0;
        p.start();
        svc.restart();
        expect(p.isRunning, isFalse);
        expect(p.secRemaining, equals(1500));
        expect(p.mode, equals(PomodoroMode.focus));
        expect(p.cycleCount, equals(0));
      });
      test('restart() é idempotente quando já resetado', () {
        svc.restart();
        svc.restart();
        expect(p.isRunning, isFalse);
        expect(p.secRemaining, equals(1500));
        expect(p.mode, equals(PomodoroMode.focus));
        expect(p.cycleCount, equals(0));
      });
    });

    group('getters -', () {
      test('remaining retorna secRemaining do pomodoro', () {
        expect(svc.remaining, equals(1500));
        p.secRemaining = 42;
        expect(svc.remaining, equals(42));
      });

      test('mode retorna mode do pomodoro', () {
        expect(svc.mode, equals(PomodoroMode.focus));
        p.mode = PomodoroMode.shortPause;
        expect(svc.mode, equals(PomodoroMode.shortPause));
      });

      test('isRunning retorna isRunning do pomodoro', () {
        expect(svc.isRunning, isFalse);
        p.start();
        expect(svc.isRunning, isTrue);
      });

      test('cycleCount retorna cycleCount do pomodoro', () {
        expect(svc.cycleCount, equals(0));
        p.cycleCount = 3;
        expect(svc.cycleCount, equals(3));
      });

      test('focusCount retorna focusCount da session', () {
        expect(svc.focusCount, equals(0));
        s.registerFocus();
        expect(svc.focusCount, equals(1));
      });

      test('pauseCount retorna pauseCount da session', () {
        expect(svc.pauseCount, equals(0));
        s.registerPause();
        expect(svc.pauseCount, equals(1));
      });
    });

    group('coordenação -', () {
      test('tick() sem transição não chama registerFocus nem registerPause', () {
        p.start();
        svc.tick();
        expect(s.focusCount, equals(0));
        expect(s.pauseCount, equals(0));
      });

      test('tick() chama registerFocus quando ciclo focus termina', () {
        p.secRemaining = 1;
        p.start();
        svc.tick();
        expect(s.focusCount, equals(1));
      });

      test('tick() chama registerPause quando shortPause termina', () {
        p.mode = PomodoroMode.shortPause;
        p.secRemaining = 1;
        p.start();
        svc.tick();
        expect(s.pauseCount, equals(1));
      });

      test('tick() chama registerPause quando longPause termina', () {
        p.mode = PomodoroMode.longPause;
        p.secRemaining = 1;
        p.start();
        svc.tick();
        expect(s.pauseCount, equals(1));
      });

      test('tick() não registra nada se pausado mesmo com secRemaining=1', () {
        p.secRemaining = 1;
        svc.tick();
        expect(s.focusCount, equals(0));
        expect(s.pauseCount, equals(0));
      });
      test('tick() com secRemaining=0 executa transição e registra focus', () {
        p.secRemaining = 0;
        p.start();
        svc.tick();
        expect(p.mode, equals(PomodoroMode.shortPause));
        expect(s.focusCount, equals(1));
      });

      test('após 4 ciclos completos, focusCount é 4', () {
        for (int i = 0; i < 4; i++) {
          p.secRemaining = 1;
          p.mode = PomodoroMode.focus;
          p.start();
          svc.tick();
          p.secRemaining = 1;
          p.start();
          svc.tick();
        }
        expect(s.focusCount, equals(4));
        expect(s.pauseCount, equals(4));
      });

      test('restart() não altera session counters', () {
        s.registerFocus();
        s.registerFocus();
        s.registerPause();
        svc.restart();
        expect(s.focusCount, equals(2));
        expect(s.pauseCount, equals(1));
      });
    });
  });
}
