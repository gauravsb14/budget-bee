import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/user_profile.dart';

class InfoField extends StatefulWidget {
  final String label;
  final String fieldKey; // fullName, email, phone

  const InfoField({super.key, required this.label, required this.fieldKey});

  @override
  State<InfoField> createState() => _InfoFieldState();
}

class _InfoFieldState extends State<InfoField> {
  late TextEditingController _controller;
  bool _isEditing = false;
  late Box<UserProfile> profileBox;
  late UserProfile profile;

  @override
  void initState() {
    super.initState();
    profileBox = Hive.box<UserProfile>('userProfile');

    if (profileBox.isEmpty) {
      // create default profile
      profile = UserProfile(fullName: "", email: "", phone: "");
      profileBox.add(profile);
    } else {
      profile = profileBox.getAt(0)!;
    }

    _controller = TextEditingController(text: _getValue());
  }

  String _getValue() {
    switch (widget.fieldKey) {
      case 'fullName':
        return profile.fullName;
      case 'email':
        return profile.email;
      case 'phone':
        return profile.phone;
      default:
        return '';
    }
  }

  void _saveValue(String value) {
    switch (widget.fieldKey) {
      case 'fullName':
        profile.fullName = value;
        break;
      case 'email':
        profile.email = value;
        break;
      case 'phone':
        profile.phone = value;
        break;
    }
    profile.save(); // saves to Hive
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controller,
        enabled: _isEditing,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 20),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _saveValue(_controller.text);
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ),
      ),
    );
  }
}
