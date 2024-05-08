import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Profile/edit_RFID_screen.dart';
import 'package:onesync/screens/Profile/edit_password_screen.dart';
import 'package:onesync/screens/Profile/edit_storeName_screen.dart';
import 'package:onesync/screens/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String vendorName = '';
  String uid = '';
  int balance = 0;
  bool _isLoading = false;
  String email = '';
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();
  File? _uploadedImageProfile;
  bool _showRemoveIcon = false;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _fetchVendorData();
    _loadProfileImage();
  }

  Future<void> _fetchVendorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String currentUserId = await getCurrentUserId();
      final vendorDoc = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(currentUserId)
          .get();

      var user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ?? "No email";

      if (vendorDoc.exists) {
        setState(() {
          vendorName = vendorDoc.data()?['Vendor Name'] ?? '';
          uid = vendorDoc.data()?['UID'] ?? '';
          balance = vendorDoc.data()?['Balance'] ?? 0;
          email = userEmail;
        });
      } else {
        print('Vendor profile not found');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Method to load and display the profile image from Firebase Storage
  Future<void> _loadProfileImage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child(user.uid)
            .child('profile')
            .child('profile_image.jpg');
        String url = await ref.getDownloadURL();
        setState(() {
          imageUrl = url; // Update the imageUrl with the new URL
        });
        print("Image URL: $url"); // Debug print
      }
    } catch (e) {
      print('Failed to load image: $e');
      imageUrl = null; // Handle the case where no image exists
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void refreshProfile() {
    setState(() {
      _loadProfileImage();
      _fetchVendorData();
    });
  }

  Future<void> _showUpdatingDialog(BuildContext context) async {
    Future.delayed(Duration(seconds: 10), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context)
            .pop(); // Close the dialog after 10 seconds if it's still open
      }
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must not dismiss the dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Updating Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Text(
                  'Please wait, updating the image. This may take a few seconds.'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addProfileImage(BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await _showUpdatingDialog(context); // Show the updating dialog

        await uploadProfileImage(pickedFile);
        await _loadProfileImage(); // Reload the image after uploading

        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Dismiss the dialog if still shown
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image Successfully Added'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(); // Navigate back to the ProfileScreen
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context)
            .pop(); // Ensure to pop the dialog in case of failure
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await uploadProfileImage(pickedFile);
        setState(() {
          _uploadedImageProfile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }

  void _handleRemoveProfileImage() async {
    if (imageUrl == null) return; // If there is no image, just return.

    setState(() {
      _isLoading = true; // Show a loading indicator while processing
    });

    try {
      // Create a reference to the storage item
      final user = FirebaseAuth.instance.currentUser;
      final ref = FirebaseStorage.instance
          .ref()
          .child(user!.uid)
          .child('profile')
          .child('profile_image.jpg');

      // Delete the file
      await ref.delete();

      // After deletion, set the image URL to null
      setState(() {
        imageUrl = null;
        _showRemoveIcon = false; // Optionally hide the remove icon
      });

      // Show a Snackbar on successful deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image Successfully Deleted'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Failed to delete image: $e");
      // Optionally show a Snackbar on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide the loading indicator
      });
    }
  }

  void _handleInputRFID(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditRFIDScreen()),
    );
  }

  void _handleChangePassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditPasswordScreen()),
    );
  }

  void _handleChangeStoreName(BuildContext context) {
    // Navigate to the EditStoreNameScreen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditStoreNameScreen()),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/Login',
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _uploadedImageProfile = null;
    });
  }

  Widget _displayImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        imageUrl != null
            ? ClipOval(
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: 160,
                  height: 160,
                ),
              )
            : const Icon(Icons.camera_alt, size: 50),
        if (_showRemoveIcon) // Show the X icon to remove the image
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: _handleRemoveProfileImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(
              color: Color(0xFF212121),
              fontSize: 28,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _editMode = !_editMode;
                _showRemoveIcon = !_showRemoveIcon;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: imageUrl == null || _editMode
                          ? _pickImage
                          : null, // Conditionally enable image picking
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: _displayImage(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      vendorName,
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Store Name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF717171),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 0.11,
                      ),
                    ),
                    SizedBox(height: 20),
                    ListView(
                      shrinkWrap:
                          true, // Ensures the ListView takes minimum space
                      children: [
                        ListTile(
                          leading: Icon(Icons.storefront_outlined),
                          title: Text(vendorName),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () => _handleChangeStoreName(context),
                        ),
                        ListTile(
                          leading: Icon(Icons.card_membership_outlined),
                          title: uid.isEmpty
                              ? Text('Please Enter Your RFID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0671E0),
                                  ))
                              : Text(uid),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () => _handleInputRFID(context),
                        ),
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text(email),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                        ListTile(
                          leading: Icon(Icons.lock),
                          title: Text('Password'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () => _handleChangePassword(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _signOut(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0671E0),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44.0,
                        child: Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
