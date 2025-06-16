// File: lib/charging_station.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChargingStation {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final int availablePorts;
  final int totalPorts;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.availablePorts,
    required this.totalPorts,
  });
}