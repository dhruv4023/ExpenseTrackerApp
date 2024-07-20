class Label {
  final String id;
  final String labelName;
  final bool isDefault;
  final DateTime addedOn;
  final DateTime updatedOn;
  final double balance;

  Label({
    required this.id,
    required this.labelName,
    required this.isDefault,
    required this.addedOn,
    required this.updatedOn,
    required this.balance,
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['_id'] as String,
      labelName: json['label_name'] as String,
      isDefault: json['default'] as bool,
      balance: (json['balance'] is int) ? (json['balance'] as int).toDouble() : json['balance'] as double,
      addedOn: DateTime.parse(json['added_on'] as String),
      updatedOn: DateTime.parse(json['updated_on'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'label_name': labelName,
      'default': isDefault,
      'balance': balance,
      'added_on': addedOn.toIso8601String(),
      'updated_on': updatedOn.toIso8601String(),
    };
  }
}
