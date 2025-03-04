import 'package:chtapp/screens/auth.dart';
import 'package:chtapp/screens/homeScreen.dart';
import 'package:chtapp/screens/register_page.dart';
import 'package:chtapp/screens/request.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
=======
>>>>>>> 9f7300153d54612f6a1810e3be46ac5bc3c3b6ce
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthScreen(),
    );
  }
}
<<<<<<< HEAD



class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Loading state
        }

        // If user is logged in, go to HomeScreen, else go to LoginScreen
        if (snapshot.hasData) {
          return Homescreen();
        } else {
          return AuthScreen();
        }
      },
    );
  }
}
=======
>>>>>>> 9f7300153d54612f6a1810e3be46ac5bc3c3b6ce
