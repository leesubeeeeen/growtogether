import 'package:flutter/material.dart';
import '../theme/palette.dart';

BottomNavigationBar buildBottomNavBar(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Palette.mainRed,
    unselectedItemColor: Palette.greyText,
    onTap: (index) {
      switch (index) {
        case 0:
          if (ModalRoute.of(context)?.settings.name != '/') {
            Navigator.pushNamed(context, '/');
          }
          break;
        case 1:
          if (ModalRoute.of(context)?.settings.name != '/todo') {
            Navigator.pushNamed(context, '/todo');
          }
          break;
        case 2:
          if (ModalRoute.of(context)?.settings.name != '/todo-ai') {
            Navigator.pushNamed(context, '/todo-ai');
          }
          break;
        case 3:
          if (ModalRoute.of(context)?.settings.name != '/chat') {
            Navigator.pushNamed(context, '/chat');
          }
          break;
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.check_box), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
    ],
  );
}
