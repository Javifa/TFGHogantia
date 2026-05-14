/// Modelo de producto del hogar.
class Producto {
  final String id;
  final String estanciaId;
  final String usuarioId;
  final String nombre;
  final String? categoria;
  final int cantidad;
  final int cantidadMinima;
  final String? unidad;
  final double? precioUnitario;
  final String? ticketUrl;
  final String? notas;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Producto({
    required this.id,
    required this.estanciaId,
    required this.usuarioId,
    required this.nombre,
    this.categoria,
    this.cantidad = 0,
    this.cantidadMinima = 0,
    this.unidad,
    this.precioUnitario,
    this.ticketUrl,
    this.notas,
    this.activo = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      estanciaId: json['estancia_id'],
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      cantidad: json['cantidad'] ?? 0,
      cantidadMinima: json['cantidad_minima'] ?? 0,
      unidad: json['unidad'],
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble(),
      ticketUrl: json['ticket_url'],
      notas: json['notas'],
      activo: json['activo'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estancia_id': estanciaId,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'cantidad_minima': cantidadMinima,
      'unidad': unidad,
      'precio_unitario': precioUnitario,
      'ticket_url': ticketUrl,
      'notas': notas,
      'activo': activo,
    };
  }

  Producto copyWith({
    String? estanciaId,
    String? nombre,
    String? categoria,
    int? cantidad,
    int? cantidadMinima,
    String? unidad,
    double? precioUnitario,
    String? ticketUrl,
    String? notas,
    bool? activo,
  }) {
    return Producto(
      id: id,
      estanciaId: estanciaId ?? this.estanciaId,
      usuarioId: usuarioId,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      cantidad: cantidad ?? this.cantidad,
      cantidadMinima: cantidadMinima ?? this.cantidadMinima,
      unidad: unidad ?? this.unidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      notas: notas ?? this.notas,
      activo: activo ?? this.activo,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Indica si el producto está bajo de stock.
  bool get bajoStock => cantidad <= cantidadMinima;

  /// Texto legible de la cantidad. Ej: "3 unidades"
  String get cantidadTexto {
    final u = unidad ?? 'unidades';
    return '$cantidad $u';
  }
}
