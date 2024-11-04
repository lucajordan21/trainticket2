import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/train_ticket.dart';

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
    'Napoli',
    'Torino',
    'Firenze',
    'Venezia',
    'Bologna',
    'Genova',
    'Palermo',
    'Verona',
    'Pisa',
    'Bari'
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
            title: const Text(
              'Cerca viaggio',
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
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        border: InputBorder.none,
        filled: true,
        fillColor: const Color(0xFF1A237E),
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
          ? 'Data: ${_selectedDate.toString().split(' ')[0]}'
          : 'Seleziona Data',
        style: const TextStyle(color: Colors.white60),
      ),
      onTap: _pickDate,
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
      final results = await _ticketService.searchTickets(
        from: _fromStation!,
        to: _toStation!,
        date: _selectedDate!.toString().split(' ')[0],
      );

      setState(() {
        _searchResults = results;
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Nessun biglietto trovato per questa ricerca',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Risultati',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final ticket = _searchResults[index];
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
                onTap: () => _showTicketDetails(ticket),
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