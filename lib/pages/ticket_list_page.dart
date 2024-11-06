// lib/pages/ticket_list_page.dart
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.train_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nessun biglietto disponibile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: InkWell(
                  onTap: () => _showTicketDetails(context, ticket),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket.stops.first.time,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(ticket.stops.first.station),
                              ],
                            ),
                            const Icon(Icons.arrow_forward),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  ticket.stops.last.time,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(ticket.stops.last.station),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Data: ${ticket.date}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '€${ticket.price}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00BFA5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              const Text(
                'Dettagli Viaggio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fermate:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...ticket.stops.asMap().entries.map((entry) {
                final index = entry.key;
                final stop = entry.value;
                final isFirst = index == 0;
                final isLast = index == ticket.stops.length - 1;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isFirst ? Icons.departure_board :
                        (isLast ? Icons.flag : Icons.train),
                        color: isFirst || isLast 
                            ? const Color(0xFF00BFA5) 
                            : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.station,
                              style: TextStyle(
                                fontWeight: isFirst || isLast
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              stop.time,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data'),
                subtitle: Text(ticket.date),
              ),
              ListTile(
                leading: const Icon(Icons.euro),
                title: const Text('Prezzo'),
                subtitle: Text('€${ticket.price}'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Venditore'),
                subtitle: Text(ticket.seller),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
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
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Acquista Biglietto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}