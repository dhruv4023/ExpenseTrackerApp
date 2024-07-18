import 'package:intl/intl.dart'; // For date formatting

class Transaction {
  final String id;
  final String comment;
  final String labelId;
  final String accountId;
  final double amt;
  final DateTime addedOn;
  final DateTime updatedOn;

  Transaction({
    required this.id,
    required this.comment,
    required this.accountId,
    required this.labelId,
    required this.amt,
    required this.addedOn,
    required this.updatedOn,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] as String,
      comment: json['comment'] as String,
      accountId: json['account_id'] as String,
      labelId: json['label_id'] as String,
      amt: (json['amt'] is int) ? (json['amt'] as int).toDouble() : json['amt'] as double,
      addedOn: DateTime.parse(json['added_on'] as String), // Assuming added_on is ISO 8601 string
      updatedOn: DateTime.parse(json['updated_on'] as String), // Assuming updated_on is ISO 8601 string
    );
  }

  String get formattedAddedOn {
    return DateFormat.yMMMd().add_jms().format(addedOn); // Example format: Jul 16, 2024 10:15:30 AM
  }

  String get formattedUpdatedOn {
    return DateFormat.yMMMd().add_jms().format(updatedOn); // Example format: Jul 16, 2024 10:15:30 AM
  }
}
