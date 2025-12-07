class Inversion {
  String tipo;
  String nombre;
  double monto;
  Map<String, dynamic> extra;

  Inversion({
    required this.tipo,
    required this.nombre,
    required this.monto,
    this.extra = const {},
  });

  factory Inversion.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipo'] as String;
    final nombre = json['nombre'] as String;
    final monto = (json['monto'] as num).toDouble();

    Map<String, dynamic> extra = {};
    switch (tipo) {
      case 'Bono':
        extra['retornoAnual'] = (json['retornoAnual'] as num).toDouble();
        extra['añosRestantes'] = json['aniosRestantes'];
        break;
      case 'Fondo':
        extra['tipoFondo'] = json['tipoFondo'] as String;
        extra['rendimientoAnual'] = (json['rendimientoAnual'] as num).toDouble();
        break;
      case 'Acción':
        extra['cantidad'] = json['cantidad'];
        extra['precioActual'] = (json['precioActual'] as num).toDouble();
        extra['eps'] = (json['eps'] as num).toDouble();
        extra['bvps'] = (json['bvps'] as num).toDouble();
        break;
      default:
        extra = {};
    }

    return Inversion(
      tipo: tipo,
      nombre: nombre,
      monto: monto,
      extra: extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'tipo': tipo,
      'nombre': nombre,
      'monto': monto,
    };

    data.addAll(extra);

    return data;
  }
}

