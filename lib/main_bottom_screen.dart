import 'package:flutter/material.dart';
import 'package:labourattendence/app_language.dart';
import 'package:labourattendence/language_provider.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class MainBottomScreen extends StatefulWidget {
  const MainBottomScreen({super.key});

  @override
  State<MainBottomScreen> createState() => _MainBottomScreenState();
}

class _MainBottomScreenState extends State<MainBottomScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashboardScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context).locale.languageCode]!;

    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups_2_outlined, size: 23),
            label: lang["labor"]!,
          ),
           BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined, size: 23),
            label: lang["settings"]!,
          ),
        ],
      ),
    );
  }
}