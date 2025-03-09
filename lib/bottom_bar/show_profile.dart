import 'package:flutter/material.dart';



class ShowProfilePage extends StatefulWidget {
  String name;
  String address;
  String email;
  String phone;

   ShowProfilePage({super.key,
     required this.name,
     required this.address,
     required this.email,
     required this.phone,

   });

  @override
  State<ShowProfilePage> createState() => _ShowProfilePageState();
}

class _ShowProfilePageState extends State<ShowProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int gender = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFEF4),
      appBar: AppBar(
        backgroundColor:  const Color(0xFFDFFEF4),
        title: Text("Profile"),
      ),
      body: Column(
        children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: "name:${widget.name}",
            suffixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
            ),
          controller: _nameController,
        ),
        SizedBox(height: 10),
        TextFormField(
        decoration: InputDecoration(
    labelText: "address:${widget.address}",
    suffixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
    ),
    controller: _addressController,
    ),
    SizedBox(
    height: 10,
    ),
    TextFormField(
    decoration: InputDecoration(
    labelText: "email:${widget.email}",
    suffixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
    ),
    controller: _emailController,
    ),
    SizedBox(
    height: 10,
    ),
    TextFormField(
    decoration: InputDecoration(
    labelText: "PhoneNumber:${widget.phone}",
    suffixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
    ),
    controller: _phoneController,
    ),
          SizedBox(
            height: 40,
          ),

          ]
      ),
    );
  }
}
