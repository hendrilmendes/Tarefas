// ignore_for_file: deprecated_member_use
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/screens/calendar/calendar_screen.dart';
import 'package:tarefas/screens/settings/settings.dart';
import 'package:tarefas/screens/home/home.dart';
import 'package:tarefas/screens/notes/notes.dart';
import 'package:tarefas/widgets/orb_glass.dart';

class BottomNavigationContainer extends StatefulWidget {
  const BottomNavigationContainer({super.key});

  @override
  State<BottomNavigationContainer> createState() =>
      _BottomNavigationContainerState();
}

class _BottomNavigationContainerState extends State<BottomNavigationContainer> {
  int _currentIndex = 0;
  bool _compact = false;
  late final PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    NotesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final compact = notification.direction == ScrollDirection.reverse;
      if (compact != _compact && mounted) setState(() => _compact = compact);
    } else if (notification is ScrollEndNotification) {
      if (_compact && mounted) setState(() => _compact = false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      _Dest(
        CupertinoIcons.checkmark_circle,
        CupertinoIcons.checkmark_circle_fill,
        l10n!.home,
      ),
      _Dest(
        CupertinoIcons.calendar,
        CupertinoIcons.calendar_today,
        l10n.tabAgenda,
      ),
      _Dest(CupertinoIcons.doc_text, CupertinoIcons.doc_text_fill, l10n.notes),
      _Dest(CupertinoIcons.gear, CupertinoIcons.gear_solid, l10n.settings),
    ];

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          children: _screens,
        ),
      ),
      bottomNavigationBar: FloatingGlassBar(
        height: _compact ? 54 : 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: destinations.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            final selected = i == _currentIndex;
            return Expanded(
              child: _GlassNavItem(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: d.label,
                selected: selected,
                showLabel: !_compact,
                onTap: () => _onTabTapped(i),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Dest {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Dest(this.icon, this.selectedIcon, this.label);
}

class _GlassNavItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  State<_GlassNavItem> createState() => _GlassNavItemState();
}

class _GlassNavItemState extends State<_GlassNavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.selected
        ? theme.colorScheme.primary
        : theme.textTheme.bodyLarge?.color?.withOpacity(0.7);

    final Widget icon = Icon(
      widget.selected ? widget.selectedIcon : widget.icon,
      color: color,
      size: 24,
    );

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: widget.selected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: icon,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: widget.showLabel
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: widget.selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: color,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
