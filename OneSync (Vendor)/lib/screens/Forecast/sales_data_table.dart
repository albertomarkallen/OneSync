import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class SalesDataTable extends StatefulWidget {
  const SalesDataTable({super.key});

  @override
  _SalesDataTableState createState() => _SalesDataTableState();
}

class _SalesDataTableState extends State<SalesDataTable> {
  final List<SalesData> _actualSalesRecords = [];
  final List<SalesData> _predictedSalesRecords = [];
  String selectedName = 'All'; // To hold the selected meal name
  final List<String> mealNames = [
    'All',
    'Java Rice',
    'Javalong',
    'Javagets',
    'Javadog',
    'Javaling',
    'Javalog',
    'Javamai',
    'Sinigang w/ Rice',
    'Adobo w/ Rice',
    'Chicken Afritada w/ Rice',
    'Menudo w/ Rice'
  ];

  @override
  void initState() {
    super.initState();
    _loadCSVData();
  }

  void _loadCSVData() async {
    final actualSalesCsvData =
        await rootBundle.loadString('assets/Meal_Orders_Transactions.csv');
    List<List<dynamic>> actualSalesTable =
        const CsvToListConverter().convert(actualSalesCsvData);
    _processCsvData(actualSalesTable, _actualSalesRecords);

    final predictedSalesCsvData =
        await rootBundle.loadString('assets/Meal_Orders_Transactions_2.csv');
    List<List<dynamic>> predictedSalesTable =
        const CsvToListConverter().convert(predictedSalesCsvData);
    _processCsvData(predictedSalesTable, _predictedSalesRecords);

    setState(() {});
  }

  void _processCsvData(
      List<List<dynamic>> csvTable, List<SalesData> salesList) {
    Map<DateTime, double> dateCounts = {};

    for (var row in csvTable.skip(1)) {
      if (selectedName == 'All' || row[1] == selectedName) {
        try {
          var rawDateTimeString = row[0].trim();
          DateTime date = DateFormat("M/d/yyyy H:mm").parse(rawDateTimeString);
          DateTime dateOnly = DateTime(date.year, date.month, date.day);
          double orders = double.parse(
              row[2].toString()); // Convert the number of orders to double
          dateCounts[dateOnly] =
              (dateCounts[dateOnly] ?? 0) + orders; // Sum orders per date
        } catch (e) {
          print("Error parsing row: $row, Error: $e");
        }
      }
    }

    salesList.clear();
    var sortedDates = dateCounts.keys.toList()..sort();
    for (var date in sortedDates) {
      salesList.add(SalesData(date: date, sales: dateCounts[date] ?? 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          DropdownButton<String>(
            value: selectedName,
            icon: const Icon(Icons.arrow_downward),
            onChanged: (String? newValue) {
              setState(() {
                selectedName = newValue!;
                _loadCSVData(); // Reload data with the new filter
              });
            },
            items: mealNames.map<DropdownMenuItem<String>>((String name) {
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LineChart(LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final date =
                          DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Text(DateFormat('MMM dd').format(date));
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: false), // This hides the top titles
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              minY: selectedName == 'All'
                  ? 1
                  : 1, // Default min Y for "All" or specific meal
              maxY: selectedName == 'All'
                  ? 150
                  : 20, // Adjusted max Y for specific meal
              lineBarsData: [
                LineChartBarData(
                  spots: _actualSalesRecords
                      .map((data) => FlSpot(
                          data.date.millisecondsSinceEpoch.toDouble(),
                          data.sales))
                      .toList(),
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: _predictedSalesRecords
                      .map((data) => FlSpot(
                          data.date.millisecondsSinceEpoch.toDouble(),
                          data.sales))
                      .toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                )
              ],
            )),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Color(0xFFD32F2F), "Actual Sales"),
                SizedBox(width: 10),
                _buildLegend(Color(0xFF1976D2), "Predicted Sales"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.stop, color: color),
        SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

class SalesData {
  SalesData({required this.date, required this.sales});

  final DateTime date;
  final double sales;
}
