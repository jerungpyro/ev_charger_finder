// File: lib/screens/station_detail_sheet.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../charging_station.dart';

class StationDetailSheet extends StatefulWidget {
  final ChargingStation station;
  final VoidCallback onUpdate;

  const StationDetailSheet({
    super.key,
    required this.station,
    required this.onUpdate,
  });

  @override
  State<StationDetailSheet> createState() => _StationDetailSheetState();
}

class _StationDetailSheetState extends State<StationDetailSheet> {
  late int _currentAvailablePorts;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentAvailablePorts = widget.station.availablePorts;
  }

  // This function sends the update to Firestore
  Future<void> _updatePortAvailability(int change) async {
    final newCount = _currentAvailablePorts + change;
    if (newCount < 0 || newCount > widget.station.totalPorts || _isUpdating) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('chargers').doc(widget.station.id);
      await docRef.update({'availablePorts': newCount});

      // Update local state to give instant feedback in the UI
      setState(() {
        _currentAvailablePorts = newCount;
      });
      
      // The map will update automatically via the stream.
      // This callback is now optional, but good for triggering other UI feedback.
      widget.onUpdate();

    } catch (e) {
      print("Error updating port count: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status. Please try again.')),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.station.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            widget.station.address,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.electrical_services, color: Colors.green, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    '$_currentAvailablePorts / ${widget.station.totalPorts} Available',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 35),
                    onPressed: _isUpdating ? null : () => _updatePortAvailability(-1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 35),
                    onPressed: _isUpdating ? null : () => _updatePortAvailability(1),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}