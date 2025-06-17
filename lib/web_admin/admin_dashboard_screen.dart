// File: lib/web_admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_login_screen.dart';
import '../charging_station.dart'; // We can reuse our mobile data model!

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _firestore = FirebaseFirestore.instance;

  // --- Logic for APPROVING a station ---
  Future<void> _approveStation(DocumentSnapshot pendingDoc) async {
    final data = pendingDoc.data() as Map<String, dynamic>;
    
    WriteBatch batch = _firestore.batch();
    
    // 1. Create a new document in the main 'chargers' collection
    DocumentReference newChargerRef = _firestore.collection('chargers').doc();
    batch.set(newChargerRef, {
      'name': data['name'],
      'address': data['address'],
      'totalPorts': data['totalPorts'],
      'availablePorts': data['totalPorts'], // On approval, all ports are available
      'location': data['location'],
      'status': 'approved',
      'approvedBy': FirebaseAuth.instance.currentUser?.uid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    
    // 2. Delete the document from the 'pending_stations' collection
    batch.delete(pendingDoc.reference);
    
    // Commit the batch
    await batch.commit();

    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station approved and is now live.'), backgroundColor: Colors.green)
      );
    }
  }

  // --- Logic for DECLINING a station ---
  Future<void> _declineStation(DocumentSnapshot pendingDoc) async {
    await pendingDoc.reference.delete();
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station submission declined.'), backgroundColor: Colors.orange)
      );
    }
  }

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
        title: const Text('Admin Dashboard - Pending Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _adminLogout(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('pending_stations').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending station submissions.'));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          final pendingDocs = snapshot.data!.docs;

          // Use ListView for a simple list, or a DataTable for a more professional look
          return ListView.builder(
            itemCount: pendingDocs.length,
            itemBuilder: (context, index) {
              final doc = pendingDocs[index];
              // We can reuse our ChargingStation model, but some fields might be missing
              final data = doc.data() as Map<String, dynamic>;
              final geoPoint = data['location'] as GeoPoint;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'No Name', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(data['address'] ?? 'No Address'),
                      Text('Total Ports: ${data['totalPorts']}'),
                      Text('Location: ${geoPoint.latitude}, ${geoPoint.longitude}'),
                      Text('Submitted by: ${data['submittedBy']}'),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text('Decline'),
                            onPressed: () => _declineStation(doc),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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