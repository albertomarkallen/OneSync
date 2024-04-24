import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/screens/Dashboard/detail_transaction.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailTransactionHistoryScreen()),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/Dashboard_Icon.svg',
                    width: 14,
                    height: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ...List.generate(20, (index) => buildTransactionCard()),
          ],
        ),
      ),
    );
  }

  Widget buildTransactionCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLeadingIcon(),
          _buildTransactionDetails(),
          _buildAmountAndTime(),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return SvgPicture.asset('assets/Receive.svg',
        width: 36, height: 36, semanticsLabel: 'Leading Icon');
  }

  Widget _buildTransactionDetails() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Name of Store',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Aug 20, 2023',
              style: TextStyle(
                color: Color(0xFF88939E),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountAndTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        Text(
          'Php 500.00',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '8:23 PM',
          style: TextStyle(
            color: Color(0xFF88939E),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
