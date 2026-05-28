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
  static const _secondaryBg = Color(0x292e42);
  static const _thirdBg = Color(0x414868);
  static const _blueFg = Color(0x7aa2f7);

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
                color: _secondaryBg,
                child: Column(
                  children: [
                    const SizedBox(height: 1),
                    const Text(
                      'METIRE TUI',
                      style: TextStyle(
                        color: _blueFg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Container(
                      child: Column(
                        children: [
                          if (_isRenaming)
                            TextField(
                              controller: _renameController,
                              focused: true,
                              onSubmitted: (value) {
                                svc.renameSession(value);
                                _isRenaming = false;
                                setState(() {});
                              },
                            )
                          else
                            Text(
                              svc.sessionName,
                              style: const TextStyle(color: Colors.white),
                            ),
                          const SizedBox(height: 1),
                          Text(
                            'Ciclo ${svc.cycleCount + 1}/4',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Focos: ${svc.focusCount}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      color: _thirdBg,
                      padding: EdgeInsets.only(
                        left: 2,
                        right: 2,
                        top: 1,
                        bottom: 1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Container(
                      padding: EdgeInsets.only(left: 1, right: 1),
                      child: const Divider(
                        color: _mainBg,
                        style: DividerStyle.bold,
                      ),
                    ),
                    const Spacer(),
                    const Text('v0.1.0', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 1),
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
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${isFocus ? "◉" : "○"} FOCUS',
                        style: TextStyle(
                          color: isFocus ? cor : Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${!isFocus ? "◉" : "○"} PAUSE $_pauseLabel',
                        style: TextStyle(
                          color: !isFocus ? cor : Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 4,
                      right: 4,
                      top: 1,
                      bottom: 1,
                    ),
                    color: _secondaryBg,
                    child: const Text(
                      'Espaço: Iniciar  R: Reset  S: Renomear  Q: Sair',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
