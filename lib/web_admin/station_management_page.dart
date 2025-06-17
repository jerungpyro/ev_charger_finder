// File: lib/web_admin/station_management_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../charging_station.dart'; // Reuse our data model

class StationManagementPage extends StatelessWidget {
  const StationManagementPage({super.key});

  // --- Logic for Deleting a station ---
  Future<void> _deleteStation(BuildContext context, String stationId) async {
    final bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to permanently delete this station?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
          ],
        ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('chargers').doc(stationId).delete();
    }
  }

  // --- Logic for showing the Edit/Create Dialog ---
  void _showEditDialog(BuildContext context, [DocumentSnapshot? stationDoc]) {
    final bool isEditing = stationDoc != null;
    final data = isEditing ? stationDoc.data() as Map<String, dynamic> : {};
    final geoPoint = isEditing ? data['location'] as GeoPoint : null;

    final _nameController = TextEditingController(text: data['name'] ?? '');
    final _addressController = TextEditingController(text: data['address'] ?? '');
    final _totalPortsController = TextEditingController(text: (data['totalPorts'] ?? 0).toString());
    final _latController = TextEditingController(text: (geoPoint?.latitude ?? 0.0).toString());
    final _lngController = TextEditingController(text: (geoPoint?.longitude ?? 0.0).toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Station' : 'Create New Station'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address')),
                TextField(controller: _totalPortsController, decoration: const InputDecoration(labelText: 'Total Ports'), keyboardType: TextInputType.number),
                TextField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number),
                TextField(controller: _lngController, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final stationData = {
                  'name': _nameController.text,
                  'address': _addressController.text,
                  'totalPorts': int.tryParse(_totalPortsController.text) ?? 0,
                  'availablePorts': int.tryParse(_totalPortsController.text) ?? 0, // Assume all are available on create/edit
                  'location': GeoPoint(double.tryParse(_latController.text) ?? 0, double.tryParse(_lngController.text) ?? 0),
                };

                if (isEditing) {
                  stationDoc.reference.update(stationData);
                } else {
                  FirebaseFirestore.instance.collection('chargers').add(stationData);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Live Stations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create New'),
              onPressed: () => _showEditDialog(context),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chargers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final stations = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Address')),
                DataColumn(label: Text('Ports')),
                DataColumn(label: Text('Actions')),
              ],
              rows: stations.map((doc) {
                final station = ChargingStation.fromFirestore(doc);
                return DataRow(cells: [
                  DataCell(Text(station.name)),
                  DataCell(Text(station.address, overflow: TextOverflow.ellipsis)),
                  DataCell(Text('${station.availablePorts}/${station.totalPorts}')),
                  DataCell(Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(context, doc)),
                      IconButton(icon: const Icon(Icons.delete), color: Colors.red, onPressed: () => _deleteStation(context, doc.id)),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}