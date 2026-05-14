import 'package:hogentia/features/estancias/models/estancia.dart';
import 'package:hogentia/features/productos/models/producto.dart';
import 'package:hogentia/features/compras/models/compra.dart';
import 'package:hogentia/features/compras/models/linea_compra.dart';
import 'package:hogentia/features/gastos/models/resumen_gastos.dart';

/// Datos de demostración para el modo invitado.
/// Permite navegar la app sin conexión a Supabase.
class DatosDemo {
  DatosDemo._();

  // ── Estancias ──
  static final List<Estancia> estancias = [
    Estancia(id: 'demo-1', usuarioId: 'invitado', nombre: 'Cocina', icono: '🍳', descripcion: 'Cocina principal', orden: 0, createdAt: DateTime.now()),
    Estancia(id: 'demo-2', usuarioId: 'invitado', nombre: 'Baño', icono: '🛁', descripcion: 'Baño principal', orden: 1, createdAt: DateTime.now()),
    Estancia(id: 'demo-3', usuarioId: 'invitado', nombre: 'Dormitorio', icono: '🛏️', orden: 2, createdAt: DateTime.now()),
    Estancia(id: 'demo-4', usuarioId: 'invitado', nombre: 'Salón', icono: '🛋️', orden: 3, createdAt: DateTime.now()),
    Estancia(id: 'demo-5', usuarioId: 'invitado', nombre: 'Lavandería', icono: '👕', orden: 4, createdAt: DateTime.now()),
    Estancia(id: 'demo-6', usuarioId: 'invitado', nombre: 'Despacho', icono: '📚', orden: 5, createdAt: DateTime.now()),
  ];

  // ── Productos ──
  static final Map<String, List<Producto>> productosPorEstancia = {
    'demo-1': [
      Producto(id: 'p-1', estanciaId: 'demo-1', usuarioId: 'invitado', nombre: 'Leche', categoria: 'Alimentación', cantidad: 2, cantidadMinima: 3, unidad: 'litros', createdAt: DateTime.now()),
      Producto(id: 'p-2', estanciaId: 'demo-1', usuarioId: 'invitado', nombre: 'Arroz', categoria: 'Alimentación', cantidad: 5, cantidadMinima: 1, unidad: 'kg', createdAt: DateTime.now()),
      Producto(id: 'p-3', estanciaId: 'demo-1', usuarioId: 'invitado', nombre: 'Aceite de oliva', categoria: 'Alimentación', cantidad: 1, cantidadMinima: 1, unidad: 'litros', createdAt: DateTime.now()),
      Producto(id: 'p-4', estanciaId: 'demo-1', usuarioId: 'invitado', nombre: 'Lavavajillas', categoria: 'Limpieza', cantidad: 0, cantidadMinima: 1, unidad: 'unidades', createdAt: DateTime.now()),
      Producto(id: 'p-5', estanciaId: 'demo-1', usuarioId: 'invitado', nombre: 'Esponjas', categoria: 'Limpieza', cantidad: 3, cantidadMinima: 2, unidad: 'paquetes', createdAt: DateTime.now()),
    ],
    'demo-2': [
      Producto(id: 'p-6', estanciaId: 'demo-2', usuarioId: 'invitado', nombre: 'Papel higiénico', categoria: 'Higiene', cantidad: 6, cantidadMinima: 4, unidad: 'unidades', createdAt: DateTime.now()),
      Producto(id: 'p-7', estanciaId: 'demo-2', usuarioId: 'invitado', nombre: 'Champú', categoria: 'Higiene', cantidad: 1, cantidadMinima: 1, unidad: 'unidades', createdAt: DateTime.now()),
      Producto(id: 'p-8', estanciaId: 'demo-2', usuarioId: 'invitado', nombre: 'Gel de ducha', categoria: 'Higiene', cantidad: 0, cantidadMinima: 1, unidad: 'unidades', createdAt: DateTime.now()),
    ],
    'demo-3': [
      Producto(id: 'p-9', estanciaId: 'demo-3', usuarioId: 'invitado', nombre: 'Sábanas repuesto', categoria: 'Ropa', cantidad: 2, cantidadMinima: 1, unidad: 'unidades', createdAt: DateTime.now()),
    ],
    'demo-4': [
      Producto(id: 'p-10', estanciaId: 'demo-4', usuarioId: 'invitado', nombre: 'Ambientador', categoria: 'Limpieza', cantidad: 1, cantidadMinima: 1, unidad: 'unidades', createdAt: DateTime.now()),
    ],
    'demo-5': [
      Producto(id: 'p-11', estanciaId: 'demo-5', usuarioId: 'invitado', nombre: 'Detergente', categoria: 'Limpieza', cantidad: 1, cantidadMinima: 1, unidad: 'litros', createdAt: DateTime.now()),
      Producto(id: 'p-12', estanciaId: 'demo-5', usuarioId: 'invitado', nombre: 'Suavizante', categoria: 'Limpieza', cantidad: 0, cantidadMinima: 1, unidad: 'litros', createdAt: DateTime.now()),
    ],
    'demo-6': [],
  };

  // ── Compras ──
  static final List<Compra> compras = [
    Compra(
      id: 'c-1', usuarioId: 'invitado', tienda: 'Mercadona', total: 47.85,
      fecha: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now(),
      lineas: [
        const LineaCompra(id: 'l-1', compraId: 'c-1', nombreItem: 'Leche', cantidad: 3, precioUnitario: 1.15, subtotal: 3.45),
        const LineaCompra(id: 'l-2', compraId: 'c-1', nombreItem: 'Pan', cantidad: 2, precioUnitario: 1.20, subtotal: 2.40),
        const LineaCompra(id: 'l-3', compraId: 'c-1', nombreItem: 'Pollo', cantidad: 1, precioUnitario: 6.50, subtotal: 6.50),
        const LineaCompra(id: 'l-4', compraId: 'c-1', nombreItem: 'Verduras varias', cantidad: 1, precioUnitario: 12.30, subtotal: 12.30),
        const LineaCompra(id: 'l-5', compraId: 'c-1', nombreItem: 'Otros', cantidad: 1, precioUnitario: 23.20, subtotal: 23.20),
      ],
    ),
    Compra(
      id: 'c-2', usuarioId: 'invitado', tienda: 'Lidl', total: 32.10,
      fecha: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now(),
      lineas: [
        const LineaCompra(id: 'l-6', compraId: 'c-2', nombreItem: 'Detergente', cantidad: 1, precioUnitario: 4.99, subtotal: 4.99),
        const LineaCompra(id: 'l-7', compraId: 'c-2', nombreItem: 'Fruta', cantidad: 1, precioUnitario: 8.50, subtotal: 8.50),
        const LineaCompra(id: 'l-8', compraId: 'c-2', nombreItem: 'Embutidos', cantidad: 1, precioUnitario: 18.61, subtotal: 18.61),
      ],
    ),
    Compra(
      id: 'c-3', usuarioId: 'invitado', tienda: 'Carrefour', total: 89.50,
      fecha: DateTime.now().subtract(const Duration(days: 12)),
      createdAt: DateTime.now(),
    ),
    Compra(
      id: 'c-4', usuarioId: 'invitado', tienda: 'Mercadona', total: 55.20,
      fecha: DateTime.now().subtract(const Duration(days: 20)),
      createdAt: DateTime.now(),
    ),
    Compra(
      id: 'c-5', usuarioId: 'invitado', tienda: 'Lidl', total: 28.90,
      fecha: DateTime.now().subtract(const Duration(days: 30)),
      createdAt: DateTime.now(),
    ),
  ];

  // ── Resumen de gastos del mes actual ──
  static ResumenGastos get resumenMesActual {
    final ahora = DateTime.now();
    return ResumenGastos(
      anio: ahora.year,
      mes: ahora.month,
      totalMes: 253.55,
      numCompras: 5,
      gastosPorTienda: {
        'Mercadona': 103.05,
        'Lidl': 61.00,
        'Carrefour': 89.50,
      },
    );
  }

  // ── Histórico de gastos (últimos 6 meses) ──
  static Map<String, double> get historico {
    final ahora = DateTime.now();
    final datos = <String, double>{};
    final valores = [253.55, 312.40, 198.75, 275.00, 340.20, 225.80];

    for (int i = 0; i < 6; i++) {
      final fecha = DateTime(ahora.year, ahora.month - i, 1);
      final clave = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
      datos[clave] = valores[i];
    }

    return datos;
  }

  // ── Contador para IDs únicos en modo demo ──
  static int _contadorId = 100;
  static String generarId() => 'demo-${_contadorId++}';
}
