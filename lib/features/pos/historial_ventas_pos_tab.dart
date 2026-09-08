// ==================== ARCHIVO: lib/features/pos/historial_ventas_pos_tab.dart ====================
// Pestaña "Historial" del Punto de Venta — Informe Global §3.6.1 / §3.6.3.
// Permite consultar, en orden cronológico inverso, todas las ventas POS
// registradas, con el desglose de líneas (precio unitario × cantidad) y
// la opción de compartir el comprobante en PDF (§8.3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../../features/configuraciones/configuraciones_provider.dart';
import 'pos_provider.dart';

class HistorialVentasPosTab extends ConsumerWidget {
  const HistorialVentasPosTab({super.key});

  Future<void> _compartirPdf(
    BuildContext context,
    WidgetRef ref,
    VentaPos v,
  ) async {
    final config = ref.read(configuracionesProvider);
    final lineas = <LineaComprobante>[
      LineaComprobante.campo('Fecha', _formatoFecha(v.fechaRegistro)),
      LineaComprobante.campo(
        'Cliente',
        (v.nombreCliente ?? '').isEmpty ? 'Sin cliente' : v.nombreCliente,
      ),
      LineaComprobante.campo('Operador', v.operador),
      LineaComprobante.separador(),
      for (final item in v.items)
        LineaComprobante.campo(
          '${item.cantidad}${item.tipo == TipoProductoPos.gramera ? ' g' : ''}'
          ' × ${item.nombre}'
          '${item.codigo != null && item.codigo!.isNotEmpty ? ' (${item.codigo})' : ''}',
          CurrencyFormatter.formatValue(item.subtotal),
        ),
      LineaComprobante.separador(),
      LineaComprobante.campo(
        'TOTAL',
        CurrencyFormatter.formatValue(v.total),
        enNegrita: true,
      ),
    ];
    final ok = await ComprobanteServicio.instancia.compartirPdf(
      encabezado: config.factura.aEncabezadoComprobante,
      titulo: 'Venta POS #${v.id}',
      lineas: lineas,
    );
    if (context.mounted && !ok) {
      Notificaciones.error(
        context,
        'No fue posible generar o compartir el PDF del comprobante.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(posProvider);
    final ventas = estado.ventasOrdenadas;

    if (ventas.isEmpty) return const _SinVentas();

    return ListView.separated(
      padding: const EdgeInsets.all(AppEspaciado.m),
      itemCount: ventas.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppEspaciado.s),
      itemBuilder: (context, index) {
        final v = ventas[index];
        return _TarjetaVenta(
          venta: v,
          onCompartir: () => _compartirPdf(context, ref, v),
        );
      },
    );
  }
}

class _TarjetaVenta extends StatelessWidget {
  final VentaPos venta;
  final VoidCallback onCompartir;

  const _TarjetaVenta({required this.venta, required this.onCompartir});

  String get _cliente {
    final nombre = venta.nombreCliente ?? '';
    return nombre.isEmpty ? 'Sin cliente' : nombre;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppPaletaOficial.blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: const BorderSide(color: Color(0xFFE0D8D0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Venta #${venta.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.cuerpo,
                    ),
                  ),
                ),
                Text(
                  _formatoFecha(venta.fechaRegistro),
                  style: const TextStyle(
                    fontSize: AppEscalaTipografica.notas,
                    color: Color(0xFF6B6660),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.xs),
            Text(
              'Cliente: $_cliente · Operador: ${venta.operador}',
              style: const TextStyle(fontSize: AppEscalaTipografica.notas),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppEspaciado.s),
              child: Divider(height: 1),
            ),
            for (var i = 0; i < venta.items.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == venta.items.length - 1 ? AppEspaciado.s : 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${venta.items[i].cantidad}'
                        '${venta.items[i].tipo == TipoProductoPos.gramera ? ' g' : ''}'
                        ' × ${venta.items[i].nombre}'
                        ' · ${venta.items[i].tipo.etiqueta} '
                        '(${CurrencyFormatter.formatValue(venta.items[i].precioUnitario)})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppEscalaTipografica.notas,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatValue(venta.items[i].subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppEscalaTipografica.notas,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  onPressed: onCompartir,
                  icon: const Icon(
                    Icons.share,
                    size: 20,
                    color: AppPaletaOficial.cafe,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total',
                  style: const TextStyle(
                    fontSize: AppEscalaTipografica.notas,
                    color: Color(0xFF6B6660),
                  ),
                ),
                const SizedBox(width: AppEspaciado.s),
                Text(
                  CurrencyFormatter.formatValue(venta.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.cuerpo,
                    color: AppPaletaOficial.cafe,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SinVentas extends StatelessWidget {
  const _SinVentas();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: Color(0xFFB0ACA7),
          ),
          SizedBox(height: AppEspaciado.m),
          Text(
            'Aún no hay ventas POS registradas',
            style: TextStyle(fontSize: AppEscalaTipografica.cuerpo),
          ),
        ],
      ),
    );
  }
}

String _formatoFecha(DateTime fecha) {
  final dd = fecha.day.toString().padLeft(2, '0');
  final mm = fecha.month.toString().padLeft(2, '0');
  final hh = fecha.hour.toString().padLeft(2, '0');
  final mi = fecha.minute.toString().padLeft(2, '0');
  return '$dd/$mm/${fecha.year} $hh:$mi';
}