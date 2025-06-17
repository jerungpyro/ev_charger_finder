// File: lib/web_admin/user_management_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _firestore = FirebaseFirestore.instance;

  // Toggles the isAdmin flag for a user
  Future<void> _toggleAdminStatus(DocumentSnapshot userDoc) async {
    bool currentStatus = userDoc.get('isAdmin') ?? false;
    await userDoc.reference.update({'isAdmin': !currentStatus});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin status updated for ${userDoc.get('email')}.')),
      );
    }
  }

  // Toggles the isDisabled flag for a user
  Future<void> _toggleDisableStatus(DocumentSnapshot userDoc) async {
    bool currentStatus = userDoc.get('isDisabled') ?? false;
    await userDoc.reference.update({'isDisabled': !currentStatus});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User account status updated for ${userDoc.get('email')}.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').orderBy('email').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found in the database.'));
          }

          final users = snapshot.data!.docs;

          // --- THIS IS THE FIX ---
          // The DataTable is wrapped in a SingleChildScrollView that scrolls horizontally.
          // This ensures it will not overflow on smaller web browser windows.
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false, // Cleaner look
              columns: const [
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Car Model')),
                DataColumn(label: Text('Car Reg No.')),
                DataColumn(label: Text('Is Admin')),
                DataColumn(label: Text('Is Disabled')),
                DataColumn(label: Text('Actions')),
              ],
              rows: users.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final bool isAdmin = data['isAdmin'] ?? false;
                final bool isDisabled = data['isDisabled'] ?? false;

                return DataRow(
                  cells: [
                    DataCell(Text(data['email'] ?? 'N/A')),
                    DataCell(Text(data['carName'] ?? 'N/A')),
                    DataCell(Text(data['carRegNo'] ?? 'N/A')),
                    DataCell(
                      Icon(
                        isAdmin ? Icons.check_circle : Icons.cancel_outlined,
                        color: isAdmin ? Colors.green : Colors.grey,
                      ),
                    ),
                    DataCell(
                      Icon(
                        isDisabled ? Icons.block : Icons.gpp_good,
                        color: isDisabled ? Colors.red : Colors.grey,
                      ),
                    ),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: isAdmin ? 'Revoke Admin' : 'Make Admin',
                          child: IconButton(
                            icon: Icon(Icons.admin_panel_settings, color: isAdmin ? Theme.of(context).colorScheme.primary : Colors.grey),
                            onPressed: () => _toggleAdminStatus(doc),
                          ),
                        ),
                        Tooltip(
                          message: isDisabled ? 'Enable User' : 'Disable User',
                          child: IconButton(
                            icon: Icon(Icons.block, color: isDisabled ? Colors.red : Colors.grey),
                            onPressed: () => _toggleDisableStatus(doc),
                          ),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}