import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SelectCategory extends StatefulWidget {
  const SelectCategory({super.key});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFDFFEF4),
      body: Stack(
        children: [
          Center(
            child: Lottie.asset(
              "assets/splash.json", // ✅ Your Lottie animation file
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.orange
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.orange
                ),
              ),

            ],
          )
        ],
      ),
    );
  }
}
