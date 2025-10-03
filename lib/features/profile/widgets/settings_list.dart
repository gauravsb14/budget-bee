import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = [
      {'title': 'Change Password', 'icon': Icons.lock},
      {'title': 'Notifications', 'icon': Icons.notifications},
      {'title': 'Theme', 'icon': Icons.palette},
      {'title': 'Logout', 'icon': Icons.logout},
    ];

    return ListView.separated(
      itemCount: settings.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = settings[index];
        return ListTile(
          leading: Icon(item['icon'] as IconData),
          title: Text(item['title'] as String),
          onTap: () {},
        );
      },
    );
  }
}
