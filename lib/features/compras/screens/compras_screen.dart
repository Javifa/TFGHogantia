import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../facades/compras_facade.dart';
import '../services/ocr_service.dart';
import 'widgets/compra_card.dart';
import 'widgets/ticket_form.dart';

/// Pantalla principal de compras.
class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});
  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComprasFacade>().cargarCompras();
      context.read<ComprasFacade>().cargarTotalMesActual();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _nueva() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
              title: const Text('Añadir manualmente'),
              onTap: () {
                Navigator.pop(ctx);
                _abrirFormulario();
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner_rounded, color: AppColors.accent),
              title: const Text('Añadir ticket inteligente ✨'),
              subtitle: const Text('La IA detectará tienda, total y fecha por ti'),
              onTap: () {
                Navigator.pop(ctx);
                _elegirFuenteIA();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _elegirFuenteIA() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Hacer foto con la cámara'),
              onTap: () {
                Navigator.pop(ctx);
                _escanearTicketIA(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Elegir foto de la galería'),
              onTap: () {
                Navigator.pop(ctx);
                _escanearTicketIA(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _abrirFormulario({String? tienda, double? total, DateTime? fecha, Uint8List? bytes}) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (_) => TicketForm(
        initialTienda: tienda,
        initialTotal: total,
        initialFecha: fecha,
        initialTicketBytes: bytes,
      )
    );
  }

  Future<void> _escanearTicketIA(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 80);
      
      if (file == null) return;

      if (!mounted) return;
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Procesando ticket con IA...'),
            ],
          ),
        ),
      );

      final bytes = await file.readAsBytes();
      final ocrService = OcrService();
      final datos = await ocrService.procesarTicket(file.path, imageBytes: bytes);
      ocrService.dispose();

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      if (datos == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se han detectado datos claros en el ticket.')));
      } else {
        _abrirFormulario(tienda: datos.tienda, total: datos.total, fecha: datos.fecha, bytes: bytes);
      }
    } catch (e, stack) {
      if (!mounted) return;
      Navigator.pop(context); // Intentar cerrar loading si sigue ahí
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error Web'),
          content: SingleChildScrollView(child: Text('Error: $e\n\nStack: $stack')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(_), child: const Text('OK'))
          ]
        )
      );
    }
  }

  Widget _buildVacio({bool isSearch = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.receipt_long_outlined, 
                size: 36, color: AppColors.accent
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'No se encontraron tickets' : 'Sin compras registradas', 
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearch ? 'Intenta buscar con otro término.' : 'Añade tus tickets de compra.', 
              style: const TextStyle(color: AppColors.textSecondary), 
              textAlign: TextAlign.center
            ),
            if (!isSearch) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _nueva, 
                icon: const Icon(Icons.document_scanner_rounded, size: 18), 
                label: const Text('Escanear o añadir ticket')
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      body: Consumer<ComprasFacade>(
        builder: (_, facade, __) {
          if (facade.cargando && facade.compras.isEmpty) return const AppLoadingIndicator(mensaje: 'Cargando compras...');
          if (facade.error != null && facade.compras.isEmpty) return AppErrorWidget(mensaje: facade.error!, onReintentar: facade.cargarCompras);
          
          final comprasFiltradas = _searchQuery.isEmpty 
              ? facade.compras 
              : facade.compras.where((c) => 
                  c.tienda?.toLowerCase().contains(_searchQuery) ?? false
                ).toList();

          return Responsive.constrained(
            context: context,
            child: Column(
              children: [
                _buildResumenGastos(context, facade, hp),
                Padding(
                  padding: EdgeInsets.fromLTRB(hp, 8, hp, 16),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar establecimiento',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: facade.cargarCompras,
                    child: comprasFiltradas.isEmpty
                        ? LayoutBuilder(
                            builder: (context, constraints) => ListView(
                              children: [
                                Container(
                                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                  child: _buildVacio(isSearch: _searchQuery.isNotEmpty),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: hp, vertical: 8),
                            itemCount: comprasFiltradas.length,
                            itemBuilder: (_, i) {
                              final c = comprasFiltradas[i];
                              return CompraCard(compra: c, onTap: () => context.go('/compras/${c.id}'));
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(heroTag: 'fab_compras', onPressed: _nueva, child: const Icon(Icons.add_rounded)),
    );
  }

  Widget _buildResumenGastos(BuildContext context, ComprasFacade facade, double hp) {
    final gastado = facade.totalGastadoEsteMes;
    final limite = facade.limiteGastos;
    final double progreso = limite > 0 ? (gastado / limite).clamp(0.0, 1.0) : 1.0;
    final bool excedido = gastado > limite;

    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 16, hp, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: excedido ? AppColors.error : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gastos del mes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => _mostrarDialogoLimite(context, facade),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Editar límite', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.moneda(gastado),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: excedido ? AppColors.error : AppColors.textPrimary),
                ),
                Text(
                  'de ${Formatters.moneda(limite)}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(excedido ? AppColors.error : AppColors.primary),
              ),
            ),
            if (excedido) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.error),
                  SizedBox(width: 4),
                  Text('Has superado tu límite mensual', style: TextStyle(fontSize: 12, color: AppColors.error)),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoLimite(BuildContext context, ComprasFacade facade) {
    final ctrl = TextEditingController(text: facade.limiteGastos.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Límite de gastos'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Límite en €',
            prefixIcon: Icon(Icons.euro_symbol, size: 18),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val >= 0) {
                facade.establecerLimite(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
