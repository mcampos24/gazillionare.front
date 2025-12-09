import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/inversion.dart';
import '../models/accion.dart';
import '../models/bono.dart';
import '../models/fondo.dart';

class CompararScreen extends StatefulWidget {
  const CompararScreen({super.key});

  @override
  State<CompararScreen> createState() => _CompararScreenState();
}

class _CompararScreenState extends State<CompararScreen> {
  late Future<List<Inversion>> _futureInversiones;
  final Set<String> _nombresSeleccionados = {};

  @override
  void initState() {
    super.initState();
    _futureInversiones = ApiService().getInversiones();
  }

  void _toggleSeleccion(String nombre) {
    setState(() {
      if (_nombresSeleccionados.contains(nombre)) {
        _nombresSeleccionados.remove(nombre);
      } else {
        _nombresSeleccionados.add(nombre);
      }
    });
  }

  void _comparar() async {
    if (_nombresSeleccionados.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione al menos 2 inversiones')),
      );
      return;
    }

    try {
      final resultado = await ApiService().compararInversiones(_nombresSeleccionados.toList());

      if (!mounted) return;

      _mostrarResultado(context, resultado);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al comparar: $e')),
      );
    }
  }

  void _mostrarResultado(BuildContext context, Comparacion comparacion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resultado de la comparación',
                style: GoogleFonts.pixelifySans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
              SizedBox(height: 16),
              _buildRow('Total invertido:', '\$${comparacion.totalMonto.toStringAsFixed(2)}'),
              _buildRow('Valor futuro total:', '\$${comparacion.totalValorFuturo.toStringAsFixed(2)}'),
              _buildRow('Rendimiento promedio (%):', '${comparacion.promedioRendimiento.toStringAsFixed(2)}%'),
              SizedBox(height: 16),
              Text(
                'Inversiones incluidas:',
                style: GoogleFonts.pixelifySans(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
              ...comparacion.inversiones.map((inv) {
                String detalles = '';
                if (inv is Accion) {
                  detalles = ' (Acción)';
                } else if (inv is Bono) {
                  detalles = ' (Bono, ${(inv).retornoAnual}% anual)';
                } else if (inv is Fondo) {
                  detalles = ' (Fondo, ${(inv).rendimientoAnual}% anual)';
                }
                return Text(
                  '• ${inv.nombre}$detalles',
                  style: GoogleFonts.pixelifySans(color: Colors.teal[800]),
                );
              }),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: Navigator.of(context).pop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.pixelifySans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.pixelifySans(
              fontWeight: FontWeight.bold,
              color: Colors.teal[900],
            ),
          ),
          Text(
            valor,
            style: GoogleFonts.pixelifySans(
              color: Colors.teal[800],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                'Comparar',
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
          body: FutureBuilder<List<Inversion>>(
            future: _futureInversiones,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final inversiones = snapshot.data!;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: inversiones.length,
                        itemBuilder: (context, index) {
                          final inv = inversiones[index];
                          final bool seleccionado = _nombresSeleccionados.contains(inv.nombre);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                inv.nombre,
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 18,
                                  color: Colors.teal[900],
                                ),
                              ),
                              subtitle: Text(
                                '${inv.tipo} - \$${inv.monto.toStringAsFixed(2)}',
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 14,
                                  color: Colors.teal[700],
                                ),
                              ),
                              value: seleccionado,
                              onChanged: (value) {
                                _toggleSeleccion(inv.nombre);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Colors.teal[900],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _comparar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent[700],
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'Comparar (${_nombresSeleccionados.length} seleccionadas)',
                              style: GoogleFonts.pixelifySans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.pixelifySans(color: Colors.white),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}