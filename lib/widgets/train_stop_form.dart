// lib/widgets/train_stop_form.dart
import 'package:flutter/material.dart';

class TrainStopForm extends StatefulWidget {
  final bool isStart;
  final bool isEnd;
  final Function(String, TimeOfDay)? onStopChanged;
  final VoidCallback? onRemove;
  final List<String> stations;

  const TrainStopForm({
    Key? key,
    this.isStart = false,
    this.isEnd = false,
    this.onStopChanged,
    this.onRemove,
    required this.stations,
  }) : super(key: key);

  @override
  State<TrainStopForm> createState() => _TrainStopFormState();
}

class _TrainStopFormState extends State<TrainStopForm> {
  String? selectedStation;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.isStart ? 'Partenza' : 
                  (widget.isEnd ? 'Arrivo' : 'Fermata Intermedia'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStationField(),
          const SizedBox(height: 8),
          _buildTimeField(),
        ],
      ),
    );
  }

  Widget _buildStationField() {
    return DropdownButtonFormField<String>(
      value: selectedStation,
      decoration: const InputDecoration(
        labelText: 'Stazione',
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        filled: true,
        fillColor: Color(0xFF1A237E),
      ),
      dropdownColor: const Color(0xFF1A237E),
      style: const TextStyle(color: Colors.white),
      items: widget.stations.map((station) {
        return DropdownMenuItem(
          value: station,
          child: Text(station),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedStation = value);
        if (selectedStation != null && selectedTime != null) {
          widget.onStopChanged?.call(selectedStation!, selectedTime!);
        }
      },
      validator: (value) => value == null ? 'Seleziona una stazione' : null,
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
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() => selectedTime = picked);
          if (selectedStation != null) {
            widget.onStopChanged?.call(selectedStation!, picked);
          }
        }
      },
      controller: TextEditingController(
        text: selectedTime?.format(context) ?? '',
      ),
      validator: (value) => selectedTime == null ? 'Seleziona un orario' : null,
    );
  }

  // Add getters to access the current values
  String? get station => selectedStation;
  TimeOfDay? get time => selectedTime;

  // Add method to check if the stop is complete
  bool get isComplete => selectedStation != null && selectedTime != null;
}