import 'package:flutter/material.dart';
import 'search_tickets_page.dart';
import 'ticket_list_page.dart';
import 'sell_ticket_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // Create a GlobalKey to access the state
  static final GlobalKey<_HomePageState> globalKey = GlobalKey<_HomePageState>();

  // Update the navigation method to use the global key
  static void navigateToTickets(BuildContext context) {
    globalKey.currentState?.navigateToIndex(1);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Add this method to handle navigation
  void navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const SearchTicketsPage(),
    const TicketListPage(),
    const SellTicketPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cerca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Biglietti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Vendi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1A237E),
        onTap: _onItemTapped,
      ),
    );
  }
}