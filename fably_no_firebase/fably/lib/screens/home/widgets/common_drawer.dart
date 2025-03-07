import 'package:flutter/material.dart';
import '../../gender/gender_selection.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.tealAccent),
              child: Text('Menu',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore),
              title: const Text('Back to Selection Screen'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AreYouScreen()),
                );
              },
            ),
          ],
        ),
      );
  }
}