import 'dart:io';

import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:matrimonial/utils/constants.dart';
import 'home.dart';
import '../utils/colors.dart';
import 'User.dart';

class AddUser extends StatefulWidget {
  final Map<String, dynamic>? userData;
  String? index;
  final VoidCallback? onUpdate;

  AddUser({super.key, this.userData, this.index, this.onUpdate});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final GlobalKey<FormState> _key = GlobalKey();

  final Map<String, TextEditingController> _controllers = {};

  //region VARIABLES
  DateTime? selectedDate;
  String? selectedCity;
  String? _selectedGender;
  String? _dobError;
  String? _genderError;
  String? selectedLookingFor;
  String? selectedReligion;
  String? selectedMaritalStatus;
  DateTime? dob;
  String? imagePath;
  int? isFav;

  bool _isObscured = true;
  bool _isObscuredConfirm = true;

  bool isLoading = false;

  int age = 0;

  //endregion

  User _user = User();

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
    } else {
      setState(() {
        _genderError = null;
      });
    }
    return _genderError == null;
  }


  bool isEmailExist(String email) {
    return _user.userList.any((user) => user[UserDatabase.EMAIL] == email);
  }

  bool isPhoneExist(int phone) {
    return _user.userList.any((user) => user[UserDatabase.PHONE] == phone);
  }

  bool isEditing = false;

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

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var hashed = sha256.convert(bytes);
    return hashed.toString();
  }

  //region INIT STATE

  @override
  void initState() {
    super.initState();
    _controllers['Name'] = TextEditingController();
    _controllers['Email'] = TextEditingController();
    _controllers['Phone'] = TextEditingController();
    _controllers['Bio'] = TextEditingController();
    _controllers['MotherTongue'] = TextEditingController();
    _controllers['Password'] = TextEditingController();
    _controllers['ConfirmPassword'] = TextEditingController();
    setState(() {
      HOBBIES.updateAll((key, value) => false);
    });

    if (widget.userData != null) {
      isEditing = true;
      _controllers['Name']?.text = widget.userData?[UserDatabase.NAME];
      _controllers['Email']?.text = widget.userData?[UserDatabase.EMAIL];
      _controllers['Phone']?.text = widget.userData![UserDatabase.PHONE].toString();
      String dobString = widget.userData?[UserDatabase.DOB];
      // dob = DateFormat("dd/MM/yyyy").parse(dobString);
      // selectedDate = DateFormat('dd/MM/yyyy').parse(dobString);

      DateTime now = DateTime.now();
      DateTime defaultDob = DateTime(now.year - 18, now.month, now.day);

      try {
        if (dobString != null) {
          DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(dobString);

          dob = parsedDate;
          selectedDate = parsedDate;
        } else if (widget.userData?[UserDatabase.DOB] != null) {
          dob = widget.userData?[UserDatabase.DOB];
          selectedDate = widget.userData?[UserDatabase.DOB];
        } else {
          dob = defaultDob;
          selectedDate = defaultDob;
        }
      } catch (e) {
        dob = defaultDob;
        selectedDate = defaultDob;
      }

      // selectedCity = widget.userData?[UserDatabase.CITY];

      String? userCity = widget.userData?[UserDatabase.CITY];
      if (userCity != null && CITIES.contains(userCity)) {
        selectedCity = userCity;
      } else {
        selectedCity = CITIES.isNotEmpty ? CITIES.first : null;
      }
      // _selectedGender = widget.userData?[UserDatabase.GENDER];

      String? gender = widget.userData?[UserDatabase.GENDER];
      if (gender != null && gender != "Female" && gender != "Male" && gender != "Others") {
        _selectedGender = "Male";
      }
      else{
        _selectedGender = gender;
      }
      List<dynamic> userHobbies=[];
      if(widget.userData?[UserDatabase.HOBBIES] !=null){
        userHobbies = widget.userData?[UserDatabase.HOBBIES].split(',').map((h) => h.trim()).toList();
      }

      _controllers['Bio']?.text = widget.userData?[UserDatabase.BIO];
      _controllers['MotherTongue']?.text = widget.userData?[UserDatabase.MOTHER_TONGUE];
      for (var hobby in HOBBIES.keys) {
        HOBBIES[hobby] = userHobbies.contains(hobby);
      }
      // selectedReligion = widget.userData?[UserDatabase.RELIGION];
      // selectedLookingFor = widget.userData?[UserDatabase.LOOKING_FOR];
      // selectedMaritalStatus = widget.userData?[UserDatabase.MARITAL_STATUS];


      String? userRelgion = widget.userData?[UserDatabase.RELIGION];
      if (userRelgion != null && RELIGIONS.contains(userRelgion)) {
        selectedReligion = userRelgion;
      } else {
        selectedReligion = RELIGIONS.isNotEmpty ? RELIGIONS.first : null;
      }

      String? lookfor = widget.userData?[UserDatabase.LOOKING_FOR];
      if (lookfor != null && LOOKINGFOR.contains(lookfor)) {
        selectedLookingFor = lookfor;
      } else {
        selectedLookingFor = LOOKINGFOR.isNotEmpty ? LOOKINGFOR.first : null;
      }

      String? marital = widget.userData?[UserDatabase.MARITAL_STATUS];
      if (marital != null && MARITALSTATUS.contains(marital)) {
        selectedMaritalStatus = marital;
      } else {
        selectedMaritalStatus = MARITALSTATUS.isNotEmpty ? MARITALSTATUS.first : null;
      }


      imagePath = widget.userData?[UserDatabase.IMAGE];
      isFav = widget.userData?[UserDatabase.IS_FAVOURITE];
    }

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.pink,
              title: const Text(
                "ADD USER",
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit User Information' : 'Enter User Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: pink400,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                    backgroundImage: (imagePath != null && File(imagePath!).existsSync())
                                        ? FileImage(File(imagePath!))
                                        : AssetImage("assets/images/default_profile.png") as ImageProvider,
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
                                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllers['Phone'],
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        filled: true,
                        fillColor: lightBg,
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
                        } else if (!isEditing && isPhoneExist(phoneNumber!)) {
                          return 'This phone number is already registered';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                                initialDate: dob ?? DateTime(today.year - 18, today.month, today.day),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context),
                                    child: Builder(
                                      builder: (context) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context)
                                              .copyWith(alwaysUse24HourFormat: false),
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
                            style: const TextStyle(fontSize: 16, color: Colors.black),
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
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10.0, top: 8.0),
                          child: Text(
                            'Select Gender',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
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
                                  const Text(
                                    'Male',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Row(
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
                                  const Text(
                                    'Female',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Row(
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
                                  const Text(
                                    'Other',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_genderError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _genderError!,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHobbiesSelection(),
                    const SizedBox(
                      height: 16,
                    ),

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
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your mother tongue' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField('Religion', RELIGIONS, selectedReligion,
                            (value) { setState(() => selectedReligion = value); }),
                    const SizedBox(height: 16),

                    _buildDropdownField('Marital Status', MARITALSTATUS, selectedMaritalStatus,
                            (value) { setState(() => selectedMaritalStatus = value); }),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _controllers['Bio'],
                      maxLines: 3,
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
                    const SizedBox(height: 16),

                    _buildDropdownField('Looking For', LOOKINGFOR, selectedLookingFor,
                            (value) { setState(() => selectedLookingFor = value); }),

                    const SizedBox(height: 20),
                    if (!isEditing) ...[
                      TextFormField(
                        controller: _controllers['Password'],
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
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _controllers['ConfirmPassword'],
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
                          if (value != _controllers['Password']?.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(
                      height: 20,
                    ),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade900),
              ),
            ),
          ),
      ],
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
              backgroundColor:Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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
      validator: (value) => value == null || value.isEmpty ? 'Please select $label' : null,
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: pink400,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(isEditing ? 'Save Changes' : 'Submit',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        onPressed: () async {
          if (_key.currentState!.validate() &&
              _validateDateOfBirth() &&
              _validateGender()) {
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
            userData[UserDatabase.MARITAL_STATUS] = selectedMaritalStatus;
            userData[UserDatabase.MOTHER_TONGUE] = _controllers['MotherTongue']?.text;
            List<String> selectedHobbies = HOBBIES.entries
                .where((entry) => entry.value == true)
                .map((entry) => entry.key)
                .toList();
            userData[UserDatabase.HOBBIES] = selectedHobbies.isEmpty ? null : selectedHobbies.join(',');
            userData[UserDatabase.IS_FAVOURITE] = isFav ?? 0;
            userData[UserDatabase.IMAGE] = imagePath;
            userData[UserDatabase.PASSWORD] = widget.userData?[UserDatabase.PASSWORD] ?? hashPassword(_controllers['Password']!.text);
            userData[UserDatabase.USER_ID]=widget.userData?[UserDatabase.USER_ID];

            // if (isEditing) {
            //
            //   _user.updateUser(userData: userData, index: userData[UserDatabase.USER_ID].toString());
            //   if (widget.onUpdate != null) {
            //     widget.onUpdate!();
            //   }
            //   _key.currentState?.reset();
            //   setState(() {
            //     HOBBIES.updateAll((key, value) => false);
            //   });
            //   Navigator.pop(context, userData);
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: const Text('User details updated successfully'),
            //       backgroundColor: forestGreen,
            //     ),
            //   );
            // }
            if (isEditing) {
              setState(() {
                isLoading = true;
              });
              bool success = await _user.updateUser(
                  userData: userData,
                  index: userData[UserDatabase.USER_ID].toString()
              );
              setState(() {
                isLoading = false;
              });

              if (success) {
                if (widget.onUpdate != null) {
                  widget.onUpdate!();
                }
                _key.currentState?.reset();
                setState(() {
                  HOBBIES.updateAll((key, value) => false);
                });
                Navigator.pop(context, userData);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User details updated successfully'),
                    backgroundColor: forestGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update user details'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            else {
              setState(() {
                isLoading = true;
              });
              bool success = await _user.addUser(user: userData);
              setState(() {
                isLoading = false;
              });

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User Added Successfully'), backgroundColor: forestGreen),
                );
                setState(() {
                  HOBBIES.updateAll((key, value) => false);
                });
                _key.currentState?.reset();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home(newUser: userData)),
                      (Route<dynamic> route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to Add User'), backgroundColor: Colors.red),
                );
              }
            }
          }
        },
      ),
    );
  }
}