import 'package:intl/intl.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SalesPredictor {
  late Interpreter _interpreter;
  bool _modelLoaded = false;

  // Load the model and set _modelLoaded flag
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/simple_model.tflite');
      _modelLoaded = true;
      print("Model loaded successfully");
      print(_interpreter.getInputTensors());
      print(_interpreter.getOutputTensors());
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  // Perform prediction
  double predictSales(DateTime date, double pastSales) {
    if (!_modelLoaded) {
      print("Model is not loaded.");
      return 0.0;
    }

    try {
      List<double> input = prepareInputData(date, pastSales);
      var inputTensor = List<double>.filled(35, 0.0).reshape([1, 5, 7]);
// Assume 'input' is a flat list with 35 elements (5 time steps * 7 features each)
      for (int i = 0; i < input.length; i++) {
        inputTensor[0][i ~/ 7][i % 7] = input[i];
      }
      var outputTensor = List<double>.filled(1, 0.0).reshape([1, 1]);

      _interpreter.run(inputTensor, outputTensor); // Run inference
      double predictedSales = postProcess(outputTensor[0][0]);
      return predictedSales;
    } catch (e) {
      print("Error during prediction: $e");
      return 0.0; // Return a default or error value
    }
  }

  // Prepare the input data for the model
  List<double> prepareInputData(DateTime date, double pastSales) {
    // Normalize the date features based on the actual range of the data

    // Year normalization remains the same since all data is from 2024
    double yearNormalized = (date.year - 2024) / (2024 - 2024 + 1);

    // Month normalization between April (4) and May (5)
    double monthNormalized = (date.month - 4) / (5 - 4);

    // Day normalization: April has 30 days, use 31 for the calculation to handle May correctly
    double dayNormalized = (date.day - 1) / (31 - 1);

    // Day of week normalization (1-7)
    double dayOfWeekNormalized = (date.weekday - 1) / (7 - 1);

    // Week of year normalization based on the specific weeks occurring in the range
    int startWeekOfYear = getWeekOfYear(DateTime(2024, 4, 22));
    int endWeekOfYear = getWeekOfYear(DateTime(2024, 5, 4));
    // int weekOfYear = getWeekOfYear(date);
    int futureWeekOfYear = getWeekOfYear(DateTime(2024, 4, 30));
    double weekOfYearNormalized = (futureWeekOfYear - startWeekOfYear) /
        (endWeekOfYear - startWeekOfYear);

    // Date ordinal normalization based on the start and end date ordinals
    double startOrdinal =
        DateTime(2024, 4, 22).toUtc().millisecondsSinceEpoch / 86400000 +
            719162;
    double endOrdinal =
        DateTime(2024, 5, 4).toUtc().millisecondsSinceEpoch / 86400000 + 719162;
    double dateOrdinal =
        date.toUtc().millisecondsSinceEpoch / 86400000 + 719162;
    double dateOrdinalScaled =
        (dateOrdinal - startOrdinal) / (endOrdinal - startOrdinal);

    // Normalize sales data based on expected range (adjust max if known)
    double ordersNormalized = (pastSales - 1) /
        (5 - 1); // Assuming '5' is the maximum sales value observed or expected

    return [
      yearNormalized,
      monthNormalized,
      dayNormalized,
      dayOfWeekNormalized,
      weekOfYearNormalized,
      dateOrdinalScaled,
      ordersNormalized,
      futureWeekOfYear.toDouble()
    ];
  }

  // Post-process the output from the model
  double postProcess(double rawOutput) {
    return rawOutput * (1000 - 1) +
        1; // Adjust based on the scaling used during training
  }

  // Utility function to get week of the year
  int getWeekOfYear(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
