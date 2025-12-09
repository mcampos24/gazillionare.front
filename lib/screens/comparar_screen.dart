
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/inversion.dart';
import '../models/accion.dart';
import '../models/bono.dart';
import '../models/fondo.dart';

class CompararScreen extends StatefulWidget {
  @override
  _CompararScreenState createState() => _CompararScreenState();
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
      _mostrarResultado(context, resultado);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al comparar: $e')),
      );
    }
  }

  void _mostrarResultado(BuildContext context, Comparacion comparacion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resultado de la comparación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildRow('Total invertido:', '\$${comparacion.totalMonto.toStringAsFixed(2)}'),
              _buildRow('Valor futuro total:', '\$${comparacion.totalValorFuturo.toStringAsFixed(2)}'),
              _buildRow('Rendimiento promedio (%):', '${comparacion.promedioRendimiento.toStringAsFixed(2)}%'),
              SizedBox(height: 16),
              Text('Inversiones incluidas:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...comparacion.inversiones.map((inv) {
                String detalles = '';
                if (inv is Accion) {
                  detalles = ' (Acción)';
                } else if (inv is Bono) {
                  detalles = ' (Bono, ${(inv as Bono).retornoAnual}% anual)';
                } else if (inv is Fondo) {
                  detalles = ' (Fondo, ${(inv as Fondo).rendimientoAnual}% anual)';
                }
                return Text('• ${inv.nombre}$detalles');
              }).toList(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(valor),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comparar Inversiones')),
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
                      return CheckboxListTile(
                        title: Text(inv.nombre),
                        subtitle: Text('${inv.tipo} - \$${inv.monto.toStringAsFixed(2)}'),
                        value: seleccionado,
                        onChanged: (value) {
                          _toggleSeleccion(inv.nombre);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _comparar,
                    child: Text('Comparar (${_nombresSeleccionados.length} seleccionadas)'),
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}