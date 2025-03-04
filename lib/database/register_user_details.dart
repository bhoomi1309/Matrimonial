import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:matrimonial/database/login.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/utils/colors.dart';
import 'package:matrimonial/utils/constants.dart';

import 'User.dart';

class RegisterUserDetails extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  RegisterUserDetails(
      {super.key,
      required this.name,
      required this.email,
      required this.password});

  @override
  _RegisterUserDetailsState createState() => _RegisterUserDetailsState();
}

class _RegisterUserDetailsState extends State<RegisterUserDetails> {
  final Map<String, TextEditingController> _controllers = {};
  final PageController _pageController = PageController();
  int _currentStep = 0;
  int totalSteps = 4;

  final GlobalKey<FormState> _personalDetailsKey = GlobalKey();
  final GlobalKey<FormState> _locationKey = GlobalKey();
  final GlobalKey<FormState> _preferencesKey = GlobalKey();
  final GlobalKey<FormState> _profileKey = GlobalKey();

  DateTime? dob;
  DateTime? selectedDate;
  int age = 0;
  String? _dobError;
  String? selectedCity;
  String? _selectedGender;
  String? _genderError;
  String? _selectedMaritalStatus;
  String? selectedReligion;
  String? selectedLookingFor;
  String? imagePath;

  User _user = User();

  void initState() {
    super.initState();
    _controllers['Name'] = TextEditingController();
    _controllers['Email'] = TextEditingController();
    _controllers['Phone'] = TextEditingController();
    _controllers['Bio'] = TextEditingController();
    _controllers['MotherTongue'] = TextEditingController();
    _controllers['Password'] = TextEditingController();
    _controllers['ConfirmPassword'] = TextEditingController();

    _controllers['Name']?.text = widget.name;
    _controllers['Email']?.text = widget.email;

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }

  bool isEmailExist(String email) {
    return _user.userList.any((user) => user[UserDatabase.EMAIL] == email);
  }

  bool isPhoneExist(int phone) {
    return _user.userList.any((user) => user[UserDatabase.PHONE] == phone);
  }

  bool _validateDateOfBirth() {
    if (selectedDate == null) {
      setState(() {
        _dobError = 'Please select your date of birth';
      });
      return false;
    }
    DateTime currentDate = DateTime.now();

    age = currentDate.year - selectedDate!.year;
    if (currentDate.month < selectedDate!.month ||
        (currentDate.month == selectedDate!.month &&
            currentDate.day < selectedDate!.day)) {
      age--;
    }
    if (age < 18) {
      setState(() {
        _dobError = 'You must be at least 18 years old to register.';
      });
    } else if (age > 80) {
      setState(() {
        _dobError = 'You must be under 80 years old to register.';
      });
    } else {
      setState(() {
        _dobError = null;
      });
    }
    return _dobError == null;
  }

  bool _validateGender() {
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      setState(() {
        _genderError = 'Please select your gender.';
      });
      return false;
    } else {
      setState(() {
        _genderError = null;
      });
      return true;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text("Take a Photo"),
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
            _pageController.animateToPage(
              _currentStep,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Register User Details",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.pink,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                      (index) => Row(
                    children: [
                      Column(
                        children: [
                          Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                            child: Icon(
                              index == 0
                                  ? Icons.person
                                  : index == 1
                                  ? Icons.location_on
                                  : index == 2
                                  ? Icons.tune
                                  : Icons.camera_alt,
                              size: 36,
                              color: _currentStep == index ? Colors.pink : Colors.grey,
                            ),
                          ),
                          Text("${index + 1}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _currentStep == index ? Colors.pink : Colors.grey)),
                        ],
                      ),
                      if (index < 3)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("—",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  personalDetailsPage(),
                  locationPage(),
                  preferencesPage(),
                  profilePicPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget personalDetailsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _personalDetailsKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                "Personal Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: pink400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                  children: [
                TextFormField(
                  controller: _controllers['Name'],
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllers['Email'],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: lightBg,
                    labelText: 'Email',
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
                    } else if (isEmailExist(value)) {
                      return 'This email is already registered';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controllers['Phone'],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: lightBg,
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: pink400),
                    prefixIcon: Icon(Icons.phone, color: pink400),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    RegExp phoneRegExp = RegExp(r"^[0-9]{10}$");
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    int? phoneNumber = int.tryParse(value);
                    if (!phoneRegExp.hasMatch(value)) {
                      return 'Enter a valid 10-digit mobile number';
                    } else if (isPhoneExist(phoneNumber!)) {
                      return 'This phone number is already registered';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pink400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          DateTime today = DateTime.now();
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dob ??
                                DateTime(
                                    today.year - 18, today.month, today.day),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context),
                                child: Builder(
                                  builder: (context) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child!,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                            _validateDateOfBirth();
                          }
                        },
                        child: Text(
                          "Date of Birth",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        selectedDate == null
                            ? "No Date Selected"
                            : DateFormat('dd/MM/yyyy').format(selectedDate!),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                if (_dobError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _dobError!,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0),
                    ),
                  ),
                const SizedBox(height: 20),
              ]
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pink400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                onPressed: () {
                  if (_personalDetailsKey.currentState!.validate() &&
                      _validateDateOfBirth()) {
                    setState(() {
                      _currentStep++;
                    });
                    _pageController.animateToPage(
                      _currentStep,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    setState(() {
                      _dobError = selectedDate == null
                          ? "Please select a valid date of birth"
                          : null;
                    });
                  }
                },
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget locationPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _locationKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                "Location and Basic Info",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: pink400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCity,
                    items: CITIES.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'City',
                      filled: true,
                      fillColor: lightBg,
                      labelStyle: TextStyle(color: pink400),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a city';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 8.0),
                    child: Text(
                      'Select Gender',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Male',
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                              _validateGender();
                            },
                          ),
                          const Text('Male', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Female',
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                              _validateGender();
                            },
                          ),
                          const Text('Female', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Other',
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                              _validateGender();
                            },
                          ),
                          const Text('Other', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                      'Marital Status', MARITALSTATUS, _selectedMaritalStatus,
                      (value) {
                    setState(() => _selectedMaritalStatus = value);
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Change this color if needed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                    _pageController.animateToPage(
                      _currentStep,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pink400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  onPressed: () {
                    if (_locationKey.currentState!.validate() && _validateGender()) {
                      setState(() {
                        _currentStep++;
                      });
                      _pageController.animateToPage(
                        _currentStep,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      setState(() {
                        _genderError =
                        _selectedGender == null ? "Please select a gender" : null;
                      });
                    }
                  },
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget preferencesPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _preferencesKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                "Preferences and Interests",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: pink400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _controllers['MotherTongue'],
                    decoration: InputDecoration(
                      labelText: 'Mother Tongue',
                      filled: true,
                      fillColor: lightBg,
                      labelStyle: TextStyle(color: pink400),
                      prefixIcon: Icon(Icons.language, color: pink400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter mother tongue'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField('Religion', RELIGIONS, selectedReligion,
                      (value) {
                    setState(() => selectedReligion = value);
                  }),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                      'Looking For', LOOKINGFOR, selectedLookingFor, (value) {
                    setState(() => selectedLookingFor = value);
                  }),
                  const SizedBox(height: 16),
                  _buildHobbiesSelection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                    _pageController.animateToPage(
                      _currentStep,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pink400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  onPressed: () {
                    if (_preferencesKey.currentState!.validate()) {
                      setState(() {
                        _currentStep++;
                      });
                      _pageController.animateToPage(
                        _currentStep,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget profilePicPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _profileKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                "Profile Picture",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: pink400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                onTap: () => showImagePicker(context),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: imagePath != null
                                      ? FileImage(File(imagePath!))
                                      : AssetImage(
                                              "assets/images/default_profile.png")
                                          as ImageProvider,
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: InkWell(
                                  onTap: () => showImagePicker(context),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.pink,
                                    child: Icon(Icons.camera_alt,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _controllers['Bio'],
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: lightBg,
                      labelStyle: TextStyle(color: pink400),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.info, color: pink400),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                    _pageController.animateToPage(
                      _currentStep,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  onPressed: () {
                    if (_profileKey.currentState!.validate()) {
                      Map<String, dynamic> userData = {};
                      userData[UserDatabase.NAME] = _controllers['Name']?.text;
                      userData[UserDatabase.EMAIL] = _controllers['Email']?.text;
                      userData[UserDatabase.PHONE] = _controllers['Phone']?.text;

                      String formattedDOB =
                      DateFormat('dd/MM/yyyy').format(selectedDate!);
                      userData[UserDatabase.DOB] = formattedDOB;
                      userData[UserDatabase.CITY] = selectedCity;
                      userData[UserDatabase.GENDER] = _selectedGender;
                      userData[UserDatabase.AGE] = age;
                      userData[UserDatabase.RELIGION]=selectedReligion;
                      userData[UserDatabase.BIO] = _controllers['Bio']?.text;
                      userData[UserDatabase.LOOKING_FOR] = selectedLookingFor;
                      userData[UserDatabase.MARITAL_STATUS] = _selectedMaritalStatus;
                      userData[UserDatabase.MOTHER_TONGUE] = _controllers['MotherTongue']?.text;
                      List<String> selectedHobbies = HOBBIES.entries
                          .where((entry) => entry.value == true)
                          .map((entry) => entry.key)
                          .toList();
                      userData[UserDatabase.HOBBIES] = selectedHobbies.join(',');
                      userData[UserDatabase.IS_FAVOURITE] = 0;
                      userData[UserDatabase.IMAGE] = imagePath;
                      userData[UserDatabase.PASSWORD] = widget.password;

                      _user.addUser(user: userData);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User registered successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      setState(() {
                        HOBBIES.updateAll((key, value) => false);
                      });

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Login(email: userData[UserDatabase.EMAIL])),
                            (Route<dynamic> route) => false,
                      );

                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: lightBg,
        labelStyle: TextStyle(color: pink400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select $label' : null,
    );
  }

  Widget _buildHobbiesSelection() {
    List<String> hobbyKeys = HOBBIES.keys.toList();
    List<String> firstRowHobbies = hobbyKeys.take(3).toList();
    List<String> secondRowHobbies = hobbyKeys.skip(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Hobbies',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: firstRowHobbies.map((hobby) {
            return ChoiceChip(
              label: Text(
                hobby,
                style: TextStyle(
                  color: HOBBIES[hobby]! ? Colors.white : Colors.black,
                ),
              ),
              selected: HOBBIES[hobby]!,
              onSelected: (selected) {
                setState(() {
                  HOBBIES[hobby] = selected;
                });
              },
              selectedColor: pink400,
              backgroundColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: secondRowHobbies.map((hobby) {
            return ChoiceChip(
              label: Text(
                hobby,
                style: TextStyle(
                  color: HOBBIES[hobby]! ? Colors.white : Colors.black,
                ),
              ),
              selected: HOBBIES[hobby]!,
              onSelected: (selected) {
                setState(() {
                  HOBBIES[hobby] = selected;
                });
              },
              selectedColor: pink400,
              backgroundColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }
}
