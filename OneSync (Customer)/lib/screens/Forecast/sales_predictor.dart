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
    // Normalize the date features
    double yearNormalized = (date.year - 2000) / (2023 - 2000);
    double monthNormalized = (date.month - 1) / (12 - 1);
    double dayNormalized = (date.day - 1) / (31 - 1);
    double dayOfWeekNormalized = (date.weekday - 1) / (7 - 1);
    int weekOfYear = getWeekOfYear(date);
    double weekOfYearNormalized = (weekOfYear - 1) / (52 - 1);

    double dateOrdinal =
        date.toUtc().millisecondsSinceEpoch / 86400000 + 719162;
    double dateOrdinalScaled = (dateOrdinal - 730120) / (738061 - 730120);

    double ordersNormalized = (pastSales - 1) / (5 - 1);

    return [
      yearNormalized,
      monthNormalized,
      dayNormalized,
      dayOfWeekNormalized,
      weekOfYearNormalized,
      dateOrdinalScaled,
      ordersNormalized
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
