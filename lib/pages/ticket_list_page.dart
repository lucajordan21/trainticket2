import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/train_ticket.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  final TicketService _ticketService = TicketService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Tutti i Biglietti',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<TrainTicket>>(
        stream: _ticketService.ticketsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Errore: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return const Center(
              child: Text(
                'Nessun biglietto disponibile',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                child: ListTile(
                  title: Text('${ticket.from} → ${ticket.to}'),
                  subtitle: Text('${ticket.date} alle ${ticket.time}'),
                  trailing: Text(
                    '€${ticket.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _showTicketDetails(context, ticket),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTicketDetails(BuildContext context, TrainTicket ticket) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ticket.from} a ${ticket.to}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Data: ${ticket.date}'),
              Text('Orario: ${ticket.time}'),
              Text('Prezzo: €${ticket.price}'),
              Text('Venditore: ${ticket.seller}'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Acquisto completato con successo!'),
                        backgroundColor: Color(0xFF00BFA5),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                  ),
                  child: const Text('Acquista Biglietto'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}