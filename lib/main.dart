import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/category_model.dart';
import 'models/subcategory_model.dart';
import 'models/expense_model.dart';
import 'models/user_profile.dart';
import 'features/core_navigation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(SubCategoryAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  await Hive.openBox<Category>('categories');
  await Hive.openBox<SubCategory>('subcategories');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<UserProfile>('userProfile');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Bee',
      theme: ThemeData(
        primaryColor: Colors.green[600],
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyLarge: const TextStyle(color: Colors.black87),
          bodyMedium: const TextStyle(color: Colors.black87),
          bodySmall: const TextStyle(color: Colors.black87),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.green[700]),
          titleTextStyle: TextStyle(
            color: const Color.fromARGB(221, 46, 46, 46),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 5,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
