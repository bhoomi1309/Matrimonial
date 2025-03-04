import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  List<Map<String, dynamic>> userList = [];

  final String baseURL =
      "https://667323296ca902ae11b33da7.mockapi.io/Matrimonial";

  // User(){
  //   userList=[
  //     {"Name": 'Bhoomi',
  //       "Email": 'bbbbbb@gmail.com',
  //       "Phone": 9876543210,
  //       "DOB": "13/09/2005",
  //       "Age":19,
  //       "City": 'Mumbai',
  //       "Gender": 'Female',
  //       "Hobbies": 'Music',
  //       "isFavourite":false,
  //       "Image": 'assets/images/p1.png',
  //       "Religion": 'Hindu',
  //       "Bio": 'A fun-loving person with interest in reading',
  //       "lookingFor": 'Male',
  //       "MaritalStatus": 'Never Married',
  //       "MotherTongue": 'Sindhi'
  //     },
  //     {"Name": 'Ankit',
  //       "Email": 'a@gmail.com',
  //       "Phone": 9999999999,
  //       "DOB": "07/01/2001",
  //       "Age":23,
  //       "City": 'Jaipur',
  //       "Gender": 'Male',
  //       "Hobbies": 'Travelling,Sports',
  //       "isFavourite":true,
  //       "Image": 'assets/images/p3.png',
  //       "Religion": 'Hindu',
  //       "Bio": 'A fun-loving person with interest in reading',
  //       "lookingFor": 'Female',
  //       "MaritalStatus": 'Never Married',
  //       "MotherTongue": 'Sindhi'
  //     },
  //     {"Name": 'Kiran',
  //       "Email": 'k@gmail.com',
  //       "Phone": 9632147850,
  //       "DOB": "17/10/2003",
  //       "Age":21,
  //       "City": 'Delhi',
  //       "Gender": 'Female',
  //       "Hobbies": 'Cooking,Travelling,Reading',
  //       "isFavourite":false,
  //       "Image": 'assets/images/p2.png',
  //       "Religion": 'Hindu',
  //       "Bio": 'A fun-loving person with interest in reading',
  //       "lookingFor": 'Male',
  //       "maritalStatus": 'Never Married',
  //       "motherTongue": 'Sindhi'
  //     }
  //   ];
  // }

  Future<List<Map<String, dynamic>>> getUserList() async {
    // Database db = await UserDatabase().initDatabase();
    // userList.clear();
    // userList
    //     .addAll(await db.rawQuery('SELECT * FROM ${UserDatabase.TBL_USER}'));

    userList.clear();

    final response = await http.get(Uri.parse(baseURL));

    if (response.statusCode == 200) {
      userList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      userList.sort((a, b) => int.parse(a[UserDatabase.USER_ID].toString())
          .compareTo(int.parse(b[UserDatabase.USER_ID].toString())));

      return userList;
    } else {
      throw Exception(
          "Failed to load users. Status Code: ${response.statusCode}");
    }
  }

  Future<bool> addUser({required Map<String, dynamic> user}) async {
    try {
      Database db = await UserDatabase().initDatabase();
      int number = await db.insert(UserDatabase.TBL_USER, user);
      if (number > 0) {
        userList.add(user);
        final response = await http.post(
          Uri.parse(baseURL),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(user),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          print("User added to API successfully: ${response.body}");
          return true;
        } else {
          print("Failed to add user to API: ${response.statusCode} - ${response.body}");
          return false;
        }
      } else {
        print('Insertion failed');
      }
      return false;
    } catch (e) {
      print('Error inserting user: $e');
      return false;
    }
  }

  Future<void> deleteUser({required String index}) async {
    // Database db = await UserDatabase().initDatabase();
    // int userID = await db.delete(
    //   UserDatabase.TBL_USER,
    //   where: "${UserDatabase.USER_ID} = ?",
    //   whereArgs: [index],
    // );
    // if (userID > 0) {
    final response = await http.delete(Uri.parse('$baseURL/$index'));

    if (response.statusCode == 200) {
      int parsedId = int.tryParse(index) ?? -1;
      if (parsedId != -1) {
        userList.removeWhere((user) => user[UserDatabase.USER_ID] == parsedId);
      }
      // } else {
      //   throw Exception("Failed to delete user");
      // }
      // userList.removeAt(index);
    }
  }

  Future<bool> updateUser({required Map<String, dynamic> userData, required String index}) async {
    // Database db = await UserDatabase().initDatabase();
    // await db.update(UserDatabase.TBL_USER, userData,
    //     where: '${UserDatabase.USER_ID} = ?', whereArgs: [index]);
    // userList[index] = userData;
    // await getUserList();

    final response = await http.put(
      Uri.parse('$baseURL/$index'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to update user");
    }
  }

  Future<void> updateUserFavourite(String userId, int isFavourite) async {
    // final db = await UserDatabase().initDatabase();
    // await db.update(
    //   UserDatabase.TBL_USER,
    //   {UserDatabase.IS_FAVOURITE: isFavourite},
    //   where: '${UserDatabase.USER_ID} = ?',
    //   whereArgs: [userId],
    // );
    final response = await http.put(
      Uri.parse('$baseURL/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"isFavourite": isFavourite}),
    );

    if (response.statusCode == 200) {
      print("User favourite updated successfully");
    } else {
      throw Exception("Failed to update user favourite");
    }
  }

  Future<List<Map<String, dynamic>>> getFavoriteUsers() async {
    // Database db = await UserDatabase().initDatabase();
    // return await db.query(
    //   UserDatabase.TBL_USER,
    //   where: '${UserDatabase.IS_FAVOURITE} = ?',
    //   whereArgs: [1],
    // );

    final response = await http.get(
      Uri.parse(baseURL),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      List<Map<String, dynamic>> favoriteUsers = data
          .where((user) => user[UserDatabase.IS_FAVOURITE] == 1)
          .map((user) => Map<String, dynamic>.from(user))
          .toList();

      if (favoriteUsers.isNotEmpty) {
        return favoriteUsers;
      } else {
        print("No favorite users found.");
        return [];
      }
    } else {
      print(
          "Failed to fetch favorite users. Status Code: ${response.statusCode}");
      return [];
    }
  }

  Future<String?> getUserId(String email, String password) async {
    // final db = await UserDatabase().initDatabase();
    //
    // List<Map<String, dynamic>> result = await db.query(
    //   UserDatabase.TBL_USER,
    //   columns: [UserDatabase.USER_ID],
    //   where: '${UserDatabase.EMAIL} = ? AND ${UserDatabase.PASSWORD} = ?',
    //   whereArgs: [email, password],
    // );
    //
    // if (result.isNotEmpty) {
    //   return result.first[UserDatabase.USER_ID].toString();
    // } else {
    //   return null;
    // }
    try {
      final response = await http.get(Uri.parse(baseURL));

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        for (var user in users) {
          if (user[UserDatabase.EMAIL] == email && user[UserDatabase.PASSWORD] == password) {
            return user[UserDatabase.USER_ID].toString();
          }
        }
        return null;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<bool> resetPassword(String email, String password) async {
    // try {
    //   final db = await UserDatabase().initDatabase();
    //   var user = await db.query(
    //     UserDatabase.TBL_USER,
    //     where: "${UserDatabase.EMAIL} = ?",
    //     whereArgs: [email],
    //   );
    //
    //   if (user.isNotEmpty) {
    //     await db.update(
    //       UserDatabase.TBL_USER,
    //       {"${UserDatabase.PASSWORD}": password},
    //       where: "${UserDatabase.EMAIL} = ?",
    //       whereArgs: [email],
    //     );
    //
    //     return true;
    //   } else {
    //     return false;
    //   }
    // } catch (e) {
    //   print("Error resetting password: $e");
    //   return false;
    // }
      String? userId;

      try {
        final response = await http.get(Uri.parse(baseURL));

        if (response.statusCode == 200) {
          final List<dynamic> users = jsonDecode(response.body);

          for (var user in users) {
            if (user[UserDatabase.EMAIL] == email) {
              userId = user[UserDatabase.USER_ID].toString();
              break;
            }
          }

          if (userId == null) {
            print("User not found");
            return false;
          }

          final updateResponse = await http.put(
            Uri.parse('$baseURL/$userId'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"Password": password}),
          );

          if (updateResponse.statusCode == 200) {
            print("User password updated successfully");
            return true;
          } else {
            print("Failed to update user password: ${updateResponse.body}");
            return false;
          }
        } else {
          print('Error fetching users: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        print('Exception: $e');
        return false;
      }
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    // final db = await UserDatabase().initDatabase();
    // List<Map<String, dynamic>> result = await db.query(UserDatabase.TBL_USER,
    //     where: "${UserDatabase.USER_ID} = ?", whereArgs: [id]);
    // if (result.isNotEmpty) {
    //   return result.first;
    // }
    // return null;

    try {
      final response = await http.get(Uri.parse(baseURL));

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        for (var user in users) {
          if (user[UserDatabase.USER_ID] == id) {
            return user;
          }
        }
        return null;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}
