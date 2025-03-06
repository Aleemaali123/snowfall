import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../bottom_bar/main_screen.dart';
import 'register_page.dart';

const String firebaseUrl = "https://your-project-id-default-rtdb.firebaseio.com/users.json";
const String firebaseAuthSignup = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=your-api-key";
const String firebaseAuthLogin = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=your-api-key";

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

  // ✅ Function to register user (POST)
  Future<void> _registerUser() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(firebaseAuthSignup),
        body: json.encode({
          "email": _enteredEmail,
          "password": _enteredPassword,
          "returnSecureToken": true,
        }),
        headers: {"Content-Type": "application/json"},
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        // ✅ Save user details in Firebase Database
        final userId = data["localId"];
        await _saveUserToDatabase(userId);
        print("✅ User registered successfully: $userId");
      } else {
        print("❌ Error: ${data["error"]["message"]}");
      }
    } catch (e) {
      print("❌ Error registering user: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Function to save user details in Firebase Database (POST)
  Future<void> _saveUserToDatabase(String userId) async {
    final response = await http.post(
      Uri.parse(firebaseUrl),
      body: json.encode({
        "uid": userId,
        "email": _enteredEmail,
        "createdAt": DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      print("✅ User data saved in Firebase");
    } else {
      print("❌ Failed to save user data");
    }
  }

  // ✅ Function to login user (GET)
  Future<void> _loginUser() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(firebaseAuthLogin),
        body: json.encode({
          "email": _enteredEmail,
          "password": _enteredPassword,
          "returnSecureToken": true,
        }),
        headers: {"Content-Type": "application/json"},
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        print("✅ Login Success: ${data["email"]}");
      } else {
        print("❌ Error: ${data["error"]["message"]}");
      }
    } catch (e) {
      print("❌ Error logging in: $e");
    } finally {
      setState(() => _isLoading = false);
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
                        onSaved: (value) => _enteredEmail = value!,
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
                        onSaved: (value) => _enteredPassword = value!,
                      ),
                      const SizedBox(height: 12),
                      // _isLoading
                      //     ? const CircularProgressIndicator()
                      //     : ElevatedButton(
                      //   onPressed: _isLogin ? _loginUser : _registerUser,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      //     foregroundColor: Theme.of(context).colorScheme.primary,
                      //   ),
                      //   child: Text("Login"),
                      // ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>MainScreen()
                            ));
                          },
                          child: Text("Login")
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>UserRegisterPage()));
                          });
                        },
                        child: Text( "Don't have an account? Signup here"),
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
