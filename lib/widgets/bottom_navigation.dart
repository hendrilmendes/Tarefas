// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/screens/settings/settings.dart';
import 'package:tarefas/screens/home/home.dart';
import 'package:tarefas/screens/notes/notes.dart';

class BottomNavigationContainer extends StatefulWidget {
  const BottomNavigationContainer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavigationContainerState createState() =>
      _BottomNavigationContainerState();
}

class _BottomNavigationContainerState extends State<BottomNavigationContainer> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
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
    setState(() {
      _currentIndex = index;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  _pageController.hasClients &&
                  _pageController.page?.round() != _currentIndex) {
                _pageController.jumpToPage(_currentIndex);
              }
            });
          }

          if (orientation == Orientation.portrait &&
              _pageController.hasClients &&
              _pageController.page?.round() != _currentIndex) {
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }

          if (orientation == Orientation.landscape) {
            return Row(
              children: [
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.2),
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: NavigationRail(
                        backgroundColor: Colors.transparent,
                        groupAlignment: 0.0,
                        selectedIndex: _currentIndex,
                        onDestinationSelected: _onTabTapped,
                        labelType: NavigationRailLabelType.all,
                        indicatorColor: Theme.of(context)
                            .bottomNavigationBarTheme
                            .selectedItemColor
                            ?.withOpacity(0.3),
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(CupertinoIcons.checkmark_alt),
                            label: Text(AppLocalizations.of(context)!.home),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(CupertinoIcons.news),
                            label: Text(AppLocalizations.of(context)!.notes),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(CupertinoIcons.settings),
                            label: Text(AppLocalizations.of(context)!.settings),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 50),
                    child: Container(
                      key: ValueKey<int>(_currentIndex),
                      child: _screens[_currentIndex],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Scaffold(
              extendBody: true,
              body: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _screens,
              ),
              bottomNavigationBar: GlassNavBar(
                selectedIndex: _currentIndex,
                onItemSelected: _onTabTapped,
                items: [
                  GlassNavBarItem(
                    icon: CupertinoIcons.checkmark_alt,
                    label: AppLocalizations.of(context)!.home,
                  ),
                  GlassNavBarItem(
                    icon: CupertinoIcons.news,
                    label: AppLocalizations.of(context)!.notes,
                  ),
                  GlassNavBarItem(
                    icon: CupertinoIcons.settings,
                    label: AppLocalizations.of(context)!.settings,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
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
  final Duration _animationDuration = const Duration(milliseconds: 50);
  final Curve _animationCurve = Curves.easeInOutQuart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.secondary;
    final unselectedColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
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
