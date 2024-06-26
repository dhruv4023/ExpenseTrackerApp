class LabelMetaData {
  final String id;
  final String labelName;
  final bool isDefault;
  final bool isAccount;

  LabelMetaData({
    required this.id,
    required this.labelName,
    required this.isDefault,
    required this.isAccount,
  });

  // Factory constructor to create a LabelMetaData from a map
  factory LabelMetaData.fromJson(Map<String, dynamic> json) {
    return LabelMetaData(
      id: json['_id'] as String,
      labelName: json['label_name'] as String,
      isDefault: json['default'] as bool,
      isAccount: json['isAccount'] as bool,
    );
  }

  // Method to convert a LabelMetaData to a map
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'label_name': labelName,
      'default': isDefault,
      'isAccount': isAccount,
    };
  }
}
