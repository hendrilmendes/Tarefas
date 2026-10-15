// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:tarefas/ai/note_calculator.dart';
import 'package:tarefas/utils/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/screens/notes/notes_details.dart';
import 'package:tarefas/widgets/action_fab.dart';
import 'package:tarefas/widgets/orb_glass.dart';
import 'package:tarefas/widgets/settings_group.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late final Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _stream = uid != null
        ? FirebaseFirestore.instance
            .collection('notes')
            .where('userId', isEqualTo: uid)
            .snapshots()
        : null;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final text = _noteController.text.trim();
      if (text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.inputNoteError)),
          );
        }
        return;
      }
      await FirebaseFirestore.instance.collection('notes').add({
        'userId': user.uid,
        'note': text,
        'timestamp': Timestamp.now(),
      });
      _noteController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveNote),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errosaveNote)),
        );
      }
    }
  }

  Future<void> _showAddNoteDialog() async {
    final l10n = AppLocalizations.of(context)!;
    _noteController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.newNote),
        content: TextField(
          controller: _noteController,
          autofocus: true,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: l10n.inputNote,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              _saveNote();
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(AppLocalizations.of(context)!.notesTitle, style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchNotesHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withOpacity(0.6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return _ErrorState(onRetry: () => setState(() {}));
          }
          final docs = (snapshot.data?.docs ?? [])
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
              .where((d) {
            if (_query.trim().isEmpty) return true;
            final note = (d.data()['note'] as String? ?? '').toLowerCase();
            return note.contains(_query.toLowerCase());
          }).toList();

          docs.sort((a, b) {
            final ta = a.data()['timestamp'];
            final tb = b.data()['timestamp'];
            final da = ta is Timestamp ? ta.toDate() : DateTime(2000);
            final db = tb is Timestamp ? tb.toDate() : DateTime(2000);
            return db.compareTo(da);
          });

          if ((snapshot.data?.docs ?? []).isEmpty) return _EmptyState(onAdd: _showAddNoteDialog);

          return CustomScrollView(
            slivers: [
              if (docs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(AppLocalizations.of(context)!.noNotesFor(_query.trim()),
                          style: TextStyle(color: scheme.onSurface.withOpacity(0.6))),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 160),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.92,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => NoteCard(note: docs[i]),
                      childCount: docs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: InsetFabLocation.aboveNavBar(context),
      floatingActionButton: GlassFab(
        onPressed: _showAddNoteDialog,
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.note_outlined, size: 52, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(l10n.noNotes, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(l10n.addNotes,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurface.withOpacity(0.6), height: 1.5)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.createNote)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 52, color: scheme.error),
            const SizedBox(height: 16),
            Text(l10n.errorLoadNotes, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> note;
  const NoteCard({super.key, required this.note});

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await confirmDeleteDialog(
      context,
      title: l10n.confirmDelete,
      message: l10n.confirmDeleteNote,
    );
    if (confirmed) {
      try {
        await FirebaseFirestore.instance.collection('notes').doc(note.id).delete();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorDeletingNote('$e'))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    final data = note.data();
    final noteText = data['note'] as String? ?? '';
    final calc = NoteCalculator.calculate(noteText);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isLight
            ? scheme.surface.withOpacity(0.70)
            : scheme.surfaceContainerHighest.withOpacity(0.35),
        border: Border.all(
          color: isLight
              ? Colors.white.withOpacity(0.8)
              : Colors.white.withOpacity(0.12),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.04 : 0.20),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
          ),
          onLongPress: () => _confirmDelete(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.note_outlined, size: 16, color: scheme.primary),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => _confirmDelete(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.more_horiz, size: 18, color: scheme.onSurface.withOpacity(0.45)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  noteText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (calc.hasValues)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calculate_outlined, size: 13, color: scheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            calc.formattedTotal(),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (data['timestamp'] != null)
                Text(
                  _relative(data['timestamp'] as Timestamp),
                  style: TextStyle(fontSize: 11.5, color: scheme.onSurface.withOpacity(0.5)),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

  String _relative(Timestamp ts) {
    final diff = DateTime.now().difference(ts.toDate());
    final l10n = S.current;
    if (diff.inDays > 0) return l10n.agoDays(diff.inDays);
    if (diff.inHours > 0) return l10n.agoHours(diff.inHours);
    if (diff.inMinutes > 0) return l10n.agoMinutes(diff.inMinutes);
    return l10n.justNow;
  }
}
