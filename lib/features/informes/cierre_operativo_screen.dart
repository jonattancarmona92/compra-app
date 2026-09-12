// ==================== ARCHIVO: lib/features/informes/cierre_operativo_screen.dart ====================
// Cierre Operativo — Informe Global §3.7. Informe consolidado de la
// operación diaria: resumen de caja, movimientos de cartera y
// transacciones de café, con lo pendiente por liquidar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../caja/caja_provider.dart';
import '../procesos/procesos_provider.dart';

class CierreOperativoScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const CierreOperativoScreen({super.key, required this.onBack});

String _tipoCartera(TipoCartera tipo) => switch (tipo) {
      TipoCartera.prestamo => 'Préstamo',
      TipoCartera.abono => 'Abono',
      TipoCartera.saldoFavor => 'Ingreso (saldo a favor)',
      TipoCartera.aplicacionSaldoFavor => 'Saldo a favor aplicado',
    };

  bool _esEntradaCartera(TipoCartera tipo) => switch (tipo) {
        TipoCartera.abono => true,
        TipoCartera.saldoFavor => true,
        TipoCartera.prestamo => false,
        TipoCartera.aplicacionSaldoFavor => false,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caja = ref.watch(cajaProvider);
    final procesos = ref.watch(procesosProvider);

    final transacciones = procesos.transaccionesOrdenadas;
    final cartera = caja.movimientosCarteraVisibles;
    final pendientes = procesos.liquidacionesPendientes;

    final rango = _calcularRango(transacciones, cartera);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre Operativo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        children: [
          _RangoCierre(rango: rango),
          const SizedBox(height: AppEspaciado.m),
          _SeccionCierre(
            titulo: 'Caja',
            icono: Icons.account_balance_wallet_outlined,
            children: [
              _filaValor(
                context,
                'Saldo actual de caja',
                caja.saldoActual,
                destacado: true,
              ),
            ],
          ),
          const SizedBox(height: AppEspaciado.m),
          _SeccionCierre(
            titulo: 'Movimientos de cartera',
            icono: Icons.account_balance_outlined,
            children: cartera.isEmpty
                ? [const Text('Sin movimientos de cartera (préstamos/abonos).')]
                : cartera.take(5).map((m) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _esEntradaCartera(m.tipo)
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: _esEntradaCartera(m.tipo)
                            ? AppPaletaOficial.verde
                            : AppPaletaOficial.rojo,
                      ),
                      title: Text(
                        m.nombreCliente,
                        style: const TextStyle(
                          fontSize: AppEscalaTipografica.cuerpo,
                        ),
                      ),
                      subtitle: Text(
                        '${_tipoCartera(m.tipo)} · ${m.concepto}',
                        style: const TextStyle(
                          fontSize: AppEscalaTipografica.notas,
                        ),
                      ),
                      trailing: Text(
                        CurrencyFormatter.formatValue(m.monto),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _esEntradaCartera(m.tipo)
                              ? AppPaletaOficial.verde
                              : AppPaletaOficial.rojo,
                        ),
                      ),
                    );
                  }).toList(),
          ),
          const SizedBox(height: AppEspaciado.m),
          _SeccionCierre(
            titulo: 'Transacciones de café',
            icono: Icons.coffee_outlined,
            children: transacciones.isEmpty
                ? const [Text('No hay transacciones registradas.')]
                : transacciones.take(5).map((t) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.swap_horiz,
                        color: AppPaletaOficial.cafe,
                      ),
                      title: Text(
                        t.nombreCliente,
                        style: const TextStyle(
                          fontSize: AppEscalaTipografica.cuerpo,
                        ),
                      ),
                      subtitle: Text(
                        '${t.esCompra ? 'Compra' : 'Venta'} · '
                        '${t.tipoCafe.etiqueta} · '
                        '${_formatearPeso(t.pesoNeto)} kg',
                        style: const TextStyle(
                          fontSize: AppEscalaTipografica.notas,
                        ),
                      ),
                      trailing: Text(
                        CurrencyFormatter.formatValue(t.valorTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppPaletaOficial.cafe,
                        ),
                      ),
                    );
                  }).toList(),
          ),
          const SizedBox(height: AppEspaciado.m),
          _SeccionCierre(
            titulo: 'Pendiente de liquidar',
            icono: Icons.pending_actions_outlined,
            children: [
              _filaValor(
                context,
                'Transacciones pendientes',
                pendientes.length.toDouble(),
                esNumero: true,
              ),
            ],
          ),
          const SizedBox(height: AppEspaciado.m),
          Text(
            'NOTA DE INTEGRACIÓN PENDIENTE: este informe consolida datos '
            'de los módulos en memoria; se conectará a la base de datos '
            'real (Módulo 5).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPaletaOficial.amarillo,
                  fontSize: AppEscalaTipografica.notas,
                ),
          ),
        ],
      ),
    );
  }

  Widget _filaValor(
    BuildContext context,
    String etiqueta,
    double valor, {
    bool destacado = false,
    bool esNumero = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            etiqueta,
            style: TextStyle(
              fontSize: destacado
                  ? AppEscalaTipografica.subtitulo
                  : AppEscalaTipografica.cuerpo,
              fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          esNumero
              ? valor.toStringAsFixed(0)
              : CurrencyFormatter.formatValue(valor),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: destacado
                ? AppEscalaTipografica.titulo
                : AppEscalaTipografica.cuerpo,
            color: AppPaletaOficial.cafe,
          ),
        ),
      ],
    );
  }

  String _formatearPeso(double peso) {
    return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 1);
  }

  /// §3.7: el Cierre Operativo puede cubrir una sola jornada o varias
  /// sin realizar. El rango se deduce de las fechas de los movimientos
  /// y transacciones consolidadas (hasta que el Módulo 5 persista la
  /// fecha real del último cierre operativo).
  ({DateTime? desde, DateTime? hasta}) _calcularRango(
    List<TransaccionCafe> transacciones,
    List<MovimientoCartera> cartera,
  ) {
    DateTime? min;
    DateTime? max;
    for (final t in transacciones) {
      final f = t.fechaRegistro;
      min = min == null || f.isBefore(min) ? f : min;
      max = max == null || f.isAfter(max) ? f : max;
    }
    for (final m in cartera) {
      final f = m.fechaRegistro;
      min = min == null || f.isBefore(min) ? f : min;
      max = max == null || f.isAfter(max) ? f : max;
    }
    return (desde: min, hasta: max);
  }
}

class _RangoCierre extends StatelessWidget {
  final ({DateTime? desde, DateTime? hasta}) rango;

  const _RangoCierre({required this.rango});

  @override
  Widget build(BuildContext context) {
    final desde = rango.desde;
    final hasta = rango.hasta;
    final text = StringBuffer();
    text.write('Jornada');
    if (desde != null && hasta != null) {
      final dias = hasta.difference(desde).inDays + 1;
      text.write(
        ' del ${_fecha(desde)} al ${_fecha(hasta)} · $dias día${dias == 1 ? '' : 's'}',
      );
    } else if (desde != null) {
      text.write(' del ${_fecha(desde)}');
    } else {
      text.write(' sin movimientos aún');
    }

    return Container(
      padding: const EdgeInsets.all(AppEspaciado.m),
      decoration: BoxDecoration(
        color: AppPaletaOficial.blanco,
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        border: Border.all(color: const Color(0xFFE0D8D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_outlined, color: AppPaletaOficial.cafe),
          const SizedBox(width: AppEspaciado.s),
          Expanded(
            child: Text(
              text.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppEscalaTipografica.cuerpo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fecha(DateTime f) {
    final dia = f.day.toString().padLeft(2, '0');
    final mes = f.month.toString().padLeft(2, '0');
    return '$dia/$mes/${f.year}';
  }
}

class _SeccionCierre extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> children;

  const _SeccionCierre({
    required this.titulo,
    required this.icono,
    required this.children,
  });

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
                Icon(icono, color: AppPaletaOficial.cafe),
                const SizedBox(width: AppEspaciado.s),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.subtitulo,
                  ),
                ),
              ],
            ),
            const Divider(height: AppEspaciado.l),
            ...children,
          ],
        ),
      ),
    );
  }
}
