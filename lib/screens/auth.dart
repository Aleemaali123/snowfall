import 'package:chtapp/screens/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'show_request.dart';

final _firebase = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance; // ✅ Firestore Instance

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isLoading = false;
  final _form = GlobalKey<FormState>();
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _checkUserLoggedIn(); // ✅ Check if user is already logged in
  // }
  //
  // Future<void> _checkUserLoggedIn() async {
  //   User? user = _firebase.currentUser;
  //   if (user != null) {
  //     Future.delayed(Duration.zero, () {
  //       Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => Homescreen()),
  //       );
  //     });
  //   }
  // }

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential;
      if (_isLogin) {
        // ✅ Login User
        userCredential = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        // ✅ Register User
        userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // ✅ Save User Data in Firestore
        await _firestore.collection("users").doc(userCredential.user!.uid).set({
          "email": _enteredEmail,
          "uid": userCredential.user!.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });

       // print("✅ User Data Saved in Firestore");
      }

      print("✅ Auth Success: ${userCredential.user?.email}");

      // if (mounted) {
      //   Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => MainScreen()),
      //   );
      // }
    } on FirebaseAuthException catch (error) {
      //Navigate to homepage after successfull login
      if(context.mounted){
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(
        //     builder: (context)=>MainScreen()
        // )
       // );
      }

    }
    on FirebaseAuthException catch (error) {
      String message = "Authentication failed!";
      if (error.code == "email-already-in-use") {
        message = "Email is already registered!";
      } else if (error.code == "wrong-password") {
        message = "Invalid password!";
      } else if (error.code == "user-not-found") {
        message = "User does not exist!";
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print("❌ Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Lottie Snowfall Background
          Positioned.fill(
            child: Lottie.asset(
              "assets/Animation - 1740996453034.json", // Replace with your Lottie animation
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Authentication UI
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredPassword = value!;
                        },
                      ),
                      const SizedBox(height: 12),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Text("Login"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => UserRegisterPage()
                          ));
                        },
                        child: Text("Don't have an account? Signup here"),



                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
