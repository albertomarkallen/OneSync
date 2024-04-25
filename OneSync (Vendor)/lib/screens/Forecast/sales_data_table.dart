import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  String _selectedDateFilter = 'Weekly'; // Default filter is now 'Weekly'
  String _selectedMeal = 'All'; // Initially show all meals
  List<String> _mealNames = ['All', 'Meal A', 'Meal B', 'Meal C', 'Meal D'];
  final List<String> _dateFilters = [
    'Weekly',
    'Monthly',
    'Yearly'
  ]; // Removed 'Daily' option

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
      try {
        // Trim and parse the date
        var rawDateTimeString = row[0].trim();
        DateTime date = DateFormat("M/d/yyyy H:mm").parse(rawDateTimeString);

        // Flexible parsing for actualSales to handle int, double, or String inputs
        double actualSales = 0;
        if (row[2] is int) {
          actualSales = row[2].toDouble(); // Convert int directly to double
        } else if (row[2] is double) {
          actualSales = row[2]; // Use double as is
        } else if (row[2] is String) {
          actualSales = double.parse(row[2]); // Parse string to double
        } else {
          throw FormatException(
              "Expected int, double, or String for actual sales, got ${row[2].runtimeType}");
        }

        // Handle a list of meal names in a single cell, split by comma
        List<dynamic> mealNames =
            row[1].split(',').map((name) => name.trim()).toList();
        for (String mealName in mealNames) {
          if (!_mealNames.contains(mealName)) {
            _mealNames.add(mealName);
          }
          // Add sales record for each meal
          _salesRecords.add(SalesData(
              date: date, actualSales: actualSales, mealName: mealName));
        }
      } catch (e) {
        print("------ ERROR ------");
        print("Error parsing date in row: $row");
        print("The error is: $e");
        print("------ END ERROR ------");
        // Optionally, you could add logic to skip the row, insert a default date, etc.
      }
    }

    setState(() {}); // Update the UI to reflect the loaded data
  }

  @override
  Widget build(BuildContext context) {
    // Generate a unique key based on the selected meal and date filter to force re-rendering of the chart
    Key chartKey = ValueKey('$_selectedMeal$_selectedDateFilter');

    List<SalesData> filteredRecords = _selectedMeal == 'All'
        ? _salesRecords
        : _salesRecords
            .where((record) => record.mealName == _selectedMeal)
            .toList();

    Map<DateTime, double> aggregatedActualSales = {};
    Map<DateTime, double> aggregatedPredictedSales = {};

    // weekly aggregation
    for (var record in filteredRecords) {
      DateTime dateKey =
          DateTime(record.date.year, record.date.month, record.date.day);
      aggregatedActualSales[dateKey] =
          (aggregatedActualSales[dateKey] ?? 0) + record.actualSales;
      double prediction =
          _predictor.predictSales(record.date, record.actualSales);
      aggregatedPredictedSales[dateKey] =
          (aggregatedPredictedSales[dateKey] ?? 0) + prediction;
    }

    List<SalesData> dailyActualSalesData = aggregatedActualSales.entries
        .map((entry) =>
            SalesData(date: entry.key, actualSales: entry.value, mealName: ''))
        .toList();
    List<SalesData> dailyPredictedSalesData = aggregatedPredictedSales.entries
        .map((entry) =>
            SalesData(date: entry.key, actualSales: entry.value, mealName: ''))
        .toList();
    _mealNames.sort();

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          DropdownButton<String>(
            value: _selectedMeal,
            onChanged: (newValue) {
              setState(() {
                _selectedMeal = newValue ?? 'All';
              });
            },
            items: _mealNames.map((mealName) {
              return DropdownMenuItem(
                value: mealName,
                child: Text(mealName),
              );
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
                value: dateFilter,
                child: Text(dateFilter),
              );
            }).toList(),
          ),
        ],
      ),
      body: _selectedDateFilter == 'Monthly' || _selectedDateFilter == 'Yearly'
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "Not enough data",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Expanded(
              child: SfCartesianChart(
                key: chartKey,
                primaryXAxis: const DateTimeAxis(),
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: _selectedDateFilter == 'Weekly'
                    ? <LineSeries>[
                        LineSeries<SalesData, DateTime>(
                          dataSource: dailyActualSalesData,
                          xValueMapper: (SalesData data, _) => data.date,
                          yValueMapper: (SalesData data, _) => data.actualSales,
                          name: 'Actual Sales',
                          color: Colors.red,
                          // Add TooltipBehavior to show y-value on tooltip
                          markerSettings: const MarkerSettings(isVisible: true),
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelAlignment: ChartDataLabelAlignment.auto,
                          ),
                          enableTooltip: true,
                        ),
                        LineSeries<SalesData, DateTime>(
                          dataSource: dailyPredictedSalesData,
                          xValueMapper: (SalesData data, _) => data.date,
                          yValueMapper: (SalesData data, _) =>
                              data.actualSales / 375,
                          name: 'Predicted Sales',
                          color: Colors.blue,
                          markerSettings: const MarkerSettings(isVisible: true),
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelAlignment: ChartDataLabelAlignment.auto,
                          ),
                          enableTooltip: true,
                        ),
                      ]
                    : [],
              ),
            ),
    );
  }
}
