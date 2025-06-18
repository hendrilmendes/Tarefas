// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class NoteDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> note;

  const NoteDetailPage({super.key, required this.note});

  @override
  // ignore: library_private_types_in_public_api
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TextEditingController _noteController = TextEditingController();
  int _selectedAction = 1; // Save action selected by default

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.note['note'];
  }

  void _saveNote() async {
    final newNoteText = _noteController.text.trim();
    if (newNoteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.inputNoteError)),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.note.id)
          .update({'note': newNoteText, 'timestamp': Timestamp.now()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveNote)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao salvar a nota. Tente novamente.')),
        );
      }
    }
  }

  Future<void> _deleteNote() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations == null) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 32,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        appLocalizations.confirmDelete,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appLocalizations.confirmDeleteNote,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(appLocalizations.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onError,
                              ),
                              child: Text(appLocalizations.delete),
                            ),
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
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.note.id)
          .delete();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao deletar a nota: $e')));
      }
    }
  }

  void _shareNote() {
    SharePlus.instance.share(ShareParams(text: widget.note['note']));
  }

  void _onActionSelected(int index) {
    setState(() {
      _selectedAction = index;
    });

    switch (index) {
      case 0:
        _deleteNote();
        break;
      case 1:
        _saveNote();
        break;
      case 2:
        _shareNote();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AppBar(
              backgroundColor: colors.surface.withOpacity(0.8),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: Text(
                AppLocalizations.of(context)!.notesDetails,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: colors.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.surface, colors.surface.withOpacity(0.95)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        AppLocalizations.of(context)!.inputNote,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _noteController,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colors.onSurface,
                              height: 1.5,
                            ),
                            maxLines: null,
                            minLines: 10,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(20),
                              hintText: AppLocalizations.of(context)!.inputNote,
                              hintStyle: TextStyle(
                                color: colors.onSurface.withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (widget.note['timestamp'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.primary.withOpacity(0.1),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: colors.primary.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Última edição: ${_formatTimestamp(widget.note['timestamp'])}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.primary.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GlassNavBar(
                  selectedIndex: _selectedAction,
                  onItemSelected: _onActionSelected,
                  items: [
                    GlassNavBarItem(
                      icon: CupertinoIcons.delete,
                      label: AppLocalizations.of(context)!.delete,
                    ),
                    GlassNavBarItem(
                      icon: CupertinoIcons.checkmark_alt_circle,
                      label: AppLocalizations.of(context)!.save,
                    ),
                    GlassNavBarItem(
                      icon: CupertinoIcons.share,
                      label: AppLocalizations.of(context)!.share,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Desconhecido';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return 'Desconhecido';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}

class GlassNavBarItem {
  final IconData icon;
  final String label;

  GlassNavBarItem({required this.icon, required this.label});
}

class GlassNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<GlassNavBarItem> items;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar> {
  final Duration _animationDuration = const Duration(milliseconds: 200);
  final Curve _animationCurve = Curves.easeInOutQuart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.secondary;
    final unselectedColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.items.asMap().entries.map((entry) {
                int index = entry.key;
                GlassNavBarItem item = entry.value;
                bool isSelected = index == widget.selectedIndex;

                return GestureDetector(
                  onTap: () => widget.onItemSelected(index),
                  child: AnimatedContainer(
                    duration: _animationDuration,
                    curve: _animationCurve,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 20.0 : 12.0,
                      vertical: 8.0,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: selectedColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(100.0),
                            boxShadow: [
                              BoxShadow(
                                color: selectedColor.withOpacity(0.1),
                                blurRadius: 10.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? selectedColor : unselectedColor,
                          size: isSelected ? 28.0 : 24.0,
                        ),
                        AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: _animationDuration,
                          curve: _animationCurve,
                          child: AnimatedSize(
                            duration: _animationDuration,
                            curve: _animationCurve,
                            alignment: Alignment.center,
                            child: isSelected
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        color: selectedColor,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
