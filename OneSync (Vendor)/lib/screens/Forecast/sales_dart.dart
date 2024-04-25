class SalesData {
  DateTime date;
  double actualSales;
  // double predictedSales; // Added for storing predicted sales data
  String mealName;

  SalesData({
    required this.date,
    required this.actualSales,
    // required this.predictedSales, // Ensuring this is now part of your constructor
    required this.mealName,
  });
}
