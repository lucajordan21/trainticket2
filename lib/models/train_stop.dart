import 'package:flutter/material.dart';

class TrainStop {
  final String station;
  final String time;  // Format: "HH:mm"
  final bool isStart;
  final bool isEnd;

  TrainStop({
    required this.station,
    required this.time,
    this.isStart = false,
    this.isEnd = false,
  });

  // Convert TimeOfDay to String in HH:mm format
  static String formatTime(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Convert String (HH:mm) to TimeOfDay
  TimeOfDay get timeOfDay {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Compare times between stops
  bool isBefore(TrainStop other) {
    final thisTime = timeOfDay;
    final otherTime = other.timeOfDay;
    return thisTime.hour < otherTime.hour || 
           (thisTime.hour == otherTime.hour && thisTime.minute < otherTime.minute);
  }

  // Get minutes from midnight
  int get minutesFromMidnight {
    return timeOfDay.hour * 60 + timeOfDay.minute;
  }

  // Calculate duration between stops
  int getDurationInMinutes(TrainStop other) {
    return other.minutesFromMidnight - minutesFromMidnight;
  }

  Map<String, dynamic> toJson() {
    return {
      'station': station,
      'time': time,
      'isStart': isStart,
      'isEnd': isEnd,
    };
  }

  factory TrainStop.fromJson(Map<String, dynamic> json) {
    return TrainStop(
      station: json['station'],
      time: json['time'],
      isStart: json['isStart'] ?? false,
      isEnd: json['isEnd'] ?? false,
    );
  }

  // Copy with method for creating modified instances
  TrainStop copyWith({
    String? station,
    String? time,
    bool? isStart,
    bool? isEnd,
  }) {
    return TrainStop(
      station: station ?? this.station,
      time: time ?? this.time,
      isStart: isStart ?? this.isStart,
      isEnd: isEnd ?? this.isEnd,
    );
  }

  // For debugging
  @override
  String toString() {
    return 'TrainStop(station: $station, time: $time, isStart: $isStart, isEnd: $isEnd)';
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is TrainStop &&
      other.station == station &&
      other.time == time &&
      other.isStart == isStart &&
      other.isEnd == isEnd;
  }

  @override
  int get hashCode {
    return station.hashCode ^
      time.hashCode ^
      isStart.hashCode ^
      isEnd.hashCode;
  }

  // Validation methods
  static bool isValidTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
    } catch (e) {
      return false;
    }
  }

  static bool areValidStops(List<TrainStop> stops) {
    if (stops.isEmpty) return false;
    
    // Check if there's exactly one start and one end
    final startStops = stops.where((stop) => stop.isStart).length;
    final endStops = stops.where((stop) => stop.isEnd).length;
    if (startStops != 1 || endStops != 1) return false;

    // Check if times are in order
    for (int i = 0; i < stops.length - 1; i++) {
      if (!stops[i].isBefore(stops[i + 1])) return false;
    }

    return true;
  }

  // Format time for display
  String get formattedTime {
    return time.substring(0, 5); // Remove seconds if present
  }

  // Get stop type description
  String get stopType {
    if (isStart) return 'Partenza';
    if (isEnd) return 'Arrivo';
    return 'Fermata Intermedia';
  }
}