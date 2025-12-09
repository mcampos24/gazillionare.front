import 'inversion.dart';

class Fondo extends Inversion {
  final String tipoFondo;
  final double rendimientoAnual;

  Fondo({
    required super.nombre,
    required super.monto,
    required this.tipoFondo,
    required this.rendimientoAnual,
  }) : super(tipo: 'FONDO');

  factory Fondo.fromJson(Map<String, dynamic> json) {
    return Fondo(
      nombre: json['nombre'],
      monto: json['monto'].toDouble(),
      tipoFondo: json['tipoFondo'],
      rendimientoAnual: json['rendimientoAnual'].toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'nombre': nombre,
      'monto': monto,
      'tipoFondo': tipoFondo,
      'rendimientoAnual': rendimientoAnual,
    };
  }
}