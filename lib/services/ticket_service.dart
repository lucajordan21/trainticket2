// lib/services/ticket_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/train_ticket.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final _supabase = Supabase.instance.client;

  // Stream all tickets
  Stream<List<TrainTicket>> get ticketsStream {
    return _supabase
      .from('tickets')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((rows) {
        return rows.map((row) => TrainTicket.fromJson(row)).toList();
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
      await _supabase.from('tickets').insert(ticket.toJson());
    } catch (e) {
      throw 'Error adding ticket: $e';
    }
  }

  // Delete ticket
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

  // Update ticket
  Future<void> updateTicket(int ticketId, TrainTicket ticket) async {
    try {
      await _supabase
          .from('tickets')
          .update(ticket.toJson())
          .eq('id', ticketId);
    } catch (e) {
      throw 'Error updating ticket: $e';
    }
  }

  // Get single ticket by id
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

  // Search tickets by route and date
  Future<List<TrainTicket>> searchTickets({
    String? fromStation,
    String? toStation,
    String? date,
  }) async {
    try {
      var query = _supabase.from('tickets').select();

      if (date != null) {
        query = query.eq('date', date);
      }

      final response = await query;
      final tickets = (response as List)
          .map((data) => TrainTicket.fromJson(data))
          .toList();

      // Filter tickets that serve the requested route if stations are provided
      if (fromStation != null && toStation != null) {
        return tickets.where((ticket) => 
          ticket.servesRoute(fromStation, toStation)).toList();
      }

      return tickets;
    } catch (e) {
      throw 'Error searching tickets: $e';
    }
  }
}