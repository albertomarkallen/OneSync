import 'package:flutter/material.dart';
import 'package:onesync/screens/Order/order_screen.dart';

class PaymentSuccessfulScreen extends StatefulWidget {
  final num totalPrice;
  const PaymentSuccessfulScreen({super.key, required this.totalPrice});

  @override
  _PaymentSuccessfulScreenState createState() =>
      _PaymentSuccessfulScreenState();
}

class _PaymentSuccessfulScreenState extends State<PaymentSuccessfulScreen> {
  int _selectedIndex =
      2; // Assuming this is the right index for this screen in your bottom nav
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Successful')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
                'Total: ₱${widget.totalPrice}'), // Access totalPrice using widget.totalPrice
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderScreen()),
                    );
                  },
                  child: const Text('New Order'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Track Order functionality (implementation not provided)
                    print('Track Order button pressed. Implement logic here.');
                  },
                  child: const Text('Track Order'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
