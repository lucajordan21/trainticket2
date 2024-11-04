import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://kgjwshmwbnewhcfihmrr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnandzaG13Ym5ld2hjZmlobXJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA2NDk2NzYsImV4cCI6MjA0NjIyNTY3Nn0.FZxs6sekIj1HgrlTnGWxzUAh4YsbUSgUBJWZn-AXqqI',
  );
  
  runApp(const TrainTicketApp());
}

class TrainTicketApp extends StatelessWidget {
  const TrainTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace Biglietti Treno',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(key: HomePage.globalKey),
    );
  }
}