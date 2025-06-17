// File: lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'about_screen.dart';
import 'friends_screen.dart'; // Import the new friends screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _carNameController = TextEditingController();
  final _carRegNoController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser!;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _carNameController.dispose();
    _carRegNoController.dispose();
    super.dispose();
  }

  // Fetches existing car data from Firestore
  Future<void> _loadCarData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).get();
      if (mounted && docSnapshot.exists) {
        final data = docSnapshot.data()!;
        _carNameController.text = data['carName'] ?? '';
        _carRegNoController.text = data['carRegNo'] ?? '';
      }
    } catch (e) {
      print("Error loading car data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load profile data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Saves the car data to Firestore
  Future<void> _saveCarData() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).set({
        'email': _currentUser.email, // Also save the email for future reference
        'carName': _carNameController.text.trim(),
        'carRegNo': _carRegNoController.text.trim(),
      }, SetOptions(merge: true)); // merge:true prevents overwriting other fields

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Logout Button
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              // Navigate back to the map screen after logout, AuthGate will handle the rest
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView( // Use ListView to prevent overflow on smaller screens
              padding: const EdgeInsets.all(20.0),
              children: [
                // User Info Header
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Logged in as:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _currentUser.email!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Car Info Section
                Text(
                  'My Vehicle Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                const SizedBox(height: 10),
                TextField(
                  controller: _carNameController,
                  decoration: const InputDecoration(
                    labelText: 'Car Model',
                    hintText: 'e.g., Tesla Model 3',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _carRegNoController,
                  decoration: const InputDecoration(
                    labelText: 'Car Registration No.',
                    hintText: 'e.g., VEV 1234',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pin),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveCarData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Profile'),
                ),
                const SizedBox(height: 40),

                // --- Links Section ---
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Friends'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const FriendsScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About this App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    );
                  },
                ),
              ],
            ),
    );
  }
}