// ignore_for_file: deprecated_member_use
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:tarefas/ai/assistant_service.dart';
import 'package:tarefas/ai/smart_parser.dart';
import 'package:tarefas/widgets/orb_glass.dart';

class QuickAddResult {
  final String title;
  final DateTime? dateTime;
  final int priority;
  final String? project;
  final List<String> suggestedSteps;

  QuickAddResult({
    required this.title,
    this.dateTime,
    this.priority = 4,
    this.project,
    this.suggestedSteps = const [],
  });
}

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  static Future<QuickAddResult?> show(BuildContext context) {
    return showModalBottomSheet<QuickAddResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickAddSheet(),
    );
  }

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  ParsedTask _parsed = const ParsedTask(title: '');
  int _priorityOverride = 0;
  DateTime? _dateOverride;
  bool _hasDateOverride = false;

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _parsed = SmartParser.parse(_controller.text);
    });
  }

  int get _priority =>
      _priorityOverride == 0 ? _parsed.priority : _priorityOverride;
  DateTime? get _date => _hasDateOverride ? _dateOverride : _parsed.dateTime;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 2),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date ?? now),
    );
    if (!mounted) return;
    setState(() {
      if (t != null) {
        _dateOverride = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      } else {
        _dateOverride = DateTime(d.year, d.month, d.day, 9, 0);
      }
      _hasDateOverride = true;
    });
  }

  void _submit() {
    final title = _parsed.title.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.quickAddEmpty)),
      );
      return;
    }
    Navigator.of(context).pop(
      QuickAddResult(
        title: title,
        dateTime: _date ?? DateTime.now().add(const Duration(hours: 2)),
        priority: _priority,
        project: _parsed.project,
        suggestedSteps: AssistantService.breakdown(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final navBarPadding = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPadding = viewInsetsBottom > 0
        ? 14.0
        : (navBarPadding > 0 ? navBarPadding + 14.0 : 20.0);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: OrbGlass(
          filter: OrbGlass.medBlur,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: scheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.quickAddTitle,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _controller,
                    focusNode: _focus,
                    minLines: 1,
                    maxLines: 3,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.quickAddHint,
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest.withOpacity(
                        0.6,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _controller.text.trim().isEmpty
                        ? Text(
                            AppLocalizations.of(context)!.quickAddTip,
                            key: const ValueKey('hint'),
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurface.withOpacity(0.55),
                            ),
                          )
                        : Wrap(
                            key: const ValueKey('preview'),
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _PreviewChip(
                                icon: Icons.schedule,
                                label: _date != null
                                    ? DateFormat.MMMEd(
                                        AppLocalizations.of(context)!
                                            .localeName,
                                      ).add_Hm().format(_date!)
                                    : AppLocalizations.of(context)!
                                          .noDateSuggestToday,
                                onTap: _pickDate,
                              ),
                              _PreviewChip(
                                icon: Icons.flag_outlined,
                                label:
                                    'P$_priority • ${SmartParser.priorityLabel(_priority)}',
                              ),
                              if ((_parsed.project ?? '').isNotEmpty)
                                _PreviewChip(
                                  icon: Icons.tag,
                                  label: '#${_parsed.project}',
                                ),
                              if (_parsed.title.isNotEmpty)
                                _PreviewChip(
                                  icon: Icons.list,
                                  label: AppLocalizations.of(context)!
                                      .suggestedSteps(
                                        AssistantService.breakdown(
                                          _parsed.title,
                                        ).length,
                                      ),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.priorityColon,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final p in [1, 2, 3, 4])
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text('P$p'),
                                    selected: _priority == p,
                                    shape: const StadiumBorder(),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (_) =>
                                        setState(() => _priorityOverride = p),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        onPressed: _submit,
                        icon: const Icon(Icons.arrow_upward, size: 18),
                        label: Text(AppLocalizations.of(context)!.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _PreviewChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: scheme.onPrimaryContainer),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              Icon(Icons.edit, size: 12, color: scheme.onPrimaryContainer),
            ],
          ],
        ),
      ),
    );
  }
}
