// lib/screens/crear_inversion_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/accion.dart';
import '../models/bono.dart';
import '../models/fondo.dart';
import '../models/inversion.dart';


class CrearInversionScreen extends StatefulWidget {
  @override
  _CrearInversionScreenState createState() => _CrearInversionScreenState();
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

    // Inicializar valores por defecto
    _cantidad = 1;
    _precioActual = 0.0;
    _eps = 0.0;
    _bvps = 0.0;

    _retornoAnual = 0.0;
    _aniosRestantes = 1;

    _tipoFondo = 'Indexado';
    _rendimientoAnual = 0.0;
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inversión creada con éxito')),
        );
        Navigator.pop(context); // Volver a la pantalla anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Inversión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Selector de tipo
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Tipo de inversión'),
                value: _tipoSeleccionado,
                items: [
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

              // Nombre (común a todos)
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
                onSaved: (value) => _nombre = value!.trim(),
              ),

              // Campos según tipo
              if (_tipoSeleccionado == 'ACCION') ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Ingrese una cantidad válida (> 0)';
                    }
                    return null;
                  },
                  onSaved: (value) => _cantidad = int.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Precio actual'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final num = double.tryParse(value!);
                    if (num == null || num <= 0) {
                      return 'Precio debe ser > 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _precioActual = double.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'EPS'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final num = double.tryParse(value!);
                    if (num == null || num <= 0) {
                      return 'EPS debe ser > 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _eps = double.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'BVPS'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final num = double.tryParse(value!);
                    if (num == null || num <= 0) {
                      return 'BVPS debe ser > 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _bvps = double.parse(value!),
                ),
              ] else if (_tipoSeleccionado == 'BONO') ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Monto invertido'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final num = double.tryParse(value!);
                    if (num == null || num <= 0) {
                      return 'Monto debe ser > 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _monto = double.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Retorno anual (%)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final num = double.tryParse(value!);
                    if (num == null || num <= 0) {
                      return 'Retorno debe ser > 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _retornoAnual = double.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Años restantes'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Años deben ser > 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _aniosRestantes = int.parse(value!),
                ),
              ] else if (_tipoSeleccionado == 'FONDO') ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Monto invertido'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final num = double.tryParse(value!);
                    if (num == null || num <= 0) {
                      return 'Monto debe ser > 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _monto = double.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Tipo de fondo'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el tipo de fondo';
                    }
                    return null;
                  },
                  onSaved: (value) => _tipoFondo = value!.trim(),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Rendimiento anual (%)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final num = double.tryParse(value!);
                    if (num == null || num < 0) {
                      return 'Rendimiento no puede ser negativo';
                    }
                    return null;
                  },
                  onSaved: (value) => _rendimientoAnual = double.parse(value!),
                ),
              ],

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar,
                child: Text('Guardar Inversión'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}