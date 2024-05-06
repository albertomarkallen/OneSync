import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Order/order_screen.dart';

class PaymentSuccessfulScreen extends StatelessWidget {
  final num totalPrice;

  const PaymentSuccessfulScreen({Key? key, required this.totalPrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0671E0),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Baseline(
                  baseline: 0,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    '₱',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0671E0),
                    ),
                  ),
                ),
                Text(
                  '$totalPrice.00',
                  style: TextStyle(
                    fontSize: 48,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            BreathingCircle(), // Using the BreathingCircle widget for breathing effect
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderScreen()),
                    );
                  },
                  icon: Icon(Icons.add, color: Colors.white), // Plus icon
                  label: Text(
                    'New Order',
                    style: TextStyle(
                      color: Colors.white, // Text color changed to white
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color(0xFF0671E0)), // Background color
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                            color: Color(0xFF0671E0)), // Border color
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(150, 40)),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Track Order functionality (implementation not provided)
                    print('Track Order button pressed. Implement logic here.');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white), // Background color set to white
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                            color: Color(0xFF0671E0)), // Border color
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(150, 40)),
                  ),
                  child: Text(
                    'Track Order',
                    style: TextStyle(
                      color: Color(0xFF0671E0), // Text color set to 0xFF0671E0
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
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

class BreathingCircle extends StatefulWidget {
  @override
  _BreathingCircleState createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Color(0xFF0671E0), // Background color
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_circle,
              color: Colors.white, // Icon color
              size: 80,
            ),
          ),
        );
      },
    );
  }
}
