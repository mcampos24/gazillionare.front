import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inversion.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.1:8080/api/portafolio";

  Future<List<Inversion>> getInversiones() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Inversion.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener inversiones: ${res.statusCode}");
    }
  }

  Future<void> agregarInversion(Inversion inv) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(inv.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Error al agregar inversión: ${res.statusCode}");
    }
  }
}
