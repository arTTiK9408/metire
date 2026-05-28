import 'dart:async';
import 'dart:io' show stdin, Process, Platform;
import 'package:nocterm/nocterm.dart';
import 'package:metire/src/services/pomodoro_service.dart';
import 'package:metire/src/models/pomodoro.dart';
import 'package:metire/src/models/session.dart';

class TuiApp extends StatefulComponent {
  const TuiApp({super.key});

  @override
  State<TuiApp> createState() => _TuiAppState();
}

class _TuiAppState extends State<TuiApp> {
  late final PomodoroService svc;
  Timer? _timer;
  bool _isRenaming = false;
  final _renameController = TextEditingController();

  static const _mainBg = Color(0x1f2335);
  static const _altBg = Color(0x292e42);
  static const _blueFg = Color(0x7aa2f7);
  static const _w = TextStyle(color: Colors.white);
  static const _g = TextStyle(color: Colors.grey);
  static const _dim = TextStyle(color: Color(0xFF555555));
  static const _gap = SizedBox(height: 1);
  static const _infoPad = EdgeInsets.only(left: 2, right: 2, top: 1, bottom: 1);
  static const _shortcutPad = EdgeInsets.only(
    left: 4,
    right: 4,
    top: 1,
    bottom: 1,
  );

  @override
  void initState() {
    svc = PomodoroService(
      pomodoro: Pomodoro(),
      session: Session(name: 'Unnamed Session'),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      if (svc.isRunning) svc.tick();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _renameController.dispose();
    super.dispose();
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

  void _handleKey(LogicalKey key) {
    if (_isRenaming) {
      if (key == LogicalKey.escape) {
        _isRenaming = false;
        setState(() {});
      }
      return;
    }
    if (key == LogicalKey.space) {
      svc.toggle();
    } else if (key == LogicalKey.keyR) {
      svc.restart();
    } else if (key == LogicalKey.keyS) {
      _renameController.text = svc.sessionName;
      _isRenaming = true;
    } else if (key == LogicalKey.keyQ) {
      _shutdown();
    }
    setState(() {});
  }

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  String get _pauseLabel {
    if (svc.mode == PomodoroMode.focus) {
      return svc.cycleCount < 3 ? '(S)' : '(L)';
    }
    return svc.mode == PomodoroMode.shortPause ? '(S)' : '(L)';
  }

  Component _buildModeRow(Color cor, bool isFocus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${isFocus ? "◉" : "○"} FOCUS',
          style: TextStyle(color: isFocus ? cor : _dim.color),
        ),
        const SizedBox(width: 4),
        Text(
          '${!isFocus ? "◉" : "○"} PAUSE $_pauseLabel',
          style: TextStyle(color: !isFocus ? cor : _dim.color),
        ),
      ],
    );
  }

  Component _buildInfoPanel() {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1),
      color: _mainBg,
      padding: _infoPad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 3,
            child: Align(
              alignment: Alignment.topLeft,
              child: _isRenaming
                  ? TextField(
                      controller: _renameController,
                      focused: true,
                      height: 1,
                      onKeyEvent: (event) {
                        if (event.logicalKey == LogicalKey.escape) {
                          _isRenaming = false;
                          setState(() {});
                          return true;
                        }
                        return false;
                      },
                      onSubmitted: (value) {
                        svc.renameSession(value);
                        _isRenaming = false;
                        setState(() {});
                      },
                    )
                  : Text(svc.sessionName, style: _w),
            ),
          ),
          Text('Ciclo ${svc.cycleCount + 1}/4', style: _w),
          Text('Focos: ${svc.focusCount}', style: _w),
        ],
      ),
    );
  }

  @override
  Component build(BuildContext context) {
    final cor = switch (svc.mode) {
      PomodoroMode.focus => Colors.green,
      PomodoroMode.shortPause => Colors.yellow,
      PomodoroMode.longPause => Colors.blue,
    };

    final isFocus = svc.mode == PomodoroMode.focus;

    return KeyboardListener(
      autofocus: true,
      onKeyEvent: (key) {
        _handleKey(key);
        return true;
      },
      child: Container(
        color: _mainBg,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: _altBg,
                child: Column(
                  children: [
                    _gap,
                    const Text(
                      'METIRE TUI',
                      style: TextStyle(
                        color: _blueFg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _gap,
                    _buildInfoPanel(),
                    const Spacer(),
                    const Text('v0.1.0', style: _g),
                    _gap,
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    _formatTime(svc.remaining),
                    style: TextStyle(color: cor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 1),
                  _buildModeRow(cor, isFocus),
                  const Spacer(),
                  const _ShortcutBar(),
                  _gap,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutBar extends StatelessComponent {
  const _ShortcutBar();

  @override
  Component build(BuildContext context) {
    return Container(
      padding: _TuiAppState._shortcutPad,
      color: _TuiAppState._altBg,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: 'Espaço', style: _TuiAppState._w),
            TextSpan(text: ': Iniciar  ', style: _TuiAppState._g),
            TextSpan(text: 'R', style: _TuiAppState._w),
            TextSpan(text: ': Reset  ', style: _TuiAppState._g),
            TextSpan(text: 'S', style: _TuiAppState._w),
            TextSpan(text: ': Renomear  ', style: _TuiAppState._g),
            TextSpan(text: 'Q', style: _TuiAppState._w),
            TextSpan(text: ': Sair', style: _TuiAppState._g),
          ],
        ),
      ),
    );
  }
}
