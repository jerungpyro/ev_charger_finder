// File: lib/screens/widgets/add_friend_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendTab extends StatefulWidget {
  const AddFriendTab({super.key});

  @override
  State<AddFriendTab> createState() => _AddFriendTabState();
}

class _AddFriendTabState extends State<AddFriendTab> {
  final _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers() async {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) return;

    setState(() { _isLoading = true; });

    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: searchQuery)
        .get();

    // Filter out the current user from search results so you can't add yourself
    if(mounted) {
      setState(() {
        _searchResults = snapshot.docs.where((doc) => doc['email'] != currentUserEmail).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String recipientId) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    
    // Reference to the recipient's friend_requests sub-collection
    final requestsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId)
        .collection('friend_requests');
    
    // Use the sender's UID as the document ID to prevent duplicate requests
    final docRef = requestsRef.doc(currentUser.uid);
    final existingRequest = await docRef.get();
    
    if (existingRequest.exists) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request already sent.')));
        return;
    }

    // Create the friend request document
    await docRef.set({
      'senderId': currentUser.uid,
      'senderEmail': currentUser.email,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request sent!'),
          backgroundColor: Colors.green,
        )
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search for users by email',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _searchUsers,
              ),
            ),
            onSubmitted: (_) => _searchUsers(),
          ),
          const SizedBox(height: 20),
          // Search Results
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_searchResults.isEmpty)
            const Text('No users found. Try searching by full email address.')
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  final userData = user.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text(userData['email'] ?? 'No Email'),
                      trailing: ElevatedButton(
                        child: const Text('Add'),
                        onPressed: () => _sendFriendRequest(user.id),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}