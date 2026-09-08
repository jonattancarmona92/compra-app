// ==================== ARCHIVO: lib/features/informes/cierre_caja_screen.dart ====================
// Cierre de Caja — Informe Global §3.7. Informe consolidado del estado de
// la caja: saldo inicial, entradas, salidas y saldo final teórico según
// la Ecuación de Consistencia del Balance (§7.9.1), con el detalle de
// movimientos.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../caja/caja_provider.dart';

class CierreCajaScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const CierreCajaScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caja = ref.watch(cajaProvider);
    final saldoInicial = caja.sesionActual?.saldoInicial ?? 0;
    final entradas = caja.totalEntradas;
    final salidas = caja.totalSalidas;
    final saldoFinal = caja.saldoActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre de Caja'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Column(
        children: [
          _encabezado(
            context,
            saldoInicial: saldoInicial,
            entradas: entradas,
            salidas: salidas,
            saldoFinal: saldoFinal,
          ),
          const Divider(height: 1),
          Expanded(
            child: caja.movimientosVisibles.isEmpty
                ? const _SinMovimientos()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppEspaciado.m),
                    itemCount: caja.movimientosVisibles.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppEspaciado.s),
                    itemBuilder: (context, index) {
                      final m = caja.movimientosVisibles[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          m.tipo == TipoMovimientoCaja.entrada
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: m.tipo == TipoMovimientoCaja.entrada
                              ? AppPaletaOficial.verde
                              : AppPaletaOficial.rojo,
                        ),
                        title: Text(
                          m.concepto,
                          style: const TextStyle(
                            fontSize: AppEscalaTipografica.cuerpo,
                          ),
                        ),
                        subtitle: Text(_formatearFechaHora(m.fechaRegistro)),
                        trailing: Text(
                          CurrencyFormatter.formatValue(m.monto),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: m.tipo == TipoMovimientoCaja.entrada
                                ? AppPaletaOficial.verde
                                : AppPaletaOficial.rojo,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _encabezado(
    BuildContext context, {
    required double saldoInicial,
    required double entradas,
    required double salidas,
    required double saldoFinal,
  }) {
    return Container(
      width: double.infinity,
      color: AppPaletaOficial.cafe,
      padding: const EdgeInsets.all(AppEspaciado.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Caja · Saldo Final Teórico (§7.9.1)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppPaletaOficial.blanco,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppEspaciado.m),
          _filaResumen(context, 'Saldo inicial', saldoInicial),
          const SizedBox(height: AppEspaciado.s),
          _filaResumen(context, 'Entradas', entradas, positivo: true),
          const SizedBox(height: AppEspaciado.s),
          _filaResumen(context, 'Salidas', salidas, negativo: true),
          const Divider(color: Colors.white24, height: AppEspaciado.l),
          _filaResumen(context, 'Saldo final', saldoFinal, destacado: true),
        ],
      ),
    );
  }

  Widget _filaResumen(
    BuildContext context,
    String etiqueta,
    double valor, {
    bool positivo = false,
    bool negativo = false,
    bool destacado = false,
  }) {
    final color = destacado
        ? AppPaletaOficial.blanco
        : positivo
            ? Colors.lightGreenAccent
            : negativo
                ? Colors.orangeAccent
                : Colors.white70;

    return Row(
      children: [
        Expanded(
          child: Text(
            etiqueta,
            style: TextStyle(
              color: color,
              fontSize: destacado
                  ? AppEscalaTipografica.subtitulo
                  : AppEscalaTipografica.cuerpo,
              fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          CurrencyFormatter.formatValue(valor),
          style: TextStyle(
            color: color,
            fontSize: destacado
                ? AppEscalaTipografica.titulo
                : AppEscalaTipografica.cuerpo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatearFechaHora(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} · $hora:$min';
  }
}

class _SinMovimientos extends StatelessWidget {
  const _SinMovimientos();

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
            'No hay movimientos de caja',
            style: TextStyle(fontSize: AppEscalaTipografica.cuerpo),
          ),
        ],
      ),
    );
  }
}
