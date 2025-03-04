import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matrimonial/database/add_user.dart';
import 'package:matrimonial/database/user_database.dart';
import 'User.dart';
import 'home.dart';
import '../utils/colors.dart';

class UserDetails extends StatefulWidget {
  late final Map<String, dynamic> userData;
  int index;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdate;

  UserDetails(
      {Key? key,
      required this.userData,
      required this.index,
      this.onDelete,
      this.onUpdate})
      : super(key: key);

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  List<bool> _isStepOpen = List.generate(6, (index) => true);
  User _users = User();
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    userData = Map.from(widget.userData);
  }

  void _toggleStep(int index) {
    setState(() {
      _isStepOpen[index] = !_isStepOpen[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details",
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildUserHeader(),
              const SizedBox(height: 20),
              _buildStepper(),
              const SizedBox(height: 30),
              _buildActionButtons()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bio,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Color(0xFF333333),
          backgroundImage: userData[UserDatabase.IMAGE] != null &&
              userData[UserDatabase.IMAGE].isNotEmpty &&
              !userData[UserDatabase.IMAGE].toLowerCase().contains("image")
              ?FileImage(File(userData[UserDatabase.IMAGE]))
          as ImageProvider
              : null,
          child: (userData[UserDatabase.IMAGE] == null ||
              userData[UserDatabase.IMAGE].isEmpty) ||
              userData[UserDatabase.IMAGE].toLowerCase().contains("image")
              ? Text(
            userData[UserDatabase.NAME][0].toUpperCase(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          userData[UserDatabase.NAME],
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          userData[UserDatabase.EMAIL],
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    List<String> _stepTitles = [
      "Basic Info",
      "Contact Details",
      "Personal Details",
      "Preferences",
    ];

    if (userData[UserDatabase.HOBBIES] != null &&
        userData[UserDatabase.HOBBIES] != '') {
      _stepTitles.add("Hobbies");
    }

    if (userData[UserDatabase.BIO] != null &&
        userData[UserDatabase.BIO].isNotEmpty) {
      _stepTitles.add("Bio");
    }
    return Column(
      children: List.generate(_stepTitles.length, (index) {
        return Column(
          children: [
            GestureDetector(
              onTap: () => _toggleStep(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_stepTitles[index],
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _isStepOpen[index]
                  ? _stepContent(index, _stepTitles)
                  : SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  Widget _stepContent(int index, List<String> stepTitles) {
    if (stepTitles[index] == "Hobbies") {
      return _buildHobbiesSection(userData[UserDatabase.HOBBIES]);
    }
    if (stepTitles[index] == "Bio") {
      return _buildBioSection(userData[UserDatabase.BIO]);
    }
    List<Map<String, String>> details = [
      {
        "Name": userData[UserDatabase.NAME],
        "Age": userData[UserDatabase.AGE].toString(),
        "Gender": userData[UserDatabase.GENDER]
      },
      {
        "Phone": userData[UserDatabase.PHONE].toString(),
        "Email": userData[UserDatabase.EMAIL],
        "City": userData[UserDatabase.CITY]
      },
      {
        "DOB": userData[UserDatabase.DOB],
        "Religion": userData[UserDatabase.RELIGION],
        "Mother Tongue": userData[UserDatabase.MOTHER_TONGUE]
      },
      {
        "Looking For": userData[UserDatabase.LOOKING_FOR],
        "Marital Status": userData[UserDatabase.MARITAL_STATUS]
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: details[index].entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 5,
                  child: Text(
                    entry.key,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: Text(
                      entry.value,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHobbiesSection(String hobbies) {
    List<String> hobbyList = hobbies.split(',').map((h) => h.trim()).toList();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: hobbyList.map((hobby) {
              return Chip(
                label: Text(
                  hobby,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                backgroundColor: Colors.pinkAccent,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddUser(
                    userData: userData,
                    index: userData[UserDatabase.USER_ID],
                    onUpdate: () {
                      widget.onUpdate?.call();
                      setState(() {});
                    },
                  ),
                )).then((updatedUser) {
              setState(() {
                userData = updatedUser!;
              });
            });
          },
          icon: Icon(Icons.edit, color: Colors.white),
          label: Text("Edit",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Delete Confirmation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: charcoalGrey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Are you sure you want to delete this user?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userData[UserDatabase.NAME],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: deepBrown,
                              ),
                            ),
                          ],
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
                                child: Text(
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
                                onPressed: () {
                                  _users.deleteUser(
                                      index: userData[UserDatabase.USER_ID]);
                                  widget.onDelete!();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("User deleted successfully"),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(252, 3, 3, 1),
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
          icon: Icon(Icons.delete, color: Colors.white),
          label: Text("Delete",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
