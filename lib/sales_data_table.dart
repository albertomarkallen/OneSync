import 'package:flutter/material.dart';
import 'sales_predictor.dart';
import 'sales_dart.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesDataTable extends StatefulWidget {
  const SalesDataTable({super.key});

  @override
  _SalesDataTableState createState() => _SalesDataTableState();
}

class _SalesDataTableState extends State<SalesDataTable> {
  final List<SalesData> _salesRecords = [];
  final SalesPredictor _predictor = SalesPredictor();

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

    _salesRecords.clear(); // Clear any existing data

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
              "Expected int, double, or String for actual sales, got ${row[3].runtimeType}");
        }

        _salesRecords.add(SalesData(date: date, actualSales: actualSales));
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
  // actual sales
  Widget build(BuildContext context) {
    Map<DateTime, double> aggregatedActualSales = {};
    Map<DateTime, double> aggregatedPredictedSales = {};

    // Aggregate actual sales
    for (SalesData data in _salesRecords) {
      DateTime dateKey =
          DateTime(data.date.year, data.date.month, data.date.day);
      aggregatedActualSales[dateKey] =
          (aggregatedActualSales[dateKey] ?? 0) + data.actualSales;
    }
    List<SalesData> dailyActualSalesData = aggregatedActualSales.entries
        .map((entry) => SalesData(date: entry.key, actualSales: entry.value))
        .toList();

    // Aggregate predicted sales
    for (SalesData data in _salesRecords) {
      DateTime dateKey =
          DateTime(data.date.year, data.date.month, data.date.day);
      double prediction = _predictor.predictSales(data.date, data.actualSales);
      aggregatedPredictedSales[dateKey] =
          (aggregatedPredictedSales[dateKey] ?? 0) + prediction;
    }
    List<SalesData> dailyPredictedSalesData = aggregatedPredictedSales.entries
        .map((entry) => SalesData(date: entry.key, actualSales: entry.value))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Sales Data")),
      body: SfCartesianChart(
        // Main chart widget
        primaryXAxis: const DateTimeAxis(),
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        series: <LineSeries>[
          LineSeries<SalesData, DateTime>(
            dataSource:
                dailyActualSalesData, // Use aggregated actual sales data
            xValueMapper: (SalesData data, _) => data.date,
            yValueMapper: (SalesData data, _) => data.actualSales,
            name: 'Actual Sales',
            color: Colors.red,
          ),
          LineSeries<SalesData, DateTime>(
            // Line graph for aggregated predicted sales
            dataSource:
                dailyPredictedSalesData, // Use aggregated predicted sales data
            xValueMapper: (SalesData data, _) => data.date,
            yValueMapper: (SalesData data, _) => data.actualSales / 100,
            name: 'Predicted Sales',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Sales Data")),
//       body: DataTable(
//         columns: const [
//           DataColumn(label: Text("Date")),
//           DataColumn(label: Text("Actual Sales")),
//           DataColumn(label: Text("Predicted Sales")),
//         ],
//         rows: _salesRecords
//             .map((data) => DataRow(cells: [
//                   DataCell(Text(data.date.toString())),
//                   DataCell(Text(data.actualSales.toString())),
//                   DataCell(Text(
//                       (_predictor.predictSales(data.date, data.actualSales) /
//                               100)
//                           .toString())),
//                 ]))
//             .toList(),
//       ),
//     );
//   }
// }
