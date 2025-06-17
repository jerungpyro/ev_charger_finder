// File: lib/web_admin/moderation_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  final _firestore = FirebaseFirestore.instance;

  // --- Logic for APPROVING a station ---
  Future<void> _approveStation(DocumentSnapshot pendingDoc) async {
    final data = pendingDoc.data() as Map<String, dynamic>;

    // Use a batch write to perform multiple operations atomically
    WriteBatch batch = _firestore.batch();

    // 1. Create a new document in the main 'chargers' collection
    DocumentReference newChargerRef = _firestore.collection('chargers').doc();
    batch.set(newChargerRef, {
      'name': data['name'],
      'address': data['address'],
      'totalPorts': data['totalPorts'],
      // When a station is approved, assume all ports are now available
      'availablePorts': data['totalPorts'],
      'location': data['location'],
      'status': 'approved', // You can add custom fields for tracking
      'approvedBy': FirebaseAuth.instance.currentUser?.uid,
      'approvedAt': FieldValue.serverTimestamp(),
      'originallySubmittedBy': data['submittedBy'],
    });

    // 2. Delete the document from the 'pending_stations' collection
    batch.delete(pendingDoc.reference);

    // Commit all the operations in the batch
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Station approved and is now live.'),
        backgroundColor: Colors.green,
      ));
    }
  }

  // --- Logic for DECLINING a station ---
  Future<void> _declineStation(DocumentSnapshot pendingDoc) async {
    // You could just delete it, or update its status to 'declined' for tracking
    await pendingDoc.reference.delete();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Station submission declined and removed.'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Station Submissions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('pending_stations')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No pending station submissions to review.'));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          final pendingDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingDocs.length,
            itemBuilder: (context, index) {
              final doc = pendingDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final geoPoint = data['location'] as GeoPoint?;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'No Name',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(data['address'] ?? 'No Address'),
                      if (geoPoint != null)
                        Text(
                            'Location: ${geoPoint.latitude.toStringAsFixed(4)}, ${geoPoint.longitude.toStringAsFixed(4)}'),
                      Text('Total Ports: ${data['totalPorts'] ?? 'N/A'}'),
                      if (data['submittedBy'] != null)
                        Text('Submitted by: ${data['submittedBy']}'),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.close_rounded, color: Colors.red),
                            label: const Text('Decline'),
                            onPressed: () => _declineStation(doc),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _approveStation(doc),
                          ),
                        ],
                      )
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