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
            TextSpan(text: 'Espaço', style: _TuiAppState._w),
            TextSpan(
              text: isRunning ? ' Pausar  ' : ' Iniciar  ',
              style: _TuiAppState._g,
            ),
            TextSpan(text: 'R', style: _TuiAppState._w),
            TextSpan(text: ' Reset  ', style: _TuiAppState._g),
            TextSpan(text: 'Q', style: _TuiAppState._w),
            TextSpan(text: ' Sair', style: _TuiAppState._g),
          ],
        ),
      ),
    );
  }
}

class _TuiAppState extends State<TuiApp> {
  static const _mainBg = Color(0xff1f2335);
  static const _altBg = Color(0xff292e42);
  static const _w = TextStyle(color: Colors.white);
  static const _g = TextStyle(color: Colors.grey);
  static const _dim = TextStyle(color: Color(0x80545c7e));
  static const _gap = SizedBox(height: 1);
  static const _keysPad = EdgeInsets.only(left: 4, right: 4, top: 1, bottom: 1);
  late final Pomodoro p;
  Timer? _timer;

  String get _pauseLabel {
    if (p.mode == PomodoroMode.focus) {
      return p.cycleCount < 3 ? '(S)' : '(L)';
    }
    return p.mode == PomodoroMode.shortPause ? '(S)' : '(L)';
  }

  @override
  Component build(BuildContext context) {
    final cor = p.isRunning
        ? switch (p.mode) {
            PomodoroMode.focus => Colors.green,
            PomodoroMode.shortPause => Colors.yellow,
            PomodoroMode.longPause => Colors.red,
          }
        : const Color(0x7aa2f7);

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
              children: List.generate(4, (i) {
                final ativo = i == p.cycleCount;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Text(
                    ativo ? '󱓻' : '󱓼',
                    style: TextStyle(
                      color: ativo ? Colors.white : Color(0xFF555555),
                    ),
                  ),
                );
              }),
            ),
            Expanded(
              child: Center(
                child: TimerCounter(seconds: p.secRemaining, color: cor),
              ),
            ),
            const SizedBox(height: 1),
            _buildModeRow(cor, isFocus),
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
    p = Pomodoro();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      if (p.isRunning) p.tick();
      setState(() {});
    });
  }

  Component _buildModeRow(Color cor, bool isFocus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'FOCUS (${p.focusCount})',
          style: TextStyle(color: isFocus ? cor : _dim.color),
        ),
        const SizedBox(width: 3),
        Text(
          'PAUSE $_pauseLabel',
          style: TextStyle(color: !isFocus ? cor : _dim.color),
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
    } else if (key == LogicalKey.keyR) {
      p.reset();
    } else if (key == LogicalKey.keyQ) {
      _shutdown();
    }
    setState(() {});
  }

  void _shutdown() {
    _timer?.cancel();
    try {
      stdin.echoMode = true;
    } catch (_) {}
    try {
      stdin.lineMode = true;
    } catch (_) {}
    try {
      if (Platform.isLinux || Platform.isMacOS) {
        Process.runSync('stty', ['sane']);
      }
    } catch (_) {}
    shutdownApp();
  }
}
