// ignore_for_file: deprecated_member_use
import 'package:tarefas/utils/app_strings.dart';
import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:tarefas/widgets/orb_glass.dart';
import 'package:tarefas/l10n/app_localizations.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const focusSecs = 25 * 60;
  static const breakSecs = 5 * 60;

  int _remaining = focusSecs;
  bool _running = false;
  bool _isBreak = false;
  int _cycles = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remaining <= 1) {
          t.cancel();
          setState(() {
            if (!_isBreak) {
              _cycles++;
              _isBreak = true;
              _remaining = breakSecs;
            } else {
              _isBreak = false;
              _remaining = focusSecs;
            }
            _running = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_isBreak ? S.current.focusDone : S.current.breakDone)),
            );
          }
        } else {
          setState(() => _remaining--);
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _isBreak = false;
      _remaining = focusSecs;
    });
  }

  String get _label {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = _isBreak ? breakSecs : focusSecs;
    final progress = 1 - (_remaining / total);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.focus, style: TextStyle(fontWeight: FontWeight.w800)), centerTitle: true),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (_isBreak ? Colors.green : scheme.primary).withOpacity(0.14),
              scheme.surface,
            ],
            stops: const [0.0, 0.55],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: (_isBreak ? Colors.green : scheme.primary).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_isBreak ? AppLocalizations.of(context)!.breakLabel : AppLocalizations.of(context)!.focusCycles(_cycles),
                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 230,
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 14,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                  Text(_label, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, letterSpacing: -1)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(_isBreak ? AppLocalizations.of(context)!.breakTip : AppLocalizations.of(context)!.focusTip,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 28),

            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: OrbGlass(
                filter: OrbGlass.highBlur,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: orbGlassDecoration(
                    Theme.of(context),
                    borderRadius: BorderRadius.circular(28),
                    hero: true,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton.icon(
                        onPressed: _toggle,
                        icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                        label: Text(_running ? AppLocalizations.of(context)!.pause : AppLocalizations.of(context)!.start),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: Text(AppLocalizations.of(context)!.reset)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
