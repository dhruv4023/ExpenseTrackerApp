class Transaction {
  final String id;
  final String dateTime;
  final String comment;
  final List<String> labelIds; // Changed to List<String>
  final double amt;

  Transaction({
    required this.id,
    required this.dateTime,
    required this.comment,
    required this.labelIds, // Changed to List<String>
    required this.amt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      dateTime: json['dateTime'],
      comment: json['comment'],
      labelIds:
          List<String>.from(json['label_ids']), // Parsing the list of label IDs
      amt: json['amt'],
    );
  }
}
