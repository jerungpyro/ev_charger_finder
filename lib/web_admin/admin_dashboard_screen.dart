// File: lib/web_admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import all the pages for the admin panel
import 'admin_login_screen.dart';
import 'moderation_page.dart';
import 'station_management_page.dart';
import 'user_management_page.dart';
import 'review_management_page.dart'; // Import the new review management page

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // The list of all pages accessible from the navigation rail
  static const List<Widget> _pages = <Widget>[
    ModerationPage(),
    StationManagementPage(),
    UserManagementPage(),
    ReviewManagementPage(), // Add the new page to the list
  ];

  // Handles logging out the admin user
  Future<void> _adminLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _adminLogout(context),
          )
        ],
      ),
      body: Row(
        children: [
          // This NavigationRail acts as the side menu for the dashboard
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            // The list of destinations/tabs shown in the side menu
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.pending_actions_outlined),
                selectedIcon: Icon(Icons.pending_actions),
                label: Text('Pending'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.ev_station_outlined),
                selectedIcon: Icon(Icons.ev_station),
                label: Text('Stations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              // Add the new destination for the review management page
              NavigationRailDestination(
                icon: Icon(Icons.rate_review_outlined),
                selectedIcon: Icon(Icons.rate_review),
                label: Text('Reviews'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // The main content area, which displays the selected page
          Expanded(
            child: _pages.elementAt(_selectedIndex),
          )
        ],
      ),
    );
  }
}