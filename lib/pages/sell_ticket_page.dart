// lib/pages/sell_ticket_page.dart
import 'package:flutter/material.dart';
import '../models/train_ticket.dart';
import '../models/train_stop.dart';
import '../widgets/train_stop_form.dart';
import '../services/ticket_service.dart';
import '../pages/home_page.dart';

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
    'Roma', 'Milano', 'Napoli', 'Torino', 'Firenze', 'Venezia',
    'Bologna', 'Genova', 'Palermo', 'Verona', 'Pisa', 'Bari'
  ];

  final List<Map<String, dynamic>> _stops = [];

  @override
  void initState() {
    super.initState();
    _initializeStops();
  }

  void _initializeStops() {
    _stops.add({'isStart': true, 'isEnd': false, 'station': null, 'time': null});
    _stops.add({'isStart': false, 'isEnd': true, 'station': null, 'time': null});
  }

  void _addIntermediateStop(int beforeIndex) {
    if (_stops.length >= 10) {
      _showSnackbar('Numero massimo di fermate raggiunto (10)', Colors.orange);
      return;
    }
    setState(() {
      _stops.insert(beforeIndex, {'isStart': false, 'isEnd': false, 'station': null, 'time': null});
    });
  }

  void _removeStop(int index) {
    if (!_stops[index]['isStart'] && !_stops[index]['isEnd']) {
      setState(() {
        _stops.removeAt(index);
      });
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text('Vendi Biglietto', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _onBackPressed,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStopsSection(),
                  const SizedBox(height: 24),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildPriceField(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  void _onBackPressed() {
    if (_formKey.currentState!.validate() && _stops.any((stop) => stop['station'] == null || stop['time'] == null)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Conferma'),
          content: const Text('Sei sicuro di voler uscire senza salvare?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
            TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('Esci')),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildStopsSection() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF283593), borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fermate',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _stops.length * 2 - 1,
            itemBuilder: (context, index) {
              if (index.isEven) {
                final stopIndex = index ~/ 2;
                return _buildStopCard(_stops[stopIndex], stopIndex);
              } else {
                final stopIndex = index ~/ 2;
                return _buildAddStopButton(stopIndex);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(Map<String, dynamic> stop, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (stop['isStart'] || stop['isEnd']) ? const Color(0xFF00BFA5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stop['isStart'] ? Icons.departure_board : (stop['isEnd'] ? Icons.flag : Icons.train),
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  stop['isStart'] ? 'Partenza' : (stop['isEnd'] ? 'Arrivo' : 'Fermata Intermedia'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                if (!stop['isStart'] && !stop['isEnd'])
                  IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => _removeStop(index)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStationField(stop),
            const SizedBox(height: 8),
            _buildTimeField(stop),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStopButton(int beforeIndex) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _addIntermediateStop(beforeIndex + 1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Aggiungi Fermata', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Data',
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        filled: true,
        fillColor: Color(0xFF1A237E),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.white60),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      controller: TextEditingController(text: _selectedDate?.toString().split(' ')[0] ?? ''),
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
      validator: (value) => _selectedDate == null ? 'Seleziona una data' : null,
    );
  }

  Widget _buildStationField(Map<String, dynamic> stop) {
    return DropdownButtonFormField<String>(
      value: stop['station'],
      decoration: const InputDecoration(
        labelText: 'Stazione',
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        filled: true,
        fillColor: Color(0xFF1A237E),
      ),
      dropdownColor: const Color(0xFF1A237E),
      style: const TextStyle(color: Colors.white),
      items: _stations.map((station) {
        return DropdownMenuItem(value: station, child: Text(station));
      }).toList(),
      onChanged: (value) => setState(() => stop['station'] = value),
      validator: (value) => value == null || value.isEmpty ? 'Seleziona una stazione' : null,
    );
  }

  Widget _buildTimeField(Map<String, dynamic> stop) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Orario',
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        filled: true,
        fillColor: Color(0xFF1A237E),
        suffixIcon: Icon(Icons.access_time, color: Colors.white60),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      controller: TextEditingController(
        text: stop['time'] != null 
            ? TrainStop.formatTime(stop['time']) 
            : '',
      ),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: stop['time'] ?? TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            stop['time'] = picked;
          });
        }
      },
      validator: (value) {
        if (stop['time'] == null) {
          return 'Seleziona un orario';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Prezzo (€)',
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        filled: true,
        fillColor: Color(0xFF1A237E),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        final price = double.tryParse(value ?? '');
        return (price == null || price <= 0) ? 'Inserisci un prezzo valido' : null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitTicket,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        minimumSize: const Size.fromHeight(48),
      ),
      child: const Text('Vendi Biglietto', style: TextStyle(color: Colors.white, fontSize: 18)),
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
          time: TrainStop.formatTime(stop['time']),
          isStart: stop['isStart'] ?? false,
          isEnd: stop['isEnd'] ?? false,
        )).toList();

        // Validate stops order
        for (int i = 0; i < stops.length - 1; i++) {
          if (!stops[i].isBefore(stops[i + 1])) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('L\'orario di ogni fermata deve essere successivo alla fermata precedente'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
            return;
          }
        }

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
