import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/order_screen.dart'; 

class PaymentSuccessfulScreen extends StatelessWidget {
  final num totalPrice;
  const PaymentSuccessfulScreen({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Successful')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text('Total: ₱${totalPrice}'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderScreen()),
                    );
                  },
                  child: Text('New Order'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Track Order functionality (implementation not provided)
                    print('Track Order button pressed. Implement logic here.');
                  },
                  child: Text('Track Order'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}

