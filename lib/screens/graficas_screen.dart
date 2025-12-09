// lib/screens/graficas_screen.dart

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/bono.dart';
import '../models/fondo.dart';
import '../models/inversion.dart';
import '../services/api_service.dart';

class GraficasScreen extends StatefulWidget {
  const GraficasScreen({super.key});

  @override
  State<GraficasScreen> createState() => _GraficasScreenState();
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

      if (!mounted) return;

      setState(() {
        _inversiones = inversiones;
        if (inversiones.isNotEmpty) {
          _inversionSeleccionada = inversiones[0].nombre;
        } else {
          _inversionSeleccionada = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar inversiones')),
      );
    }
  }

  List<FlSpot> _generarDatos(Inversion inv) {
    final List<FlSpot> spots = <FlSpot>[];
    for (int anio = 1; anio <= 10; anio++) {
      double valorFuturo;
      if (inv is Bono) {
        valorFuturo = inv.monto * pow(1 + inv.retornoAnual / 100, anio);
      } else if (inv is Fondo) {
        valorFuturo = inv.monto * pow(1 + inv.rendimientoAnual / 100, anio);
      } else {
        valorFuturo = inv.monto;
      }
      spots.add(FlSpot(anio.toDouble(), valorFuturo));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final inversionActual = _inversiones.isNotEmpty
        ? _inversiones.firstWhere(
          (inv) => inv.nombre == _inversionSeleccionada,
      orElse: () => _inversiones[0],
    )
        : null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Gráficas',
                style: GoogleFonts.pixelifySans(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: true,
            toolbarHeight: 90,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: _inversiones.isEmpty
              ? Center(
            child: Text(
              'No hay inversiones para mostrar',
              style: GoogleFonts.pixelifySans(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          )
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Selecciona una inversión',
                      labelStyle: GoogleFonts.pixelifySans(color: Colors.teal[900]),
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.white,
                    style: GoogleFonts.pixelifySans(color: Colors.teal[900]),
                    value: _inversionSeleccionada,
                    items: _inversiones
                        .map(
                          (inv) => DropdownMenuItem<String>(
                        value: inv.nombre,
                        child: Text(
                          inv.nombre,
                          style: GoogleFonts.pixelifySans(color: Colors.teal[800]),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _inversionSeleccionada = value;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LineChart(
                        LineChartData(
                          backgroundColor: Colors.transparent,
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: GoogleFonts.pixelifySans(
                                      color: Colors.teal[700],
                                      fontSize: 12,
                                    ),
                                  );
                                },
                                reservedSize: 36,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '\$${value.toInt()}',
                                    style: GoogleFonts.pixelifySans(
                                      color: Colors.teal[700],
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _generarDatos(inversionActual!),
                              isCurved: true,
                              color: Colors.teal[900],
                              barWidth: 4,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) =>
                                    FlDotCirclePainter(color: Colors.teal[900]!, strokeWidth: 2),
                              ),
                              belowBarData: BarAreaData(show: true, color: Colors.teal[900]!.withOpacity(0.1)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

