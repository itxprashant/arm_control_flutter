import 'package:arm_control/servo_control.dart';
import 'package:flutter/material.dart';
// import 'package:usb_serial/usb_serial.dart';
// import 'package:usb_serial/transaction.dart';
import 'serial_home.dart';
import 'pick_item_homepage.dart';
import 'voice_control.dart';
import 'about_page.dart';
// import 'servo_control.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pick and Place Robot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Pick and Place Robot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    ServoControlPage(),
    SerialHomePage(),
    PickItemHomepage(),
    VoiceControlPage(),
    AboutPage(),
  ];

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Servo Control'),
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              title: const Text('Serial Communication'),
              onTap: () => _onDrawerItemTapped(1),
            ),
            ListTile(
              title: const Text("Pick Item"),
              onTap: () => _onDrawerItemTapped(2),
            ),
            ListTile(
              title: const Text("Voice Control"),
              onTap: () => _onDrawerItemTapped(3),
            ),
            ListTile(
              title: const Text("About"),
              onTap: () => _onDrawerItemTapped(4),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
