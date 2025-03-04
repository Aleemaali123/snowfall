import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'auth.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  int gender = 0; // 0 = Male, 1 = Female

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _registerUser() async{
    // if (_formKey.currentState!.validate()) return;
    // setState(() {
    //   _isLoading = true;
    // });

    try{
      //1.Register user with firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
           password: _passwordController.text.trim()
      );
      print(userCredential.user!.uid);

      //2. save the additional details in firestore
      await _firestore.collection("users").doc(
        userCredential.user!.uid
      ).set({
        "name": _nameController.text.trim(),
        "email" : _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "gender": gender == 0 ? "Male" : "female",
        "uid": userCredential.user!.uid,
        "createdAt": Timestamp.now()
      });

      //3. Navigate to loginpage
      if(context.mounted){
        Navigator.pushReplacement(
            context, MaterialPageRoute(
            builder: (context)=> AuthScreen(),
        )
        );
      }
    }
    catch (e){
      //show erron message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content : Text("Error: ${e.toString()}"))
      );
    }

    setState(() {
      _isLoading = false;
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     //backgroundColor: Theme.of(context).colorScheme.primary,

      body: Stack(
        children: [
      // ✅ Lottie Snowfall Background
      Positioned.fill(
      child: Lottie.asset(
        "assets/register.json", // Replace with your Lottie animation
        fit: BoxFit.cover,
      ),
    ),


      Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Register here...",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Enter your name",
                            suffixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          validator: (value) => value!.isEmpty ? "Name is required" : null,
                        ),
                        const SizedBox(height: 10),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Enter your email",
                            suffixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                          value!.isEmpty || !value.contains("@") ? "Enter a valid email" : null,
                        ),
                        const SizedBox(height: 10),

                        // Phone Number Field
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            suffixIcon: const Icon(Icons.phone_android),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                          value!.length < 10 ? "Enter a valid phone number" : null,
                        ),
                        const SizedBox(height: 10),

                        // Gender Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Gender:", style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                Radio(
                                  value: 0,
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                ),
                                const Text("Male"),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: 1,
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                ),
                                const Text("Female"),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          validator: (value) =>
                          value!.length < 6 ? "Password must be at least 6 characters" : null,
                        ),
                        const SizedBox(height: 10),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          validator: (value) =>
                          value != _passwordController.text ? "Passwords do not match" : null,
                        ),
                        const SizedBox(height: 20),

                        // Signup Button
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _registerUser,
                          child: const Text("Sign Up"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]
    )
    );
  }
}
