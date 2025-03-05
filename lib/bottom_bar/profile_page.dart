import 'package:flutter/material.dart';

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

  int gender = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFDFFEF4), // ✅ Light greenish blue color

        body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Padding(
                padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                  children  :[

                    InkWell(
                      onTap: () {

                      },
                      child: CircleAvatar(
                        radius: 80,
                      ),
                    ),
                    // IconButton(
                    //     onPressed: () {
                    //
                    //     },
                    //     icon: Icon(Icons.edit)
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                  ]

                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      suffixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    controller: _nameController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'PhoneNumber',
                      suffixIcon: Icon(Icons.mobile_friendly),
                      border: OutlineInputBorder(),
                    ),
                    controller: _phoneNumberController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      suffixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    controller: _addressController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'EmailAddress',
                      suffixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    controller: _emailController,
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 0,
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value!;
                             }
                          );
                        },
                      ),
                      Text('Male'),
        SizedBox(
          width: 10,
        ),
                      Radio(
                        value: 1,
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value!;
                          }
                          );
                        },
                      ),
                      Text('female'),


                ],
              ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {

                      },
                      child: Text("Update Profile")
                  )
        ]
            ),
            ),
          ],
        ),
      )
    );
  }
}
