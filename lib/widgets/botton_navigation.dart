import 'package:flutter/material.dart';
import 'package:tarefas/telas/home/home.dart';
import 'package:tarefas/telas/notas/notas.dart';
import 'package:tarefas/telas/config/config.dart';

class BottomNavigationContainer extends StatefulWidget {
  const BottomNavigationContainer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavigationContainerState createState() =>
      _BottomNavigationContainerState();
}

class _BottomNavigationContainerState extends State<BottomNavigationContainer> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    NotasScreen(),
    ConfigScreen(),
  ];

  // Metodo da button nav
  void onTabTapped(int index) {
    if (currentIndex == index) return;

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return Row(
              children: [
                NavigationRail(
                  groupAlignment: 0.0,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onTabTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.task),
                      selectedIcon: Icon(Icons.task_outlined),
                      label: Text("Tarefas"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notes),
                      selectedIcon: Icon(Icons.notes_outlined),
                      label: Text("Anotações"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      selectedIcon: Icon(Icons.settings_outlined),
                      label: Text("Ajustes"),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: screens[currentIndex]),
              ],
            );
          } else {
            return Scaffold(
              body: screens[currentIndex],
              // Bottom Nav
              bottomNavigationBar: NavigationBarTheme(
                data: NavigationBarThemeData(
                  labelTextStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
                child: NavigationBar(
                  onDestinationSelected: onTabTapped,
                  selectedIndex: currentIndex,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.task),
                      selectedIcon: Icon(Icons.task_outlined),
                      label: "Tarefas",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notes),
                      selectedIcon: Icon(Icons.notes_outlined),
                      label: "Anotações",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings),
                      selectedIcon: Icon(Icons.settings_outlined),
                      label: "Ajustes",
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
