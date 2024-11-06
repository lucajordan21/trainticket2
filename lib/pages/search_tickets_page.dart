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
    'Milano',
    'Napoli Centrale',
    'Torino Porta Nuova',
    'Firenze Santa Maria Novella',
    'Venezia Santa Lucia',
    'Bologna',
    'Genova Piazza Principe',
    'Palermo Centrale',
    'Verona Porta Nuova',
    'Pisa Centrale',
    'Bari Centrale'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF1A237E),
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Cerca Biglietti',
                style: TextStyle(color: Colors.white),
              ),
              background: Container(
                color: const Color(0xFF1A237E),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSearchForm(),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
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

  Widget _buildSearchForm() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF283593),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStationField(
            label: 'Partenza',
            value: _fromStation,
            onChanged: (value) => setState(() => _fromStation = value),
            icon: Icons.train,
          ),
          const SizedBox(height: 16),
          _buildStationField(
            label: 'Arrivo',
            value: _toStation,
            onChanged: (value) => setState(() => _toStation = value),
            icon: Icons.place,
          ),
          const SizedBox(height: 16),
          _buildDateField(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _searchTickets,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Cerca Biglietti',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
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
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Data del viaggio',
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        filled: true,
        fillColor: Color(0xFF1A237E),
        prefixIcon: Icon(Icons.calendar_today, color: Colors.white60),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      controller: TextEditingController(
        text: _selectedDate != null 
            ? _formatDate(_selectedDate!)
            : '',
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF00BFA5),
                  surface: Color(0xFF1A237E),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _searchTickets() async {
    if (_fromStation == null || _toStation == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa tutti i campi per cercare'),
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
          .toList()
        ..sort((a, b) {
          final aStart = a.stops.firstWhere((s) => s.station == _fromStation);
          final bStart = b.stops.firstWhere((s) => s.station == _fromStation);
          return aStart.timeOfDay.hour * 60 + aStart.timeOfDay.minute
              .compareTo(bStart.timeOfDay.hour * 60 + bStart.timeOfDay.minute);
        });

      setState(() {
        _hasSearched = true;
        _isLoading = false;  // Don't forget to set loading to false on success
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
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(
                Icons.search_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Nessun treno trovato da\n$_fromStation a $_toStation\nil ${_formatDate(_selectedDate!)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            '${_searchResults.length} risultati trovati',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        ...(_searchResults.map((ticket) {
          final relevantStops = ticket.stops
              .where((stop) => 
                  stop.station == _fromStation || 
                  stop.station == _toStation)
              .toList();
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _showTicketDetails(ticket),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                relevantStops.first.time,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                relevantStops.first.station,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                relevantStops.last.time,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                relevantStops.last.station,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (ticket.stops.first.station != _fromStation ||
                        ticket.stops.last.station != _toStation)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, 
                                     size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Treno completo: ${ticket.stops.first.station} → ${ticket.stops.last.station}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ticket.date,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '€${ticket.price}',
                          style: const TextStyle(
                            fontSize: 20,
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
        }).toList()),
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
                'Tutte le fermate:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...ticket.stops.map((stop) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      stop.station == ticket.stops.first.station 
                          ? Icons.departure_board
                          : (stop.station == ticket.stops.last.station 
                              ? Icons.flag 
                              : Icons.train),
                      color: stop.station == _fromStation || 
                             stop.station == _toStation
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
                              fontWeight: stop.station == _fromStation || 
                                         stop.station == _toStation
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
              )).toList(),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data'),
                subtitle: Text(_formatDate(DateTime.parse(ticket.date))),
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
                child: const Text(
                  'Acquista Biglietto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}