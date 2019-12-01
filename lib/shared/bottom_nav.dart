import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.graduationCap, size: 20),
            title: Text('Quiz')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userCircle, size: 20),
            title: Text('Profile')),
      ].toList(),
      fixedColor: Colors.deepPurple[200],
      onTap: (int idx) {
        switch (idx) {
          case 0:
            // do nuttin
            Navigator.pushNamed(context, '/quiz');
            Navigator.pop(context);

            break;
          case 1:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }
}