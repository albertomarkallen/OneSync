import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';

class VerifyNewEmailScreen extends StatefulWidget {
  @override
  _VerifyNewEmailScreenState createState() => _VerifyNewEmailScreenState();
}

class _VerifyNewEmailScreenState extends State<VerifyNewEmailScreen> {
  final TextEditingController phoneNumberController = TextEditingController();

  void _handleEmailOTPNew(BuildContext context) {
    Navigator.of(context).pushNamed('/updatedEmailAddress');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Consider adding properties to AppBar if needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify your new number',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We’ve sent an SMS with an activation code to your phone +33 2 94 27 84 11.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Enter code',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(65, 150, 240, 100)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(171, 190, 209, 25)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleEmailOTPNew(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0),
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

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }
}
