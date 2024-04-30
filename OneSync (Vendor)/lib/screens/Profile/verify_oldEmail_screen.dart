import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';


class VerifyOldEmailScreen extends StatelessWidget {
  void _handleEmailOTP(BuildContext context) {
    Navigator.of(context).pushNamed('/updateEmailAddress');
  }
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align children to the start
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [
            // Label for input field
            Text(
              'Verify your email',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Add spacing between label and input field

            Text(
              'We’ve sent an SMS with an activation code to your phone +33 2 94 27 84 11.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24), // Add spacing between label and input field

            // Input field for phone number
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone, // Only accept numbers
              decoration: InputDecoration(
                labelText: 'Enter code',
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
              onPressed: () => _handleEmailOTP(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0), // Set the background color
              ),
              child: Container(
                width: double.infinity,
                height: 44.0,
                child: Center(
                  child: Text(
                    'Verify',
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
