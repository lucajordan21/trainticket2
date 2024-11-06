// lib/pages/search_tickets_page.dart
import 'package:flutter/material.dart';
import '../models/train_ticket.dart';
import '../models/train_stop.dart';
import '../services/ticket_service.dart';

class SearchTicketsPage extends StatefulWidget {
  const SearchTicketsPage({super.key});

  @override
  State<SearchTicketsPage> createState() => _SearchTicketsPageState();
}

class _SearchTicketsPageState extends State<SearchTicketsPage> {
  final TicketService _ticketService = TicketService();
  String? _fromStation;
  String? _toStation;
  DateTime? _selectedDate;
  bool _hasSearched = false;
  List<TrainTicket> _searchResults = [];
  bool _isLoading = false;

  final List<String> _stations = [
    'Roma',
    'Milano Centrale',
    'Napoli Centrale',
    'Torino Porta Nuova',
    'Firenze',
    'Venezia Santa Lucia',
    'Bologna Centrale',
    'Genova Piazza Principe',
    'Palermo Centrale',
    'Verona Porta Nuova',
    'Pisa Centrale',
    'Bari Centrale'
  ];

// Add these helper methods right after your class variables
  String getStartStation(TrainTicket ticket) {
    return ticket.stops.firstWhere((stop) => stop.station == _fromStation,
            orElse: () => ticket.stops.first)
        .station;
  }

  String getEndStation(TrainTicket ticket) {
    return ticket.stops.firstWhere((stop) => stop.station == _toStation,
            orElse: () => ticket.stops.last)
        .station;
  }

  bool isFullRoute(TrainTicket ticket) {
    final startStation = getStartStation(ticket);
    final endStation = getEndStation(ticket);
    return startStation == ticket.stops.first.station &&
        endStation == ticket.stops.last.station;
  }

  String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours h ${remainingMinutes.toString().padLeft(2, '0')} min';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF1A237E),
            pinned: true,
            title: const Text(
              'Orari e Biglietti',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSearchContainer(),
                const SizedBox(height: 16),
                _buildSearchButton(),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (_hasSearched)
                  _buildSearchResults(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContainer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF283593),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStationField(
            label: 'Partenza',
            value: _fromStation,
            onChanged: (value) => setState(() => _fromStation = value),
            icon: Icons.train,
          ),
          const SizedBox(height: 12),
          _buildStationField(
            label: 'Arrivo',
            value: _toStation,
            onChanged: (value) => setState(() => _toStation = value),
            icon: Icons.place,
          ),
          const SizedBox(height: 12),
          _buildDateField(),
        ],
      ),
    );
  }

  Widget _buildStationField({
    required String label,
    required String? value,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        border: InputBorder.none,
        filled: true,
        fillColor: const Color(0xFF1A237E),
        prefixIcon: Icon(icon, color: Colors.white60),
      ),
      dropdownColor: const Color(0xFF1A237E),
      style: const TextStyle(color: Colors.white),
      items: _stations.map((station) {
        return DropdownMenuItem(
          value: station,
          child: Text(station),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField() {
    return ListTile(
      leading: const Icon(Icons.calendar_month, color: Colors.white60),
      title: Text(
        _selectedDate != null 
            ? 'Data: ${_formatDate(_selectedDate!)}'
            : 'Seleziona Data',
        style: const TextStyle(color: Colors.white60),
      ),
      onTap: _pickDate,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _searchTickets,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00BFA5),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: const Text(
        'Cerca Orari e Prezzi',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _searchTickets() async {
    if (_fromStation == null || _toStation == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona tutti i campi per effettuare la ricerca'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tickets = await _ticketService.getTicketsByDate(
        date: _selectedDate!.toString().split(' ')[0],
      );

      _searchResults = tickets
          .where((ticket) => ticket.servesRoute(_fromStation!, _toStation!))
          .toList();

      setState(() {
        _hasSearched = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la ricerca: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(
                Icons.search_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Nessun treno trovato da $_fromStation a $_toStation',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_searchResults.length} risultati trovati',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final ticket = _searchResults[index];
            final firstStop = ticket.stops.firstWhere(
              (stop) => stop.station == _fromStation,
              orElse: () => ticket.stops.first,
            );
            final lastStop = ticket.stops.firstWhere(
              (stop) => stop.station == _toStation,
              orElse: () => ticket.stops.last,
            );
            
            final duration = firstStop.getDurationInMinutes(lastStop);
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () => _showTicketDetails(ticket),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstStop.formattedTime,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(firstStop.station),
                            ],
                          ),
                          Column(
                            children: [
                              Text('$duration min'),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                lastStop.formattedTime,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(lastStop.station),
                            ],
                          ),
                        ],
                      ),
                      if (firstStop.station != ticket.from ||
                          lastStop.station != ticket.to)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Treno completo: ${ticket.from} → ${ticket.to}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '€${ticket.price}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00BFA5),
                            ),
                          ),
                          Text('${ticket.numberOfStops} fermate'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showTicketDetails(TrainTicket ticket) {
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
        builder: (context, scrollController) => _TicketDetailsSheet(
          ticket: ticket,
          fromStation: _fromStation!,
          toStation: _toStation!,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _TicketDetailsSheet extends StatelessWidget {
  final TrainTicket ticket;
  final String fromStation;
  final String toStation;
  final ScrollController scrollController;

  const _TicketDetailsSheet({
    required this.ticket,
    required this.fromStation,
    required this.toStation,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 16),
          const Text(
            'Tutte le fermate:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...ticket.stops.map((stop) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  stop.station == ticket.from ? Icons.departure_board :
                  (stop.station == ticket.to ? Icons.flag : Icons.train),
                  color: stop.station == fromStation || stop.station == toStation
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
                          fontWeight: stop.station == fromStation || 
                                     stop.station == toStation
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        stop.formattedTime,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 16),
          const Divider(),
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
    );
  }
}