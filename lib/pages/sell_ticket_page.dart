import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/train_ticket.dart';
import 'home_page.dart';


class SellTicketPage extends StatefulWidget {
  final VoidCallback? onTicketSold;
  
  const SellTicketPage({
    super.key,
    this.onTicketSold,
  });

  @override
  State<SellTicketPage> createState() => _SellTicketPageState();
}

class _SellTicketPageState extends State<SellTicketPage> {
  final TicketService _ticketService = TicketService();
  final _formKey = GlobalKey<FormState>();
  String? _fromStation;
  String? _toStation;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _priceController = TextEditingController();
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
                  children: [
                    _buildStationField(
                      label: 'Stazione di Partenza',
                      value: _fromStation,
                      onChanged: (value) => setState(() => _fromStation = value),
                    ),
                    const SizedBox(height: 16),
                    _buildStationField(
                      label: 'Stazione di Arrivo',
                      value: _toStation,
                      onChanged: (value) => setState(() => _toStation = value),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(),
                    const SizedBox(height: 16),
                    _buildTimeField(),
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

  Widget _buildStationField({
    required String label,
    required String? value,
    required Function(String?) onChanged,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obbligatorio';
        }
        return null;
      },
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

  Widget _buildTimeField() {
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
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() => _selectedTime = picked);
        }
      },
      controller: TextEditingController(
        text: _selectedTime != null 
            ? _selectedTime!.format(context)
            : '',
      ),
      validator: (value) {
        if (_selectedTime == null) {
          return 'Seleziona un orario';
        }
        return null;
      },
    );
  }

  // In sell_ticket_page.dart

Future<void> _submitTicket() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    
    try {
      // Format price to have 2 decimal places
      final price = double.parse(_priceController.text.trim()).toStringAsFixed(2);
      
      final newTicket = TrainTicket(
        from: _fromStation!,
        to: _toStation!,
        date: _selectedDate!.toString().split(' ')[0],
        time: _selectedTime!.format(context),
        price: price, // Now passing a formatted string
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

      // Clear the form
      setState(() {
        _fromStation = null;
        _toStation = null;
        _selectedDate = null;
        _selectedTime = null;
        _priceController.clear();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la pubblicazione: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Also update the price field validation
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
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}