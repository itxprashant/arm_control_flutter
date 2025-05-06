import 'package:flutter/material.dart';
import 'dart:typed_data';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutPage createState() => _AboutPage();
}

class _AboutPage extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text('Pick and Place Robot', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Version 1.0.0', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Developed by Prashant', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text(
              'Made for MCP101 Project for group 9C1',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Group Members:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('1. Prashant Tiwari', style: TextStyle(fontSize: 18)),
            Text('2. Aditya Jain', style: TextStyle(fontSize: 18)),
            Text('3. Sambhav Jain', style: TextStyle(fontSize: 18)),
            Text('4. Preksha', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
