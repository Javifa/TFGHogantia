import 'linea_compra.dart';

/// Modelo de compra / ticket.
class Compra {
  final String id;
  final String usuarioId;
  final String? tienda;
  final String? concepto;
  final double total;
  final String? imagenTicketUrl;
  final DateTime fecha;
  final DateTime createdAt;
  final List<LineaCompra> lineas;

  const Compra({
    required this.id,
    required this.usuarioId,
    this.tienda,
    this.concepto,
    this.total = 0,
    this.imagenTicketUrl,
    required this.fecha,
    required this.createdAt,
    this.lineas = const [],
  });

  factory Compra.fromJson(Map<String, dynamic> json) {
    return Compra(
      id: json['id'],
      usuarioId: json['usuario_id'],
      tienda: json['tienda'],
      concepto: json['concepto'],
      total: (json['total'] as num?)?.toDouble() ?? 0,
      imagenTicketUrl: json['imagen_ticket_url'],
      fecha: DateTime.parse(json['fecha']),
      createdAt: DateTime.parse(json['created_at']),
      lineas: json['lineas_compra'] != null
          ? (json['lineas_compra'] as List)
                .map((l) => LineaCompra.fromJson(l))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'tienda': tienda,
      'concepto': concepto,
      'total': total,
      'imagen_ticket_url': imagenTicketUrl,
      'fecha': fecha.toIso8601String().split('T').first,
    };
  }

  Compra copyWith({
    String? tienda,
    String? concepto,
    double? total,
    String? imagenTicketUrl,
    DateTime? fecha,
    List<LineaCompra>? lineas,
  }) {
    return Compra(
      id: id,
      usuarioId: usuarioId,
      tienda: tienda ?? this.tienda,
      concepto: concepto ?? this.concepto,
      total: total ?? this.total,
      imagenTicketUrl: imagenTicketUrl ?? this.imagenTicketUrl,
      fecha: fecha ?? this.fecha,
      createdAt: createdAt,
      lineas: lineas ?? this.lineas,
    );
  }

  /// Total calculado desde las líneas.
  double get totalCalculado => lineas.fold(0.0, (sum, l) => sum + l.subtotal);

  /// Número de artículos en la compra.
  int get numArticulos => lineas.length;
}
