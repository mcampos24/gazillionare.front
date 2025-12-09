import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetalleInversionScreen extends StatelessWidget {
  final Map<String, dynamic> datos;

  const DetalleInversionScreen({super.key, required this.datos});

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
                datos['nombre'] ?? 'Inversión',
                style: GoogleFonts.pixelifySans(
                  fontSize: 48,
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Tipo', datos['tipo'] ?? 'N/A'),
                  _buildDetailRow('Monto', '\$${(datos['monto'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildDetailRow('Valor futuro', '\$${(datos['valorFuturo'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                  const SizedBox(height: 16),

                  if (datos['tipo'] == 'BONO') ...[
                    _buildDetailRow('Retorno anual', '${datos['retornoAnual']}%'),
                    _buildDetailRow('Años restantes', '${datos['aniosRestantes']}'),
                  ],
                  if (datos['tipo'] == 'FONDO') ...[
                    _buildDetailRow('Tipo de fondo', datos['tipoFondo'] ?? 'N/A'),
                    _buildDetailRow('Rendimiento anual', '${datos['rendimientoAnual']}%'),
                  ],
                  if (datos['tipo'] == 'ACCION') ...[
                    _buildDetailRow('Cantidad', '${datos['cantidad']}'),
                    _buildDetailRow('Precio actual', '\$${(datos['precioActual'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                    _buildDetailRow('EPS', '${datos['eps']}'),
                    _buildDetailRow('BVPS', '${datos['bvps']}'),
                    _buildDetailRow('P/E', '${(datos['pe'] as num?)?.toStringAsFixed(2) ?? 'N/A'}'),
                    _buildDetailRow('P/B', '${(datos['pb'] as num?)?.toStringAsFixed(2) ?? 'N/A'}'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: GoogleFonts.pixelifySans(
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.pixelifySans(
                color: Colors.teal[800],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}