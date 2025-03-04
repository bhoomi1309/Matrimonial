import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matrimonial/database/User.dart';
import 'package:matrimonial/database/forgot_password.dart';
import 'package:matrimonial/database/home.dart';
import 'package:matrimonial/database/register.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';


class Login extends StatefulWidget {

  String? email;

  Login({super.key, this.email});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final GlobalKey<FormState> _key = GlobalKey();
  User _user=User();

  void initState(){
    super.initState();
    if(widget.email!=null){
      _emailController.text=widget.email!;
    }
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var hashed = sha256.convert(bytes);
    return hashed.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE4E1),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 120,
                  color: Colors.pink,
                ),
                SizedBox(height: 20),
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Login to continue",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                SizedBox(height: 40),

                Form(
                  key: _key,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon:
                              Icon(Icons.email, color: Colors.pink[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          RegExp emailRegExp = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          } else if (!emailRegExp.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock, color: Colors.pink[400]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty.';
                          }
                          String pattern = r'^(?!.*\s).{8,}$';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value)) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword(),));
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.pink[700]),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_key.currentState!.validate()) {
                              String email = _emailController.text.trim();
                              String password = _passwordController.text.trim();
                              password=hashPassword(password);
                              String? userId = await _user.getUserId(email, password);

                              if (userId != null) {
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                pref.setString(UserDatabase.USER_ID, userId);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => Home()),
                                );
                              } else {
                                var snackBar = SnackBar(
                                  content: Text(
                                      'Invalid email or password! Please try again.'),
                                  backgroundColor: Colors.red,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.pink[400],
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register(),));
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.pink[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
