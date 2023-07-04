import 'dart:math';

class StatisticalFunctions {
  static double calculateMean(List<double> dataList) {
    double sum = 0;
    for (var value in dataList) {
      sum += value;
    }
    return sum / dataList.length;
  }

  static double calculateVariance(List<double> dataList) {
    double mean = calculateMean(dataList);
    double variance = 0;
    for (var value in dataList) {
      variance += pow(value - mean, 2);
    }
    return variance / dataList.length;
  }

  static double calculateStandardDeviation(List<double> dataList) {
    return sqrt(calculateVariance(dataList));
  }

  static double calculateMedian(List<double> dataList) {
    List<double> sortedList = List.from(dataList);
    sortedList.sort();
    int middleIndex = sortedList.length ~/ 2;
    if (sortedList.length % 2 == 0) {
      return (sortedList[middleIndex - 1] + sortedList[middleIndex]) / 2;
    } else {
      return sortedList[middleIndex];
    }
  }
  static double calculateSkewness(List<double> dataList) {
    double mean = calculateMean(dataList);
    double variance = calculateVariance(dataList);
    double skewness = 0;

    if (variance == 0) {
      return 0; // or any other appropriate value when variance is zero
    }

    for (var value in dataList) {
      skewness += pow((value - mean) / sqrt(variance), 3);
    }

    return skewness * (dataList.length / ((dataList.length - 1) * (dataList.length - 2)));
  }

  static double calculateKurtosis(List<double> dataList) {
    double mean = calculateMean(dataList);
    double variance = calculateVariance(dataList);
    double kurtosis = 0;

    if (variance == 0) {
      return 0; // or any other appropriate value when variance is zero
    }

    for (var value in dataList) {
      kurtosis += pow((value - mean) / (sqrt(variance)), 4);
    }

    return (kurtosis * (dataList.length * (dataList.length + 1))) /
        ((dataList.length - 1) * (dataList.length - 2) * (dataList.length - 3));
  }


  static double _calculateMeanOfList(List<double> list) {
    double sum = 0;
    for (var value in list) {
      sum += value;
    }
    return sum / list.length;
  }
}
