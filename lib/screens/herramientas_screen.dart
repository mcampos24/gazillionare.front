
import 'package:flutter/material.dart';
import '../services/api_service.dart';


class HerramientasScreen extends StatefulWidget {
  @override
  _HerramientasScreenState createState() => _HerramientasScreenState();
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
      setState(() {
        _infoPortafolio = response;
      });
    } catch (e) {
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
      setState(() {
        _resultadoBusqueda = 'Encontrado: ${inversion.nombre} (${inversion.tipo})';
      });
    } catch (e) {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eliminado')));
      _cargarInfo(); // Actualiza el contador
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar')));
    }
  }

  Future<void> _limpiarPortafolio() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Vaciar portafolio?'),
        content: Text('Se eliminarán todas las inversiones.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Sí')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService().limpiarPortafolio();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Portafolio vaciado')));
        _cargarInfo();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error')));
      }
    }
  }

  Future<String?> _showTextInputDialog(String title, String hint) {
    final controller = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text('Aceptar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Herramientas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info del portafolio
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _infoPortafolio,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Botones de herramientas
            _buildButton('Buscar por nombre', _buscarPorNombre),
            SizedBox(height: 10),
            _buildButton('Eliminar por nombre', _eliminarPorNombre),
            SizedBox(height: 10),
            _buildButton('Limpiar portafolio', _limpiarPortafolio, color: Colors.red),
            SizedBox(height: 20),

            // Resultado de búsqueda
            if (_resultadoBusqueda.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(_resultadoBusqueda, style: TextStyle(color: Colors.blue)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(text),
    );
  }
}