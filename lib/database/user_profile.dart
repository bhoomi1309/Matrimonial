import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'User.dart';
import 'add_user.dart';
import 'login.dart';

class UserProfile extends StatefulWidget {
  final Function(int) onNavigate;

  UserProfile({super.key, required this.onNavigate});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  User _user = User();

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(UserDatabase.USER_ID);

    if (userId != null) {
      Map<String, dynamic>? user = await _user.getUserById(userId);
      if (user != null) {
        setState(() {
          userData = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE4E1),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: userData![UserDatabase.IMAGE] != null &&
                                  userData![UserDatabase.IMAGE].isNotEmpty
                              ? Image.file(
                                  File(userData![UserDatabase.IMAGE]),
                                  height: 320,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 320,
                                  width: double.infinity,
                                  color: charcoalGrey,
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    radius: 100,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    child: Text(
                                      userData![UserDatabase.NAME][0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddUser(
                                          userData: userData,
                                          index:
                                              userData![UserDatabase.USER_ID],
                                        ),
                                      ),
                                    ).then((updatedUser) {
                                      if (updatedUser != null) {
                                        _loadUserData();
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.edit,
                                      color: charcoalGrey, size: 28),
                                ),
                              ),
                              const SizedBox(width: 30),
                              CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.pink,
                                  child: IconButton(
                                      onPressed: () {
                                        widget.onNavigate(2);
                                      },
                                      icon: const Icon(Icons.favorite,
                                          color: Colors.white, size: 35))),
                              const SizedBox(width: 30),
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          backgroundColor: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red,
                                                  size: 50,
                                                ),
                                                const SizedBox(height: 15),
                                                Text(
                                                  'Delete Confirmation',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: charcoalGrey,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                const Text(
                                                  'Are you sure you want to delete your account?',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        style: TextButton.styleFrom(
                                                          backgroundColor: Colors.grey,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          if (userData != null) {
                                                            String userId = userData![UserDatabase.USER_ID];

                                                            _user.deleteUser(index: userId);

                                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                                            await prefs.clear();

                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: const Text(
                                                                  'Account deleted successfully!',
                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                ),
                                                                backgroundColor: Colors.red,
                                                                duration: Duration(seconds: 2),
                                                              ),
                                                            );

                                                            Navigator.pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => Login()),
                                                                  (Route<dynamic> route) => false,
                                                            );

                                                          }
                                                        },
                                                        style: TextButton.styleFrom(
                                                          backgroundColor: const Color.fromRGBO(252, 3, 3, 1),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData![UserDatabase.NAME] ?? "User Name",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Row(
                            children: [
                              Text(
                                "${userData![UserDatabase.AGE]} years",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              Text(
                                "  |  ",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              Text(
                                "${userData![UserDatabase.GENDER]}",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.pink, size: 20),
                              SizedBox(width: 6),
                              Text(userData![UserDatabase.CITY] ?? "Location",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black)),
                            ],
                          ),
                          SizedBox(height: 12),
                          Divider(thickness: 1),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.pink, size: 20),
                              SizedBox(width: 8),
                              Text(
                                  '${userData?[UserDatabase.PHONE] ?? "Phone"}',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.email, color: Colors.pink, size: 20),
                              SizedBox(width: 8),
                              Text(userData![UserDatabase.EMAIL] ?? "Email",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.cake, color: Colors.pink, size: 20),
                              SizedBox(width: 8),
                              Text(
                                  "DOB: ${userData![UserDatabase.DOB] ?? 'N/A'}",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(thickness: 1),
                          SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Looking For
                              Text(
                                "Looking For",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.favorite,
                                      color: Colors.pink, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                      userData?[UserDatabase.LOOKING_FOR] ??
                                          "N/A",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(height: 16),
                              Divider(thickness: 1),

                              // Religion
                              Text(
                                "Religion",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.church,
                                      color: Colors.pink, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                      userData?[UserDatabase.RELIGION] ?? "N/A",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),

                              SizedBox(height: 16),
                              Divider(thickness: 1),

                              Text(
                                "Mother Tongue",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.language,
                                      color: Colors.pink, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                      userData?[UserDatabase.MOTHER_TONGUE] ??
                                          "N/A",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),

                              SizedBox(height: 16),
                              Divider(thickness: 1),

                              Text(
                                "Marital Status",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.ring_volume,
                                      color: Colors.pink, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                      userData?[UserDatabase.MARITAL_STATUS] ??
                                          "N/A",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),

                              if (userData?[UserDatabase.BIO] != null &&
                                  userData![UserDatabase.BIO]
                                      .toString()
                                      .isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16),
                                    Divider(thickness: 1),
                                    Text(
                                      "Bio",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      userData![UserDatabase.BIO],
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(thickness: 1),
                          Text(
                            "Hobbies",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children:
                                (userData![UserDatabase.HOBBIES] as String)
                                    .split(',')
                                    .map((hobby) {
                              return Chip(
                                  label: Text(hobby.trim()),
                                  backgroundColor: Colors.pink[100]);
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              // SizedBox(
                              //   width: double.infinity,
                              //   child: ElevatedButton.icon(
                              //     onPressed: () {
                              //       // Navigate to Edit Profile Page
                              //     },
                              //     icon: Icon(Icons.edit, color: Colors.white),
                              //     label: Text("Edit Profile",
                              //         style: TextStyle(
                              //             fontSize: 18,
                              //             fontWeight: FontWeight.bold,
                              //             color: Colors.white)),
                              //     style: ElevatedButton.styleFrom(
                              //       padding: EdgeInsets.symmetric(vertical: 14),
                              //       elevation: 5,
                              //       backgroundColor: Colors.pink,
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(12),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    bool confirmLogout = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20), // Rounded Corners
                                        ),
                                        backgroundColor: Color(0xFFFFE4E1),
                                        // Blush Pink Background
                                        title: Text(
                                          "Logout",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        content: Text(
                                          "Are you sure you want to logout?",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87),
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                        // Center the buttons
                                        actions: [
                                          Row(
                                            children: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 5),
                                                  foregroundColor: Colors.black,
                                                  // Text Color
                                                  backgroundColor: Colors.white,
                                                  // Button Color
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: Text("Cancel",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ),
                                              SizedBox(width: 15),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 5),
                                                  foregroundColor: Colors.white,
                                                  // Text Color
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: Text("Logout",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmLogout == true) {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.remove(UserDatabase.USER_ID);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Login()),
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.logout, color: Colors.white),
                                  label: Text("Logout",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    elevation: 5,
                                    backgroundColor: charcoalGrey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
