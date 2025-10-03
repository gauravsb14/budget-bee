import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/info_field.dart';
import '../widgets/settings_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> tabs = const [
    Tab(text: 'Overview'),
    Tab(text: 'Personal Info'),
    Tab(text: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          indicatorColor: const Color.fromARGB(255, 138, 184, 179),
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black87,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_overviewTab(), _personalInfoTab(), _settingsTab()],
      ),
    );
  }

  Widget _overviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          ProfileHeader(
            name: 'Gaurav Singh',
            email: 'gaurav@email.com',
            onEditAvatar: null,
          ),
          SizedBox(height: 16),
          QuickStatsCard(),
        ],
      ),
    );
  }

  Widget _personalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          InfoField(label: 'Full Name', fieldKey: 'fullName'),
          InfoField(label: 'Email', fieldKey: 'email'),
          InfoField(label: 'Phone', fieldKey: 'phone'),
        ],
      ),
    );
  }

  Widget _settingsTab() {
    return const SettingsList();
  }
}
