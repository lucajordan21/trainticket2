import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/train_ticket.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final _supabase = Supabase.instance.client;

  // Get all tickets
  Stream<List<TrainTicket>> get ticketsStream {
    return _supabase
      .from('tickets')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((rows) {
        return rows.map((row) => TrainTicket.fromJson(row)).toList();
      });
  }

  // Add a new ticket
  Future<void> addTicket(TrainTicket ticket) async {
    try {
      await _supabase.from('tickets').insert({
        'from_station': ticket.from,
        'to_station': ticket.to,
        'date': ticket.date,
        'time': ticket.time,
        'price': ticket.price,
        'seller': ticket.seller,
      });
    } catch (e) {
      throw 'Error adding ticket: $e';
    }
  }

  // Search tickets
  Future<List<TrainTicket>> searchTickets({
    required String from,
    required String to,
    required String date,
  }) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .eq('from_station', from)
          .eq('to_station', to)
          .eq('date', date);
      
      return (response as List).map((row) => TrainTicket.fromJson(row)).toList();
    } catch (e) {
      throw 'Error searching tickets: $e';
    }
  }
}