// File: lib/screens/widgets/friends_list_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsListTab extends StatefulWidget {
  const FriendsListTab({super.key});

  @override
  State<FriendsListTab> createState() => _FriendsListTabState();
}

class _FriendsListTabState extends State<FriendsListTab> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  // --- Logic for removing a friend ---
  Future<void> _removeFriend(String friendId, String friendEmail) async {
    // Display a confirmation dialog before removing
    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove $friendEmail from your friends list?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Remove'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    
    // If the user cancelled, do nothing
    if (shouldRemove == null || !shouldRemove) {
      return;
    }

    // Use a batch write to remove the friendship from both users
    WriteBatch batch = _firestore.batch();

    // 1. Delete the friend from the current user's list
    DocumentReference currentUserFriendRef = _firestore
        .collection('users').doc(_currentUser.uid)
        .collection('friends').doc(friendId);
    batch.delete(currentUserFriendRef);
    
    // 2. Delete the current user from the friend's list
    DocumentReference friendUserRef = _firestore
        .collection('users').doc(friendId)
        .collection('friends').doc(_currentUser.uid);
    batch.delete(friendUserRef);
    
    // Commit both delete operations
    await batch.commit();

    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Removed $friendEmail from your friends.'), backgroundColor: Colors.orange)
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Listen to the 'friends' sub-collection for the current user
      stream: _firestore
          .collection('users')
          .doc(_currentUser.uid)
          .collection('friends')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('You have not added any friends yet.'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        final friends = snapshot.data!.docs;

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            final friendData = friend.data() as Map<String, dynamic>;
            final friendEmail = friendData['friendEmail'] ?? 'Unknown Friend';
            final friendId = friend.id; // The document ID is the friend's UID

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(friendEmail[0].toUpperCase())),
                title: Text(friendEmail),
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                  tooltip: 'Remove Friend',
                  onPressed: () => _removeFriend(friendId, friendEmail),
                ),
              ),
            );
          },
        );
      },
    );
  }
}