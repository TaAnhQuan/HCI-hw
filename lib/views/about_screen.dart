import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String version = "Version 0.0.0";
  String updateDetails = "";

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
    _loadUpdateDetails();
  }

  Future<void> _loadVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = packageInfo.version;
      updateDetails = "• Bug fixes\n• Performance improvements\n• Added new features";
    });
  }

  Future<void> _loadUpdateDetails() async {
    final String jsonString = await rootBundle.loadString('assets/update_details.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      updateDetails = jsonData['updateDetails'] ?? "No update details available";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'About Buddie',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensure alignment starts from the left
          children: [
            // Center the logo
            Center(
              child: Image.asset('assets/images/logo.png', height: 150),
            ),
            SizedBox(height: 10),

            // Center the version text
            Center(
              child: Text(
                'Version:$version',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),

            // Official Design Media Section (Align left)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Official Design Media',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            // Align the social media buttons to the left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Official Website'),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('TikTok'),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Facebook'),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Version Update Details Section (Align left)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Version Update Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Text(
              updateDetails,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14, height: 2),
            ),

            SizedBox(height: 40),

            // Center the Rate & Feedback Section and Button
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Rate & Feedback',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 80),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Give Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
