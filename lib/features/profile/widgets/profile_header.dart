import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onEditAvatar;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: const AssetImage('assets/avatar.png'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onEditAvatar,
                child: const CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
