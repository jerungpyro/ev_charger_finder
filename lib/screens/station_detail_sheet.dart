// File: lib/screens/station_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../charging_station.dart';
import 'widgets/add_review_dialog.dart';

class StationDetailSheet extends StatelessWidget {
  final ChargingStation station;
  const StationDetailSheet({super.key, required this.station});
  
  Future<void> _launchMaps(BuildContext context, ChargingStation stationData) async {
    final lat = stationData.location.latitude;
    final lng = stationData.location.longitude;
    final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri);
      } else {
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps to get directions.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('chargers').doc(station.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final stationData = ChargingStation.fromFirestore(snapshot.data!);
        final ratingCount = stationData.ratingCount;
        final ratingSum = stationData.ratingSum;
        final averageRating = (ratingCount > 0) ? ratingSum / ratingCount : 0.0;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20.0),
                children: [
                  Text(stationData.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(stationData.address, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${stationData.availablePorts} / ${stationData.totalPorts} Available',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${averageRating.toStringAsFixed(1)} ($ratingCount)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: ElevatedButton.icon(onPressed: () => _launchMaps(context, stationData), icon: const Icon(Icons.directions), label: const Text('Directions'))),
                      const SizedBox(width: 10),
                      // --- NEW: This button now dynamically checks if a user has reviewed ---
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chargers')
                              .doc(stationData.id)
                              .collection('reviews')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final bool hasReviewed = snapshot.hasData && snapshot.data!.exists;
                            return OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AddReviewDialog(stationId: stationData.id),
                                );
                              },
                              icon: Icon(hasReviewed ? Icons.edit_note : Icons.rate_review_outlined),
                              label: Text(hasReviewed ? 'Edit Review' : 'Add Review'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 40),

                  Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('chargers').doc(station.id).collection('reviews').orderBy('timestamp', descending: true).snapshots(),
                    builder: (context, reviewSnapshot) {
                      if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!reviewSnapshot.hasData || reviewSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text('Be the first to leave a review!'),
                        ));
                      }
                      return Column(
                        children: reviewSnapshot.data!.docs.map((doc) {
                          final review = doc.data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(child: Text((review['userEmail'] ?? 'A')[0].toUpperCase())),
                              title: Text(review['userEmail'] ?? 'Anonymous'),
                              subtitle: Text(review['comment'] ?? ''),
                              trailing: RatingBarIndicator(
                                rating: (review['rating'] ?? 0.0).toDouble(),
                                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 15.0,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}