import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:login/screens/dados.dart';
import 'package:login/screens/fichas.dart';
import 'package:login/services/shared_prefs.dart';
import 'dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Dashboard(),
    const Dados(),
    const Fichas(),
  ];

  final List<String> _titles = ['Dashboard', 'Dados', 'Fichas'];

  void _onSelectScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Abre no navegador padrão
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível abrir o link: $url',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    const String apiUrl = "https://gynworkouts.domcloud.dev/api/logout";

    try {
      // Retrieve the token
      String? token = await SharedPrefsService.getToken();

      if (token == null) {
        _showError("Token inválido. Faça login novamente.");
        return;
      }

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.delete(apiUrl);

      if (response.statusCode == 200) {
        _showSuccess("Deslogado com sucesso!");
        await SharedPrefsService.clearToken();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showError("Erro ao deslogar: ${response.data['message']}");
      }
    } on DioError catch (e) {
      String errorMessage = "Erro desconhecido.";
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? "Erro no servidor.";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Erro de conexão. Tente novamente.";
      }
      _showError(errorMessage);
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Você tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
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
        child: Container(
          color: const Color.fromRGBO(7, 59, 76, 1), // Background color
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF073B4C),
                      Color(0xFF118AB2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 100,
                      child: Image.asset(
                        'assets/images/dumbbell.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.white),
                title: const Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _onSelectScreen(0),
              ),
              ListTile(
                leading: const Icon(Icons.data_object, color: Colors.white),
                title: const Text(
                  'Dados',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _onSelectScreen(1),
              ),
              ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.white),
                title: const Text(
                  'Fichas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _onSelectScreen(2),
              ),
              const Divider(color: Colors.white54),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.white),
                title: const Text(
                  'Visite nosso site',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _launchURL('https://gynworkouts.domcloud.dev'),
              ),
              const Divider(color: Colors.white54),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Sair',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: _showLogoutConfirmationDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
