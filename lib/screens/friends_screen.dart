// File: lib/screens/friends_screen.dart

import 'package:flutter/material.dart';

// Import the new tab widgets
import 'widgets/add_friend_tab.dart';
import 'widgets/friend_requests_tab.dart';
import 'widgets/friends_list_tab.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // The number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'My Friends'),
              Tab(icon: Icon(Icons.mark_email_unread), text: 'Requests'),
              Tab(icon: Icon(Icons.person_add), text: 'Add Friend'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Each tab is now a dedicated widget
            FriendsListTab(),
            FriendRequestsTab(),
            AddFriendTab(),
          ],
        ),
      ),
    );
  }
}