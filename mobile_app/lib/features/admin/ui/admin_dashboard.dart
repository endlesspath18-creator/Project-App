import 'package:flutter/material.dart';




class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("Home Page Control")),
    const Center(child: Text("Admin Panel Overview")),
    const Center(child: Text("General Settings")),
    const Center(child: Text("Provider Accounts Controller")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: "Admin"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Providers"),
        ],
      ),
    );
  }
}





