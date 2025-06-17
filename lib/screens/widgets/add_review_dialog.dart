// File: lib/screens/widgets/add_review_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddReviewDialog extends StatefulWidget {
  final String stationId;
  const AddReviewDialog({super.key, required this.stationId});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _commentController = TextEditingController();
  double _rating = 3.0;
  bool _isLoading = true; // Start in loading state
  bool _isSubmitting = false;
  DocumentSnapshot? _existingReview;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Load user's previous review if it exists
  Future<void> _loadExistingReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Should not happen if UI is built correctly
      setState(() { _isLoading = false; });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('chargers')
        .doc(widget.stationId)
        .collection('reviews')
        .doc(user.uid)
        .get();

    if (doc.exists && mounted) {
      setState(() {
        _existingReview = doc;
        _rating = (doc.data()?['rating'] ?? 3.0).toDouble();
        _commentController.text = doc.data()?['comment'] ?? '';
      });
    }
    setState(() { _isLoading = false; });
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    setState(() { _isSubmitting = true; });

    final user = FirebaseAuth.instance.currentUser!;
    final stationRef = FirebaseFirestore.instance.collection('chargers').doc(widget.stationId);
    final reviewRef = stationRef.collection('reviews').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final stationSnapshot = await transaction.get(stationRef);
        if (!stationSnapshot.exists) throw Exception("Station does not exist!");

        int currentRatingCount = (stationSnapshot.data() as Map)['ratingCount'] ?? 0;
        int currentRatingSum = (stationSnapshot.data() as Map)['ratingSum'] ?? 0;
        int oldRating = (_existingReview?.data() as Map?)?['rating']?.toInt() ?? 0;

        final reviewData = {
          'userId': user.uid,
          'userEmail': user.email,
          'rating': _rating,
          'comment': _commentController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        };

        if (_existingReview == null) {
          // This is a NEW review
          transaction.set(reviewRef, reviewData);
          transaction.update(stationRef, {
            'ratingCount': currentRatingCount + 1,
            'ratingSum': currentRatingSum + _rating.toInt(),
          });
        } else {
          // This is an EDITED review
          transaction.update(reviewRef, reviewData);
          transaction.update(stationRef, {
            'ratingSum': currentRatingSum - oldRating + _rating.toInt(),
          });
        }
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _existingReview != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Your Review' : 'Add Your Review'),
      content: _isLoading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Your comment (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit'),
        ),
      ],
    );
  }
}