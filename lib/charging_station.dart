// File: lib/charging_station.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChargingStation {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final int availablePorts;
  final int totalPorts;
  // --- NEW: Add the new rating fields ---
  final int ratingCount;
  final int ratingSum;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.availablePorts,
    required this.totalPorts,
    // --- NEW: Add them to the constructor ---
    required this.ratingCount,
    required this.ratingSum,
  });

  // --- UPDATED: Update the factory constructor to parse the new fields ---
  factory ChargingStation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    GeoPoint geoPoint = data['location'] ?? const GeoPoint(0, 0);

    return ChargingStation(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Station',
      address: data['address'] ?? 'No Address',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      availablePorts: data['availablePorts'] ?? 0,
      totalPorts: data['totalPorts'] ?? 0,
      // Safely parse the new integer fields, defaulting to 0 if they don't exist
      ratingCount: data['ratingCount'] ?? 0,
      ratingSum: data['ratingSum'] ?? 0,
    );
  }
}