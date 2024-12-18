import 'package:flutter/material.dart';
import 'package:login/screens/dados.dart';
import 'package:login/screens/fichas.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    const Dashboard(),
    const Dados(),
    const Fichas(),
  ];

  // Titles for the screens
  final List<String> _titles = ['Dashboard', 'Dados', 'Fichas'];

  // Change the selected screen
  void _onSelectScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
      ),
      body: _screens[_currentIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[600],
              ),
              child: Center(
                child: Text(
                  'GYM WORKOUTS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.blue[600]),
              title: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _onSelectScreen(0),
            ),
            ListTile(
              leading: Icon(Icons.data_object, color: Colors.blue[600]),
              title: Text(
                'Dados',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _onSelectScreen(1),
            ),
            ListTile(
              leading: Icon(Icons.fitness_center, color: Colors.blue[600]),
              title: Text(
                'Fichas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _onSelectScreen(2),
            ),
          ],
        ),
      ),
    );
  }
}
