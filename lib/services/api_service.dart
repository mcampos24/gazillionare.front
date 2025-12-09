import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inversion.dart';
import '../models/accion.dart';
import '../models/bono.dart';
import '../models/fondo.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.10:8080/api/portafolio';

  Future<List<Inversion>> getInversiones() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        switch (item['tipo']) {
          case 'ACCION':
            return Accion.fromJson(item);
          case 'BONO':
            return Bono.fromJson(item);
          case 'FONDO':
            return Fondo.fromJson(item);
          default:
            throw Exception('Tipo desconocido');
        }
      }).toList();
    } else {
      throw Exception('Error al cargar inversiones');
    }
  }

  Future<void> crearInversion(Inversion inv) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(inv.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al crear inversión');
    }
  }


  Future<double> getTotalInvertido() async {
    final response = await http.get(Uri.parse('$baseUrl/total-invertido'));
    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Error al obtener total invertido');
    }
  }


  Future<void> eliminarInversion(String nombre) async {
    final response = await http.delete(Uri.parse('$baseUrl/$nombre'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar');
    }
  }


  Future<Comparacion> compararInversiones(List<String> nombres) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comparar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(nombres),
    );
    if (response.statusCode == 200) {
      return Comparacion.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al comparar');
    }
  }


  Future<String> getInfoPortafolio() async {
    final response = await http.get(Uri.parse('$baseUrl/info'));
    if (response.statusCode == 200) return response.body;
    throw Exception('Error al obtener info');
  }


  Future<Inversion> buscarPorNombre(String nombre) async {
    final response = await http.get(Uri.parse('$baseUrl/buscar/$nombre'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      switch (jsonData['tipo']) {
        case 'ACCION':
          return Accion.fromJson(jsonData);
        case 'BONO':
          return Bono.fromJson(jsonData);
        case 'FONDO':
          return Fondo.fromJson(jsonData);
        default:
          throw Exception('Tipo desconocido');
      }
    } else {
      throw Exception('Inversión no encontrada');
    }
  }


  Future<void> limpiarPortafolio() async {
    final response = await http.delete(Uri.parse('$baseUrl/limpiar'));
    if (response.statusCode != 204) {
      throw Exception('Error al limpiar portafolio');
    }
  }
}

class Comparacion {
  final List<Inversion> inversiones;
  final double totalMonto;
  final double totalValorFuturo;
  final double promedioRendimiento;

  Comparacion({
    required this.inversiones,
    required this.totalMonto,
    required this.totalValorFuturo,
    required this.promedioRendimiento,
  });

  factory Comparacion.fromJson(Map<String, dynamic> json) {
    final inversiones = (json['inversiones'] as List).map((item) {
      switch (item['tipo']) {
        case 'ACCION':
          return Accion.fromJson(item);
        case 'BONO':
          return Bono.fromJson(item);
        case 'FONDO':
          return Fondo.fromJson(item);
        default:
          throw Exception('Tipo desconocido en comparación');
      }
    }).toList();

    return Comparacion(
      inversiones: inversiones,
      totalMonto: (json['totalMonto'] as num).toDouble(),
      totalValorFuturo: (json['totalValorFuturo'] as num).toDouble(),
      promedioRendimiento: (json['promedioRendimiento'] as num).toDouble(),
    );
  }
}
