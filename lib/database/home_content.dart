import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'User.dart';
import 'add_user.dart';
import 'package:matrimonial/database/user_details.dart';

class HomeContent extends StatefulWidget {
  final bool isGridView;

  HomeContent({required this.isGridView});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final User _user = User();
  int? _tappedIndex;
  List<Map<String, dynamic>> list = [];
  List<Map<String, dynamic>> filteredList = [];
  FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  Future<void> _fetchUsers() async {
    try {
      List<Map<String, dynamic>> users = await _user.getUserList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? loggedInUserId = prefs.getString(UserDatabase.USER_ID);

      if (loggedInUserId == null) {
        print("No logged-in user ID found in SharedPreferences.");
        return;
      }

      List<Map<String, dynamic>> filteredUsers = users.where((user) {
        return user[UserDatabase.USER_ID] != loggedInUserId;
      }).toList();

      setState(() {
        list = filteredUsers;
        filteredList = List.from(filteredUsers);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchUsers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchFocusNode.hasFocus) {
        FocusScope.of(context).unfocus();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUsers();
    });
  }

  void _filterList(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredList = list.where((user) {
        return user[UserDatabase.NAME].toLowerCase().contains(query) ||
            user[UserDatabase.CITY].toLowerCase().contains(query) ||
            user[UserDatabase.AGE].toString().toLowerCase().contains(query) ||
            user[UserDatabase.PHONE].toString().toLowerCase().contains(query) ||
            user[UserDatabase.EMAIL].toLowerCase().contains(query) ||
            user[UserDatabase.GENDER].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _sortList(String criteria) {
    setState(() {
      if (criteria == 'Name') {
        filteredList.sort((a, b) => a['Name'].compareTo(b['Name']));
      } else if (criteria == 'Age') {
        filteredList.sort((a, b) => a['Age'].compareTo(b['Age']));
      } else if (criteria == 'City') {
        filteredList.sort((a, b) => a['City'].compareTo(b['City']));
      }
    });
  }

  void _reverseList() {
    setState(() {
      filteredList = filteredList.reversed.toList();
    });
  }

  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration(milliseconds: 10), () {
      _searchFocusNode.unfocus();
    });
  }

  void updateFavoriteStatus(int index, int newValue) {
    setState(() {
      _fetchUsers();
      filteredList[index][UserDatabase.IS_FAVOURITE] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: mistyRose,
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    onChanged: (query) => _filterList(query),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, color: pink400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort, color: pink300),
                  onSelected: (value) {
                    _sortList(value);
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'Name',
                        child: Text(
                          'Sort by Name',
                          style: TextStyle(fontSize: 16, color: charcoalGrey),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Age',
                        child: Text(
                          'Sort by Age',
                          style: TextStyle(fontSize: 16, color: charcoalGrey),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'City',
                        child: Text(
                          'Sort by City',
                          style: TextStyle(fontSize: 16, color: charcoalGrey),
                        ),
                      ),
                    ];
                  },
                ),
                IconButton(
                  icon: Icon(Icons.swap_vert, color: pink300),
                  onPressed: _reverseList,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(
                        child: Text(
                          "No Users Found",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : widget.isGridView
                        ? GridView.builder(
                            itemCount: filteredList.length,
                            physics: BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              return AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  transform: Matrix4.translationValues(
                                      0, _tappedIndex == index ? -5 : 0, 0),
                                  decoration: BoxDecoration(
                                    boxShadow: _tappedIndex == index
                                        ? [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(15),
                                      splashColor:
                                          Colors.pinkAccent.withOpacity(0.3),
                                      highlightColor:
                                          Colors.pinkAccent.withOpacity(0.2),
                                      onTapDown: (_) {
                                        setState(() => _tappedIndex = index);
                                        FocusScope.of(context).unfocus();
                                      },
                                      onTapUp: (_) {
                                        setState(() => _tappedIndex = null);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserDetails(
                                              userData: filteredList[index],
                                              index: index,
                                              onDelete: () {
                                                setState(() {
                                                  filteredList.removeAt(index);
                                                });
                                              },
                                              onUpdate: () {
                                                setState(() {
                                                  _fetchUsers();
                                                });
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      onTapCancel: () =>
                                          setState(() => _tappedIndex = null),
                                      child: UserCard(
                                        user: filteredList[index],
                                        onFavoriteToggle: (newValue) =>
                                            updateFavoriteStatus(
                                                index, newValue),
                                        onDelete: () {
                                          setState(() {
                                            filteredList.removeAt(index);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "User deleted successfully"),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          });
                                        },
                                        onUpdate: () {
                                          setState(() {
                                            _fetchUsers();
                                          });
                                        },
                                      ),
                                    ),
                                  ));
                            },
                          )
                        : ListView.builder(
                            itemCount: filteredList.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  splashColor:
                                      Colors.pinkAccent.withOpacity(0.3),
                                  highlightColor:
                                      Colors.pinkAccent.withOpacity(0.2),
                                  onTapDown: (_) {
                                    setState(() => _tappedIndex = index);
                                    FocusScope.of(context).unfocus();
                                  },
                                  onTapUp: (_) {
                                    setState(() => _tappedIndex = null);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserDetails(
                                          userData: filteredList[index],
                                          index: index,
                                          onDelete: () {
                                            setState(() {
                                              filteredList.removeAt(index);
                                            });
                                          },
                                          onUpdate: () {
                                            setState(() {
                                              _fetchUsers();
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  onTapCancel: () =>
                                      setState(() => _tappedIndex = null),
                                  child: PinkUserCard(
                                    user: filteredList[index],
                                    onFavoriteToggle: (newValue) =>
                                        updateFavoriteStatus(index, newValue),
                                    onDelete: () {
                                      setState(() {
                                        filteredList.removeAt(index);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "User deleted successfully"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      });
                                    },
                                    onUpdate: () {
                                      setState(() {
                                        _fetchUsers();
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ]),
        floatingActionButton: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            backgroundColor: Colors.pink.shade800,
            elevation: 8,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddUser(),
                ),
              ).then((_) => _fetchUsers());
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(Icons.add, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdate;
  final Function(int) onFavoriteToggle;

  UserCard(
      {required this.user,
      required this.onDelete,
      this.onUpdate,
      required this.onFavoriteToggle});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _isExpanded = false;

  User _users = User();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: widget.user[UserDatabase.IMAGE] != null &&
                      widget.user[UserDatabase.IMAGE].isNotEmpty &&
                      !widget.user[UserDatabase.IMAGE].toLowerCase().contains("image")
                      ? Image.file(
                    File(widget.user[UserDatabase.IMAGE]),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 140,
                    width: double.infinity,
                    color: charcoalGrey,
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        widget.user[UserDatabase.NAME][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 2,
                  right: 5,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: 40,
                          width: _isExpanded ? 100 : 0,
                          curve: Curves.easeInOut,
                          child: Row(
                            children: _isExpanded
                                ? [
                                    CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.pink,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddUser(
                                                    userData: widget.user,
                                                    index: widget.user[
                                                        UserDatabase.USER_ID].toString(),
                                                    onUpdate: () {
                                                      setState(() {
                                                        widget.onUpdate?.call();
                                                      });

                                                    },
                                                  ),
                                                )).then((updatedUser) {
                                              setState(() {});
                                            });
                                          },
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: const Material(
                                            color: Colors.transparent,
                                            shape: CircleBorder(),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                    CircleAvatar(
                                      radius: 25,
                                      child: Center(
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  backgroundColor: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .warning_amber_rounded,
                                                          color: Colors.red,
                                                          size: 50,
                                                        ),
                                                        const SizedBox(
                                                            height: 15),
                                                        Text(
                                                          'Delete Confirmation',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: charcoalGrey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Text(
                                                              'Are you sure you want to delete this user?',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              widget.user[
                                                                  UserDatabase
                                                                      .NAME],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    deepBrown,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .grey,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  'Cancel',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  _users.deleteUser(
                                                                      index: widget
                                                                              .user[
                                                                          UserDatabase
                                                                              .USER_ID].toString());
                                                                  Navigator.pop(
                                                                      context);
                                                                  setState(() {
                                                                    _isExpanded =
                                                                        false;
                                                                  });
                                                                  widget
                                                                      .onDelete!();
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Color.fromRGBO(
                                                                          252,
                                                                          3,
                                                                          3,
                                                                          1),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  'Delete',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: const Material(
                                            color: Colors.transparent,
                                            shape: CircleBorder(),
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.more_horiz, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user[UserDatabase.NAME],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.user[UserDatabase.AGE].toString(),
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.user[UserDatabase.CITY],
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[700]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        widget.user[UserDatabase.IS_FAVOURITE] == 1
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.user[UserDatabase.IS_FAVOURITE] == 1
                            ? Colors.red
                            : Colors.grey,
                        size: 28,
                      ),
                      onPressed: () async {
                        int newValue =
                            widget.user[UserDatabase.IS_FAVOURITE] == 1 ? 0 : 1;
                        await _users.updateUserFavourite(
                            widget.user[UserDatabase.USER_ID].toString(), newValue);
                        widget.onFavoriteToggle(newValue);
                        setState(() {
                          widget.user[UserDatabase.IS_FAVOURITE] = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PinkUserCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final Function(int) onFavoriteToggle;

  const PinkUserCard({
    Key? key,
    required this.user,
    required this.onUpdate,
    required this.onDelete,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<PinkUserCard> createState() => _PinkUserCardState();
}

class _PinkUserCardState extends State<PinkUserCard> {
  User _user = User();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFF333333),
                backgroundImage: widget.user[UserDatabase.IMAGE] != null &&
                        widget.user[UserDatabase.IMAGE].isNotEmpty &&
                    !widget.user[UserDatabase.IMAGE].toLowerCase().contains("image")
                    ?FileImage(File(widget.user[UserDatabase.IMAGE]))
                as ImageProvider
                    : null,
                child: (widget.user[UserDatabase.IMAGE] == null ||
                        widget.user[UserDatabase.IMAGE].isEmpty) ||
                    widget.user[UserDatabase.IMAGE].toLowerCase().contains("image")
                    ? Text(
                        widget.user[UserDatabase.NAME][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user[UserDatabase.NAME],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${widget.user[UserDatabase.AGE]} years',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  int newValue =
                      widget.user[UserDatabase.IS_FAVOURITE] == 1 ? 0 : 1;
                  await _user.updateUserFavourite(
                      widget.user[UserDatabase.USER_ID], newValue);
                  widget.onFavoriteToggle(newValue);
                  setState(() {
                    widget.user[UserDatabase.IS_FAVOURITE] = newValue;
                  });
                },
                child: Icon(
                  widget.user[UserDatabase.IS_FAVOURITE] == 1
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.user[UserDatabase.IS_FAVOURITE] == 1
                      ? Colors.red
                      : Colors.grey,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  widget.user[UserDatabase.GENDER],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                avatar: Icon(
                  widget.user[UserDatabase.GENDER] == 'Male'
                      ? Icons.male
                      : Icons.female,
                  color: Colors.white,
                ),
                backgroundColor: Colors.pink[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.pink[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.user[UserDatabase.CITY]}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink[900],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddUser(
                        userData: widget.user,
                        index: widget.user[UserDatabase.USER_ID],
                        onUpdate: () {
                          widget.onUpdate.call();
                          setState(() {});
                        },
                      ),
                    ),
                  ).then((updatedUser) {
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Edit",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                                    widget.user[UserDatabase.NAME],
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                        _user.deleteUser(
                                            index: widget
                                                .user[UserDatabase.USER_ID]);
                                        Navigator.pop(context);
                                        widget.onDelete();
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(252, 3, 3, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  "Delete",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}