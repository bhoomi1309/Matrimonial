import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/database/user_details.dart';
import 'package:matrimonial/utils/colors.dart';

import 'User.dart';

class Favourites extends StatefulWidget {
  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  User _users = User();
  List<Map<String, dynamic>> favoriteUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoriteUsers();
  }


  Future<void> fetchFavoriteUsers() async {
    setState(() {
      isLoading = true;
    });

    favoriteUsers = await _users.getFavoriteUsers();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateFavoriteStatus() async {
    await fetchFavoriteUsers();
  }

  Future<void> onRemoveFavorite(int index) async {
    String userId = favoriteUsers[index][UserDatabase.USER_ID];
    int newValue = favoriteUsers[index][UserDatabase.IS_FAVOURITE] == 1 ? 0 : 1;

    await _users.updateUserFavourite(userId, newValue);

    // setState(() {
    //   favoriteUsers.removeAt(index);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mistyRose,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: favoriteUsers.isEmpty && !isLoading
                ? Center(
              child: Text(
                "No Favorites Yet!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: favoriteUsers.length,
              itemBuilder: (context, index) {
                return FavoriteCard(
                  fetchFavoriteUsers,
                  favoriteUsers,
                  favoriteUsers[index],
                  index,
                  onRemoveFavorite,
                  isLoading,
                  onFavoriteToggle: updateFavoriteStatus,
                );
              },
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FavoriteCard extends StatefulWidget {
  final VoidCallback fetchFavouriteUsers;
  final Function(int) onRemoveFavorite;
  bool isLoading;
  List<Map<String, dynamic>> favoriteUsers;
  final Map<String, dynamic> favourite;
  int index;
  final VoidCallback onFavoriteToggle;

  FavoriteCard(
      this.fetchFavouriteUsers, this.favoriteUsers, this.favourite, this.index, this.onRemoveFavorite, this.isLoading, {required this.onFavoriteToggle});

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF333333),
            backgroundImage: widget.favourite[UserDatabase.IMAGE] != null &&
                widget.favourite[UserDatabase.IMAGE].isNotEmpty &&
                !widget.favourite[UserDatabase.IMAGE].toLowerCase().contains("image")
                ?FileImage(File(widget.favourite[UserDatabase.IMAGE]))
            as ImageProvider
                : null,
            child: (widget.favourite[UserDatabase.IMAGE] == null ||
                widget.favourite[UserDatabase.IMAGE].isEmpty) ||
                widget.favourite[UserDatabase.IMAGE].toLowerCase().contains("image")
                ? Text(
              widget.favourite[UserDatabase.NAME][0].toUpperCase(),
              style: const TextStyle(
                fontSize: 33,
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
                  widget.favourite[UserDatabase.NAME]!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.favourite[UserDatabase.AGE]} years",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.pink),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.favourite[UserDatabase.CITY]!,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 60,
                child: Center(
                  child: IconButton(
                    onPressed: () async {
                      setState(() {
                        widget.isLoading=true;
                      });
                        await widget.onRemoveFavorite(widget.index);
                      if (mounted) {
                        setState(() {
                          widget.onFavoriteToggle();
                          widget.isLoading=false;
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Removed from favorites!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetails(
                          userData: widget.favourite,
                          index: widget.index,
                          onDelete: () {
                            setState(() {
                              widget.fetchFavouriteUsers();
                            });
                          },
                          onUpdate: () {
                            widget.fetchFavouriteUsers();
                          },
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetails(
                            userData: widget.favourite,
                            index: widget.index,
                            onDelete: () {
                              setState(() {
                                widget.fetchFavouriteUsers();
                              });
                            },
                            onUpdate: () {
                              widget.fetchFavouriteUsers();
                            },
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.blue.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      child: const Text(
                        "View Details",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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