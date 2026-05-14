/// Modelo de estancia del hogar.
class Estancia {
  final String id;
  final String usuarioId;
  final String nombre;
  final String icono;
  final String? descripcion;
  final int orden;
  final DateTime createdAt;

  const Estancia({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    this.icono = '🏠',
    this.descripcion,
    this.orden = 0,
    required this.createdAt,
  });

  factory Estancia.fromJson(Map<String, dynamic> json) {
    return Estancia(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      icono: json['icono'] ?? '🏠',
      descripcion: json['descripcion'],
      orden: json['orden'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre': nombre,
      'icono': icono,
      'descripcion': descripcion,
      'orden': orden,
    };
  }

  Estancia copyWith({
    String? nombre,
    String? icono,
    String? descripcion,
    int? orden,
  }) {
    return Estancia(
      id: id,
      usuarioId: usuarioId,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      descripcion: descripcion ?? this.descripcion,
      orden: orden ?? this.orden,
      createdAt: createdAt,
    );
  }
}
