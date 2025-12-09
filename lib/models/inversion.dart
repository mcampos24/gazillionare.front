class Inversion {
  final String tipo;
  final String nombre;
  final double monto;

  Inversion({
    required this.tipo,
    required this.nombre,
    required this.monto,
  });

  factory Inversion.fromJson(Map<String, dynamic> json) {
    return Inversion(
      tipo: json['tipo'],
      nombre: json['nombre'],
      monto: json['monto'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'nombre': nombre,
      'monto': monto,
    };
  }
}
