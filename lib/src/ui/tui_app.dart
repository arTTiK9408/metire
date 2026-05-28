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
    if (key == LogicalKey.space) {
      svc.toggle();
    } else if (key == LogicalKey.keyR) {
      svc.restart();
    } else if (key == LogicalKey.keyS) {
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

  Component _buildRenameDialog() {
    return KeyboardListener(
      autofocus: true,
      onKeyEvent: (key) {
        if (key == LogicalKey.escape) {
          _isRenaming = false;
          setState(() {});
          return true;
        }
        return false;
      },
      child: Center(
        child: Container(
          width: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: BoxBorder.all()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Novo nome da sessão:'),
              const SizedBox(height: 1),
              TextField(
                focused: true,
                onSubmitted: (value) {
                  svc.renameSession(value);
                  _isRenaming = false;
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Component build(BuildContext context) {
    if (_isRenaming) return _buildRenameDialog();

    final cor = switch (svc.mode) {
      PomodoroMode.focus => Colors.green,
      PomodoroMode.shortPause => Colors.yellow,
      PomodoroMode.longPause => Colors.blue,
    };

    final rotulo = switch (svc.mode) {
      PomodoroMode.focus => 'FOCUS',
      PomodoroMode.shortPause => 'SHORT PAUSE',
      PomodoroMode.longPause => 'LONG PAUSE',
    };

    return KeyboardListener(
      autofocus: true,
      onKeyEvent: (key) {
        _handleKey(key);
        return true;
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'POMODORO',
                style: TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(svc.sessionName, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                _formatTime(svc.remaining),
                style: TextStyle(color: cor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 1),
              Text(
                '${svc.isRunning ? "⏵" : "⏸"} $rotulo',
                style: TextStyle(color: cor),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ciclo ${svc.cycleCount + 1}/4'),
                  const Text('  │  '),
                  Text('Focos: ${svc.focusCount}'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '[ Espaço: Iniciar  R: Reset  S: Renomear  Q: Sair ]',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
