import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  List<String> savedAddresses = [];

  // Function to Show Address Selection Dialog
  void _showAddressSelection() async {
    String? selectedAddress = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Address"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // List of saved addresses
              ...savedAddresses.map((address) {
                return ListTile(
                  title: Text(address),
                  onTap: () {
                    Navigator.pop(context, address);
                  },
                );
              }).toList(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.blue),
                title: const Text("Add New Address", style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.pop(context, null); // Close dialog
                  _showAddAddressDialog();
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedAddress != null) {
      setState(() {
        _addressController.text = selectedAddress;
      });
    }
  }

  // Function to Show Add Address Dialog
  void _showAddAddressDialog() {
    TextEditingController newAddressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Address"),
          content: TextField(
            controller: newAddressController,
            decoration: const InputDecoration(hintText: "Enter new address"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (newAddressController.text.isNotEmpty) {
                  setState(() {
                    savedAddresses.add(newAddressController.text);
                    _addressController.text = newAddressController.text;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Address")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              onTap: _showAddressSelection, // Show address selection dialog
            ),
          ],
        ),
      ),
    );
  }
}
