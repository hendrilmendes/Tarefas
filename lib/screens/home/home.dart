// ignore_for_file: deprecated_member_use
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/utils/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tarefas/ai/assistant_service.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/screens/focus/focus_screen.dart';
import 'package:tarefas/screens/home/home_details.dart';
import 'package:tarefas/tasks/tasks.dart';
import 'package:tarefas/widgets/dashboard_cards.dart';
import 'package:tarefas/widgets/action_fab.dart';
import 'package:tarefas/widgets/orb_glass.dart';
import 'package:tarefas/widgets/quick_add_sheet.dart';
import 'package:tarefas/widgets/task_tile.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  int _filter = HomeFilter.all;
  String _query = '';

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkUser() async {
    final user = await _authService.currentUser();
    if (mounted) setState(() => _user = user);
  }

  List<Task> _visibleTasks(List<Task> all) {
    var list = applyFilter(all, _filter);
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                (t.project ?? '').toLowerCase().contains(q),
          )
          .toList();
    }

    list.sort((a, b) {
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      final now = DateTime.now();
      final sa = AssistantService.score(a, now);
      final sb = AssistantService.score(b, now);
      if (sa != sb) return sa.compareTo(sb);
      final da = a.dateTime ?? DateTime(2100);
      final db = b.dateTime ?? DateTime(2100);
      return da.compareTo(db);
    });
    return list;
  }

  Future<void> _quickAdd() async {
    if (_user == null) return;
    final result = await QuickAddSheet.show(context);
    if (result == null || !mounted) return;
    try {
      final docRef = await tasksCollection.add({
        'title': result.title,
        'completed': false,
        'userId': _user!.uid,
        'dateTime': result.dateTime,
        'priority': result.priority,
        if (result.project != null) 'project': result.project,
        if (result.suggestedSteps.isNotEmpty) 'subtasks': result.suggestedSteps,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _scheduleNotification(docRef.id, result.title, result.dateTime);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.current.taskCreatedByAi(
                result.title,
                result.suggestedSteps.length,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(S.current.errorSaving('$e'))));
      }
    }
  }

  Future<void> _scheduleNotification(
    String docId,
    String title,
    DateTime? when,
  ) async {
    if (when == null || when.isBefore(DateTime.now())) return;
    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          S.current.notificationChannelName,
          channelDescription: S.current.notificationChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      await FlutterLocalNotificationsPlugin().zonedSchedule(
        id: docId.hashCode,
        title: title,
        body: S.current.notificationTask,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {}
  }

  Future<void> _toggle(Task task) async {
    try {
      await tasksCollection.doc(task.id).update({'completed': !task.completed});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.updateFailed)),
        );
      }
    }
  }

  Future<void> _delete(Task task) async {
    try {
      await FlutterLocalNotificationsPlugin().cancel(id: task.id.hashCode);
      await tasksCollection.doc(task.id).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(S.current.errorRemoving('$e'))));
      }
    }
  }

  void _openDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomeDetailsScreen(task: task)),
    );
  }

  void _openFocus() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FocusScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final userName = _user?.displayName ?? _user?.email?.split('@').first ?? '';

    return Scaffold(
      backgroundColor: scheme.surface,
      body: StreamBuilder<QuerySnapshot>(
        stream: _user != null
            ? tasksCollection.where('userId', isEqualTo: _user!.uid).snapshots()
            : null,
        builder: (context, snapshot) {
          final all = (snapshot.data?.docs ?? []).map(Task.fromDoc).toList();
          final visible = _visibleTasks(all);
          final briefing = AssistantService.briefing(
            all,
            userName.split(' ').first,
          );
          final stats = AssistantService.stats(all);
          return CustomScrollView(
            slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 68,
                  titleSpacing: 16,
                  title: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            scheme.brightness == Brightness.light ? 0.10 : 0.35,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: OrbGlass(
                        filter: OrbGlass.navBlur,
                        child: Container(
                          decoration: BoxDecoration(
                            color: (scheme.brightness == Brightness.light
                                    ? Colors.white
                                    : scheme.surface)
                                .withOpacity(
                              scheme.brightness == Brightness.light ? 0.70 : 0.45,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: scheme.brightness == Brightness.light
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.14),
                              width: 1.1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchTasksHint,
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
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: GreetingHeader(
                    userName: userName,
                    now: DateTime.now(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AiBriefingCard(
                    briefing: briefing,
                    onFocusTap: briefing.focusTask != null
                        ? () => _openDetails(briefing.focusTask!)
                        : null,
                  ),
                ),
                SliverToBoxAdapter(
                  child: StatsRow(stats: stats, onFocusTap: _openFocus),
                ),
                SliverToBoxAdapter(
                  child: _FilterBar(
                    filter: _filter,
                    onChange: (f) => setState(() => _filter = f),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  )
                else if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: _EmptyState(filter: _filter),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final task = visible[i];
                      return TaskTile(
                        task: task,
                        onToggle: () => _toggle(task),
                        onTap: () => _openDetails(task),
                        onDelete: () => _delete(task),

                        featured: i == 0 && !task.completed,
                      );
                    }, childCount: visible.length),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 160)),
              ],
            );
        },
      ),
      floatingActionButtonLocation: InsetFabLocation.aboveNavBar(context),
      floatingActionButton: GlassFab(
        onPressed: _quickAdd,
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final int filter;
  final ValueChanged<int> onChange;
  const _FilterBar({required this.filter, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (HomeFilter.all, l10n.filterAll, Icons.inbox_outlined),
      (HomeFilter.today, l10n.filterMyDay, Icons.today_outlined),
      (HomeFilter.upcoming, l10n.filterUpcoming, Icons.upcoming_outlined),
      (HomeFilter.overdue, l10n.overdue, Icons.warning_amber_rounded),
      (HomeFilter.done, l10n.filterDone, Icons.check_circle_outline),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final (value, label, icon) = items[i];
          final selected = filter == value;
          return FilterChip(
            selected: selected,
            showCheckmark: false,
            shape: const StadiumBorder(),
            visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            avatar: Icon(
              icon,
              size: 15,
              color: selected
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : null,
            ),
            label: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            onSelected: (_) => onChange(value),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final msg = filter == HomeFilter.done
        ? AppLocalizations.of(context)!.emptyDone
        : AppLocalizations.of(context)!.emptyTasks;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_outlined,
              size: 52,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.65),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
