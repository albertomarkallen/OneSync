import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Profile/success_update_password_screen.dart';
import 'package:onesync/screens/utils.dart'; // Ensure this import is correct

class EditPasswordScreen extends StatelessWidget {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _handleUpdatePass(BuildContext context) async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('New Password and Confirm Password do not match')),
      );
      return;
    }

    // Attempt to reauthenticate before changing the password
    User? user = FirebaseAuth.instance.currentUser;
    String email = user!.email!;

    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      // Use the utility function to change the password
      bool result = await changePassword(newPassword);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password successfully updated')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SuccessUpdatedPassword()),
        );
      } else {
        throw Exception('Failed to update password.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password: $e')),
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
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: currentPasswordController, // Use separate controller
              keyboardType: TextInputType.text,
              obscureText: true, // Hide password
              decoration: InputDecoration(
                labelText: 'Enter Current Password',
                floatingLabelBehavior:
                    FloatingLabelBehavior.never, // Keep label in place
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(65, 150, 240,
                          100)), // Set focused border color to blue
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(171, 190, 209,
                          25)), // Set enabled border color to blue
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
              controller: newPasswordController, // Use separate controller
              keyboardType: TextInputType.text,
              obscureText: true, // Hide password
              decoration: InputDecoration(
                labelText: 'Enter New Password',
                floatingLabelBehavior:
                    FloatingLabelBehavior.never, // Keep label in place
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(65, 150, 240,
                          100)), // Set focused border color to blue
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(171, 190, 209,
                          25)), // Set enabled border color to blue
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
                floatingLabelBehavior:
                    FloatingLabelBehavior.never, // Keep label in place
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(65, 150, 240,
                          100)), // Set focused border color to blue
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(171, 190, 209,
                          25)), // Set enabled border color to blue
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
