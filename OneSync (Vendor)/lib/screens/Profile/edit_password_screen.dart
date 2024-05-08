import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Profile/success_update_password_screen.dart';
import 'package:onesync/screens/utils.dart'; // Ensure this import is correct

class EditPasswordScreen extends StatefulWidget {
  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isCurrentPasswordValid = true;
  bool _isNewPasswordValid = true;

  void _handleUpdatePass(BuildContext context) async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    bool passwordsMatch = newPassword == confirmPassword;
    bool isNewPasswordValid = newPassword.length >= 8;

    // Update the validation state for new and confirm password fields
    setState(() {
      _isNewPasswordValid = passwordsMatch && isNewPasswordValid;
    });

    if (!passwordsMatch || !isNewPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Ensure the new password is at least 8 characters long and both passwords match.')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    String email = user!.email!;

    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      bool result = await changePassword(newPassword);
      if (result) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SuccessUpdatedPassword()),
        );
      } else {
        throw Exception('Failed to update password.');
      }
    } catch (e) {
      setState(() {
        _isCurrentPasswordValid =
            false; // Assume reauthentication failed due to incorrect current password
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to reauthenticate. Check your current password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isCurrentPasswordValid ? Colors.black : Colors.red,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: currentPasswordController, // Use separate controller
              keyboardType: TextInputType.text,
              obscureText: true, // Hide password
              decoration: InputDecoration(
                labelText: 'Enter Current Password',
                errorText: !_isCurrentPasswordValid
                    ? 'Invalid current password'
                    : null,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isCurrentPasswordValid
                        ? Color.fromRGBO(65, 150, 240, 100)
                        : Colors.red,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isCurrentPasswordValid ? Colors.grey : Colors.red,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 16), // Adjust padding
              ),
            ),
            SizedBox(height: 20),
            Text(
              'New Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter New Password',
                errorText: !_isNewPasswordValid
                    ? 'Password must be at least 8 characters and match confirmation.'
                    : null,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _isNewPasswordValid
                          ? Color.fromRGBO(65, 150, 240, 100)
                          : Colors.red),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _isNewPasswordValid ? Colors.grey : Colors.red),
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 16), // Adjust padding
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController, // Use separate controller
              keyboardType: TextInputType.text,
              obscureText: true, // Hide password
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: !_isNewPasswordValid
                    ? 'Passwords must match and be at least 8 characters.'
                    : null,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _isNewPasswordValid
                          ? Color.fromRGBO(65, 150, 240, 100)
                          : Colors.red),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _isNewPasswordValid ? Colors.grey : Colors.red),
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 16), // Adjust padding
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleUpdatePass(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44.0,
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
