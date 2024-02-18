import 'package:flutter/material.dart';
import 'package:tarefas/telas/mais/mais.dart';
import 'package:tarefas/telas/home/home.dart';
import 'package:tarefas/telas/notas/notas.dart';

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
    MaisScreen(),
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
      body: screens[currentIndex],
      // Bottom Nav
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          shadowColor: Colors.blue,
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
              icon: Icon(Icons.task_outlined),
              selectedIcon: Icon(Icons.task),
              label: 'Tarefas',
            ),
            NavigationDestination(
              icon: Icon(Icons.notes_outlined),
              selectedIcon: Icon(Icons.notes),
              label: 'Anotações',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'Mais',
            ),
          ],
        ),
      ),
    );
  }
}
