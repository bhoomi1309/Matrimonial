import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matrimonial/database/about_us.dart';
import 'package:matrimonial/database/add_user.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'User.dart';
import 'home_content.dart';
import 'login.dart';
import 'analytics.dart';
import 'favourites.dart';
import 'user_profile.dart';

class Home extends StatefulWidget {
  Map<String, dynamic>? newUser;

  Home({super.key, this.newUser});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  int _index = 0;
  bool _isGridView = true;
  bool _isUserDataLoaded = false;

  Future<void> _fetchUsers() async {
    try {
      List<Map<String, dynamic>> users = await _user.getUserList();

      setState(() {});
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
      _index = index;
    });
  }

  User _user = User();

  Map<String, dynamic> userData = {};

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(UserDatabase.USER_ID);

    if (userId != null && userId.isNotEmpty) {

        Map<String, dynamic>? user = await _user.getUserById(userId);
        setState(() {
          userData = user!;
          _isUserDataLoaded = true;
        });
      } else {
        setState(() {
          _isUserDataLoaded = true;
        });
      }
  }

  void initState() {
    super.initState();
    _loadUserData();
    if (widget.newUser != null) {
      setState(() {
        _user.userList.add(widget.newUser!);
      });
      setState(() {});
    }
  }

  BottomNavigationBarItem _buildNavBarItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          if (_currentIndex == index)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pinkAccent.withOpacity(0.3),
              ),
            ),
          Icon(icon, size: 28),
        ],
      ),
      label: label,
    );
  }

  Widget drawerItem(
      BuildContext context, IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () {
        Navigator.pop(context);

        if (index < 4) {
          setState(() {
            _currentIndex = index;
            _index = _currentIndex;
          });
        } else {
          if (index == 4) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddUser(),
                )
            );
          }
          if (index == 5) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutUs(),
                ));
          }
          // setState(() {
          //   _index = index;
          // });
        }
      },
    );
  }

  String getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return "Find Your Match";
      case 1:
        return "Analytics";
      case 2:
        return "Favourites";
      case 3:
        return "My Profile";
      default:
        return "Find Your Match";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeContent(isGridView: _isGridView),
      Analytics(),
      Favourites(),
      UserProfile(onNavigate: changePage),
      AddUser(),
      AboutUs()
    ];
    return WillPopScope(
      onWillPop: () async {
        if (_index != 0) {
          setState(() {
            _currentIndex = 0;
            _index = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: (_index == 4 || _index == 5)
            ? null
            : AppBar(
                title: Text(
                  getAppBarTitle(_index),
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.pink,
                iconTheme: IconThemeData(color: Colors.white),
                actions: _currentIndex == 0
                    ? [
                        IconButton(
                          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                          onPressed: toggleView,
                        ),
                      ]
                    : [],
              ),
        drawer: Drawer(
          child: Container(
            color: Colors.pink,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.pink.shade700,
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(40)),
                          ),
                          child: UserAccountsDrawerHeader(
                            accountName: Text(
                              _isUserDataLoaded ? (userData?[UserDatabase.NAME] ?? "Name") : "Loading...",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            accountEmail: Text(
                              _isUserDataLoaded ? (userData?[UserDatabase.EMAIL] ?? "Email") : "Loading...",
                              style: TextStyle(color: Colors.white70),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade700,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(40)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 16,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: charcoalGrey,
                            backgroundImage: _isUserDataLoaded && userData[UserDatabase.IMAGE] != null &&
                                userData[UserDatabase.IMAGE].isNotEmpty
                                ? FileImage(File(userData[UserDatabase.IMAGE])) as ImageProvider
                                : null,
                            child: (userData.containsKey(UserDatabase.IMAGE) && userData[UserDatabase.IMAGE] != null &&
                                userData[UserDatabase.IMAGE].isNotEmpty)
                                ? null
                                : Text(
                              userData.containsKey(UserDatabase.NAME) && userData[UserDatabase.NAME] != null
                                  ? userData[UserDatabase.NAME][0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          ),
                        ),
                        Positioned(
                          top: 25,
                          left: 10,
                          child: IconButton(
                            icon: Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          drawerItem(context, Icons.person, "My Profile", 3),
                          // drawerItem(context, Icons.favorite, "Match Request", 3),
                          // drawerItem(context, Icons.send, "Sent Request", UserProfile()),
                          // drawerItem(context, Icons.list_alt, "Shortlisted Profiles", UserProfile()),
                          drawerItem(context, Icons.add, "Add New User", 4),
                          Divider(color: Colors.white70, thickness: 0.5),
                          // drawerItem(context, Icons.settings, "Settings", UserProfile()),
                          // drawerItem(context, Icons.privacy_tip, "Privacy Policy", UserProfile()),
                          // drawerItem(context, Icons.info, "Terms & Conditions", UserProfile()),
                          drawerItem(context, Icons.help, "About Us", 5),
                          // drawerItem(context, Icons.logout, "Log Out", UserProfile()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
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
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25, vertical: 5),
                                        foregroundColor: Colors.black,
                                        // Text Color
                                        backgroundColor: Colors.white,
                                        // Button Color
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text("Cancel",
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                    SizedBox(width: 15),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25, vertical: 5),
                                        foregroundColor: Colors.white,
                                        // Text Color
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text("Logout",
                                          style: TextStyle(fontSize: 16)),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.pink),
                            SizedBox(width: 8),
                            Text(
                              "Logout",
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: _pages[_index],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Colors.pinkAccent,
            unselectedItemColor: Colors.grey,
            // selectedLabelStyle: const TextStyle(color: Colors.pinkAccent),
            // unselectedLabelStyle: const TextStyle(color: Colors.grey),
            backgroundColor: Colors.white,
            showUnselectedLabels: false,
            elevation: 10,
            // Removes shadow/elevation
            // type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _index = _currentIndex;
              });
            },
            items: [
              _buildNavBarItem(Icons.home, "Home", 0),
              _buildNavBarItem(Icons.analytics_outlined, "Analytics", 1),
              _buildNavBarItem(Icons.favorite, "Favourites", 2),
              _buildNavBarItem(Icons.person, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }
}