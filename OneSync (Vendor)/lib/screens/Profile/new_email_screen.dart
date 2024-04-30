import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';

class UpdateEmailAddressScreen extends StatelessWidget {
  void _handleSendEmailOTPNew(BuildContext context) {
    Navigator.of(context).pushNamed('/verifyNewEmailAddress');
  }
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Phone Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align children to the start
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [
            // Label for input field
            Text(
              'New Mobile Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Add spacing between label and input field
            // Input field for phone number
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone, // Only accept numbers
              decoration: InputDecoration(
                labelText: 'Enter Mobile Number',
                floatingLabelBehavior: FloatingLabelBehavior.never, // Keep label in place
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color:Color.fromRGBO(65, 150, 240, 100)), // Set focused border color to blue
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(171, 190, 209, 25)), // Set enabled border color to blue
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Adjust padding
              ),
            ),
            SizedBox(height: 20), // Add spacing between input field and button
            // Responsive button
            ElevatedButton(
              onPressed: () => _handleSendEmailOTPNew(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0), // Set the background color
              ),
              child: Container(
                width: double.infinity,
                height: 44.0,
                child: Center(
                  child: Text(
                    'Send OTP',
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
