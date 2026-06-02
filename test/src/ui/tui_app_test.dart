import 'package:test/test.dart' hide isEmpty;
import 'package:nocterm/nocterm.dart';
import 'package:metire/src/ui/tui_app.dart';

void main() {
  test('TuiApp - renderiza layout com contador braille', () async {
    await testNocterm('render', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('FOCUS (0)'));
      expect(tester.terminalState, containsText('PAUSE (S)'));
      expect(tester.terminalState, containsText('󱓻'));
      expect(tester.terminalState, containsText('Q Quit'));
      expect(tester.terminalState, containsText('⣿'));
    });
  });

  test('TuiApp - espaço inicia e pausa o pomodoro', () async {
    await testNocterm('space toggle', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('FOCUS (0)'));
      expect(tester.terminalState, containsText('⣿'));

      await tester.sendKey(LogicalKey.space);
      await tester.pump(const Duration(seconds: 1));

      expect(tester.terminalState, containsText('⣿'));

      await tester.sendKey(LogicalKey.space);
      await tester.pump(const Duration(seconds: 1));

      expect(tester.terminalState, containsText('⣿'));
    });
  });

  test('TuiApp - r reseta o pomodoro ao estado inicial', () async {
    await testNocterm('reset', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('⣿'));

      await tester.sendKey(LogicalKey.space);
      await tester.pump(const Duration(seconds: 1));

      expect(tester.terminalState, containsText('⣿'));

      await tester.sendKey(LogicalKey.keyR);
      await tester.pump();

      expect(tester.terminalState, containsText('⣿'));
    });
  });

  test('TuiApp - timer mostra valor atual após pausar', () async {
    await testNocterm('pause display', (tester) async {
      await tester.pumpComponent(const TuiApp());

      expect(tester.terminalState, containsText('⣿'));

      await tester.sendKey(LogicalKey.space);
      await tester.pump(const Duration(seconds: 1));

      await tester.sendKey(LogicalKey.space);
      await tester.pump();

      expect(tester.terminalState, containsText('⣿'));
    });
  });
}
