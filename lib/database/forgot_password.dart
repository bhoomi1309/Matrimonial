import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import 'User.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  bool _isPasswordVisible = false;
  User _user=User();

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var hashed = sha256.convert(bytes);
    return hashed.toString();
  }

  void handleResetPassword() async {
    String email = _emailController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    newPassword=hashPassword(newPassword);

    if (email.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and new password"),
            backgroundColor: Colors.red),
      );
      return;
    }

    bool success = await _user.resetPassword(email, newPassword);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset successful!"),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No user found with this email!"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE4E1),
      appBar: AppBar(
        title: Text("Reset Password"),
        backgroundColor: Colors.pink[400],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.lock_reset, size: 80, color: Colors.pink[400]),
                  SizedBox(height: 20),
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Enter your email and new password.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email, color: Colors.pink[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      RegExp emailRegExp = RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                      if (!emailRegExp.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "New Password",
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
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty.';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){
                        handleResetPassword();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.pink[400],
                      ),
                      child: Text(
                        "Reset Password",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
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