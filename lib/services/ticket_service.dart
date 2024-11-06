// lib/services/ticket_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/train_ticket.dart';
import '../models/train_stop.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final _supabase = Supabase.instance.client;

  // Get all tickets stream
  Stream<List<TrainTicket>> get ticketsStream {
    return _supabase
      .from('tickets')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((rows) {
        return rows.map((data) => TrainTicket.fromJson(data)).toList();
      });
  }

  // Get tickets by date
  Future<List<TrainTicket>> getTicketsByDate({required String date}) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .eq('date', date);
      
      return (response as List)
          .map((data) => TrainTicket.fromJson(data))
          .toList();
    } catch (e) {
      throw 'Error fetching tickets: $e';
    }
  }

  // Add a new ticket
  Future<void> addTicket(TrainTicket ticket) async {
    try {
      final ticketData = {
        'stops': ticket.stops.map((stop) => {
          'station': stop.station,
          'time': stop.time,
          'isStart': stop.isStart,
          'isEnd': stop.isEnd,
        }).toList(),
        'date': ticket.date,
        'price': double.parse(ticket.price),
        'seller': ticket.seller,
      };

      await _supabase
          .from('tickets')
          .insert(ticketData);
    } catch (e) {
      throw 'Error adding ticket: $e';
    }
  }

  // Delete a ticket
  Future<void> deleteTicket(int ticketId) async {
    try {
      await _supabase
          .from('tickets')
          .delete()
          .eq('id', ticketId);
    } catch (e) {
      throw 'Error deleting ticket: $e';
    }
  }

  // Update a ticket
  Future<void> updateTicket(int ticketId, TrainTicket ticket) async {
    try {
      final ticketData = {
        'stops': ticket.stops.map((stop) => {
          'station': stop.station,
          'time': stop.time,
          'isStart': stop.isStart,
          'isEnd': stop.isEnd,
        }).toList(),
        'date': ticket.date,
        'price': double.parse(ticket.price),
        'seller': ticket.seller,
      };

      await _supabase
          .from('tickets')
          .update(ticketData)
          .eq('id', ticketId);
    } catch (e) {
      throw 'Error updating ticket: $e';
    }
  }

  // Search tickets by route and date
  Future<List<TrainTicket>> searchTickets({
    required String fromStation,
    required String toStation,
    required String date,
  }) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .eq('date', date);
      
      final tickets = (response as List)
          .map((data) => TrainTicket.fromJson(data))
          .where((ticket) => ticket.servesRoute(fromStation, toStation))
          .toList();

      // Sort by departure time
      tickets.sort((a, b) {
        final aStart = a.stops.firstWhere((s) => s.station == fromStation);
        final bStart = b.stops.firstWhere((s) => s.station == fromStation);
        return aStart.timeOfDay.hour * 60 + aStart.timeOfDay.minute
            .compareTo(bStart.timeOfDay.hour * 60 + bStart.timeOfDay.minute);
      });

      return tickets;
    } catch (e) {
      throw 'Error searching tickets: $e';
    }
  }

  // Get ticket details by id
  Future<TrainTicket?> getTicketById(int ticketId) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .eq('id', ticketId)
          .single();
      
      return TrainTicket.fromJson(response);
    } catch (e) {
      throw 'Error fetching ticket: $e';
    }
  }

  // Get tickets between dates
  Future<List<TrainTicket>> getTicketsBetweenDates({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .gte('date', startDate)
          .lte('date', endDate)
          .order('date');
      
      return (response as List)
          .map((data) => TrainTicket.fromJson(data))
          .toList();
    } catch (e) {
      throw 'Error fetching tickets: $e';
    }
  }
}