import 'dart:async';
import 'dart:io' show stdin, Process, Platform;

import 'package:metire/src/models/pomodoro.dart';
import 'package:metire/src/ui/widgets/counter.dart';
import 'package:nocterm/nocterm.dart';

class TuiApp extends StatefulComponent {
  const TuiApp({super.key});

  @override
  State<TuiApp> createState() => _TuiAppState();
}

class _ShortcutBar extends StatelessComponent {
  const _ShortcutBar({required this.isRunning});
  final bool isRunning;

  @override
  Component build(BuildContext context) {
    return Container(
      padding: _TuiAppState._keysPad,
      color: _TuiAppState._altBg,
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(text: 'Espaço', style: _TuiAppState._white),
            TextSpan(
              text: isRunning ? ' Pausar  ' : ' Iniciar  ',
              style: _TuiAppState._grey,
            ),
            TextSpan(text: 'R', style: _TuiAppState._white),
            TextSpan(text: ' Reset  ', style: _TuiAppState._grey),
            TextSpan(text: 'Q', style: _TuiAppState._white),
            TextSpan(text: ' Sair', style: _TuiAppState._grey),
          ],
        ),
      ),
    );
  }
}

class _TuiAppState extends State<TuiApp> {
  static const _mainBg = Color(0xff1f2335);
  static const _altBg = Color(0xff292e42);

  static const _dim = TextStyle(color: Color(0x80545c7e));
  static const _white = TextStyle(color: Color(0xffc0caf5));
  static const _grey = TextStyle(color: Color(0xff545c7e));

  static const _gap = SizedBox(height: 1);
  static const _keysPad = EdgeInsets.only(left: 4, right: 4, top: 1, bottom: 1);
  final p = Pomodoro();
  Timer? _timer;

  String get _pauseLabel {
    if (p.mode == PomodoroMode.focus) {
      return p.cycleCount < 3 ? '(S)' : '(L)';
    }
    return p.mode == PomodoroMode.shortPause ? '(S)' : '(L)';
  }

  @override
  Component build(BuildContext context) {
    final color = p.isRunning
        ? switch (p.mode) {
            PomodoroMode.focus => Colors.green,
            PomodoroMode.shortPause => Colors.yellow,
            PomodoroMode.longPause => Colors.red,
          }
        : const Color(0xff7aa2f7);

    final isFocus = p.mode == PomodoroMode.focus;

    return KeyboardListener(
      autofocus: true,
      onKeyEvent: (key) {
        _handleKey(key);
        return true;
      },
      child: Container(
        color: _mainBg,
        child: Column(
          children: [
            _gap,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: _keysPad,
                  color: _altBg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(4, (i) {
                          final ativo = i == p.cycleCount;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Text(
                              ativo ? '󱓻' : '󱓼',
                              style: TextStyle(
                                color: ativo ? _white.color : _dim.color,
                              ),
                            ),
                          );
                        }),
                      ),
                      _gap,
                      _buildModeRow(color, isFocus),
                    ],
                  ),
                ),
              ],
            ),
            _gap,
            // _buildModeRow(color, isFocus),
            Expanded(
              child: Center(
                child: TimerCounter(seconds: p.secRemaining, color: color),
              ),
            ),
            _ShortcutBar(isRunning: p.isRunning),
            _gap,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      if (p.isRunning) {
        p.tick();
        setState(() {});
      }
    });
  }

  Component _buildModeRow(Color color, bool isFocus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'FOCUS (${p.focusCount})',
          style: TextStyle(color: isFocus ? color : _dim.color),
        ),
        const SizedBox(width: 3),
        Text(
          'PAUSE $_pauseLabel',
          style: TextStyle(color: !isFocus ? color : _dim.color),
        ),
      ],
    );
  }

  void _handleKey(LogicalKey key) {
    if (key == LogicalKey.space) {
      if (p.isRunning) {
        p.pause();
      } else {
        p.start();
      }
      setState(() {});
    } else if (key == LogicalKey.keyR) {
      p.reset();
      setState(() {});
    } else if (key == LogicalKey.keyQ) {
      _shutdown();
    }
  }

  void _shutdown() {
    _timer?.cancel();
    try {
      stdin.echoMode = true;
    } catch (_) {}
    try {
      stdin.lineMode = true;
    } catch (_) {}
    if (Platform.isLinux || Platform.isMacOS) {
      try {
        Process.runSync('stty', ['sane']);
      } catch (_) {}
    }
    shutdownApp();
  }
}
