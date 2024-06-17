class Wallet {
  final String id;
  final String title;
  final String year;

  Wallet({
    required this.id,
    required this.title,
    required this.year,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['_id'],
      title: json['title'],
      year: json['year'],
    );
  }
}
