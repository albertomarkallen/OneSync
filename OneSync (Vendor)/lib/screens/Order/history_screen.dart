import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onesync/navigation.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, dynamic>? _selectedOrder;
  String _selectedLabel = 'All';

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }

  InputDecoration _searchBarDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(8.0),
      hintText: 'Title',
      prefixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          width: 1,
          color: Color(0x3FABBED1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          width: 1,
          color: Color(0x3FABBED1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          width: 1,
          color: Color(0xFF717171),
        ),
      ),
    );
  }

  // Filter Category Widget
  Widget _selectedLabelCategory(String label) {
    return Container(
      width: 168,
      height: 36,
      decoration: BoxDecoration(
        color: _selectedLabel == label ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0xFF0671E0),
          ),
        ),
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (_selectedLabel == label) {
              // If the label is already selected, deselect it
              _selectedLabel = '';
            } else {
              // Otherwise, select this label
              _selectedLabel = label;
            }
          });
        },
        style: TextButton.styleFrom(
          foregroundColor: _selectedLabel == label ? Colors.white : Colors.blue,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            height: 0.08,
          ),
        ),
      ),
    );
  }

  Widget _filterCategory() {
    var labels = ['Cash In', 'Cash Out'];
    return Container(
      margin: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: labels.map((label) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4.0), // Add space between each button
              child: _selectedLabelCategory(label),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Search Bar
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: _searchBarDecoration(),
        onChanged: (value) {
          // Implement search functionality here
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(1.0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0, // Removes the shadow
        title: const Text('Transaction History',
            style: TextStyle(
              color: Color(0xFF212121),
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            )),
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

            return Column(
              children: [
                _searchBar(),
                _filterCategory(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Transactions')
                        .where('currentUid', isEqualTo: currentUid)
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
                            DocumentSnapshot orderDoc =
                                snapshot.data!.docs[index];
                            Timestamp timestamp = orderDoc.get('date');
                            DateTime orderDate = timestamp
                                .toDate()
                                .add(const Duration(hours: 8));
                            bool hasType =
                                (orderDoc.data() as Map<String, dynamic>)
                                    .containsKey('type');

                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              margin: const EdgeInsets.all(12.0),
                              child: InkWell(
                                onTap: () => _showOrderDetails(orderDoc),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Leading icon with transaction information
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // SvgPicture.asset(
                                          //   'assets/Receive.svg',
                                          //   height: 39,
                                          //   width: 39,
                                          // ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(orderDoc.id,
                                                  style: const TextStyle(
                                                    color: Color(0xFF212121),
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                  )),
                                              const SizedBox(height: 8),
                                              Text(
                                                DateFormat('yyyy-MM-dd')
                                                    .format(orderDate),
                                                style: const TextStyle(
                                                  color: Color(0xFF88939E),
                                                  fontSize: 12,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // Price and time of the transaction
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
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            DateFormat('hh:mm a')
                                                .format(orderDate),
                                            style: const TextStyle(
                                              color: Color(0xFF88939E),
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
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
            title: const Text(
              'Transaction Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
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

class SvgPicture {}
