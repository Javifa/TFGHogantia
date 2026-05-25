/// Modelo de usuario / perfil.
class Usuario {
  final String id;
  final String email;
  final String? nombre;
  final String? avatarUrl;
  final DateTime createdAt;

  const Usuario({
    required this.id,
    required this.email,
    this.nombre,
    this.avatarUrl,
    required this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'nombre': nombre, 'avatar_url': avatarUrl};
  }

  Usuario copyWith({String? nombre, String? avatarUrl}) {
    return Usuario(
      id: id,
      email: email,
      nombre: nombre ?? this.nombre,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }

  /// Nombre para mostrar (nombre o email).
  String get nombreVisible => nombre?.isNotEmpty == true ? nombre! : email;
}
