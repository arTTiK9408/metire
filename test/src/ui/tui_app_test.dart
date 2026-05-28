import 'package:test/test.dart' hide isEmpty;
import 'package:nocterm/nocterm.dart';
import 'package:metire/src/ui/tui_app.dart';

void main() {
  test('TuiApp - renderiza layout com sidebar e área principal', () async {
    await testNocterm('render', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('POMODORO'));
      expect(tester.terminalState, containsText('Sessão'));
      expect(tester.terminalState, containsText('25:00'));
      expect(tester.terminalState, containsText('◉ FOCUS'));
      expect(tester.terminalState, containsText('○ PAUSE'));
      expect(tester.terminalState, containsText('Ciclo 1/4'));
      expect(tester.terminalState, containsText('v0.1.0'));
      expect(tester.terminalState, containsText('Q: Sair'));
    });
  });

  test('TuiApp - espaço inicia e pausa o pomodoro', () async {
    await testNocterm('space toggle', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('◉ FOCUS'));

      await tester.sendKey(LogicalKey.space);
      await tester.pump(const Duration(seconds: 1));

      expect(tester.terminalState, containsText('24:59'));

      await tester.sendKey(LogicalKey.space);
      await tester.pump(const Duration(seconds: 1));

      expect(tester.terminalState, containsText('24:59'));
    });
  });

  test('TuiApp - r reseta o pomodoro ao estado inicial', () async {
    await testNocterm('reset', (tester) async {
      await tester.pumpComponent(const TuiApp());

      await tester.sendKey(LogicalKey.space);
      await tester.pump(const Duration(seconds: 1));

      expect(tester.terminalState, containsText('24:59'));

      await tester.sendKey(LogicalKey.keyR);
      await tester.pump();

      expect(tester.terminalState, containsText('25:00'));
    });
  });

  test('TuiApp - s entra em modo rename e esc sai sem alterar', () async {
    await testNocterm('rename', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('Sessão'));

      await tester.sendKey(LogicalKey.keyS);
      await tester.pump();

      await tester.sendKey(LogicalKey.escape);
      await tester.pump();

      expect(tester.terminalState, containsText('Sessão'));
    });
  });
}
