// File: lib/web_admin/review_management_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart'; // For formatting dates

class ReviewManagementPage extends StatefulWidget {
  const ReviewManagementPage({super.key});

  @override
  State<ReviewManagementPage> createState() => _ReviewManagementPageState();
}

class _ReviewManagementPageState extends State<ReviewManagementPage> {
  final _firestore = FirebaseFirestore.instance;

  // --- Logic for Deleting a review ---
  // Note: This is complex because we must also update the aggregate rating
  Future<void> _deleteReview(DocumentSnapshot reviewDoc) async {
    final reviewData = reviewDoc.data() as Map<String, dynamic>;
    final stationRef = reviewDoc.reference.parent.parent!; // This gets the parent charger document
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this review? This will also update the station\'s average rating.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    
    if (confirm != true) return;

    try {
      // Use a transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot stationSnapshot = await transaction.get(stationRef);
        if (!stationSnapshot.exists) {
          // If station was deleted, just delete the review
          transaction.delete(reviewDoc.reference);
          return;
        }

        int currentRatingCount = (stationSnapshot.data() as Map)['ratingCount'] ?? 0;
        int currentRatingSum = (stationSnapshot.data() as Map)['ratingSum'] ?? 0;
        int reviewRating = (reviewData['rating'] ?? 0).toInt();

        // Decrement the count and sum
        int newRatingCount = currentRatingCount > 0 ? currentRatingCount - 1 : 0;
        int newRatingSum = currentRatingSum - reviewRating;

        // Update the aggregate fields on the charger document
        transaction.update(stationRef, {
          'ratingCount': newRatingCount,
          'ratingSum': newRatingSum < 0 ? 0 : newRatingSum,
        });

        // Delete the review document itself
        transaction.delete(reviewDoc.reference);
      });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
       if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting review: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage All Reviews'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // --- This is the Collection Group Query ---
        stream: _firestore.collectionGroup('reviews').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No reviews have been submitted yet.'));

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final doc = reviews[index];
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text('Review by: ${data['userEmail'] ?? 'Unknown'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Comment: "${data['comment'] ?? 'No comment.'}"'),
                      const SizedBox(height: 4),
                      // We need to fetch the station name for context
                      FutureBuilder<DocumentSnapshot>(
                        future: doc.reference.parent.parent!.get(),
                        builder: (context, stationSnapshot) {
                          if (!stationSnapshot.hasData) return const Text('On: Loading station...');
                          return Text('On: ${stationSnapshot.data!.get('name') ?? 'Unknown Station'}');
                        },
                      ),
                       if (timestamp != null) 
                        Text('Date: ${DateFormat.yMMMd().add_jm().format(timestamp)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingBarIndicator(
                        rating: (data['rating'] ?? 0.0).toDouble(),
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 18.0,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _deleteReview(doc),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}