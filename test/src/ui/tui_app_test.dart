import 'package:test/test.dart' hide isEmpty;
import 'package:nocterm/nocterm.dart';
import 'package:metire/src/ui/tui_app.dart';

void main() {
  test('TuiApp - renderiza título e estado inicial', () async {
    await testNocterm('render', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('POMODORO'));
      expect(tester.terminalState, containsText('25:00'));
      expect(tester.terminalState, containsText('FOCUS'));
      expect(tester.terminalState, containsText('Sessão'));
      expect(tester.terminalState, containsText('Q: Sair'));
    });
  });

  test('TuiApp - espaço inicia e pausa o pomodoro', () async {
    await testNocterm('space toggle', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('⏸'));

      await tester.sendKey(LogicalKey.space);
      await tester.pump();

      expect(tester.terminalState, containsText('⏵'));

      await tester.sendKey(LogicalKey.space);
      await tester.pump();

      expect(tester.terminalState, containsText('⏸'));
    });
  });

  test('TuiApp - r reseta o pomodoro ao estado inicial', () async {
    await testNocterm('reset', (tester) async {
      await tester.pumpComponent(const TuiApp());

      await tester.sendKey(LogicalKey.space);
      await tester.pump();

      await tester.sendKey(LogicalKey.keyR);
      await tester.pump();

      expect(tester.terminalState, containsText('25:00'));
      expect(tester.terminalState, containsText('⏸'));
    });
  });

  test('TuiApp - s abre diálogo de rename e esc sai sem alterar', () async {
    await testNocterm('rename', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('Sessão'));

      await tester.sendKey(LogicalKey.keyS);
      await tester.pump();

      expect(tester.terminalState, containsText('Novo nome'));

      await tester.sendKey(LogicalKey.escape);
      await tester.pump();

      expect(tester.terminalState, containsText('Sessão'));
    });
  });
}
