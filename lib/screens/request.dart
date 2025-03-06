import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../bottom_bar/Homepage.dart';
import 'show_request.dart';

class UserRequestPage extends StatefulWidget {
  const UserRequestPage({super.key});

  @override
  State<UserRequestPage> createState() => _UserRequestPageState();
}

class _UserRequestPageState extends State<UserRequestPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  File? image1;
  File? image2;

  int category = 0;

  //agency List
  List<String> agencies = [
    "Agency 1", "Agency 2", "Agency 3", "Agency 4", "Agency 5"
  ];
  String? selectedAgency;



  // Function to get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ✅ Step 1: Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    // ✅ Step 2: Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permissions are permanently denied.")),
      );
      return;
    }

    // ✅ Step 3: Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // ✅ Step 4: Convert coordinates to human-readable address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fullAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";

        setState(() {
          _locationController.text = fullAddress;
        });

        print("✅ Current Location: $fullAddress");
      }
    } catch (e) {
      print("❌ Error getting address: $e");
    }
  }





  // Function to show Date & Time picker
  Future<void> _selectDateTime(BuildContext context) async {
    // Step 1: Select Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2100), // Maximum date
    );

    if (pickedDate != null) {
      // Step 2: Select Time after date is picked
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine Date & Time
        DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format Date & Time for display
        String formattedDateTime =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}";

        // Update TextFormField
        setState(() {
          _dateTimeController.text = formattedDateTime;
        });
      }
    }
  }

  // Function to pick an image from the gallery
  Future<void> pickImage(int imageNumber) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (imageNumber == 1) {
          image1 = File(pickedFile.path);
        } else {
          image2 = File(pickedFile.path);
        }
      });
    }
  }

  // Function to remove an image
  void removeImage(int imageNumber) {
    setState(() {
      if (imageNumber == 1) {
        image1 = null;
      } else {
        image2 = null;
      }
    });
  }



  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      Reference storageRef =
      FirebaseStorage.instance.ref().child('requests/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL(); // Get download URL
    } catch (e) {
      print("❌ Error uploading image: $e");
      return null;
    }
  }


  void _sendRequest() async {
    if (_locationController.text.isEmpty || _areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please fill all required fields!")),
      );
      return;
    }

    try {
      String? imageUrl1;
      String? imageUrl2;

      // Upload image1 if available
      if (image1 != null) {
        imageUrl1 = await uploadImage(image1!, "image1_${DateTime.now().millisecondsSinceEpoch}.jpg");
      }

      // Upload image2 if available
      if (image2 != null) {
        imageUrl2 = await uploadImage(image2!, "image2_${DateTime.now().millisecondsSinceEpoch}.jpg");
      }

      // Store request data in Firestore
      DocumentReference requestRef = await FirebaseFirestore.instance.collection('request').add({
        'location': _locationController.text,
        'area': _areaController.text,
        'date_time': _dateTimeController.text,
        'category': category == 0 ? "Bid" : "Direct",
        'agency': category == 1 ? selectedAgency : null,
        'image1': imageUrl1 ?? "", // Store Firebase Storage URL
        'image2': imageUrl2 ?? "",
        'status':"pending",
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Request Sent Successfully!")),
      );



      // Navigate to homepage after successful submission
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StatusTabScreen()),
      );

      // // ✅ Start listening for status change
      // _trackRequestStatus(requestRef.id);
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send request: $e")),
      );
    }
  }


  // void _trackRequestStatus(String orderId) {
  //   FirebaseFirestore.instance.collection('request').doc(orderId).snapshots().listen((snapshot) {
  //     if (snapshot.exists) {
  //       String status = snapshot.data()?['status'] ?? "pending";
  //
  //       if (status == "accepted") {
  //         // ✅ Navigate to Tracking Screen only when accepted
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => TrackingScreen(orderId: orderId)),
  //         );
  //       }
  //     }
  //   });
  // }


  // void acceptRequest(String orderId) {
  //   FirebaseFirestore.instance.collection('request').doc(orderId).update({
  //     'status': "accepted",
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFEF4), // ✅ Light greenish blue color

      resizeToAvoidBottomInset: true,
      //backgroundColor: Theme.of(context).colorScheme.background,
      // appBar: AppBar(
      //   title: const Text("User Request Page"),
      //   centerTitle: true,
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //
      // ),
      body:
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text("Send Request here...",
                  style: TextStyle(
                    fontSize: 25
                  ),
                  ),
                   SizedBox(height: 10),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: "Use Current  Location",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.location_on, color: Colors.red),
                    ),
                    onTap: () {
                      _getCurrentLocation();
                    },
                  ),
                  const SizedBox(height: 10),
                  // TextFormField(
                  //   controller: _areaController,
                  //   decoration: InputDecoration(
                  //     labelText: "Approximate Area",
                  //     suffixIcon: const Icon(Icons.area_chart),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //   ),
                  // ),

                  TextFormField(
                    controller: _areaController,
                    readOnly: true, // Prevents manual input
                    decoration: InputDecoration(
                      labelText: "Approximate Area",
                      suffixIcon: Icon(Icons.area_chart),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text("Use current location"),
                                leading: Icon(Icons.my_location),
                                onTap: () {
                                  // Implement logic to get current location
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text("Enter new address"),
                                leading: Icon(Icons.add),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Show a dialog or new screen to enter the address
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                   SizedBox(height: 10),
                  const Text("Upload Weather Images"),
                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          if (image1 != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    image1!,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => removeImage(1),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () => pickImage(1),
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text("Upload 1"),
                            ),
                        ],
                      ),
                      Column(
                        children: [
                          if (image2 != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    image2!,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => removeImage(2),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () => pickImage(2),
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text("Upload 2"),
                            ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  TextFormField(
                    controller: _dateTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "select Date & time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            _selectDateTime(context);
                          },
                          icon: Icon(Icons.access_time)),
                    ),
                    onTap: () => _selectDateTime(context),
                  ),
                   SizedBox(
                     height: 10,
                   ),
                   Row(
                     children: [
                       Radio(
                           value: 0,
                           groupValue: category,
                           onChanged: (value) {
                             setState(() {
                               category = value!;
                             });
                           },
                       ),
                       SizedBox(
                         width: 5,
                       ),
                       Text("Bid"),
                       SizedBox(
                         width: 5,
                       ),
                       Radio(
                         value: 1,
                         groupValue: category,
                         onChanged: (value) {
                           setState(() {
                             category = value!;
                           });
                         },
                       ),
                       Text("Direct")
                     ],
                   ),
                   if(category == 1)...[
                     SizedBox(
                       height: 10,
                     ),
                     Text("Select Agency",
                       style: TextStyle(fontWeight: FontWeight.bold),
                     ),
                     SizedBox(
                       height: 5,
                     ),
                     DropdownButtonFormField(
                       value: selectedAgency,
                         hint: Text("choose an agency"),
                         items: agencies.map((agency){
                           return DropdownMenuItem(
                             value: agency,
                             child: Text(agency),
                           );
                         }).toList(),
                         onChanged: (value) {
                           setState(() {
                             selectedAgency = value!;
                           });
                         },
                       decoration: InputDecoration(
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(10),
                         ),
                         contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                       ),
                     )

                   ],

                   SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _sendRequest();
                    },
                    child: const Text("Send Request"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
