class Label {
  final String id;
  final String labelName;
  final bool isDefault;
  final bool isAccount;
  final Map<String, Map<String, double>> monthlyData;

  Label({
    required this.id,
    required this.labelName,
    required this.isDefault,
    required this.isAccount,
    required this.monthlyData,
  });

  // Utility function to ensure values are converted to double
  static double toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      throw ArgumentError('Invalid type for dr or cr value');
    }
  }

  // Factory constructor to create a Label from a map
  factory Label.fromMap(Map<String, dynamic> map) {
    Map<String, Map<String, double>> processMonthlyData(Map<String, dynamic> map) {
      return {
        'jan': map['jan'] != null ? map['jan'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'feb': map['feb'] != null ? map['feb'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'mar': map['mar'] != null ? map['mar'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'apr': map['apr'] != null ? map['apr'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'may': map['may'] != null ? map['may'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'jun': map['jun'] != null ? map['jun'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'jul': map['jul'] != null ? map['jul'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'aug': map['aug'] != null ? map['aug'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'sep': map['sep'] != null ? map['sep'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'oct': map['oct'] != null ? map['oct'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'nov': map['nov'] != null ? map['nov'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
        'dec': map['dec'] != null ? map['dec'].map<String, double>((key, value) => MapEntry(key as String, toDouble(value))) : {},
      };
    }

    return Label(
      id: map['_id'] as String,
      labelName: map['label_name'] as String,
      isDefault: map['default'] as bool,
      isAccount: map['isAccount'] as bool,
      monthlyData: processMonthlyData(map),
    );
  }

  // Method to convert a Label to a map
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'label_name': labelName,
      'default': isDefault,
      'isAccount': isAccount,
      'jan': monthlyData['jan'],
      'feb': monthlyData['feb'],
      'mar': monthlyData['mar'],
      'apr': monthlyData['apr'],
      'may': monthlyData['may'],
      'jun': monthlyData['jun'],
      'jul': monthlyData['jul'],
      'aug': monthlyData['aug'],
      'sep': monthlyData['sep'],
      'oct': monthlyData['oct'],
      'nov': monthlyData['nov'],
      'dec': monthlyData['dec'],
    };
  }

  // Method to calculate the total Dr and Cr
  Map<String, double> calculateTotalDrCr() {
    double totalDr = 0;
    double totalCr = 0;

    monthlyData.forEach((month, data) {
      totalDr += data['dr'] ?? 0;
      totalCr += data['cr'] ?? 0;
    });

    totalDr = double.parse(totalDr.toStringAsFixed(2));
    totalCr = double.parse(totalCr.toStringAsFixed(2));

    return {
      'total_dr': totalDr,
      'total_cr': totalCr,
      'overall': double.parse((totalCr - totalDr).toStringAsFixed(2)),
    };
  }
}
