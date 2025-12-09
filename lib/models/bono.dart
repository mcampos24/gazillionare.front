import 'inversion.dart';

class Bono extends Inversion {
  final double retornoAnual;
  final int aniosRestantes;

  Bono({
    required super.nombre,
    required super.monto,
    required this.retornoAnual,
    required this.aniosRestantes,
  }) : super(tipo: 'BONO');

  factory Bono.fromJson(Map<String, dynamic> json) {
    return Bono(
      nombre: json['nombre'],
      monto: json['monto'].toDouble(),
      retornoAnual: json['retornoAnual'].toDouble(),
      aniosRestantes: json['aniosRestantes'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'nombre': nombre,
      'monto': monto,
      'retornoAnual': retornoAnual,
      'aniosRestantes': aniosRestantes,
    };
  }
}
