// File: lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // We'll use this for links

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Helper function to launch URLs
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // You could show a snackbar here if you want
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Add your group members' names here! ---
    const List<String> teamMembers = [
      'Badrul Muhammad Akasyah',
      'Wan Muhammad Azlan',
      'Sufyan',
      'Azwar Ansori',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('About EV Charger Finder'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // --- App Info Section ---
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EV Charger Finder',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This application helps electric vehicle drivers locate nearby charging stations with real-time availability updates contributed by the community.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text('Version: 1.0.0 (Project Build)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Development Team Section ---
          Text(
            'Development Team',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          // Use map to create a ListTile for each team member
          ...teamMembers.map((name) => ListTile(
                leading: const Icon(Icons.person, color: Colors.green),
                title: Text(name),
              )),

          const SizedBox(height: 20),

          // --- Useful Links Section ---
          Text(
            'Useful Links',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.code, color: Colors.blue),
            title: const Text('View Project on GitHub'),
            onTap: () => _launchURL('https://github.com/jerungpyro/EV-Charger-Finder'), // TODO: Change to your repo URL
          ),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.red),
            title: const Text('Report an Issue'),
            onTap: () => _launchURL('https://github.com/jerungpyro/EV-Charger-Finder/issues/new'), // TODO: Change to your repo's "issues" URL
          ),
        ],
      ),
    );
  }
}