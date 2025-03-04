import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:matrimonial/database/User.dart';
import 'package:matrimonial/database/login.dart';
import 'package:matrimonial/database/register_user_details.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool isEditing = false;
  bool _isObscured=true;
  bool _isObscuredConfirm=true;
  User _user = User();

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  bool isEmailExist(String email) {
    return _user.userList.any((user) => user[UserDatabase.EMAIL] == email);
  }

  void handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = hashPassword(_passwordController.text.trim());

    // Check if user already exists
    bool userExists = isEmailExist(email);
    if (userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email already registered! Try logging in.'), backgroundColor: Colors.red),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterUserDetails(name: name, email: email, password: password),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blushPink,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  "Create an Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Sign up to get started",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: lightBg,
                          labelText: 'Name',
                          labelStyle: TextStyle(color: pink400),
                          prefixIcon: Icon(Icons.person, color: pink400),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          RegExp nameRegExp = RegExp(r"^[a-zA-Z\s']{3,50}$");
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          } else if (!nameRegExp.hasMatch(value)) {
                            return 'Enter a valid full name (3-50 characters, alphabets only)';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s']")),
                        ],
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: lightBg,
                          labelStyle: TextStyle(color: pink400),
                          prefixIcon: Icon(Icons.email, color: pink400),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          RegExp emailRegExp = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          } else if (!emailRegExp.hasMatch(value)) {
                            return 'Enter a valid email address';
                          } else if (!isEditing && isEmailExist(value)) {
                            return 'This email is already registered';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        obscuringCharacter: '•',
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: lightBg,
                          prefixIcon:
                          Icon(Icons.lock_outline, color: pink400),
                          labelStyle: TextStyle(color: pink400),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured ? Icons.visibility_off : Icons.visibility,
                              color: pink400,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
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

                      SizedBox(height: 20),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isObscuredConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          filled: true,
                          fillColor: lightBg,
                          prefixIcon:
                          Icon(Icons.lock_clock, color: pink400),
                          labelStyle: TextStyle(color: pink400),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscuredConfirm ? Icons.visibility_off : Icons.visibility,
                              color: pink400,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscuredConfirm = !_isObscuredConfirm;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController?.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.pink[400],
                          ),
                          child: Text(
                            "Register",
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
                    Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: Text(
                        "Login",
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