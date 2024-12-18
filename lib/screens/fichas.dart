import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/shared_prefs.dart';
import 'dart:convert';

class Fichas extends StatefulWidget {
  const Fichas({super.key});

  @override
  State<Fichas> createState() => _FichasState();
}

class _FichasState extends State<Fichas> {
  List<dynamic> fichas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFichas();
  }

  Future<void> fetchFichas() async {
    try {
      String? token = await SharedPrefsService.getToken();
      if (token == null || token.isEmpty) throw Exception("No token found.");

      final response = await Dio().get(
        'http://127.0.0.1:8000/api/fichas',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      setState(() {
        if (response.statusCode == 200) {
          fichas = response.data is String
              ? jsonDecode(response.data)
              : response.data;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fichas de Treino')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fichas.isEmpty
              ? const Center(child: Text('Você não possui fichas disponíveis.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: fichas.length,
                  itemBuilder: (context, index) {
                    final ficha = fichas[index];
                    return buildFichaCard(ficha, context);
                  },
                ),
    );
  }

  Widget buildFichaCard(Map<String, dynamic> ficha, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          ficha['nome'] ?? 'Ficha sem nome',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(ficha['descricao'] ?? 'Sem descrição'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciciosScreen(
                nomeFicha: ficha['nome'],
                exercicios: ficha['exercicios'] as List<dynamic>,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExerciciosScreen extends StatelessWidget {
  final String? nomeFicha;
  final List<dynamic> exercicios;

  const ExerciciosScreen({
    super.key,
    required this.nomeFicha,
    required this.exercicios,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nomeFicha ?? 'Detalhes da Ficha'),
      ),
      body: exercicios.isEmpty
          ? const Center(child: Text('Nenhum exercício encontrado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: exercicios.length,
              itemBuilder: (context, index) {
                final exercicio = exercicios[index];
                return buildExercicioCard(exercicio);
              },
            ),
    );
  }

  Widget buildExercicioCard(Map<String, dynamic> exercicio) {
    final pivot = exercicio['pivot'] ?? {};
    final imageUrl = exercicio['img_itens'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Name
            Text(
              exercicio['nome'] ?? 'Exercício sem nome',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Image (if available)
            if (imageUrl != null)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[200], // Placeholder background
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'http://127.0.0.1:8000/storage/$imageUrl',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),

            // Exercise Details
            Text('Séries: ${pivot['series'] ?? '-'}'),
            Text('Repetições: ${pivot['repeticoes'] ?? '-'}'),
            Text('Observações: ${pivot['observacoes'] ?? '-'}'),
          ],
        ),
      ),
    );
  }
}
