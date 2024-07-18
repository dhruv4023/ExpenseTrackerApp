class LabelAccount {
  String id;
  String labelORAccountName;
  bool isDefault;

  LabelAccount(
      {required this.id,
      required this.isDefault,
      required this.labelORAccountName});

  factory LabelAccount.fromJson(Map<String, dynamic> json) {
    return LabelAccount(
      id: json['_id'],
      isDefault: json['default'] as bool,
      labelORAccountName: json['label_name'] ?? json['account_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['isDefault'] = this.isDefault;
    data['labelORAccountName'] = this.labelORAccountName;
    return data;
  }
}
