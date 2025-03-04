import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrimonial/database/add_user.dart';
import 'package:matrimonial/database/home.dart';
import 'package:matrimonial/database/login.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget{

  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  Future<int?> getSavedUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("All stored keys: ${prefs.getKeys()}");
    if (prefs.containsKey(UserDatabase.USER_ID)) {
      String? userIdString = prefs.getString(UserDatabase.USER_ID);
      print("Retrieved USER_ID (String): $userIdString");
      if (userIdString != null) {
        return int.tryParse(userIdString);
      }
    } else {
      print("USER_ID not found in SharedPreferences");
    }
    return null;
  }

  @override
  void initState(){
    super.initState();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 1));
    int? userId = await getSavedUserId();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => userId==null?Login():Home()),
    );
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => Home()),
    // );

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => AddUser()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 210,
              width: 210,
            ),
            // Text(
            //   'Marry Me',
            //   style: TextStyle(
            //     fontSize: 35,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //     letterSpacing: 2,
            //     fontFamily: 'DancingScript'
            //   ),
            // ),
            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}