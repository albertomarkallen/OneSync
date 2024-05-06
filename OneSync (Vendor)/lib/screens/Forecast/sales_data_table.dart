import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import 'sales_dart.dart';
import 'sales_predictor.dart';

class SalesDataTable extends StatefulWidget {
  const SalesDataTable({super.key});

  @override
  _SalesDataTableState createState() => _SalesDataTableState();
}

class _SalesDataTableState extends State<SalesDataTable> {
  final List<SalesData> _salesRecords = [];
  final SalesPredictor _predictor = SalesPredictor();
  String _selectedDateFilter = 'Weekly'; // Default filter
  String _selectedMeal = 'All'; // Initially show all meals
  List<String> _mealNames = ['All', 'Meal A', 'Meal B', 'Meal C', 'Meal D'];
  final List<String> _dateFilters = ['Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _predictor.loadModel().then((_) {
      _loadCSVData(); // Move this inside the callback to ensure the model is loaded
    });
  }

  void _loadCSVData() async {
    final csvData =
        await rootBundle.loadString('assets/Meal_Orders_Transactions.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);

    _salesRecords.clear(); // Clear existing data
    _mealNames = ['All']; // Reset meal names

    for (var row in csvTable.skip(1)) {
      var rawDateTimeString = row[0].trim();
      DateTime date = DateFormat("M/d/yyyy H:mm").parse(rawDateTimeString);
      double actualSales = double.tryParse(row[2].toString()) ?? 0.0;
      List<dynamic> mealNames =
          row[1].split(',').map((name) => name.trim()).toList();
      for (String mealName in mealNames) {
        if (!_mealNames.contains(mealName)) {
          _mealNames.add(mealName);
        }
        _salesRecords.add(SalesData(
            date: date, actualSales: actualSales, mealName: mealName));
      }
    }
    setState(() {});
  }

  List<LineChartBarData> _createChartBarData() {
    Map<DateTime, double> dailyActual = {};
    Map<DateTime, double> dailyPredicted = {};

    Iterable<SalesData> filteredRecords = (_selectedMeal == 'All')
        ? _salesRecords
        : _salesRecords.where((record) => record.mealName == _selectedMeal);

    for (var data in filteredRecords) {
      DateTime day = DateTime(data.date.year, data.date.month, data.date.day);
      dailyActual[day] = (dailyActual[day] ?? 0) + data.actualSales;
      double predicted = _predictor.predictSales(day, dailyActual[day]!);
      dailyPredicted[day] = predicted / 30;
    }

    List<FlSpot> actualSpots = dailyActual.entries
        .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
        .toList();
    List<FlSpot> predictedSpots = dailyPredicted.entries
        .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
        .toList();

    return [
      LineChartBarData(
        spots: actualSpots,
        isCurved: true,
        color: Colors.red,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: predictedSpots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Data"),
        actions: [
          DropdownButton<String>(
            value: _selectedMeal,
            onChanged: (newValue) {
              setState(() {
                _selectedMeal = newValue ?? 'All';
              });
            },
            items: _mealNames.map((mealName) {
              return DropdownMenuItem(value: mealName, child: Text(mealName));
            }).toList(),
          ),
          DropdownButton<String>(
            value: _selectedDateFilter,
            onChanged: (newValue) {
              setState(() {
                _selectedDateFilter = newValue ?? 'Weekly';
              });
            },
            items: _dateFilters.map((dateFilter) {
              return DropdownMenuItem(
                  value: dateFilter, child: Text(dateFilter));
            }).toList(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LineChart(LineChartData(
          minY: 1, // Setting minimum y-axis value
          maxY: 150, // Setting maximum y-axis value
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: _createChartBarData(),
        )),
      ),
    );
  }
}
