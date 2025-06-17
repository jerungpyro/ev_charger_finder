// File: lib/screens/add_station_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStationScreen extends StatefulWidget {
  const AddStationScreen({super.key});

  @override
  State<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalPortsController = TextEditingController();

  LatLng? _stationLocation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Start with the user's current location as a default
    _setUserCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _totalPortsController.dispose();
    super.dispose();
  }

  Future<void> _setUserCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _stationLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Default to a central location if location cannot be fetched
      setState(() {
        _stationLocation = const LatLng(3.1390, 101.6869);
      });
    }
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _stationLocation = newPosition;
    });
  }

  Future<void> _submitStation() async {
    if (_formKey.currentState!.validate() && _stationLocation != null) {
      setState(() { _isSubmitting = true; });

      try {
        await FirebaseFirestore.instance.collection('pending_stations').add({
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'totalPorts': int.tryParse(_totalPortsController.text.trim()) ?? 1,
          'availablePorts': 0, // Submitted stations default to 0 available
          'location': GeoPoint(_stationLocation!.latitude, _stationLocation!.longitude),
          'submittedBy': FirebaseAuth.instance.currentUser?.uid,
          'submittedAt': FieldValue.serverTimestamp(),
          'status': 'pending', // For admin review
        });

        if(mounted) {
          Navigator.of(context).pop(); // Go back to the map screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Station submitted for review. Thank you!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit station: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if(mounted) {
          setState(() { _isSubmitting = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Station'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _submitStation,
          )
        ],
      ),
      body: _stationLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- The Interactive Map ---
                  SizedBox(
                    height: 250,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _stationLocation!,
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('new_station_marker'),
                          position: _stationLocation!,
                          draggable: true,
                          onDragEnd: _onMarkerDragEnd,
                        )
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Text('Drag the marker to the exact location.', style: Theme.of(context).textTheme.bodySmall)),
                  const SizedBox(height: 20),

                  // --- The Form Fields ---
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Station Name', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address or Description', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter an address' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _totalPortsController,
                    decoration: const InputDecoration(labelText: 'Total Number of Ports', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a number';
                      if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Please enter a valid number greater than 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitStation,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit for Review'),
                  )
                ],
              ),
            ),
    );
  }
}