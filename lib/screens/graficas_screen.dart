
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../services/api_service.dart';
import '../models/inversion.dart';
import '../models/bono.dart';
import '../models/fondo.dart';

class GraficasScreen extends StatefulWidget {
  @override
  _GraficasScreenState createState() => _GraficasScreenState();
}

class _GraficasScreenState extends State<GraficasScreen> {
  List<Inversion> _inversiones = [];
  String? _inversionSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarInversiones();
  }

  Future<void> _cargarInversiones() async {
    try {
      final inversiones = await ApiService().getInversiones();
      setState(() {
        _inversiones = inversiones;
        if (inversiones.isNotEmpty) {
          _inversionSeleccionada = inversiones[0].nombre;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar')));
    }
  }

  List<FlSpot> _generarDatos(Inversion inv) {
    final List<FlSpot> spots = [];
    for (int anio = 1; anio <= 10; anio++) {
      double valorFuturo;
      if (inv is Bono) {
        valorFuturo = inv.monto * pow(1 + inv.retornoAnual / 100, anio);
      } else if (inv is Fondo) {
        valorFuturo = inv.monto * pow(1 + inv.rendimientoAnual / 100, anio);
      } else {
        // Acción: valor constante
        valorFuturo = inv.monto;
      }
      spots.add(FlSpot(anio.toDouble(), valorFuturo));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final inversionActual = _inversiones
        .firstWhere((inv) => inv.nombre == _inversionSeleccionada, orElse: () => _inversiones.isNotEmpty ? _inversiones[0] : Inversion(tipo: 'N/A', nombre: 'N/A', monto: 0));

    return Scaffold(
      appBar: AppBar(title: Text('Gráficas de Valor Futuro')),
      body: Column(
        children: [
          // Selector de inversión
          if (_inversiones.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _inversionSeleccionada,
                items: _inversiones.map((inv) => DropdownMenuItem(
                  value: inv.nombre,
                  child: Text(inv.nombre),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _inversionSeleccionada = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Selecciona una inversión'),
              ),
            ),

          // Gráfica
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()} años');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generarDatos(inversionActual),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}