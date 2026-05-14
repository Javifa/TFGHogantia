/// Modelo de línea de compra (item dentro de un ticket).
class LineaCompra {
  final String id;
  final String compraId;
  final String? productoId;
  final String nombreItem;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const LineaCompra({
    required this.id,
    required this.compraId,
    this.productoId,
    required this.nombreItem,
    this.cantidad = 1,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory LineaCompra.fromJson(Map<String, dynamic> json) {
    return LineaCompra(
      id: json['id'],
      compraId: json['compra_id'],
      productoId: json['producto_id'],
      nombreItem: json['nombre_item'],
      cantidad: json['cantidad'] ?? 1,
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'compra_id': compraId,
      'producto_id': productoId,
      'nombre_item': nombreItem,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
    };
  }

  LineaCompra copyWith({
    String? productoId,
    String? nombreItem,
    int? cantidad,
    double? precioUnitario,
  }) {
    final nuevaCantidad = cantidad ?? this.cantidad;
    final nuevoPrecio = precioUnitario ?? this.precioUnitario;
    return LineaCompra(
      id: id,
      compraId: compraId,
      productoId: productoId ?? this.productoId,
      nombreItem: nombreItem ?? this.nombreItem,
      cantidad: nuevaCantidad,
      precioUnitario: nuevoPrecio,
      subtotal: nuevaCantidad * nuevoPrecio,
    );
  }
}
