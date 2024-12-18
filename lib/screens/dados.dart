import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/shared_prefs.dart';

class Dados extends StatefulWidget {
  const Dados({super.key});

  @override
  State<Dados> createState() => _DadosState();
}

class _DadosState extends State<Dados> {
  List<dynamic> userData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Retrieve token from SharedPreferences
      String? token = await SharedPrefsService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("No token found. Please log in.");
      }

      // Make the API request
      final response = await Dio().get(
        'http://127.0.0.1:8000/api/dados',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Verify the response format and parse correctly
      if (response.statusCode == 200) {
        List<dynamic> responseData =
            response.data is String ? jsonDecode(response.data) : response.data;

        setState(() {
          userData = responseData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: userData.length,
                  itemBuilder: (context, index) {
                    final data = userData[index];
                    return buildSingleCard(data);
                  },
                ),
    );
  }

  Widget buildSingleCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow('Data da Medida', data['data_medida']),
            buildRow('Peso', '${data['peso']} kg'),
            buildRow('Altura', '${data['altura']} cm'),
            buildRow('Cintura', '${data['cintura']} cm'),
            buildRow('Quadril', '${data['quadril']} cm'),
            buildRow('Peito', '${data['peito']} cm'),
            buildRow('Braço Direito', '${data['braco_direito']} cm'),
            buildRow('Braço Esquerdo', '${data['braco_esquerdo']} cm'),
            buildRow('Coxa Direita', '${data['coxa_direita']} cm'),
            buildRow('Coxa Esquerda', '${data['coxa_esquerda']} cm'),
            buildRow('Gordura', '${data['gordura']} %'),
            buildRow('Gênero', data['genero']),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
