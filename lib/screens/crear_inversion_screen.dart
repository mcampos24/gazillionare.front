import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/accion.dart';
import '../models/bono.dart';
import '../models/fondo.dart';
import '../models/inversion.dart';

class CrearInversionScreen extends StatefulWidget {
  const CrearInversionScreen({super.key});

  @override
  State<CrearInversionScreen> createState() => _CrearInversionScreenState();
}

class _CrearInversionScreenState extends State<CrearInversionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _tipoSeleccionado;
  late String _nombre;
  late double _monto;

  // Accion
  late int _cantidad;
  late double _precioActual;
  late double _eps;
  late double _bvps;

  // Bono
  late double _retornoAnual;
  late int _aniosRestantes;

  // Fondo
  late String _tipoFondo;
  late double _rendimientoAnual;

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = 'ACCION';
    _nombre = '';
    _monto = 0.0;

    _cantidad = 1;
    _precioActual = 0.0;
    _eps = 0.0;
    _bvps = 0.0;

    _retornoAnual = 0.0;
    _aniosRestantes = 1;

    _tipoFondo = 'Indexado';
    _rendimientoAnual = 0.0;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      Inversion nuevaInversion;

      switch (_tipoSeleccionado) {
        case 'ACCION':
          nuevaInversion = Accion(
            nombre: _nombre,
            cantidad: _cantidad,
            precioActual: _precioActual,
            eps: _eps,
            bvps: _bvps,
          );
          break;
        case 'BONO':
          nuevaInversion = Bono(
            nombre: _nombre,
            monto: _monto,
            retornoAnual: _retornoAnual,
            aniosRestantes: _aniosRestantes,
          );
          break;
        case 'FONDO':
          nuevaInversion = Fondo(
            nombre: _nombre,
            monto: _monto,
            tipoFondo: _tipoFondo,
            rendimientoAnual: _rendimientoAnual,
          );
          break;
        default:
          throw Exception('Tipo no soportado');
      }

      await ApiService().crearInversion(nuevaInversion);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inversión creada con éxito')),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                'Añade...',
                style: GoogleFonts.pixelifySans(
                  fontSize: 55,
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
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Tipo de inversión',
                        labelStyle: GoogleFonts.pixelifySans(color: Colors.teal[900]),
                        border: const OutlineInputBorder(),
                      ),
                      dropdownColor: Colors.white,
                      style: GoogleFonts.pixelifySans(color: Colors.teal[900]),
                      value: _tipoSeleccionado,
                      items: const [
                        DropdownMenuItem(value: 'ACCION', child: Text('Acción')),
                        DropdownMenuItem(value: 'BONO', child: Text('Bono')),
                        DropdownMenuItem(value: 'FONDO', child: Text('Fondo')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _tipoSeleccionado = value!;
                        });
                      },
                      validator: (value) => value == null ? 'Seleccione un tipo' : null,
                    ),

                    const SizedBox(height: 12),

                    // Nombre
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: GoogleFonts.pixelifySans(color: Colors.teal[900]),
                        border: const OutlineInputBorder(),
                      ),
                      style: GoogleFonts.pixelifySans(color: Colors.teal[900]),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                      onSaved: (value) => _nombre = value?.trim() ?? '',
                    ),

                    const SizedBox(height: 12),

                    // Acción
                    if (_tipoSeleccionado == 'ACCION') ...[
                      _buildTextFormField(
                        labelText: 'Cantidad',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null) return 'Ingrese una cantidad válida (> 0)';
                          final parsed = int.tryParse(value);
                          return (parsed == null || parsed <= 0)
                              ? 'Ingrese una cantidad válida (> 0)'
                              : null;
                        },
                        onSaved: (value) => _cantidad = int.parse(value ?? '1'),
                      ),
                      _buildTextFormField(
                        labelText: 'Precio actual',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null) return 'Precio debe ser > 0';
                          final num = double.tryParse(value);
                          return (num == null || num <= 0)
                              ? 'Precio debe ser > 0'
                              : null;
                        },
                        onSaved: (value) => _precioActual = double.parse(value ?? '0.01'),
                      ),
                      _buildTextFormField(
                        labelText: 'EPS',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null) return 'EPS debe ser > 0';
                          final num = double.tryParse(value);
                          return (num == null || num <= 0)
                              ? 'EPS debe ser > 0'
                              : null;
                        },
                        onSaved: (value) => _eps = double.parse(value ?? '0.01'),
                      ),
                      _buildTextFormField(
                        labelText: 'BVPS',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null) return 'BVPS debe ser > 0';
                          final num = double.tryParse(value);
                          return (num == null || num <= 0)
                              ? 'BVPS debe ser > 0'
                              : null;
                        },
                        onSaved: (value) => _bvps = double.parse(value ?? '0.01'),
                      ),
                    ]
                    // Bono
                    else if (_tipoSeleccionado == 'BONO') ...[
                      _buildTextFormField(
                        labelText: 'Monto invertido',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null) return 'Monto debe ser > 0';
                          final num = double.tryParse(value);
                          return (num == null || num <= 0)
                              ? 'Monto debe ser > 0'
                              : null;
                        },
                        onSaved: (value) => _monto = double.parse(value ?? '0.01'),
                      ),
                      _buildTextFormField(
                        labelText: 'Retorno anual (%)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null) return 'Retorno debe ser > 0';
                          final num = double.tryParse(value);
                          return (num == null || num <= 0)
                              ? 'Retorno debe ser > 0'
                              : null;
                        },
                        onSaved: (value) => _retornoAnual = double.parse(value ?? '0.01'),
                      ),
                      _buildTextFormField(
                        labelText: 'Años restantes',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null) return 'Años deben ser > 0';
                          final parsed = int.tryParse(value);
                          return (parsed == null || parsed <= 0)
                              ? 'Años deben ser > 0'
                              : null;
                        },
                        onSaved: (value) => _aniosRestantes = int.parse(value ?? '1'),
                      ),
                    ]
                    // Fondo
                    else if (_tipoSeleccionado == 'FONDO') ...[
                        _buildTextFormField(
                          labelText: 'Monto invertido',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null) return 'Monto debe ser > 0';
                            final num = double.tryParse(value);
                            return (num == null || num <= 0)
                                ? 'Monto debe ser > 0'
                                : null;
                          },
                          onSaved: (value) => _monto = double.parse(value ?? '0.01'),
                        ),
                        _buildTextFormField(
                          labelText: 'Tipo de fondo',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese el tipo de fondo';
                            }
                            return null;
                          },
                          onSaved: (value) => _tipoFondo = value?.trim() ?? 'Indexado',
                        ),
                        _buildTextFormField(
                          labelText: 'Rendimiento anual (%)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null) return 'Rendimiento no puede ser negativo';
                            final num = double.tryParse(value);
                            return (num == null || num < 0)
                                ? 'Rendimiento no puede ser negativo'
                                : null;
                          },
                          onSaved: (value) => _rendimientoAnual = double.parse(value ?? '0'),
                        ),
                      ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent[700],
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Guardar Inversión',
                          style: GoogleFonts.pixelifySans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    TextInputType? keyboardType,
    required String? Function(String?)? validator,
    required void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.pixelifySans(color: Colors.teal[900]),
          border: const OutlineInputBorder(),
        ),
        style: GoogleFonts.pixelifySans(color: Colors.teal[900]),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}