import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/inversion.dart';
import 'crear_inversion_screen.dart';
import 'herramientas_screen.dart';
import 'graficas_screen.dart';
import 'comparar_screen.dart';
import 'detalle_inversion_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Inversion>> _futureInversiones;
  late Future<double> _futureTotalInvertido;



  @override
  void initState() {
    super.initState();
    _recargarDatos();
  }

  Future<void> _recargarDatos() async {
    try {
      final inversiones = await ApiService().getInversiones();
      final total = await ApiService().getTotalInvertido();
      if (!mounted) return;

      setState(() {
        _futureInversiones = Future.value(inversiones);
        _futureTotalInvertido = Future.value(total);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _futureInversiones = Future.error(e);
        _futureTotalInvertido = Future.error(e);
      });
    }
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
                'Gazillionare',
                style: GoogleFonts.pixelifySans(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 8,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: true,
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: _recargarDatos,
            child: Column(
              children: [
                FutureBuilder<double>(
                  future: _futureTotalInvertido,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final total = snapshot.data!;
                      return Card(
                        color: Colors.yellow[100],
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'TOTAL INVERTIDO',
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.tealAccent[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Card(
                        margin: EdgeInsets.all(16),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Error al cargar total'),
                        ),
                      );
                    } else {
                      return const Card(
                        margin: EdgeInsets.all(16),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
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
                Expanded(
                  child: FutureBuilder<List<Inversion>>(
                    future: _futureInversiones,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final inversiones = snapshot.data!;
                        if (inversiones.isEmpty) {
                          return const Center(
                            child: Text('No hay inversiones. ¡Agrega una!'),
                          );
                        }
                        return ListView.builder(
                          itemCount: inversiones.length,
                          itemBuilder: (context, index) {
                            final inv = inversiones[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.90),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  inv.nombre,
                                  style: GoogleFonts.pixelifySans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.teal[800],
                                  ),
                                ),
                                subtitle: Text(
                                  '${inv.tipo} - \$${inv.monto.toStringAsFixed(2)}',
                                  style: GoogleFonts.pixelifySans(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                onTap: () async {
                                  try {
                                    final response = await http.get(
                                      Uri.parse('http://192.168.1.10:8080/api/portafolio/${Uri.encodeComponent(inv.nombre)}/detalles'),
                                    );
                                    if (response.statusCode == 200) {
                                      final datos = jsonDecode(response.body);
                                      if (!mounted) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetalleInversionScreen(datos: datos),
                                        ),
                                      );
                                    } else {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No se pudieron cargar los detalles')),
                                      );
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
                                    );
                                  }
                                },
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red[900]),
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    try {
                                      await ApiService().eliminarInversion(inv.nombre);
                                      if (!mounted) return;
                                      await _recargarDatos();
                                      messenger.showSnackBar(
                                        const SnackBar(content: Text('Inversión eliminada')),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        const SnackBar(content: Text('Error al eliminar')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
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
                MaterialPageRoute(builder: (context) => const CrearInversionScreen()),
              );
              if (!mounted) return;
              await _recargarDatos();
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HerramientasScreen()),
                  ),
                  child: Text(
                    'Herramientas',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CompararScreen()),
                  ),
                  child: Text(
                    'Comparar',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GraficasScreen()),
                  ),
                  child: Text(
                    'Gráficas',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


