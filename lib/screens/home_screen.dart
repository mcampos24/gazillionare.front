
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/inversion.dart';
import 'crear_inversion_screen.dart';
import 'herramientas_screen.dart';
import 'graficas_screen.dart';
import 'comparar_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Inversion>> _futureInversiones;
  late Future<double> _futureTotalInvertido;

  @override
  void initState() {
    super.initState();
    _recargarDatos();
  }

  void _recargarDatos() {
    setState(() {
      _futureInversiones = ApiService().getInversiones();
      _futureTotalInvertido = ApiService().getTotalInvertido();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gazillionare')),
      body: RefreshIndicator(
        onRefresh: () async {
          _recargarDatos();
        },
        child: Column(
          children: [
            // 🔹 Recuadro con total invertido
            FutureBuilder<double>(
              future: _futureTotalInvertido,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final total = snapshot.data!;
                  return Card(
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'TOTAL INVERTIDO',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Card(
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error al cargar total'),
                    ),
                  );
                } else {
                  return Card(
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('TOTAL INVERTIDO'),
                          SizedBox(height: 8),
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

            // 🔹 Lista de inversiones
            Expanded(
              child: FutureBuilder<List<Inversion>>(
                future: _futureInversiones,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final inversiones = snapshot.data!;
                    if (inversiones.isEmpty) {
                      return Center(
                        child: Text('No hay inversiones. ¡Agrega una!'),
                      );
                    }
                    return ListView.builder(
                      itemCount: inversiones.length,
                      itemBuilder: (context, index) {
                        final inv = inversiones[index];
                        return ListTile(
                          title: Text(inv.nombre),
                          subtitle: Text(
                            '${inv.tipo} - \$${inv.monto.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                await ApiService().eliminarInversion(inv.nombre);
                                _recargarDatos();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al eliminar')),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CrearInversionScreen()),
          );
          _recargarDatos();
        },
        child: Icon(Icons.add),
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HerramientasScreen()),
              ),
              child: Text('Herramientas'),
            ),

            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CompararScreen()),
              ),
              child: Text('Comparar'),
            ),

            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GraficasScreen()),
              ),
              child: Text('Gráficas'),
            ),
          ],
        ),
      ),
    );
  }
}
