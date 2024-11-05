// lib/pages/sell_ticket_page.dart
import 'package:flutter/material.dart';
import '../models/train_ticket.dart';
import '../models/train_stop.dart';
import '../widgets/train_stop_form.dart';
import '../services/ticket_service.dart';
import '../pages/home_page.dart'; // Add this import


class SellTicketPage extends StatefulWidget {
  const SellTicketPage({super.key});

  @override
  State<SellTicketPage> createState() => _SellTicketPageState();
}

class _SellTicketPageState extends State<SellTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _ticketService = TicketService();
  final _priceController = TextEditingController();
  DateTime? _selectedDate;
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

  // List to store stop data
  final List<Map<String, dynamic>> _stops = [];

  @override
  void initState() {
    super.initState();
    // Add initial start and end stops
    _stops.add({'isStart': true, 'isEnd': false});
    _stops.add({'isStart': false, 'isEnd': true});
  }

  void _addIntermediateStop() {
    setState(() {
      // Insert new stop before the last one (end stop)
      _stops.insert(_stops.length - 1, {
        'isStart': false,
        'isEnd': false,
      });
    });
  }

  void _removeStop(int index) {
    if (!_stops[index]['isStart'] && !_stops[index]['isEnd']) {
      setState(() {
        _stops.removeAt(index);
      });
    }
  }

  void _updateStop(int index, String station, TimeOfDay time) {
    setState(() {
      _stops[index]['station'] = station;
      _stops[index]['time'] = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Vendi Biglietto',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF283593),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fermate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Build stop forms
                    ..._stops.asMap().entries.map((entry) {
                      final index = entry.key;
                      final stop = entry.value;
                      return TrainStopForm(
                        isStart: stop['isStart'] ?? false,
                        isEnd: stop['isEnd'] ?? false,
                        stations: _stations,
                        onStopChanged: (station, time) => 
                            _updateStop(index, station, time),
                        onRemove: (!stop['isStart'] && !stop['isEnd']) 
                            ? () => _removeStop(index)
                            : null,
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    // Add stop button
                    Center(
                      child: TextButton.icon(
                        onPressed: _addIntermediateStop,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Aggiungi Fermata',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(),
                    const SizedBox(height: 16),
                    _buildPriceField(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Pubblica Biglietto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Data',
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        filled: true,
        fillColor: Color(0xFF1A237E),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.white60),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      controller: TextEditingController(
        text: _selectedDate != null 
            ? _selectedDate.toString().split(' ')[0]
            : '',
      ),
      validator: (value) {
        if (_selectedDate == null) {
          return 'Seleziona una data';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Prezzo (€)',
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        filled: true,
        fillColor: Color(0xFF1A237E),
        prefixIcon: Icon(Icons.euro, color: Colors.white60),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Inserisci un prezzo';
        }
        try {
          final price = double.parse(value);
          if (price <= 0) {
            return 'Il prezzo deve essere maggiore di 0';
          }
        } catch (e) {
          return 'Inserisci un prezzo valido';
        }
        return null;
      },
    );
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      // Validate all stops have station and time
      for (final stop in _stops) {
        if (stop['station'] == null || stop['time'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Completa tutte le fermate'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() => _isLoading = true);
      
      try {
        final stops = _stops.map((stop) => TrainStop(
          station: stop['station'],
          time: stop['time'].format(context),
          isStart: stop['isStart'] ?? false,
          isEnd: stop['isEnd'] ?? false,
        )).toList();

        final newTicket = TrainTicket(
          stops: stops,
          date: _selectedDate!.toString().split(' ')[0],
          price: _priceController.text.trim(),
          seller: 'Tu',
        );

        await _ticketService.addTicket(newTicket);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biglietto pubblicato con successo!'),
              backgroundColor: Color(0xFF00BFA5),
            ),
          );
          
          HomePage.navigateToTickets(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore durante la pubblicazione: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}