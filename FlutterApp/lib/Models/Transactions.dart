class Transaction {
  final String id;
  final String dateTime;
  final String comment;
  final String labelId;
  final String accountId;
  final double amt;

  Transaction({
    required this.id,
    required this.dateTime,
    required this.comment,
    required this.accountId,
    required this.labelId,
    required this.amt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      dateTime: json['dateTime'],
      comment: json['comment'],
      accountId: json['account_id'],
      labelId: json['label_id'],
      amt: json['amt'],
    );
  }
}
