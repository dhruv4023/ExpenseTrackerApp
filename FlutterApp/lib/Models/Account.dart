class Account {
  String id;
  String accountName;
  bool isDefault;
  double openingBalance;
  DateTime addedOn;
  DateTime updatedOn;
  double balance;

  Account({
    required this.id,
    required this.accountName,
    required this.isDefault,
    required this.openingBalance,
    required this.addedOn,
    required this.updatedOn,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['_id'] as String,
      accountName: json['account_name'] as String,
      isDefault: json['default'] as bool,
      openingBalance: json['opening_balance'] as double,
      balance: json['balance'] as double,
      addedOn: DateTime.parse(json['added_on'] as String),
      updatedOn: DateTime.parse(json['updated_on'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'account_name': accountName,
      'default': isDefault,
      'balance':balance,
      'opening_balance': openingBalance,
      'added_on': addedOn.toIso8601String(),
      'updated_on': updatedOn.toIso8601String(),
    };
  }
}
