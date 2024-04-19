import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesync/navigation.dart';
import 'package:intl/intl.dart'; 

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Transactions')
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
                 DateTime orderDate = timestamp.toDate().add(const Duration(hours: 8));

                return Card(
                  margin: const EdgeInsets.all(12.0), 
                  elevation: 2.0, 
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row( // Main Row divides the layout
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded( // Expanded for flexible spacing
                          child: Column( 
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${orderDoc.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0, 
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${DateFormat('yyyy-MM-dd').format(orderDate)}',
                              ),
                            ],
                          ),
                        ),
                        Expanded( 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // Align right
                            children: [
                              Text(
                                '₱${orderDoc.get('totalPrice')}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${DateFormat('hh:mm a').format(orderDate)}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
