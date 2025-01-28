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
      String? token = await SharedPrefsService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("No token found. Please log in.");
      }

      final response = await Dio().get(
        'https://gynworkouts.domcloud.dev/api/dados',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData =
            response.data is String ? jsonDecode(response.data) : response.data;

        setState(() {
          userData = responseData;
          isLoading = false;
        });
      } else {
        throw Exception('Não possui dados ainda');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você não possui dados ainda '),
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
            : userData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 80,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No data available",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: userData.length,
                    itemBuilder: (context, index) {
                      final data = userData[index];
                      return buildSingleCard(data);
                    },
                  ),
      ),
    );
  }

  Widget buildSingleCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(7, 59, 76, 0.9),
            Color.fromRGBO(10, 87, 102, 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.blueAccent, // Cor de destaque da borda
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
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
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Cor branca para o label
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white, // Cor branca para o valor
              ),
            ),
          ),
        ],
      ),
    );
  }
}
