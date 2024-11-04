class TrainTicket {
  final int? id;
  final String from;
  final String to;
  final String date;
  final String time;
  final String price;  // Keep as String since that's what Supabase expects
  final String seller;
  final DateTime? createdAt;

  TrainTicket({
    this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.price,
    required this.seller,
    this.createdAt,
  });

  factory TrainTicket.fromJson(Map<String, dynamic> json) {
    return TrainTicket(
      id: json['id'],
      from: json['from_station'],
      to: json['to_station'],
      date: json['date'],
      time: json['time'],
      price: json['price'].toString(), // Convert to String
      seller: json['seller'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_station': from,
      'to_station': to,
      'date': date,
      'time': time,
      'price': price,
      'seller': seller,
    };
  }
}