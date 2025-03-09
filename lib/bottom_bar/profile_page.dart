import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _image;
  int _gender = 0;
  String? _profileImageUrl;

  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final ref = _storage.ref().child("profile_images/${_auth.currentUser!.uid}.jpg");
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return "";
    }
  }

  Future<void> _updateProfile() async {
    if (_auth.currentUser == null) {
      print("User not logged in");
      return;
    }
    try {
      String imageUrl = _profileImageUrl ?? "";
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
      }

      await _fireStore.collection("users").doc(_auth.currentUser!.uid).set({
        "name": _nameController.text,
        "phoneNumber": _phoneNumberController.text,
        "address": _addressController.text,
        "email": _emailController.text,
        "gender": _gender == 0 ? "Male" : "Female",
        "profileImage": imageUrl,
      }, SetOptions(merge: true));

      setState(() {
        _profileImageUrl = imageUrl;
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Your profile has been updated successfully!")));
    } catch (e) {
      print("❌ Error updating profile: $e");
    }
  }

  Future<void> _fetchProfileDetails() async {
    if (_auth.currentUser == null) return;
    try {
      DocumentSnapshot userDoc = await _fireStore.collection("users").doc(_auth.currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc["name"] ?? "";
          _phoneNumberController.text = userDoc["phoneNumber"] ?? "";
          _addressController.text = userDoc["address"] ?? "";
          _emailController.text = userDoc["email"] ?? "";
          _gender = userDoc["gender"] == "Male" ? 0 : 1;
          _profileImageUrl = userDoc["profileImage"] ?? "";
        });
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFEF4),
      appBar: AppBar(
        backgroundColor:  const Color(0xFFDFFEF4),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // SizedBox(height: 50),
              Stack(
                children: [
                  InkWell(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!) as ImageProvider
                          : AssetImage("assets/default_profile.png")),
                      child: _image == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                          ? Icon(Icons.camera_alt_outlined, size: 40)
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  suffixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                controller: _nameController,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  suffixIcon: Icon(Icons.mobile_friendly),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                controller: _phoneNumberController,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address',
                  suffixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                controller: _addressController,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                controller: _emailController,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Radio(
                    value: 0,
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  Text('Male'),
                  SizedBox(width: 10),
                  Radio(
                    value: 1,
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  Text('Female'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text("Update Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
