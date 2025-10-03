import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 4) // make sure this ID is unique in your app
class UserProfile extends HiveObject {
  @HiveField(0)
  String fullName;

  @HiveField(1)
  String email;

  @HiveField(2)
  String phone;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
  });
}
