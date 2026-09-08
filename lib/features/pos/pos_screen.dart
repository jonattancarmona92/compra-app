// ==================== ARCHIVO: lib/features/pos/pos_screen.dart ====================
// Punto de Venta (POS) — Informe Global §3.6.
// Ventana única del módulo POS con pestañas para agilizar la operación:
//   * Vender (§3.6.1): registro de ventas con descuento de inventario.
//   * Catálogo (§3.6.2): gestión del catálogo de productos de tienda.
//   * Historial (§3.6.3): consulta de ventas POS y comprobantes PDF.
// La pestaña "Vender" se oculta si el complemento "Ventas POS" está
// deshabilitado (Complementos §3.6).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../configuraciones/configuraciones_provider.dart';
import 'historial_ventas_pos_tab.dart';
import 'productos_tab.dart';
import 'ventas_pos_tab.dart';

class PosScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const PosScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventasPosHabilitadas =
        ref.watch(configuracionesProvider).complementos.ventasPos;

    final tabs = <(String, IconData, Widget)>[
      if (ventasPosHabilitadas)
        (
          'Vender',
          Icons.shopping_cart,
          const VentasPosTab(),
        ),
      (
        'Catálogo',
        Icons.inventory_2,
        const ProductosTab(),
      ),
      (
        'Historial',
        Icons.receipt_long,
        const HistorialVentasPosTab(),
      ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Punto de Venta (POS)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          bottom: TabBar(
            tabs: [
              for (final t in tabs)
                Tab(text: t.$1, icon: Icon(t.$2)),
            ],
          ),
        ),
        body: TabBarView(
          children: [for (final t in tabs) t.$3],
        ),
      ),
    );
  }
}