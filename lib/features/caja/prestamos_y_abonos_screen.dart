// ==================== ARCHIVO: lib/features/caja/prestamos_y_abonos_screen.dart ====================
// Préstamos y Abonos — Informe Global §3.3.2.
// Proporciona dinero a clientes (préstamos) y recibe pagos de cartera
// (abonos con distribución automática), integrado con la Caja.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../clientes/models/cliente_model.dart';
import '../clientes/providers/cliente_provider.dart';
import '../configuraciones/configuraciones_provider.dart';
import '../../core/widgets/pin_entry_widget.dart';
import '../inicio/control_inicio_provider.dart';
import 'caja_provider.dart';
import 'widgets/banner_caja_widget.dart';
import 'widgets/menu_tres_puntos_widget.dart';

class PrestamosYAbonosScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const PrestamosYAbonosScreen({super.key, required this.onBack});

  @override
  ConsumerState<PrestamosYAbonosScreen> createState() =>
      _PrestamosYAbonosScreenState();
}

class _PrestamosYAbonosScreenState
    extends ConsumerState<PrestamosYAbonosScreen> {
  // NOTA DE INTEGRACIÓN PENDIENTE: el operador autenticado debe venir
  // de control_inicio_provider.dart una vez exista un identificador de
  // usuario real. Por ahora se usa un valor fijo documentado (§3.3.2).
  static const String _operadorActual = 'operador_demo';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estadoCaja = ref.watch(cajaProvider);
    final estadoClientes = ref.watch(clienteProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Préstamos y Abonos'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: estadoCaja.isCargando || estadoClientes.isCargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // §3.3.2: banner obligatorio "Caja Actual: $[Valor]".
                BannerCajaWidget(saldoActual: estadoCaja.saldoActual),
                const SizedBox(height: AppEspaciado.s),
                // Selector Préstamo / Abono.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.m,
                  ),
                  child: SegmentedButton<TipoCartera>(
                    segments: const [
                      ButtonSegment(
                        value: TipoCartera.prestamo,
                        label: Text('Préstamo'),
                        icon: Icon(Icons.account_balance_wallet),
                      ),
                      ButtonSegment(
                        value: TipoCartera.abono,
                        label: Text('Abono'),
                        icon: Icon(Icons.savings_outlined),
                      ),
                      ButtonSegment(
                        value: TipoCartera.saldoFavor,
                        label: Text('Ingreso'),
                        icon: Icon(Icons.attach_money),
                      ),
                    ],
                    selected: {_tipoSeleccionado},
                    onSelectionChanged: (seleccion) => setState(
                      () => _tipoSeleccionado = seleccion.first,
                    ),
                  ),
                ),
                const SizedBox(height: AppEspaciado.m),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppEspaciado.m,
                    ),
                    children: [
                      _buildSeccionClientes(theme),
                      const SizedBox(height: AppEspaciado.l),
                      _buildSeccionHistorial(theme, estadoCaja),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  TipoCartera _tipoSeleccionado = TipoCartera.prestamo;

  // ==========================================================================
  // SECCIÓN: BUSCADOR INTELIGENTE DE CLIENTES (§3.3.2)
  // ==========================================================================

  Widget _buildSeccionClientes(ThemeData theme) {
    final clientes = ref.watch(clienteProvider).clientes;

    // §3.3.2: préstamo solo clientes con crédito autorizado;
    // abono prioriza a deudores y clientes con anticipos; el ingreso
    // (saldo a favor) aplica a cualquier cliente activo.
    final elegibles = switch (_tipoSeleccionado) {
      TipoCartera.prestamo =>
        ref.read(clienteProvider.notifier).clientesParaPrestamo(),
      TipoCartera.abono =>
        ref.read(clienteProvider.notifier).clientesParaAbono(),
      TipoCartera.saldoFavor => ref
          .read(clienteProvider)
          .clientes
          .where((c) => c.activo)
          .toList(),
      // La aplicación de saldo a favor es solo por liquidación (§3.3.2).
      TipoCartera.aplicacionSaldoFavor => <ClienteModel>[],
    };

    final normalizada = _busquedaCliente.trim().toLowerCase();
    final filtrados = normalizada.isEmpty
        ? elegibles
        : elegibles
              .where(
                (c) =>
                    c.nombreCompleto.toLowerCase().contains(normalizada) ||
                    c.documento.contains(_busquedaCliente.trim()),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          switch (_tipoSeleccionado) {
            TipoCartera.prestamo => 'Cliente (crédito autorizado)',
            TipoCartera.abono => 'Cliente (deudor / con anticipos)',
            TipoCartera.saldoFavor => 'Cliente (recibir saldo a favor)',
            TipoCartera.aplicacionSaldoFavor => 'Cliente',
          },
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppEspaciado.s),
        TextField(
          onChanged: (v) => setState(() => _busquedaCliente = v),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o documento...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
            ),
            isDense: true,
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        if (filtrados.isEmpty)
          _buildSinClientes(theme)
        else
          ...filtrados.map(
            (c) => _ClienteCarteraCard(
              cliente: c,
              tipo: _tipoSeleccionado,
              saldoFavorDisponible: ref
                  .read(cajaProvider.notifier)
                  .saldoFavorDisponible(c.id),
              onSeleccionar: () => _abrirFormulario(context, cliente: c),
            ),
          ),
        if (clientes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppEspaciado.s),
            child: Text(
              'No hay clientes registrados todavía. Cree clientes desde '
              'el Módulo de Clientes.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  String _busquedaCliente = '';

  Widget _buildSinClientes(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppEspaciado.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              switch (_tipoSeleccionado) {
                TipoCartera.prestamo => 'No hay clientes con crédito autorizado.',
                TipoCartera.abono => 'No hay clientes con saldo pendiente.',
                TipoCartera.saldoFavor => 'No hay clientes activos.',
                TipoCartera.aplicacionSaldoFavor => 'No hay clientes.',
              },
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SECCIÓN: HISTORIAL DE CARTERA (§3.3.2)
  // ==========================================================================

  Widget _buildSeccionHistorial(ThemeData theme, CajaEstado estadoCaja) {
    final movimientos = estadoCaja.movimientosCarteraVisibles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de cartera',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppEspaciado.s),
        if (movimientos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppEspaciado.l),
            child: Center(
              child: Text(
                'Sin movimientos de cartera aún.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...movimientos.map(
            (mov) => _MovimientoCarteraTile(
              movimiento: mov,
              onEditar: () => _abrirFormularioEdicion(context, mov),
              onAnular: () => _anularMovimiento(context, mov),
              onCompartirPdf: () => _compartirPdf(context, mov),
              onImprimir: () => _imprimirTicket(context, mov),
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // FORMULARIO: REGISTRO DE PRÉSTAMO / ABONO
  // ==========================================================================

  void _abrirFormulario(BuildContext context, {required ClienteModel cliente}) {
    if (_tipoSeleccionado == TipoCartera.prestamo &&
        !cliente.creditoAutorizado) {
      Notificaciones.advertencia(
        context,
        'Este cliente no tiene crédito autorizado para préstamos.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppEspaciado.radioEstandar),
        ),
      ),
      builder: (context) => _CarteraFormSheet(
        cliente: cliente,
        tipo: _tipoSeleccionado,
        operador: _operadorActual,
      ),
    );
  }

  void _abrirFormularioEdicion(
    BuildContext context,
    MovimientoCartera movimiento,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppEspaciado.radioEstandar),
        ),
      ),
      builder: (context) => _CarteraFormSheet(
        cliente: null,
        movimientoAEditar: movimiento,
        operador: _operadorActual,
      ),
    );
  }

  // ==========================================================================
  // ACCIONES DEL MENÚ DE 3 PUNTOS
  // ==========================================================================

  Future<void> _anularMovimiento(
    BuildContext context,
    MovimientoCartera movimiento,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anular movimiento'),
        content: Text(
          '¿Confirma anular "${_tipoLabel(movimiento.tipo)}" de '
          '${movimiento.nombreCliente} por '
          '${CurrencyFormatter.formatValue(movimiento.monto)}? Esta acción '
          'requiere PIN de seguridad.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Anular'),
          ),
        ],
      ),
    );

    if (confirmado != true || !context.mounted) return;

    // §3.3.2/§8.4: validación obligatoria con PIN antes de anular.
    final pinValido = await showPinValidationDialog(
      context,
      onValidate: (pin) => _validarPin(context, pin),
    );

    if (!pinValido || !context.mounted) return;

    try {
      await ref
          .read(cajaProvider.notifier)
          .anularMovimientoCartera(
            carteraId: movimiento.id,
            operador: _operadorActual,
          );
      if (context.mounted) {
        Notificaciones.exito(context, 'Movimiento anulado correctamente.');
      }
    } on SaldoInsuficienteException {
      if (context.mounted) {
        Notificaciones.error(
          context,
          'No es posible anular: la Caja no tiene fondos suficientes para '
          'la reversión. Registre una Entrada manual primero.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        Notificaciones.error(context, 'No fue posible anular el movimiento.');
      }
    }
  }

  Future<void> _compartirPdf(BuildContext context, MovimientoCartera m) async {
    final config = ref.read(configuracionesProvider);
    final ok = await ref
        .read(cajaProvider.notifier)
        .compartirComprobantePdf(
          movimiento: m,
          encabezado: config.factura.aEncabezadoComprobante,
        );
    if (context.mounted && !ok) {
      Notificaciones.error(
        context,
        'No fue posible generar o compartir el PDF del comprobante.',
      );
    }
  }

  Future<void> _imprimirTicket(BuildContext context, MovimientoCartera m) async {
    final config = ref.read(configuracionesProvider);
    final ok = await ref
        .read(cajaProvider.notifier)
        .imprimirTicketTermico(
          movimiento: m,
          encabezado: config.factura.aEncabezadoComprobante,
          copias: config.impresora.copias,
          cortarPapel: config.impresora.cortarPapel,
        );
    if (context.mounted && !ok) {
      Notificaciones.error(
        context,
        'No se pudo imprimir. Verifica la conexión con la impresora.',
      );
    }
  }

String _tipoLabel(TipoCartera tipo) => switch (tipo) {
      TipoCartera.prestamo => 'préstamo',
      TipoCartera.abono => 'abono',
      TipoCartera.saldoFavor => 'ingreso',
      TipoCartera.aplicacionSaldoFavor => 'saldo a favor aplicado',
    };

  // §1.2 — valida contra el PIN registrado en el primer inicio.
  Future<bool> _validarPin(BuildContext context, String pin) async =>
      ref.read(controlInicioProvider.notifier).validarPinOperativo(pin);
}

// ============================================================================
// TARJETA DE CLIENTE ELEGIBLE
// ============================================================================

class _ClienteCarteraCard extends StatelessWidget {
  final ClienteModel cliente;
  final TipoCartera tipo;

  /// Saldo a favor disponible del cliente (cargado fuera para evitar
  /// dependencias circulares con la Caja).
  final double saldoFavorDisponible;
  final VoidCallback onSeleccionar;

  const _ClienteCarteraCard({
    required this.cliente,
    required this.tipo,
    required this.saldoFavorDisponible,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppEspaciado.s),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppPaletaOficial.cafe,
          child: Text(
            cliente.nombreCompleto.isNotEmpty
                ? cliente.nombreCompleto.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(color: AppPaletaOficial.blanco),
          ),
        ),
        title: Text(
          cliente.nombreCompleto,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doc: ${cliente.documento}'),
            switch (tipo) {
              TipoCartera.prestamo => Text(
                  'Cupo disponible: '
                  '${CurrencyFormatter.formatValue(cliente.cupoDisponible)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cliente.cupoDisponible <= 0
                        ? AppPaletaOficial.rojo
                        : AppPaletaOficial.verde,
                  ),
                ),
              TipoCartera.abono => Text(
                  'Saldo pendiente: '
                  '${CurrencyFormatter.formatValue(cliente.saldoDeuda)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppPaletaOficial.rojo,
                  ),
                ),
              TipoCartera.saldoFavor => Text(
                  'Saldo a favor disponible: '
                  '${CurrencyFormatter.formatValue(saldoFavorDisponible)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: saldoFavorDisponible > 0
                        ? AppPaletaOficial.verde
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              TipoCartera.aplicacionSaldoFavor => Text(
                  'Saldo deuda: '
                  '${CurrencyFormatter.formatValue(cliente.saldoDeuda)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppPaletaOficial.rojo,
                  ),
                ),
            },
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onSeleccionar,
      ),
    );
  }
}

// ============================================================================
// FILA DE MOVIMIENTO DE CARTERA
// ============================================================================

class _MovimientoCarteraTile extends StatelessWidget {
  final MovimientoCartera movimiento;
  final VoidCallback onEditar;
  final VoidCallback onAnular;
  final VoidCallback onCompartirPdf;
  final VoidCallback onImprimir;

  const _MovimientoCarteraTile({
    required this.movimiento,
    required this.onEditar,
    required this.onAnular,
    required this.onCompartirPdf,
    required this.onImprimir,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esEntrada = switch (movimiento.tipo) {
      TipoCartera.abono => true,
      TipoCartera.saldoFavor => true,
      TipoCartera.prestamo => false,
      TipoCartera.aplicacionSaldoFavor => false,
    };
    final color =
        esEntrada ? AppPaletaOficial.verde : AppPaletaOficial.rojo;
    final signo = esEntrada ? '+' : '-';
    final etiqueta = switch (movimiento.tipo) {
      TipoCartera.prestamo => 'Préstamo',
      TipoCartera.abono => 'Abono',
      TipoCartera.saldoFavor => 'Ingreso (saldo a favor)',
      TipoCartera.aplicacionSaldoFavor => 'Saldo a favor aplicado',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppEspaciado.s),
      child: ListTile(
        leading: Icon(
          esEntrada
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color: color,
        ),
        title: Text(
          '${movimiento.nombreCliente} — $etiqueta',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatearFechaHora(movimiento.fechaRegistro)),
            if (movimiento.distribucion != null &&
                movimiento.distribucion!.isNotEmpty)
              ...movimiento.distribucion!.map(
                (d) =>
                    Text('• ${d.concepto}: ${CurrencyFormatter.formatValue(d.monto)}'),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$signo ${CurrencyFormatter.formatValue(movimiento.monto)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            MenuTresPuntosWidget(
              onEditar: onEditar,
              onAnular: onAnular,
              onCompartirPdf: onCompartirPdf,
              onImprimir: onImprimir,
            ),
          ],
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

// ============================================================================
// FORMULARIO (BOTTOM SHEET) — Préstamo / Abono / Edición
// ============================================================================

class _CarteraFormSheet extends ConsumerStatefulWidget {
  final ClienteModel? cliente;
  final TipoCartera? tipo;
  final MovimientoCartera? movimientoAEditar;
  final String operador;

  const _CarteraFormSheet({
    this.cliente,
    this.tipo,
    this.movimientoAEditar,
    required this.operador,
  });

  @override
  ConsumerState<_CarteraFormSheet> createState() => _CarteraFormSheetState();
}

class _CarteraFormSheetState extends ConsumerState<_CarteraFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _conceptoController = TextEditingController();

  bool _guardando = false;

  bool get _esEdicion => widget.movimientoAEditar != null;
  bool get _esAbono => widget.tipo == TipoCartera.abono;
  bool get _esIngreso => widget.tipo == TipoCartera.saldoFavor;

  String get _tituloFormulario {
    if (_esEdicion) return 'Editar movimiento';
    return switch (widget.tipo) {
      TipoCartera.prestamo => 'Registrar préstamo',
      TipoCartera.abono => 'Registrar abono',
      TipoCartera.saldoFavor => 'Registrar ingreso (saldo a favor)',
      TipoCartera.aplicacionSaldoFavor => 'Aplicación de saldo a favor',
      null => 'Registrar movimiento',
    };
  }

  String get _tituloBoton {
    if (_esEdicion) return 'Guardar cambios';
    return switch (widget.tipo) {
      TipoCartera.prestamo => 'Registrar préstamo',
      TipoCartera.abono => 'Registrar abono',
      TipoCartera.saldoFavor => 'Registrar ingreso',
      TipoCartera.aplicacionSaldoFavor => 'Aplicar saldo a favor',
      null => 'Guardar',
    };
  }

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final m = widget.movimientoAEditar!;
      _montoController.text = m.monto.toStringAsFixed(0);
      _conceptoController.text = (_esAbono || _esIngreso)
          ? (_esAbono ? 'Abono a cartera' : 'Saldo a favor de cliente')
          : m.concepto;
    } else {
      _conceptoController.text = _esAbono
          ? 'Abono a cartera'
          : (_esIngreso ? 'Saldo a favor de cliente' : '');
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  ClienteModel? get _cliente {
    if (widget.cliente != null) return widget.cliente;
    if (_esEdicion) {
      return ref
          .read(clienteProvider.notifier)
          .buscarPorId(widget.movimientoAEditar!.clienteId);
    }
    return null;
  }

  // ==========================================================================
  // DISTRIBUCIÓN AUTOMÁTICA DE ABONOS (§3.3.2)
  // ==========================================================================

  List<AbonoDetalle> _distribuirAbono(ClienteModel cliente, double monto) {
    final tramos = <AbonoDetalle>[];
    var disponible = monto;

    // 1. Anticipos.
    final anticipos = cliente.tieneAnticipos ? cliente.saldoDeuda * 0.3 : 0.0;
    if (anticipos > 0 && disponible > 0) {
      final aplicar = anticipos < disponible ? anticipos : disponible;
      tramos.add(AbonoDetalle(concepto: 'Anticipo', monto: aplicar));
      disponible -= aplicar;
    }

    // 2. Préstamos.
    if (disponible > 0) {
      tramos.add(AbonoDetalle(concepto: 'Préstamo', monto: disponible));
    }

    // NOTA: Créditos POS (3) y Ventas Pendientes (4) solo se activan
    // cuando existan esos módulos; la caja absorbe el remanente en
    // préstamos hasta integrarlos (placeholder de la prioridad
    // completa §3.3.2).
    return tramos;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _guardando) return;

    final cliente = _cliente;
    if (cliente == null && !_esEdicion) {
      Notificaciones.error(context, 'Debe seleccionar un cliente.');
      return;
    }

    setState(() => _guardando = true);
    final monto = CurrencyFormatter.parseValue(_montoController.text);

    try {
      if (_esEdicion) {
        final m = widget.movimientoAEditar!;
        await ref
            .read(cajaProvider.notifier)
            .editarMovimientoCartera(
              carteraId: m.id,
              nuevoMonto: monto,
              nuevoConcepto: _conceptoController.text.trim(),
              operador: widget.operador,
            );
        // §3.3.2: editar exige PIN (validado en la pantalla antes).
      } else {
        if (_esAbono) {
          // Sin anticipos asumimos el tramo completo a préstamos.
          final distribucion = _distribuirAbono(cliente!, monto);
          await ref
              .read(cajaProvider.notifier)
              .registrarAbono(
                clienteId: cliente.id,
                nombreCliente: cliente.nombreCompleto,
                monto: monto,
                distribucion: distribucion,
                operador: widget.operador,
              );
        } else if (_esIngreso) {
          await ref
              .read(cajaProvider.notifier)
              .registrarIngresoCliente(
                clienteId: cliente!.id,
                nombreCliente: cliente.nombreCompleto,
                monto: monto,
                concepto: _conceptoController.text.trim(),
                operador: widget.operador,
              );
        } else {
          await ref
              .read(cajaProvider.notifier)
              .registrarPrestamo(
                clienteId: cliente!.id,
                nombreCliente: cliente.nombreCompleto,
                monto: monto,
                concepto: _conceptoController.text.trim(),
                cupoDisponible: cliente.cupoDisponible,
                operador: widget.operador,
              );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        Notificaciones.exito(
          context,
          _esEdicion
              ? 'Movimiento actualizado.'
              : (switch (widget.tipo) {
                  TipoCartera.prestamo => 'Préstamo registrado.',
                  TipoCartera.abono => 'Abono registrado y distribuido.',
                  TipoCartera.saldoFavor =>
                    'Ingreso registrado como saldo a favor.',
                  TipoCartera.aplicacionSaldoFavor =>
                    'Saldo a favor aplicado.',
                  null => 'Movimiento registrado.',
                }),
        );
      }
    } on CupoInsuficienteException catch (e) {
      if (mounted) {
        Notificaciones.error(
          context,
          'Cupo insuficiente: disponible '
          '${CurrencyFormatter.formatValue(e.cupoDisponible)}.',
        );
      }
    } on SaldoInsuficienteException catch (e) {
      if (mounted) {
        Notificaciones.error(
          context,
          'Fondos de Caja insuficientes: disponible '
          '${CurrencyFormatter.formatValue(e.saldoDisponible)}.',
        );
      }
    } on ValorInvalidoException catch (e) {
      if (mounted) Notificaciones.error(context, e.mensaje);
    } catch (_) {
      if (mounted) {
        Notificaciones.error(
          context,
          'No fue posible guardar el movimiento.',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cliente = _cliente;

    return Padding(
      padding: EdgeInsets.only(
        left: AppEspaciado.l,
        right: AppEspaciado.l,
        top: AppEspaciado.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppEspaciado.l,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _tituloFormulario,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: AppEscalaTipografica.subtitulo + 2,
                ),
              ),
              if (cliente != null) ...[
                const SizedBox(height: AppEspaciado.m),
                _InfoClienteChip(cliente: cliente),
              ],
              const SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [CurrencyFormatter()],
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
                validator: CurrencyFormatter.validar,
              ),
              const SizedBox(height: AppEspaciado.m),
              if (!_esAbono && !_esIngreso)
                TextFormField(
                  controller: _conceptoController,
                  enabled: !_guardando,
                  decoration: const InputDecoration(
                    labelText: 'Concepto / motivo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Campo obligatorio'
                          : null,
                ),
              if (_esIngreso)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _conceptoController,
                      enabled: !_guardando,
                      decoration: const InputDecoration(
                        labelText: 'Motivo del ingreso',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Campo obligatorio'
                              : null,
                    ),
                    const SizedBox(height: AppEspaciado.s),
                    Text(
                      'Este ingreso genera un saldo a favor del cliente que '
                      'se descontará automáticamente al liquidar sus ventas '
                      'pendientes (§3.3.2).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppEspaciado.l),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _tituloBoton,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoClienteChip extends StatelessWidget {
  final ClienteModel cliente;
  const _InfoClienteChip({required this.cliente});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppEspaciado.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: AppPaletaOficial.cafe),
          const SizedBox(width: AppEspaciado.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nombreCompleto,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Cupo disponible: '
                  '${CurrencyFormatter.formatValue(cliente.cupoDisponible)} · '
                  'Deuda: ${CurrencyFormatter.formatValue(cliente.saldoDeuda)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
