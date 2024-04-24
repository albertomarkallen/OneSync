import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:onesync/navigation.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, dynamic>? _selectedOrder;

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: FutureBuilder<String>(
        future: getCurrentUserId(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          } else {
            String currentUid = userSnapshot.data ?? '';

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Transactions')
                  .where('currentUid',
                      isEqualTo: currentUid) // Filter by currentUid
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                } else if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot orderDoc = snapshot.data!.docs[index];
                      Timestamp timestamp = orderDoc.get('date');
                      DateTime orderDate =
                          timestamp.toDate().add(const Duration(hours: 8));

                      return Card(
                          margin: const EdgeInsets.all(12.0),
                          elevation: 2.0,
                          child: InkWell(
                              onTap: () => _showOrderDetails(orderDoc),
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                      // Distribute available space equally between columns
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Column containing transaction number and total price
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              orderDoc.id,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${DateFormat('yyyy-MM-dd').format(orderDate)}',
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ],
                                        ),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '₱${orderDoc.get('totalPrice')}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${DateFormat('hh:mm a').format(orderDate)}',
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            )
                                          ],
                                        ),
                                      ]))));
                    },
                  );
                }
              },
            );
          }
        },
      ),
      bottomNavigationBar: Navigation(),
    );
  }

  void _showOrderDetails(DocumentSnapshot orderDoc) {
    setState(() {
      _selectedOrder = orderDoc.data() as Map<String, dynamic>;
    });

    showDialog(
      context: context,
      builder: (context) {
        if (_selectedOrder == null) return const SizedBox.shrink();

        Timestamp timestamp = _selectedOrder!['date'];
        DateTime orderDate = timestamp.toDate().add(const Duration(hours: 8));

        // Calculate total items
        int totalItems = 0;
        List<dynamic> itemsList = _selectedOrder!['items'];
        for (var item in itemsList) {
          totalItems += (item['quantity'] as int); // Cast 'quantity' to int
        }

        // Calculate total price
        int totalPrice = _selectedOrder!['totalPrice'];

        return AlertDialog(
          title: Text('Transaction Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RFID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RFID: ', style: const TextStyle(color: Colors.black)),
                    Text(
                      _selectedOrder!['rfid'],
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: ', style: const TextStyle(color: Colors.black)),
                    Text(
                      '${DateFormat.yMMMd().format(orderDate)}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Time: ', style: const TextStyle(color: Colors.black)),
                    Text(
                      '${DateFormat('hh:mm a').format(orderDate)}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Items
                const Text('Order Summary'),
                SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (_selectedOrder!['items'] as List)
                      .map(
                        (item) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 11),
                            ),
                            Text(
                              'x${item['quantity']}',
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 11),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),

                // Total Items
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Items: ',
                        style: const TextStyle(color: Colors.black)),
                    Text(
                      '$totalItems items',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),

                // Total Price
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price: ',
                        style: const TextStyle(color: Colors.black)),
                    Text(
                      '₱$totalPrice',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              height: 32, // Adjust the height as desired
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(
                      5), // Optional: adds rounded corners
                ),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      setState(() {
                        _selectedOrder = null;
                      });
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
