import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart'; // Import your navigation widget

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: const TextStyle(fontSize: 12.0),
                ),
                Text(
                  'Transaction History',
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Title Row
            Row(
              children: [
                Text(
                  'Title',
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'Reference Number',
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Amount',
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Transaction Items (Replace with actual data)
            Expanded(
              // Added Expanded to make the ListView scrollable
              child: ListView.builder(
                shrinkWrap: true, // Makes the list view flexible in height
                itemCount: 10, // Replace with the number of transactions
                itemBuilder: (context, index) => TransactionItem(
                  referenceNumber: '1234567890',
                  amount: 500.00,
                  date: 'Aug 20, 2023',
                  time: '8:23 PM',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(), // Your navigation widget
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String referenceNumber;
  final double amount;
  final String date;
  final String time;

  TransactionItem({
    required this.referenceNumber,
    required this.amount,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Add padding for spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align left
              children: [
                Text(
                  referenceNumber,
                  style: const TextStyle(fontSize: 14.0),
                ),
                Text(
                  '$date $time',
                  style: const TextStyle(fontSize: 12.0),
                ),
              ],
            ),
          ),
          Text(
            'Php ${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
