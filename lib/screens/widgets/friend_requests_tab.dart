// File: lib/screens/widgets/friend_requests_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsTab extends StatefulWidget {
  const FriendRequestsTab({super.key});

  @override
  State<FriendRequestsTab> createState() => _FriendRequestsTabState();
}

class _FriendRequestsTabState extends State<FriendRequestsTab> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  // --- Logic for accepting a friend request ---
  Future<void> _acceptRequest(String senderId, String senderEmail) async {
    final now = Timestamp.now();
    
    // Use a batch write to perform multiple operations atomically
    WriteBatch batch = _firestore.batch();

    // 1. Add the sender to the current user's 'friends' sub-collection
    DocumentReference currentUserFriendRef = _firestore
        .collection('users').doc(_currentUser.uid)
        .collection('friends').doc(senderId);
    batch.set(currentUserFriendRef, {
      'friendId': senderId,
      'friendEmail': senderEmail,
      'friendshipDate': now,
    });
    
    // 2. Add the current user to the sender's 'friends' sub-collection
    DocumentReference senderFriendRef = _firestore
        .collection('users').doc(senderId)
        .collection('friends').doc(_currentUser.uid);
    batch.set(senderFriendRef, {
      'friendId': _currentUser.uid,
      'friendEmail': _currentUser.email,
      'friendshipDate': now,
    });

    // 3. Delete the friend request from the current user's list
    DocumentReference requestRef = _firestore
        .collection('users').doc(_currentUser.uid)
        .collection('friend_requests').doc(senderId);
    batch.delete(requestRef);

    // Commit all the operations in the batch
    await batch.commit();

    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are now friends with $senderEmail!'), backgroundColor: Colors.green)
        );
    }
  }

  // --- Logic for declining a friend request ---
  Future<void> _declineRequest(String senderId) async {
    // Just delete the request document
    await _firestore
        .collection('users').doc(_currentUser.uid)
        .collection('friend_requests').doc(senderId)
        .delete();

    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend request declined.'), backgroundColor: Colors.orange)
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Listen to the friend_requests sub-collection for the current user
      stream: _firestore
          .collection('users')
          .doc(_currentUser.uid)
          .collection('friend_requests')
          .where('status', isEqualTo: 'pending') // Only show pending requests
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('You have no incoming friend requests.'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final requestData = request.data() as Map<String, dynamic>;
            final senderEmail = requestData['senderEmail'] ?? 'Unknown User';
            final senderId = request.id; // The document ID is the sender's UID

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(senderEmail[0].toUpperCase())),
                title: Text(senderEmail),
                subtitle: const Text('Sent you a friend request.'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Accept Button
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Accept',
                      onPressed: () => _acceptRequest(senderId, senderEmail),
                    ),
                    // Decline Button
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Decline',
                      onPressed: () => _declineRequest(senderId),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}