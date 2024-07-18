class Wallet {
  final String id;
  final String year;

  Wallet({
    required this.id,
    required this.year,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['_id'],
      year: json['year'],
    );
  }
}
