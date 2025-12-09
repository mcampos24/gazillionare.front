import 'inversion.dart';

class Accion extends Inversion {
  final int cantidad;
  final double precioActual;
  final double eps;
  final double bvps;

  Accion({
    required super.nombre,
    required this.cantidad,
    required this.precioActual,
    required this.eps,
    required this.bvps,
  }) : super(
    tipo: 'ACCION',
    monto: (cantidad * precioActual).toDouble(),
  );

  factory Accion.fromJson(Map<String, dynamic> json) {
    return Accion(
      nombre: json['nombre'],
      cantidad: json['cantidad'],
      precioActual: json['precioActual'].toDouble(),
      eps: json['eps'].toDouble(),
      bvps: json['bvps'].toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'nombre': nombre,
      'monto': monto,
      'cantidad': cantidad,
      'precioActual': precioActual,
      'eps': eps,
      'bvps': bvps,
    };
  }
}
