import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/shared_prefs.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

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
      if (token == null || token.isEmpty)
        throw Exception("Token não encontrado.");

      final response = await Dio().get(
        'https://gynworkouts.domcloud.dev/api/fichas',
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
          content: Text('Você não possui fichas ainda'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(7, 59, 76, 1),
              Color.fromRGBO(10, 87, 102, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : fichas.isEmpty
                ? const Center(
                    child: Text(
                      'Você não possui fichas disponíveis.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: fichas.length,
                    itemBuilder: (context, index) {
                      final ficha = fichas[index];
                      return buildFichaCard(ficha);
                    },
                  ),
      ),
    );
  }

  Widget buildFichaCard(Map<String, dynamic> ficha) {
    String formattedDate = "";
    if (ficha['data'] != null) {
      final date = DateTime.tryParse(ficha['data']);
      if (date != null) {
        formattedDate = DateFormat('dd/MM/yyyy').format(date);
      }
    }

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          "${ficha['nome'] ?? 'Ficha sem nome'} - $formattedDate",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(7, 59, 76, 1),
          ),
        ),
        subtitle: Text(
          ficha['descricao'] ?? 'Sem descrição',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.teal),
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
        title: Text(
          nomeFicha ?? 'Detalhes da Ficha',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: exercicios.isEmpty
          ? const Center(
              child: Text(
                'Nenhum exercício encontrado.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
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
    final imageUrl = exercicio['img_url'];

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Container(
                margin: const EdgeInsets.only(right: 16),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercicio['nome'] ?? 'Exercício sem nome',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Séries: ${pivot['series'] ?? '-'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Repetições: ${pivot['repeticoes'] ?? '-'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Observações: ${pivot['observacoes'] ?? '-'}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
