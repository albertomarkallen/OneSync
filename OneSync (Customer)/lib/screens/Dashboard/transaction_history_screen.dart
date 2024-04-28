import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, dynamic>? _selectedOrder;
  String currentRfid = '';

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<void> _fetchRfid() async {
    try {
      final uid = await getCurrentUserId();
      final rfidSnapshot = await FirebaseFirestore.instance
          .collection('Student-Users')
          .doc(uid)
          .get();

      if (rfidSnapshot.exists && rfidSnapshot.data() != null) {
        setState(() {
          currentRfid = rfidSnapshot.data()!['rfid'] ?? '';
        });
      } else {
        // Handle case if RFID is not found
      }
    } catch (e) {
      // Handle errors while getting the RFID
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRfid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Transaction History',
            style: TextStyle(
              color: Color(0xFF212121),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Transactions')
              .where('rfid', isEqualTo: currentRfid)
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
                  bool hasType = (orderDoc.data() as Map<String, dynamic>)
                      .containsKey('type');

                  return Card(
                      margin: const EdgeInsets.all(12.0),
                      elevation: 2.0,
                      child: InkWell(
                          onTap: () => _showOrderDetails(orderDoc),
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
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
                                          DateFormat('yyyy-MM-dd')
                                              .format(orderDate),
                                          style:
                                              const TextStyle(fontSize: 12.0),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₱${orderDoc.get('totalPrice')}',
                                          style: TextStyle(
                                            color: hasType
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(orderDate),
                                          style:
                                              const TextStyle(fontSize: 12.0),
                                        )
                                      ],
                                    ),
                                  ]))));
                },
              );
            }
          },
        ));
  }

  void _showOrderDetails(DocumentSnapshot orderDoc) {
    setState(() {
      _selectedOrder = orderDoc.data() as Map<String, dynamic>;
    });

    showDialog(
      context: context,
      builder: (context) {
        if (_selectedOrder == null) return const SizedBox.shrink();

        bool isNewType = _selectedOrder!.containsKey('type') &&
            _selectedOrder!['type'] == 'cashout';

        Timestamp timestamp = _selectedOrder!['date'];
        DateTime orderDate = timestamp.toDate().add(const Duration(hours: 8));

        if (isNewType) {
          // UI for 'cashout' type transaction details
          return AlertDialog(
            title: const Text('Cashout Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transaction ID: ',
                          style: TextStyle(color: Colors.black)),
                      Text(_selectedOrder!['transactionId'].toString(),
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Date: ',
                          style: TextStyle(color: Colors.black)),
                      Text(DateFormat.yMMMd().format(orderDate),
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time: ',
                          style: TextStyle(color: Colors.black)),
                      Text(DateFormat('hh:mm a').format(orderDate),
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Price: ',
                          style: TextStyle(color: Colors.black)),
                      Text('₱${_selectedOrder!['totalPrice']}',
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Type: ',
                          style: TextStyle(color: Colors.black)),
                      Text(_selectedOrder!['type'],
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedOrder = null;
                  });
                },
                child: const Text('Close'),
              ),
            ],
          );
        } else {
          // Existing order details UI for other types
          int totalItems = 0;
          List<dynamic> itemsList = _selectedOrder!['items'];
          for (var item in itemsList) {
            totalItems += (item['quantity'] as int);
          }
          int totalPrice = _selectedOrder!['totalPrice'];

          return AlertDialog(
            title: const Text('Order Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('RFID: ',
                          style: TextStyle(color: Colors.black)),
                      Text(
                        _selectedOrder!['rfid'],
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Date: ',
                          style: TextStyle(color: Colors.black)),
                      Text(
                        DateFormat.yMMMd().format(orderDate),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time: ',
                          style: TextStyle(color: Colors.black)),
                      Text(
                        DateFormat('hh:mm a').format(orderDate),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Order Summary'),
                  SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: itemsList
                        .map((item) => Row(
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
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Items: ',
                          style: TextStyle(color: Colors.black)),
                      Text(
                        '$totalItems items',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Price: ',
                          style: TextStyle(color: Colors.black)),
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedOrder = null;
                  });
                },
                child: const Text('Close'),
              ),
            ],
          );
        }
      },
    );
  }
}
