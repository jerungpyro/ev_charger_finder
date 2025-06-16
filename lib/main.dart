// File: lib/main.dart

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Firebase & Location Imports
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Local Imports
import 'firebase_options.dart';
import 'charging_station.dart';
import 'screens/auth_gate.dart';
import 'screens/profile_screen.dart';
import 'screens/station_detail_sheet.dart';

// --- Main Function: Initializes Firebase before running the app ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EV Charger Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  final Set<Marker> _markers = {};

  // This will hold our live connection to Firestore
  StreamSubscription<QuerySnapshot>? _chargerSubscription;

  BitmapDescriptor? _iconAvailable;
  BitmapDescriptor? _iconBusy;
  BitmapDescriptor? _iconUnavailable;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  // --- NEW: Cancel the subscription when the screen is closed ---
  @override
  void dispose() {
    _chargerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _loadCustomIcons();
    _listenToChargerUpdates(); // This now sets up the live stream
    await _checkLocationPermissionAndFetchLocation();
  }

  // --- REFACTORED: This now listens for real-time updates ---
  void _listenToChargerUpdates() {
    final firestore = FirebaseFirestore.instance;

    _chargerSubscription = firestore.collection('chargers').snapshots().listen(
      (snapshot) {
        print("[DEBUG] Firestore data changed. Received ${snapshot.docs.length} documents.");
        if (!mounted) return;

        final List<ChargingStation> stations = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data['location'] == null || data['location'] is! GeoPoint) {
            continue;
          }

          final geoPoint = data['location'] as GeoPoint;
          stations.add(
            ChargingStation(
              id: doc.id,
              name: data['name'] ?? 'Unnamed Station',
              address: data['address'] ?? 'No address',
              location: LatLng(geoPoint.latitude, geoPoint.longitude),
              availablePorts: data['availablePorts'] ?? 0,
              totalPorts: data['totalPorts'] ?? 0,
            ),
          );
        }
        
        _addMarkers(stations);

        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        print("[DEBUG] ❌ Firestore listener error: $error");
      },
    );
  }

  // --- (The following methods are mostly unchanged) ---
  Future<void> _loadCustomIcons() async {
    _iconAvailable = BitmapDescriptor.fromBytes(await _getBytesFromAsset('assets/images/ev_icon_green.png', 120));
    _iconBusy = BitmapDescriptor.fromBytes(await _getBytesFromAsset('assets/images/ev_icon_orange.png', 120));
    _iconUnavailable = BitmapDescriptor.fromBytes(await _getBytesFromAsset('assets/images/ev_icon_red.png', 120));
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void _addMarkers(List<ChargingStation> stations) {
    setState(() {
      _markers.clear();
      for (final station in stations) {
        _markers.add(
          Marker(
            markerId: MarkerId(station.id),
            position: station.location,
            icon: _getMarkerIcon(station),
            onTap: () => _showStationDetails(station),
          ),
        );
      }
    });
  }

  BitmapDescriptor _getMarkerIcon(ChargingStation station) {
    if (station.availablePorts == 0) {
      return _iconUnavailable ?? BitmapDescriptor.defaultMarker;
    } else if (station.availablePorts < station.totalPorts) {
      return _iconBusy ?? BitmapDescriptor.defaultMarker;
    } else {
      return _iconAvailable ?? BitmapDescriptor.defaultMarker;
    }
  }

  // --- REFACTORED: This function is now simpler ---
  void _showStationDetails(ChargingStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // The onUpdate callback now does nothing, as the stream handles updates.
        // We could remove it entirely, but this works for simplicity.
        return StationDetailSheet(
          station: station,
          onUpdate: () {}, 
        );
      },
    );
  }

  Future<void> _checkLocationPermissionAndFetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      return;
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _goToPosition(position);
    }
  }

  Future<void> _goToPosition(Position position) async {
    final GoogleMapController controller = await _controllerCompleter.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EV Charger Finder'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(target: LatLng(3.1390, 101.6869), zoom: 11.0),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                if (!_controllerCompleter.isCompleted) {
                  _controllerCompleter.complete(controller);
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkLocationPermissionAndFetchLocation,
        tooltip: 'My Location',
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}