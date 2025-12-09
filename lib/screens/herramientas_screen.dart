
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class HerramientasScreen extends StatefulWidget {
  const HerramientasScreen({super.key});

  @override
  State<HerramientasScreen> createState() => _HerramientasScreenState();
}

class _HerramientasScreenState extends State<HerramientasScreen> {
  String _infoPortafolio = 'Cargando...';
  String _resultadoBusqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarInfo();
  }

  Future<void> _cargarInfo() async {
    try {
      final response = await ApiService().getInfoPortafolio();
      if (!mounted) return;
      setState(() {
        _infoPortafolio = response;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _infoPortafolio = 'Error al cargar info';
      });
    }
  }

  Future<void> _buscarPorNombre() async {
    final nombre = await _showTextInputDialog('Buscar inversión', 'Nombre');
    if (nombre == null || nombre.isEmpty) return;

    try {
      final inversion = await ApiService().buscarPorNombre(nombre);
      if (!mounted) return;
      setState(() {
        _resultadoBusqueda = 'Encontrado: ${inversion.nombre} (${inversion.tipo})';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultadoBusqueda = 'No encontrado';
      });
    }
  }

  Future<void> _eliminarPorNombre() async {
    final nombre = await _showTextInputDialog('Eliminar inversión', 'Nombre');
    if (nombre == null || nombre.isEmpty) return;

    try {
      await ApiService().eliminarInversion(nombre);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminado')));
      _cargarInfo();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar')));
    }
  }

  Future<void> _limpiarPortafolio() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Vaciar portafolio?'),
        content: const Text('Se eliminarán todas las inversiones.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService().limpiarPortafolio();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portafolio vaciado')));
        _cargarInfo();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error')));
      }
    }
  }

  Future<String?> _showTextInputDialog(String title, String hint) {
    final controller = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.pixelifySans(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Aceptar')),
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
                'Herramientas',
                style: GoogleFonts.pixelifySans(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF006858), // tu verde personalizado
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
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.yellow[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        _infoPortafolio,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pixelifySans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botones
                _buildButton('Buscar por nombre', _buscarPorNombre),
                const SizedBox(height: 10),
                _buildButton('Eliminar por nombre', _eliminarPorNombre),
                const SizedBox(height: 10),
                _buildButton('Limpiar portafolio', _limpiarPortafolio, color: Colors.red[800]),
                const SizedBox(height: 20),

                // Resultado de búsqueda
                if (_resultadoBusqueda.isNotEmpty)
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Text(
                          _resultadoBusqueda,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pixelifySans(
                            color: const Color(0xFF3BAA43),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildButton(String text, VoidCallback onPressed, {Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text,
          style: GoogleFonts.pixelifySans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF3BAA43),
          ),
        ),
      ),
    );
  }
}