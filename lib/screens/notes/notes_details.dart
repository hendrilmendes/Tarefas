// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:tarefas/ai/note_calculator.dart';
import 'package:tarefas/utils/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarefas/widgets/action_fab.dart';
import 'package:tarefas/widgets/settings_group.dart';

class NoteDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> note;
  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final TextEditingController _controller;
  bool _saving = false;
  late NoteCalculation _calc;

  @override
  void initState() {
    super.initState();
    final initialText = widget.note.data()['note'] as String? ?? '';
    _controller = TextEditingController(text: initialText);
    _calc = NoteCalculator.calculate(initialText);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final newCalc = NoteCalculator.calculate(_controller.text);
    if (newCalc.total != _calc.total || newCalc.count != _calc.count) {
      setState(() => _calc = newCalc);
    }
  }

  void _insertTotal() {
    final formatted = _calc.formattedTotal();
    final currentText = _controller.text;
    final totalLabel = 'Total: $formatted';
    final newText = currentText.endsWith('\n')
        ? '$currentText$totalLabel\n'
        : '$currentText\n\n$totalLabel\n';
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.inputNoteError)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.note.id)
          .update({'note': text, 'timestamp': Timestamp.now()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveNote),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(S.current.saveNoteFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await confirmDeleteDialog(
      context,
      title: l10n.confirmDelete,
      message: l10n.confirmDeleteNote,
    );
    if (!confirmed) return;
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.note.id)
          .delete();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.errorDeletingNote('$e'))),
        );
      }
    }
  }

  void _share() {
    SharePlus.instance.share(ShareParams(text: _controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final ts = widget.note.data()['timestamp'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.notesDetails,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          if (ts is Timestamp)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 15, color: scheme.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.lastEdit(_relative(ts)),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_calc.hasValues) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primaryContainer.withOpacity(0.6),
                    scheme.secondaryContainer.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calculate_outlined, size: 20, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.noteTotalDetected,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _calc.formattedTotal(),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${l10n.noteValuesCount(_calc.count)})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _insertTotal,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      l10n.save,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 12,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.inputNote,
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(18),
            ),
            style: const TextStyle(fontSize: 16, height: 1.55),
          ),
        ],
      ),
      floatingActionButtonLocation: InsetFabLocation.aboveSystemBar(context),
      floatingActionButton: ActionFab(
        busy: _saving,
        primary: FabAction(
          icon: Icons.check,
          label: l10n.save,
          onPressed: _save,
        ),
        secondary: [
          FabAction(
            icon: Icons.share_outlined,
            label: l10n.share,
            onPressed: _share,
          ),
          FabAction(
            icon: Icons.delete_outline,
            label: l10n.delete,
            onPressed: _delete,
          ),
        ],
      ),
    );
  }

  String _relative(Timestamp ts) {
    final diff = DateTime.now().difference(ts.toDate());
    final l10n = S.current;
    if (diff.inDays > 0) return l10n.agoDaysLong(diff.inDays);
    if (diff.inHours > 0) return l10n.agoHoursLong(diff.inHours);
    if (diff.inMinutes > 0) return l10n.agoMinutesLong(diff.inMinutes);
    return l10n.justNow;
  }
}
