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
        return _selectedOrder != null
            ? _buildDetailsDialog(context)
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetailsDialog(BuildContext context) {
    Timestamp timestamp = _selectedOrder!['date'];
    DateTime orderDate = timestamp.toDate().add(const Duration(hours: 8));
    bool isNewType = _selectedOrder!.containsKey('type') &&
        _selectedOrder!['type'] == 'Cashout';

    return isNewType
        ? _buildCashoutDetails(orderDate)
        : _buildOrderDetails(orderDate);
  }

  AlertDialog _buildCashoutDetails(DateTime orderDate) {
    return AlertDialog(
      title: Text(
        'Transaction Details',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF212121),
          fontSize: 18,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.infinity,
        child: _buildTransactionDetails(
            orderDate), // Sets the background color of the content area
      ),
      actions: [_buildCloseButton()],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }

  AlertDialog _buildOrderDetails(DateTime orderDate) {
    return AlertDialog(
      title: const Text('Transaction Details'),
      content: _buildTransactionDetails(orderDate),
      actions: [_buildCloseButton()],
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            10), // Optional: Adds rounded corners to the AlertDialog
      ),
    );
  }

  Widget _buildTransactionDetails(DateTime orderDate) {
    return SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          _buildDetailRow(
              'Transaction ID:', _selectedOrder!['transactionId'].toString()),
          _buildDetailRow('Date:', DateFormat.yMMMd().format(orderDate)),
          _buildDetailRow('Time:', DateFormat('hh:mm a').format(orderDate)),
          _buildDetailRow('Total Price:', '₱${_selectedOrder!['totalPrice']}'),
          _buildDetailRow('Type:', _selectedOrder!['type']),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black)),
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        setState(() {
          _selectedOrder = null;
        });
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFF0671E0),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          'Close',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Search Bar Decoration
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
}
