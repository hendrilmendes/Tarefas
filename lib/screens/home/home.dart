// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/tasks/tasks.dart';
import 'package:tarefas/screens/home/home_details.dart';
import 'package:tarefas/widgets/home/task_dialog.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  User? _user;
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  String loadingMessage = '';
  bool _isLoading = true;

  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _fabSlideAnimation;
  bool _isFabVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _fabSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fabAnimationController.forward();

    _checkUser();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScrollPosition = _scrollController.position.pixels;
    final scrollDelta = currentScrollPosition - _lastScrollPosition;

    if (scrollDelta.abs() > 5) {
      if (scrollDelta > 0 && _isFabVisible) {
        _hideFab();
      } else if (scrollDelta < 0 && !_isFabVisible) {
        _showFab();
      }
    }

    _lastScrollPosition = currentScrollPosition;
  }

  void _showFab() {
    if (!_isFabVisible) {
      if (mounted) {
        setState(() {
          _isFabVisible = true;
        });
      }
      _fabAnimationController.forward();
    }
  }

  void _hideFab() {
    if (_isFabVisible) {
      if (mounted) {
        setState(() {
          _isFabVisible = false;
        });
      }
      _fabAnimationController.reverse();
    }
  }

  void _checkUser() async {
    final user = await _authService.currentUser();
    if (!mounted) return;

    setState(() {
      _user = user;
    });

    if (_user != null) {
      if (_pendingTasks.isEmpty && _completedTasks.isEmpty) {
        await _loadTasks();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (kDebugMode) {
        print('Usuário nulo ao carregar tarefas.');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTasks() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      setState(() {
        _isLoading = true;
      });

      if (_user != null) {
        final querySnapshot = await tasksCollection
            .where('userId', isEqualTo: _user!.uid)
            .get();

        if (!mounted) return;

        final pendingTasks = <Task>[];
        final completedTasks = <Task>[];

        for (var doc in querySnapshot.docs) {
          final task = Task(
            title: doc['title'],
            completed: doc['completed'],
            id: doc.id,
            dateTime: (doc['dateTime'] as Timestamp).toDate(),
          );

          if (task.completed) {
            completedTasks.add(task);
          } else {
            pendingTasks.add(task);
          }
        }

        if (mounted) {
          setState(() {
            _pendingTasks = pendingTasks;
            _completedTasks = completedTasks;
            loadingMessage = '';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loadingMessage = 'Erro ao carregar as tarefas.';
          });
        }
      }
    } catch (e) {
      setState(() {
        loadingMessage = 'Erro ao carregar as tarefas.';
      });
      if (kDebugMode) {
        print('Erro ao carregar as tarefas: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget buildTaskItem(Task task, bool isPending) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      child: GestureDetector(
        onLongPress: () => _removeTask(task),
        child: ClipRRect(
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeDetailsScreen(task: task),
                      ),
                    );
                    if (result == true) await _loadTasks();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _updateTaskCompletion(task, !task.completed),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isPending
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.6)
                                    : Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              color: task.completed
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: task.completed
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      key: const ValueKey('checked'),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('unchecked'),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.completed
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withOpacity(0.6)
                                      : Theme.of(context).colorScheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                              if (task.dateTime != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy • HH:mm',
                                  ).format(task.dateTime!),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addTask() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations == null || _user == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => const TaskDialog(),
    );

    if (result != null) {
      final String newTaskTitle = result['title'];
      final DateTime taskDateTime = result['dateTime'];

      try {
        final newDocRef = await tasksCollection.add({
          'title': newTaskTitle,
          'completed': false,
          'userId': _user!.uid,
          'dateTime': taskDateTime,
        });

        final notificationId = newDocRef.id.hashCode;
        const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Lembretes de Tarefas',
            icon: '@drawable/ic_notification',
            channelDescription: 'Alertas de tarefas agendadas',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(),
        );

        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          newTaskTitle,
          appLocalizations.notificationTask,
          tz.TZDateTime.from(taskDateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );

        await _loadTasks();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao salvar a tarefa: $e")),
          );
        }
      }
    }
  }

  void _updateTaskCompletion(Task task, bool completed) async {
    if (_user == null) {
      return;
    }

    setState(() {
      task.completed = completed;
      if (completed) {
        _pendingTasks.removeWhere((t) => t.id == task.id);
        _completedTasks.add(task);
      } else {
        _completedTasks.removeWhere((t) => t.id == task.id);
        _pendingTasks.add(task);
      }
    });

    try {
      await tasksCollection.doc(task.id).update({'completed': completed});

      if (kDebugMode) {
        print(
          'Estado de conclusão da tarefa ${task.id} atualizado com sucesso.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar estado de conclusão da tarefa: $e');
      }

      if (mounted) {
        setState(() {
          task.completed = !completed;
          if (!completed) {
            _pendingTasks.add(task);
            _completedTasks.removeWhere((t) => t.id == task.id);
          } else {
            _completedTasks.add(task);
            _pendingTasks.removeWhere((t) => t.id == task.id);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao atualizar a tarefa. Tente novamente.'),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao atualizar a tarefa. Tente novamente.'),
          ),
        );
      }
    }
  }

  void _removeTask(Task task) async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations == null || _user == null) {
      return;
    }
    final confirmed =
        await showDialog<bool>(
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
                              CupertinoIcons.delete,
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
                            appLocalizations.confirmDeleteTask,
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
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(appLocalizations.cancel),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
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
        ) ??
        false;

    if (confirmed == true) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.cancel(task.id.hashCode);

      try {
        await tasksCollection.doc(task.id).delete();

        if (mounted) {
          setState(() {
            if (task.completed) {
              _completedTasks.removeWhere((t) => t.id == task.id);
            } else {
              _pendingTasks.removeWhere((t) => t.id == task.id);
            }
          });
        }

        if (kDebugMode) {
          print('Tarefa removida do Firestore: ${task.id}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao apagar tarefa: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao remover a tarefa: $e')),
          );
        }
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    const double bottomNavHeight = 80.0;
    final double fabBottomMargin = bottomNavHeight + 40.0;

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
                appLocalizations.home,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
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
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height:
                              kToolbarHeight +
                              MediaQuery.of(context).padding.top,
                        ),
                      ),
                      if (_pendingTasks.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildSectionHeader(appLocalizations.pendants),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) =>
                              buildTaskItem(_pendingTasks[index], true),
                          childCount: _pendingTasks.length,
                        ),
                      ),
                      if (_completedTasks.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildSectionHeader(
                            appLocalizations.completed,
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) =>
                              buildTaskItem(_completedTasks[index], false),
                          childCount: _completedTasks.length,
                        ),
                      ),
                      if (_pendingTasks.isEmpty && _completedTasks.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colors.primary.withOpacity(0.1),
                                          colors.primary.withOpacity(0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.primary.withOpacity(0.2),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.primary.withOpacity(
                                            0.1,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.task_alt_outlined,
                                      size: 64,
                                      color: colors.primary.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    AppLocalizations.of(context)!.noTask,
                                    style: TextStyle(
                                      color: colors.onSurface.withOpacity(0.8),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLocalizations.of(context)!.addTasks,
                                    style: TextStyle(
                                      color: colors.onSurface.withOpacity(0.5),
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 140)),
                    ],
                  ),
            Positioned(
              right: 20,
              bottom: fabBottomMargin,
              child: SlideTransition(
                position: _fabSlideAnimation,
                child: AnimatedBuilder(
                  animation: _fabAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fabAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _addTask,
                                  child: Icon(
                                    CupertinoIcons.add,
                                    color: colors.onPrimary,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
