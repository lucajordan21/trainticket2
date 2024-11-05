// lib/models/train_ticket.dart
import 'train_stop.dart';

class TrainTicket {
  final int? id;
  final List<TrainStop> stops;
  final String date;
  final String price;
  final String seller;
  final DateTime? createdAt;

  TrainTicket({
    this.id,
    required this.stops,
    required this.date,
    required this.price,
    required this.seller,
    this.createdAt,
  });

  // Convenience getters
  String get from => stops.firstWhere((stop) => stop.isStart).station;
  String get to => stops.firstWhere((stop) => stop.isEnd).station;
  String get departureTime => stops.first.formattedTime;
  String get arrivalTime => stops.last.formattedTime;
  int get duration => stops.first.getDurationInMinutes(stops.last);
  int get numberOfStops => stops.length - 2; // Excluding start and end

  factory TrainTicket.fromJson(Map<String, dynamic> json) {
    return TrainTicket(
      id: json['id'],
      stops: (json['stops'] as List)
          .map((stop) => TrainStop.fromJson(stop))
          .toList(),
      date: json['date'],
      price: json['price'].toString(),
      seller: json['seller'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'date': date,
      'price': price,
      'seller': seller,
    };
  }

  bool servesRoute(String fromStation, String toStation) {
    final stationsList = stops.map((s) => s.station).toList();
    final fromIndex = stationsList.indexOf(fromStation);
    final toIndex = stationsList.indexOf(toStation);
    return fromIndex != -1 && toIndex != -1 && fromIndex < toIndex;
  }

  // Get stops between two stations
  List<TrainStop> getStopsBetween(String fromStation, String toStation) {
    final stationsList = stops.map((s) => s.station).toList();
    final fromIndex = stationsList.indexOf(fromStation);
    final toIndex = stationsList.indexOf(toStation);
    
    if (fromIndex == -1 || toIndex == -1 || fromIndex >= toIndex) {
      return [];
    }
    
    return stops.sublist(fromIndex, toIndex + 1);
  }

  String formatDuration() {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} min';
    }
    return '$minutes min';
  }
}