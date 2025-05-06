import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';
import 'dart:typed_data';

class PickItemHomepage extends StatefulWidget {
  const PickItemHomepage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PickItemHomepage createState() => _PickItemHomepage();
}

class _PickItemHomepage extends State<PickItemHomepage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allItems = List.generate(
    12,
    (index) => "Item ${index + 1}",
  );
  final List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems.addAll(_allItems);
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems.clear();
      if (query.isEmpty) {
        _filteredItems.addAll(_allItems);
      } else {
        for (String item in _allItems) {
          if (item.toLowerCase().contains(query)) {
            _filteredItems.add(item);
          }
        }
      }
    });
  }

  void _pickItem(String item) {
    // Execute the command (replace this with the actual command logic)
    print("Executing command to pick item: $item");

    // Show dialog that the item is being picked
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text("Processing"),
          content: Text("Picking item: $item"),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog when "OK" is pressed
                Navigator.of(context).pop();
                print("Item picking dialog closed.");
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    // _searchController.removeListener(_filterItems);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text("Pick item page"),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search",
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length, // Example: 12 items
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text(_filteredItems[index]),
                  onTap: () => {_pickItem(_filteredItems[index])},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
