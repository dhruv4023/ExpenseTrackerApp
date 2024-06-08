class Label {
  final String id;
  final String labelName;
  final bool isDefault;
  final Map<String, Map<String, double>> monthlyData;

  Label({
    required this.id,
    required this.labelName,
    required this.isDefault,
    required this.monthlyData,
  });

  // Factory constructor to create a Label from a map
  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['_id'] as String,
      labelName: map['label_name'] as String,
      isDefault: map['default'] as bool,
      monthlyData: {
        'jan': Map<String, double>.from(map['jan']),
        'feb': Map<String, double>.from(map['feb']),
        'mar': Map<String, double>.from(map['mar']),
        'apr': Map<String, double>.from(map['apr']),
        'may': Map<String, double>.from(map['may']),
        'jun': Map<String, double>.from(map['jun']),
        'jul': Map<String, double>.from(map['jul']),
        'aug': Map<String, double>.from(map['aug']),
        'sep': Map<String, double>.from(map['sep']),
        'oct': Map<String, double>.from(map['oct']),
        'nov': Map<String, double>.from(map['nov']),
        'dec': Map<String, double>.from(map['dec']),
      },
    );
  }

  // Method to convert a Label to a map
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'label_name': labelName,
      'default': isDefault,
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
      "overall": double.parse((totalCr - totalDr).toStringAsFixed(2)),
    };
  }

  @override
  String toString() {
    return 'Label{id: $id, labelName: $labelName, isDefault: $isDefault, monthlyData: $monthlyData}';
  }
}
