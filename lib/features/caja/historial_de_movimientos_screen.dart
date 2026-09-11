// ==================== ARCHIVO: lib/features/caja/historial_de_movimientos_screen.dart ====================
// Historial de Movimientos — Informe Global §3.3.3.
// Listado cronológico de todos los flujos monetarios de la sesión
// (manuales y automáticos), con reportes impresos/PDF y anulación por
// gesto de deslizamiento.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../configuraciones/configuraciones_provider.dart';
import '../configuraciones/impresora_bluetooth_servicio.dart';
import 'caja_provider.dart';

/// Tipos de café reconocidos por el sistema — §3.3.3 (consolidado por
/// tipo) y §5.5.6/§5.5.7 (enum tipo_cafe). Se centraliza aquí porque
/// el Módulo de Caja necesita listarlos para el "Informe de Café por
/// Tipo", aunque la semántica completa del café pertenece a Procesos.
enum TipoCafe { seco, mojado, oreado, pasilla, secado }

extension TipoCafeLabel on TipoCafe {
  String get etiqueta {
    switch (this) {
      case TipoCafe.seco:
        return 'Seco';
      case TipoCafe.mojado:
        return 'Mojado';
      case TipoCafe.oreado:
        return 'Oreado';
      case TipoCafe.pasilla:
        return 'Pasilla';
      case TipoCafe.secado:
        return 'Secado';
    }
  }
}

class HistorialDeMovimientosScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const HistorialDeMovimientosScreen({super.key, required this.onBack});

  @override
  ConsumerState<HistorialDeMovimientosScreen> createState() =>
      _HistorialDeMovimientosScreenState();
}

class _HistorialDeMovimientosScreenState
    extends ConsumerState<HistorialDeMovimientosScreen> {
  static const String _operadorActual = 'operador_demo';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final custom = theme.extension<CoffeeCustomTheme>()!;
    final estado = ref.watch(cajaProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Historial de Movimientos'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Resumen'),
              Tab(text: 'Entradas'),
              Tab(text: 'Salidas'),
            ],
          ),
        ),
        body: estado.isCargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // §3.3: banner obligatorio en vistas operativas sensibles.
                  Container(
                    width: double.infinity,
                    color: custom.cajaBannerBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppEspaciado.l,
                      vertical: AppEspaciado.m,
                    ),
                    child: Text(
                      'Dinero actual en caja: '
                      '${CurrencyFormatter.formatValue(estado.saldoActual)}',
                      style: custom.cajaBannerTextStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppEspaciado.m),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _abrirOpcionesDeReporte(context),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Imprimir Reporte de Caja'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildResumenTab(theme, estado),
                        _buildListaTipo(theme, estado, TipoMovimientoCaja.entrada),
                        _buildListaTipo(theme, estado, TipoMovimientoCaja.salida),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// §3.3.3 — Pestaña principal: apertura de caja, sumatorias de
  /// entradas/salidas, dinero actual y el consolidado de movimientos.
  Widget _buildResumenTab(ThemeData theme, CajaEstado estado) {
    final movimientos = estado.movimientosVisibles;
    final apertura = estado.sesionActual?.saldoInicial ?? 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppEspaciado.m,
            0,
            AppEspaciado.m,
            AppEspaciado.m,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TarjetaResumen(
                      etiqueta: 'Entrada por Apertura',
                      valor: apertura,
                      icon: Icons.login,
                      colorIcono: AppPaletaOficial.cafe,
                      colorValor: AppPaletaOficial.cafe,
                    ),
                  ),
                  const SizedBox(width: AppEspaciado.s),
                  Expanded(
                    child: _TarjetaResumen(
                      etiqueta: 'Total Entradas',
                      valor: estado.totalEntradas,
                      icon: Icons.arrow_downward,
                      colorIcono: AppPaletaOficial.verde,
                      colorValor: AppPaletaOficial.verde,
                    ),
                  ),
                  const SizedBox(width: AppEspaciado.s),
                  Expanded(
                    child: _TarjetaResumen(
                      etiqueta: 'Total Salidas',
                      valor: estado.totalSalidas,
                      icon: Icons.arrow_upward,
                      colorIcono: AppPaletaOficial.rojo,
                      colorValor: AppPaletaOficial.rojo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppEspaciado.m),
              _EquilibrioCaja(
                apertura: apertura,
                entradas: estado.totalEntradas,
                salidas: estado.totalSalidas,
                saldo: estado.saldoActual,
              ),
            ],
          ),
        ),
        Expanded(
          child: movimientos.isEmpty
              ? _buildVacio(theme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.m,
                  ),
                  itemCount: movimientos.length,
                  itemBuilder: (context, index) {
                    final movimiento = movimientos[index];
                    return _MovimientoDismissible(
                      key: ValueKey(movimiento.id),
                      movimiento: movimiento,
                      onAnular: () =>
                          _confirmarAnulacion(context, movimiento),
                      onTapComprobante: () =>
                          _abrirComprobanteIndividual(
                            context,
                            movimiento,
                          ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// §3.3.3 — Pestañas de Entradas/Salidas: listado filtrado por tipo
  /// con su subtotal en la cabecera.
  Widget _buildListaTipo(
    ThemeData theme,
    CajaEstado estado,
    TipoMovimientoCaja tipo,
  ) {
    final esEntrada = tipo == TipoMovimientoCaja.entrada;
    final movimientos = estado.movimientosVisibles
        .where((m) => m.tipo == tipo)
        .toList();
    final subtotal = esEntrada ? estado.totalEntradas : estado.totalSalidas;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: esEntrada
              ? AppPaletaOficial.verde.withValues(alpha: 0.12)
              : AppPaletaOficial.rojo.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(
            horizontal: AppEspaciado.l,
            vertical: AppEspaciado.m,
          ),
          child: Row(
            children: [
              Icon(
                esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                color: esEntrada
                    ? AppPaletaOficial.verde
                    : AppPaletaOficial.rojo,
              ),
              const SizedBox(width: AppEspaciado.s),
              Expanded(
                child: Text(
                  esEntrada ? 'Sumatoria de Entradas' : 'Sumatoria de Salidas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.formatValue(subtotal),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: esEntrada
                      ? AppPaletaOficial.verde
                      : AppPaletaOficial.rojo,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: movimientos.isEmpty
              ? _buildVacio(theme, mensaje: esEntrada
                  ? 'No hay entradas registradas en esta sesión.'
                  : 'No hay salidas registradas en esta sesión.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.m,
                  ),
                  itemCount: movimientos.length,
                  itemBuilder: (context, index) {
                    final movimiento = movimientos[index];
                    return _MovimientoDismissible(
                      key: ValueKey(movimiento.id),
                      movimiento: movimiento,
                      onAnular: () =>
                          _confirmarAnulacion(context, movimiento),
                      onTapComprobante: () =>
                          _abrirComprobanteIndividual(
                            context,
                            movimiento,
                          ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVacio(
    ThemeData theme, {
    String mensaje = 'Aún no hay movimientos registrados en esta sesión.',
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 56,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppEspaciado.m),
          Text(
            mensaje,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // §3.3.3 — BOTONES DE REPORTE (Imprimir Reporte de Caja)
  // ==========================================================================

  void _abrirOpcionesDeReporte(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppEspaciado.radioEstandar),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppEspaciado.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppEspaciado.l),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reportes de Caja',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Imprimir Todo el Informe'),
              subtitle: const Text(
                'Tiquete largo con la totalidad de entradas y salidas de la sesión',
              ),
              onTap: () {
                Navigator.pop(context);
                _emitirReporte(context, 'Informe completo de la sesión');
              },
            ),
            ListTile(
              leading: const Icon(Icons.coffee),
              title: const Text('Imprimir Informe de Café por Tipo'),
              subtitle: const Text('Seco, Mojado, Oreado, Pasilla o Secado'),
              onTap: () {
                Navigator.pop(context);
                _abrirSelectorTipoCafe(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('Imprimir Informe Total'),
              subtitle: const Text(
                'Saldo inicial, entradas, salidas y saldo teórico final',
              ),
              onTap: () {
                Navigator.pop(context);
                _emitirReporte(context, 'Resumen consolidado de la jornada');
              },
            ),
            const SizedBox(height: AppEspaciado.m),
          ],
        ),
      ),
    );
  }

  void _abrirSelectorTipoCafe(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Seleccione el tipo de café'),
        children: TipoCafe.values.map((tipo) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _emitirReporte(context, 'Informe de café — ${tipo.etiqueta}');
            },
            child: Text(tipo.etiqueta),
          );
        }).toList(),
      ),
    );
  }

  void _abrirComprobanteIndividual(
    BuildContext context,
    MovimientoCaja movimiento,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comprobante Individual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Concepto: ${movimiento.concepto}'),
            const SizedBox(height: AppEspaciado.s),
            Text('Valor: ${CurrencyFormatter.formatValue(movimiento.monto)}'),
            const SizedBox(height: AppEspaciado.s),
            Text('Operador: ${movimiento.operador}'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _emitirReporte(context, 'Comprobante individual');
            },
            icon: const Icon(Icons.print_outlined),
            label: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }

  /// §3.3.3/§8.3: genera el reporte pedido y ofrece compartirlo en PDF
  /// o imprimirlo en la térmica (§10.2).
  Future<void> _emitirReporte(BuildContext context, String tipoReporte) async {
    final estado = ref.read(cajaProvider);
    final config = ref.read(configuracionesProvider);
    final lineas = _lineasDelReporte(
      tipoReporte: tipoReporte,
      estado: estado,
    );

    final accion = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppEspaciado.radioEstandar),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppEspaciado.s),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Compartir como PDF'),
              subtitle: const Text('Guarda o envía el reporte (PDF)'),
              onTap: () => Navigator.pop(context, 'compartir'),
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: const Text('Imprimir Ticket'),
              subtitle: const Text('Impresora térmica Bluetooth'),
              onTap: () => Navigator.pop(context, 'imprimir'),
            ),
            const SizedBox(height: AppEspaciado.m),
          ],
        ),
      ),
    );

    if (accion == null || !context.mounted) return;

    if (accion == 'compartir') {
      final ok = await ComprobanteServicio.instancia.compartirPdf(
        encabezado: config.factura.aEncabezadoComprobante,
        titulo: tipoReporte,
        lineas: lineas,
      );
      if (context.mounted && !ok) {
        Notificaciones.error(
          context,
          'No fue posible generar o compartir el PDF del reporte.',
        );
      }
    } else {
      final datos = TicketEscPosBuilder.construir(
        titulo: 'REPORTE DE CAJA',
        lineas: [
          for (final l in lineas)
            if (l.valor == null) l.etiqueta else '${l.etiqueta}: ${l.valor}',
        ],
        encabezado: config.factura.aEncabezadoComprobante,
        copias: config.impresora.copias,
        cortarPapel: config.impresora.cortarPapel,
      );
      try {
        await ImpresoraBluetoothServicio.instancia.escribir(datos);
      } catch (_) {
        if (context.mounted) {
          Notificaciones.error(
            context,
            'No se pudo imprimir. Verifica la conexión con la impresora.',
          );
        }
      }
    }
  }

  List<LineaComprobante> _lineasDelReporte({
    required String tipoReporte,
    required CajaEstado estado,
  }) {
    final visibles = estado.movimientosVisibles;
    if (tipoReporte == 'Resumen consolidado de la jornada') {
      return [
        LineaComprobante.texto('RESUMEN DE LA JORNADA'),
        LineaComprobante.campo(
          'Saldo inicial',
          CurrencyFormatter.formatValue(
            estado.sesionActual?.saldoInicial ?? 0,
          ),
        ),
        LineaComprobante.campo(
          'Total entradas',
          CurrencyFormatter.formatValue(estado.totalEntradas),
        ),
        LineaComprobante.campo(
          'Total salidas',
          CurrencyFormatter.formatValue(estado.totalSalidas),
        ),
        LineaComprobante.campo(
          'Saldo teórico final',
          CurrencyFormatter.formatValue(estado.saldoActual),
          enNegrita: true,
        ),
      ];
    }
    if (visibles.isEmpty) {
      return [
        const LineaComprobante.texto('Sin movimientos registrados en la sesión.')
      ];
    }
    return [
      LineaComprobante.texto(tipoReporte),
      for (final m in visibles) ...[
        LineaComprobante.campo(
          m.concepto,
          '${m.tipo == TipoMovimientoCaja.entrada ? '+' : '-'} '
          '${CurrencyFormatter.formatValue(m.monto)}',
        ),
      ],
    ];
  }

  // ==========================================================================
  // §3.3.3 — GESTO DE ANULACIÓN (deslizar a la izquierda)
  // ==========================================================================

  Future<void> _confirmarAnulacion(
    BuildContext context,
    MovimientoCaja movimiento,
  ) async {
    // NOTA DE INTEGRACIÓN PENDIENTE: el §3.3.3 exige PIN de seguridad
    // de 4 dígitos antes de anular. Se integra el diálogo de PIN real
    // cuando conectemos control_inicio_provider en el Módulo 6.
    try {
      await ref
          .read(cajaProvider.notifier)
          .anularMovimiento(
            movimientoId: movimiento.id,
            operador: _operadorActual,
          );
      if (context.mounted) {
        Notificaciones.exito(
          context,
          'Movimiento anulado. Registrado en Audit Log.',
        );
      }
    } on SaldoInsuficienteException {
      if (context.mounted) {
        Notificaciones.error(
          context,
          'No es posible anular: la Caja no tiene fondos suficientes.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        Notificaciones.error(context, 'No fue posible anular el movimiento.');
      }
    }
  }
}

// ============================================================================
// FILA DESLIZABLE — §3.3.3: "Deslizar el registro hacia la izquierda
// revela únicamente la opción de 'Anular'".
// ============================================================================

class _MovimientoDismissible extends StatelessWidget {
  final MovimientoCaja movimiento;
  final VoidCallback onAnular;
  final VoidCallback onTapComprobante;

  const _MovimientoDismissible({
    super.key,
    required this.movimiento,
    required this.onAnular,
    required this.onTapComprobante,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esEntrada = movimiento.tipo == TipoMovimientoCaja.entrada;
    final esAutomatico = movimiento.origenTabla != null;

    return Dismissible(
      key: ValueKey('dismiss_${movimiento.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppEspaciado.l),
        margin: const EdgeInsets.only(bottom: AppEspaciado.s),
        decoration: BoxDecoration(
          color: AppPaletaOficial.rojo,
          borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, color: AppPaletaOficial.blanco),
            SizedBox(width: AppEspaciado.s),
            Text('Anular', style: TextStyle(color: AppPaletaOficial.blanco)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onAnular();
        return false; // el estado se actualiza vía Riverpod, no por swipe físico.
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppEspaciado.s),
        child: ListTile(
          onTap: onTapComprobante,
          leading: Icon(
            esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
            color: esEntrada ? AppPaletaOficial.verde : AppPaletaOficial.rojo,
          ),
          title: Text(movimiento.concepto),
          subtitle: Text(
            [
              esAutomatico
                  ? 'Automático (${movimiento.origenTabla})'
                  : 'Manual',
              _formatearFechaHora(movimiento.fechaRegistro),
            ].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            '${esEntrada ? '+' : '-'} ${CurrencyFormatter.formatValue(movimiento.monto)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: esEntrada ? AppPaletaOficial.verde : AppPaletaOficial.rojo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatearFechaHora(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '${fecha.day}/${fecha.month}/${fecha.year} $h:$m';
  }
}

/// §3.3.3 — Tarjeta resumen de la pestaña principal: apertura de caja y
/// sumatorias de entradas/salidas.
class _TarjetaResumen extends StatelessWidget {
  final String etiqueta;
  final double valor;
  final IconData icon;
  final Color colorIcono;
  final Color colorValor;

  const _TarjetaResumen({
    required this.etiqueta,
    required this.valor,
    required this.icon,
    required this.colorIcono,
    required this.colorValor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Icon(icon, color: colorIcono, size: 22),
            const SizedBox(height: AppEspaciado.s),
            Text(
              etiqueta,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppEspaciado.xs),
            Text(
              CurrencyFormatter.formatValue(valor),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorValor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// §3.3.3 — Ecuación de Consistencia del Balance (§7.9.1) expuesta en la
/// pestaña Resumen: Saldo Inicial + Entradas − Salidas = Saldo actual.
class _EquilibrioCaja extends StatelessWidget {
  final double apertura;
  final double entradas;
  final double salidas;
  final double saldo;

  const _EquilibrioCaja({
    required this.apertura,
    required this.entradas,
    required this.salidas,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppEspaciado.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fila(
            context,
            'Saldo Inicial',
            apertura,
            AppPaletaOficial.cafe,
          ),
          _fila(
            context,
            '+ Entradas',
            entradas,
            AppPaletaOficial.verde,
          ),
          _fila(
            context,
            '− Salidas',
            salidas,
            AppPaletaOficial.rojo,
          ),
          const Divider(height: AppEspaciado.m),
          _fila(
            context,
            '= Saldo actual',
            saldo,
            AppPaletaOficial.cafe,
            negrita: true,
          ),
        ],
      ),
    );
  }

  Widget _fila(
    BuildContext context,
    String label,
    double valor,
    Color color, {
    bool negrita = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppEspaciado.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: negrita ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            CurrencyFormatter.formatValue(valor),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
