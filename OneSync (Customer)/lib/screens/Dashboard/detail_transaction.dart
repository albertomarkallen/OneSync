import 'package:flutter/material.dart';

class DetailTransactionHistoryScreen extends StatefulWidget {
  const DetailTransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  _DetailTransactionHistoryScreenState createState() =>
      _DetailTransactionHistoryScreenState();
}

class _DetailTransactionHistoryScreenState
    extends State<DetailTransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detailed Transaction History',
          style: TextStyle(
            color: Colors.white, // AppBar titles are typically white.
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true, // This centers the title text in the AppBar.
      ),
      body: Center(
        child: Text('Details of transaction history will be shown here.'),
      ),
    );
  }
}
