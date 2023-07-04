import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:statistics/statistics.dart';
import 'package:transafe/accgyro/statistical_function.dart';
import 'package:sklite/SVM/SVM.dart';
import 'package:sklite/utils/io.dart';
import 'dart:convert';


class Screen2 extends StatefulWidget {
  const Screen2({Key? key}) : super(key: key);

  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  int res = 0;
  String interaccgyro = 'Null';
  String intermediatedata = 'Null';
  double accX = 0, accY = 0, accZ = 0, gyroX = 0, gyroY = 0, gyroZ = 0;
  String _prediction = 'Null';
  String accelerometerValues = 'Null';
  String gyroscopeValues = 'Null';
  List<double> inputdata = [];
  List<double> means = List.filled(NUM_COLUMNS, 0.0);
  List<double> skewnesses = List.filled(NUM_COLUMNS, 0.0);
  List<double> kurtosis = List.filled(NUM_COLUMNS, 0.0);
  List<double> sums = List.filled(NUM_COLUMNS, 0.0);
  List<double> mins = List.filled(NUM_COLUMNS, double.infinity);
  List<double> maxs = List.filled(NUM_COLUMNS, double.negativeInfinity);
  List<double> variances = List.filled(NUM_COLUMNS, 0.0);
  List<double> medians = List.filled(NUM_COLUMNS, 0.0);
  List<double> standardDeviations = List.filled(NUM_COLUMNS, 0.0);
  static const int QUEUE_CAPACITY = 14;
  static const int NUM_COLUMNS = 6;
  List<double> currentData = List.filled(NUM_COLUMNS, 0.0);
  List<List<double>> dataQueue = List.generate(QUEUE_CAPACITY, (_) => List.filled(NUM_COLUMNS, 0.0), growable: true);
  SVC? svc;
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    loadModel("assets/transafe2.json").then((x) {
      setState(() {
        svc = SVC.fromMap(json.decode(x));
        startListeningSensors();
      });
    });
  }

  void startListeningSensors() {
    Stream<dynamic> sensorStream = StreamZip([userAccelerometerEvents, gyroscopeEvents]);

    sensorStream.listen((sensorData) {
      if (mounted) { // Check if the widget is still in the tree
        UserAccelerometerEvent accelerometerEvent = sensorData[0];
        GyroscopeEvent gyroscopeEvent = sensorData[1];

        setState(() {
          accX = accelerometerEvent.x;
          accY = accelerometerEvent.y;
          accZ = accelerometerEvent.z;

          gyroX = gyroscopeEvent.x;
          gyroY = gyroscopeEvent.y;
          gyroZ = gyroscopeEvent.z;

          accelerometerValues =
          'Accelerometer: X=${accX.toStringAsFixed(2)}, Y=${accY.toStringAsFixed(2)}, Z=${accZ.toStringAsFixed(2)}';
          gyroscopeValues =
          'Gyroscope: X=${gyroX.toStringAsFixed(2)}, Y=${gyroY.toStringAsFixed(2)}, Z=${gyroZ.toStringAsFixed(2)}';
          updateData();
          performStatisticalOperations();
          makePrediction();
        });
      }
    });
  }

  void updateData() {
    currentData[0] = accX;
    currentData[1] = accY;
    currentData[2] = accZ;
    currentData[3] = gyroX;
    currentData[4] = gyroY;
    currentData[5] = gyroZ;
    dataQueue.removeAt(0);
    dataQueue.add(currentData.toList());
    interaccgyro = dataQueue.toString();
    // print(dataQueue.length);
  }

  void performStatisticalOperations() {
    for (var i = 0; i < NUM_COLUMNS; i++) {
      List<double> columnData = dataQueue.map((row) => row[i]).toList();
      means[i] = columnData.mean;
      skewnesses[i] = StatisticalFunctions.calculateSkewness(columnData);
      kurtosis[i] = StatisticalFunctions.calculateKurtosis(columnData);
      sums[i] = columnData.sum;
      mins[i] = columnData.reduce((a, b) => a < b ? a : b);
      maxs[i] = columnData.reduce((a, b) => a > b ? a : b);
      variances[i] = StatisticalFunctions.calculateVariance(columnData);
      medians[i] = StatisticalFunctions.calculateMedian(columnData);
      standardDeviations[i] = columnData.standardDeviation;
    }
    inputdata = [
      means[0], means[1], means[2], means[3], means[4], means[5], maxs[0], maxs[1], maxs[2], maxs[3], maxs[4], maxs[5], mins[0], mins[1], mins[2], mins[3], mins[4], mins[5],
      sums[0], sums[1], sums[2], sums[3], sums[4], sums[5], variances[0], variances[1], variances[2], variances[3], variances[4], variances[5],
      standardDeviations[0], standardDeviations[1], standardDeviations[2], standardDeviations[3], standardDeviations[4], standardDeviations[5], skewnesses[0], skewnesses[1], skewnesses[2], skewnesses[3], skewnesses[4], skewnesses[5],
      kurtosis[0], kurtosis[1], kurtosis[2], kurtosis[3], kurtosis[4], kurtosis[5], medians[0], medians[1], medians[2], medians[3], medians[4], medians[5],
    ];
    intermediatedata = inputdata.toString();
    // print(inputdata.length);
  }

  void makePrediction() {
    if (svc != null) {
      setState(() {
        res = svc!.predict(inputdata).toInt();
        if (res == 1)
          _prediction = 'Safe';
        else if (res == 3)
          _prediction = 'Aggressive';
      });
    } else {
      setState(() {
        _prediction = 'Error: Model not loaded';
      });
    }
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 2'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Prediction: $_prediction'),
              const SizedBox(height: 20),
              Text(accelerometerValues),
              const SizedBox(height: 20),
              Text(gyroscopeValues),
            ],
          ),
        ),
      ),
    );
  }
}
