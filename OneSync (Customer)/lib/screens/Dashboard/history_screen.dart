import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:onesync/navigation.dart';

class HistoryScreen extends StatefulWidget {
  final bool showBottomNav;
  final bool showActionButton;
  final bool showSearchBar;
  final bool showFilterCategory;

  const HistoryScreen(
      {Key? key,
      this.showBottomNav = true,
      this.showActionButton = false,
      this.showSearchBar = true,
      this.showFilterCategory = true})
      : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String currentRfid = '';
  Map<String, dynamic>? _selectedOrder;
  String _selectedLabel = 'All';

  @override
  void initState() {
    super.initState();
    _fetchRfid();
  }

  Future<void> _fetchRfid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final uid = user.uid;
    final rfidSnapshot = await FirebaseFirestore.instance
        .collection('Student-Users')
        .doc(uid)
        .get();

    if (rfidSnapshot.exists && rfidSnapshot.data() != null) {
      setState(() {
        currentRfid = rfidSnapshot.data()!['rfid'] ?? '';
      });
    }
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
        bool isNewType = _selectedOrder!.containsKey('type') &&
            _selectedOrder!['type'] == 'cashout';

        return AlertDialog(
          title: isNewType
              ? const Text('Cashout Details')
              : const Text('Order Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transaction ID:',
                        style: TextStyle(color: Colors.black)),
                    Text(_selectedOrder!['transactionId'].toString(),
                        style: TextStyle(color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date:', style: TextStyle(color: Colors.black)),
                    Text(DateFormat.yMMMd().format(orderDate),
                        style: TextStyle(color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Time:', style: TextStyle(color: Colors.black)),
                    Text(DateFormat('hh:mm a').format(orderDate),
                        style: TextStyle(color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Price:',
                        style: TextStyle(color: Colors.black)),
                    Text('₱${_selectedOrder!['totalPrice']}',
                        style: TextStyle(color: Colors.blue)),
                  ],
                ),
                if (!isNewType &&
                    _selectedOrder!['items'] != null &&
                    _selectedOrder!['items'] is List)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text('Order Summary:',
                          style: TextStyle(color: Colors.black)),
                      ...(_selectedOrder!['items'] as List).map((item) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['name'] ?? '',
                                style: const TextStyle(color: Colors.blue)),
                            Text('x${item['quantity']}',
                                style: const TextStyle(color: Colors.blue)),
                          ],
                        );
                      }).toList(),
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
      },
    );
  }

  Widget _buildTransactionCard(DocumentSnapshot orderDoc) {
    Timestamp timestamp = orderDoc.get('date');
    DateTime orderDate = timestamp.toDate().add(const Duration(hours: 8));
    bool hasType =
        (orderDoc.data() as Map<String, dynamic>).containsKey('type');
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () => _showOrderDetails(orderDoc),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/Receive.svg',
                    height: 39,
                    width: 39,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orderDoc.id,
                          style: const TextStyle(
                            color: Color(0xFF212121),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(height: 8),
                      Text(DateFormat('yyyy-MM-dd').format(orderDate),
                          style: const TextStyle(
                            color: Color(0xFF88939E),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          )),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₱${orderDoc.get('totalPrice')}',
                      style: TextStyle(
                          color: hasType ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0)),
                  const SizedBox(height: 8),
                  Text(DateFormat('hh:mm a').format(orderDate),
                      style: const TextStyle(
                        color: Color(0xFF88939E),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transaction History'),
        titleTextStyle: TextStyle(
          color: Color(0xFF212121),
          fontSize: 18,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        actions: widget.showActionButton
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                  tooltip: 'Go to Transaction History',
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          if (widget.showSearchBar) _searchBar(),
          if (widget.showFilterCategory) _filterCategory(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Transactions')
                  .where('rfid', isEqualTo: currentRfid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionCard(snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav ? const Navigation() : null,
    );
  }

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
              _selectedLabel = '';
            } else {
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
}

void main() {
  runApp(MaterialApp(
    home: HistoryScreen(),
  ));
}
