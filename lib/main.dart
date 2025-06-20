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
import 'screens/add_station_screen.dart';
import 'screens/auth_gate.dart';
import 'screens/profile_screen.dart';
import 'screens/station_detail_sheet.dart';

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
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
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
  final TextEditingController _searchController = TextEditingController();

  BitmapDescriptor? _iconAvailable;
  BitmapDescriptor? _iconBusy;
  BitmapDescriptor? _iconUnavailable;
  String? _darkMapStyle;

  bool _filterAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _checkLocationPermissionAndFetchLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    _iconAvailable = BitmapDescriptor.fromBytes(await _getBytesFromAsset('assets/images/ev_icon_green.png', 120));
    _iconBusy = BitmapDescriptor.fromBytes(await _getBytesFromAsset('assets/images/ev_icon_orange.png', 120));
    _iconUnavailable = BitmapDescriptor.fromBytes(await _getBytesFromAsset('assets/images/ev_icon_red.png', 120));
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark_style.json');
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
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

  // --- UPDATED: Simplified function call ---
  void _showStationDetails(ChargingStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to be dragged up
      backgroundColor: Colors.transparent, // Important for rounded corners on the sheet
      builder: (context) => StationDetailSheet(station: station),
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

  void _setMapStyle(GoogleMapController controller) {
    final Brightness currentBrightness = Theme.of(context).brightness;
    if (currentBrightness == Brightness.dark) {
      controller.setMapStyle(_darkMapStyle);
    } else {
      controller.setMapStyle(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    Query chargersQuery = FirebaseFirestore.instance.collection('chargers');
    final searchQuery = _searchController.text.trim();

    if (searchQuery.isNotEmpty) {
      chargersQuery = chargersQuery
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    if (_filterAvailable) {
      chargersQuery = chargersQuery.where('availablePorts', isGreaterThan: 0);
    }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by station name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8.0,
                children: [
                  FilterChip(
                    label: const Text('Available Now'),
                    selected: _filterAvailable,
                    onSelected: (bool selected) {
                      setState(() {
                        _filterAvailable = selected;
                      });
                    },
                    selectedColor: Colors.green.withOpacity(0.2),
                    checkmarkColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chargersQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong. Check the console.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No matching charging stations found.'));
                }

                final Set<Marker> markers = snapshot.data!.docs.map((doc) {
                  final station = ChargingStation.fromFirestore(doc);
                  return Marker(
                    markerId: MarkerId(station.id),
                    position: station.location,
                    icon: _getMarkerIcon(station),
                    onTap: () => _showStationDetails(station),
                  );
                }).toSet();

                return GoogleMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(3.1390, 101.6869), zoom: 11.0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  markers: markers,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controllerCompleter.isCompleted) {
                      _controllerCompleter.complete(controller);
                    }
                    _setMapStyle(controller);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'add_station_fab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddStationScreen()),
                );
              },
              tooltip: 'Add Station',
              child: const Icon(Icons.add_location_alt),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'my_location_fab',
              onPressed: _checkLocationPermissionAndFetchLocation,
              tooltip: 'My Location',
              child: const Icon(Icons.my_location),
            ),
          ],
        ),
      ),
    );
  }
}