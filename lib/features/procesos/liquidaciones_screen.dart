// ==================== ARCHIVO: lib/features/procesos/liquidaciones_screen.dart ====================
// Liquidaciones — Informe Global §3.4.4. Se organiza en dos pestañas
// funcionales estrictas: "Pendientes de Liquidar" y "Liquidadas".
//  - Pendientes de Liquidar: compras y ventas pendientes de cierre
//    financiero. Permite liquidar según el precio del momento y
//    cancelar la transacción pendiente (con PIN).
//  - Liquidadas: historial consolidado de las transacciones ya
//    saldadas al 100%, con menú de tres puntos (Compartir / Imprimir /
//    Anular). En ambos flujos se muestra la ventana "Transacción
//    Exitosa" con Imprimir Recibo / Compartir PDF / Salir.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../../core/widgets/pin_entry_widget.dart';
import '../caja/caja_provider.dart';
import '../configuraciones/configuraciones_provider.dart';
import '../configuraciones/impresora_bluetooth_servicio.dart';
import '../inicio/control_inicio_provider.dart';
import 'procesos_provider.dart';

class LiquidacionesScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const LiquidacionesScreen({super.key, required this.onBack});

  @override
  ConsumerState<LiquidacionesScreen> createState() =>
      _LiquidacionesScreenState();
}

class _LiquidacionesScreenState extends ConsumerState<LiquidacionesScreen> {
  final _precioController = TextEditingController();
  int? _transaccionEnProceso;

  // §1.2 — valida contra el PIN registrado en el primer inicio
  // (mismo patrón de los demás módulos).
  Future<bool> _validarPin(String pin) async =>
      ref.read(controlInicioProvider.notifier).validarPinOperativo(pin);

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  void _alternarProceso(int transaccionId) {
    setState(() {
      if (_transaccionEnProceso == transaccionId) {
        _transaccionEnProceso = null;
        _precioController.clear();
      } else {
        _transaccionEnProceso = transaccionId;
        // §3.4.4 — precarga el precio de carga de la transacción para que
        // el operador solo confirme o ajuste, sin volver a escribirlo.
        _precioController.text = _precioCargaDe(transaccionId);
      }
    });
  }

  /// Precio de carga a precargar: el precio final registrado si existe
  /// (café seco/secado) o, si no, el precio de carga de referencia.
  String _precioCargaDe(int transaccionId) {
    final estado = ref.read(procesosProvider);
    for (final t in estado.liquidacionesPendientes) {
      if (t.id == transaccionId) {
        final precio = t.precioFinalCarga > 0
            ? t.precioFinalCarga
            : t.precioCarga;
        return CurrencyFormatter.formatCifraExacta(precio);
      }
    }
    return '';
  }

  // ==========================================================================
  // LIQUIDACIÓN DE UNA TRANSACCIÓN PENDIENTE (§3.4.4/§3.9.1)
  // ==========================================================================

  Future<void> _liquidar(TransaccionCafe transaccion) async {
    final texto = _precioController.text.trim();
    final precioFinal = CurrencyFormatter.parseValue(texto);
    if (texto.isEmpty || precioFinal < CurrencyFormatter.minimo) {
      Notificaciones.error(
        context,
        'Ingrese un precio final de carga válido (mínimo '
        '${CurrencyFormatter.formatValue(CurrencyFormatter.minimo)}).',
      );
      return;
    }

    double saldoNeto;
    try {
      saldoNeto = await ref
          .read(procesosProvider.notifier)
          .liquidarTransaccion(
            transaccionId: transaccion.id,
            precioFinalMomento: precioFinal,
          );
    } on SaldoInsuficienteException {
      if (!mounted) return;
      Notificaciones.error(
        context,
        'No fue posible liquidar: la Caja no tiene fondos suficientes para '
        'cubrir este egreso. Registre una Entrada manual primero.',
      );
      return;
    } on CajaNoAbiertaException {
      if (!mounted) return;
      Notificaciones.error(
        context,
        'Debe abrir la Caja antes de liquidar transacciones.',
      );
      return;
    }

    if (!mounted) return;
    _precioController.clear();
    setState(() => _transaccionEnProceso = null);
    final registro = _registroDe(transaccion.id);
    _mostrarExitoOperacion(
      titulo: transaccion.esCompra
          ? 'Liquidación de Compra'
          : 'Liquidación de Venta',
      lineas: _lineasLiquidacion(
        transaccion,
        precioFinal,
        saldoNeto,
        saldoFavorAplicado: registro?.saldoFavorAplicado ?? 0,
      ),
    );
  }

  // ==========================================================================
  // CANCELACIÓN DE TRANSACCIÓN PENDIENTE (§3.4.4)
  // ==========================================================================

  Future<void> _cancelarTransaccion(TransaccionCafe transaccion) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar transacción pendiente'),
        content: Text(
          '¿Confirma cancelar la ${transaccion.esCompra ? 'compra' : 'venta'} '
          'pendiente de ${transaccion.nombreCliente} por '
          '${CurrencyFormatter.formatValue(transaccion.valorTotal)}? '
          'Se reversará el anticipo en Caja y se ajustará la Bodega. '
          'Esta acción requiere PIN de seguridad.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final pinValido = await showPinValidationDialog(
      context,
      onValidate: _validarPin,
    );
    if (!pinValido || !mounted) return;

    try {
      await ref
          .read(procesosProvider.notifier)
          .cancelarTransaccionPendiente(transaccionId: transaccion.id);
    } on SaldoInsuficienteException {
      if (!mounted) return;
      Notificaciones.error(
        context,
        'No fue posible cancelar: la Caja no tiene fondos suficientes para '
        'la reversión. Registre una Entrada manual primero.',
      );
      return;
    } on CajaNoAbiertaException {
      if (!mounted) return;
      Notificaciones.error(
        context,
        'Debe abrir la Caja antes de cancelar transacciones.',
      );
      return;
    }

    if (!mounted) return;
    _mostrarExitoOperacion(
      titulo: 'Cancelación de Transacción',
      lineas: _lineasCancelacion(transaccion),
    );
  }

  // ==========================================================================
  // ANULACIÓN DE TRANSACCIÓN SALDADA (§3.4.4)
  // ==========================================================================

  Future<void> _anularTransaccion(TransaccionCafe transaccion) async {
    final registro = _registroDe(transaccion.id);
    final montoEnCaja = registro != null
        ? registro.saldoNetoPagado
        : transaccion.valorTotal;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anular transacción saldada'),
        content: Text(
          '¿Confirma anular la ${transaccion.esCompra ? 'compra' : 'venta'} '
          'de ${transaccion.nombreCliente} por '
          '${CurrencyFormatter.formatValue(montoEnCaja)}? '
          'Se reversará el valor en Caja y (si aplica) el café vuelve a '
          'Bodega. Esta acción requiere PIN de seguridad.',
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
    if (confirmado != true || !mounted) return;

    final pinValido = await showPinValidationDialog(
      context,
      onValidate: _validarPin,
    );
    if (!pinValido || !mounted) return;

    try {
      await ref
          .read(procesosProvider.notifier)
          .anularTransaccionLiquidada(transaccionId: transaccion.id);
    } on SaldoInsuficienteException {
      if (!mounted) return;
      Notificaciones.error(
        context,
        'No fue posible anular: la Caja no tiene fondos suficientes para '
        'la reversión. Registre una Entrada manual primero.',
      );
      return;
    } on CajaNoAbiertaException {
      if (!mounted) return;
      Notificaciones.error(
        context,
        'Debe abrir la Caja antes de anular transacciones.',
      );
      return;
    }

    if (!mounted) return;
    _mostrarExitoOperacion(
      titulo: 'Anulación de Transacción',
      lineas: _lineasAnulacion(transaccion, registro),
    );
  }

  // ==========================================================================
  // §3.4.4 — TRANSACCIÓN EXITOSA (Imprimir Recibo / Compartir PDF / Salir)
  // ==========================================================================

  Future<void> _mostrarExitoOperacion({
    required String titulo,
    required List<LineaComprobante> lineas,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppPaletaOficial.verde,
          size: 40,
        ),
        title: const Text('Transacción Exitosa'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final l in lineas)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: l.valor == null
                      ? Text(
                          l.etiqueta,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Text('${l.etiqueta}: ${l.valor ?? ''}'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _imprimirRecibo(titulo, lineas);
            },
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Imprimir Recibo'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _compartirRecibo(titulo, lineas);
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Compartir PDF'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  List<LineaComprobante> _lineasLiquidacion(
    TransaccionCafe t,
    double precioFinal,
    double saldoNeto, {
    double saldoFavorAplicado = 0,
  }) {
    // §3.4.4 — el anticipo se resta (o suma si hay devolución) sobre el
    // valor total de la liquidación; el recibo lo hace explícito.
    // §3.3.2 — si se aplicó saldo a favor del cliente, ese tramo se
    // muestra aparte y el efectivo final llega reducido.
    final valorTotal = t.pesoNeto * (precioFinal / 125);
    final esCompra = t.esCompra;
    final efectivoFinal = saldoNeto - saldoFavorAplicado;
    final etiquetaFinal = saldoNeto >= 0
        ? (esCompra ? 'Valor cancelado' : 'Valor recibido')
        : 'Devolución';
    final etiquetaAnticipo =
        esCompra ? 'Anticipo entregado' : 'Anticipo recibido';
    return [
      const LineaComprobante.texto('RECIBO DE LIQUIDACIÓN'),
      LineaComprobante.campo('Cliente', t.nombreCliente),
      LineaComprobante.campo(
        'Operación',
        esCompra ? 'Compra de café' : 'Venta de café',
      ),
      LineaComprobante.campo('Tipo de café', t.tipoCafe.etiqueta),
      LineaComprobante.campo('Peso neto', '${t.pesoNeto.toStringAsFixed(1)} kg'),
      LineaComprobante.campo(
        'Precio de carga final',
        CurrencyFormatter.formatValue(precioFinal),
      ),
      LineaComprobante.campo(
        'Valor total',
        CurrencyFormatter.formatValue(valorTotal),
      ),
      LineaComprobante.campo(
        etiquetaAnticipo,
        CurrencyFormatter.formatValue(t.anticipo),
        enNegrita: true,
      ),
      if (saldoFavorAplicado > 0) ...[
        const LineaComprobante.separador(),
        LineaComprobante.campo(
          'Saldo a favor aplicado',
          CurrencyFormatter.formatValue(saldoFavorAplicado),
        ),
        LineaComprobante.campo(
          'Efectivo recibido',
          CurrencyFormatter.formatValue(efectivoFinal),
          enNegrita: true,
        ),
      ] else
        LineaComprobante.campo(
          etiquetaFinal,
          CurrencyFormatter.formatValue(saldoNeto.abs()),
          enNegrita: true,
        ),
    ];
  }

  /// §3.4.4 — registro de liquidación VALIDADA de una transacción, si existe.
  LiquidacionRegistro? _registroDe(int transaccionId) {
    final estado = ref.read(procesosProvider);
    return estado.liquidacionesRegistradas.cast<LiquidacionRegistro?>().firstWhere(
          (l) => l!.transaccionId == transaccionId,
          orElse: () => null,
        );
  }

  /// §3.4.4 — líneas del recibo de una transacción saldada del historial
  /// (pestaña Liquidadas) para re-impresión o compartición.
  List<LineaComprobante> _lineasLiquidacionHistorial(
    TransaccionCafe t,
    LiquidacionRegistro? reg,
  ) {
    final montoEnCaja = reg?.saldoNetoPagado ?? t.valorTotal;
    final saldoFavorAplicado = reg?.saldoFavorAplicado ?? 0;
    return [
      const LineaComprobante.texto('RECIBO DE TRANSACCIÓN SALDADA'),
      LineaComprobante.campo('Cliente', t.nombreCliente),
      LineaComprobante.campo(
        'Operación',
        t.esCompra ? 'Compra de café' : 'Venta de café',
      ),
      LineaComprobante.campo('Tipo de café', t.tipoCafe.etiqueta),
      LineaComprobante.campo('Peso neto', '${t.pesoNeto.toStringAsFixed(1)} kg'),
      LineaComprobante.campo(
        'Total transacción',
        CurrencyFormatter.formatValue(t.valorTotal),
      ),
      LineaComprobante.campo(
        'Anticipos previos',
        CurrencyFormatter.formatValue(t.anticipo),
      ),
      if (saldoFavorAplicado > 0)
        LineaComprobante.campo(
          'Saldo a favor aplicado',
          CurrencyFormatter.formatValue(saldoFavorAplicado),
        ),
      LineaComprobante.campo(
        montoEnCaja >= 0
            ? (t.esCompra ? 'Valor cancelado' : 'Valor recibido')
            : 'Devolución',
        CurrencyFormatter.formatValue(montoEnCaja.abs()),
        enNegrita: true,
      ),
    ];
  }

  List<LineaComprobante> _lineasCancelacion(TransaccionCafe t) {
    return [
      const LineaComprobante.texto('CANCELACIÓN DE TRANSACCIÓN'),
      LineaComprobante.campo('Cliente', t.nombreCliente),
      LineaComprobante.campo(
        'Operación',
        t.esCompra ? 'Compra de café' : 'Venta de café',
      ),
      LineaComprobante.campo('Tipo de café', t.tipoCafe.etiqueta),
      LineaComprobante.campo('Peso neto', '${t.pesoNeto.toStringAsFixed(1)} kg'),
      LineaComprobante.campo(
        'Anticipo devuelto',
        CurrencyFormatter.formatValue(t.anticipo),
        enNegrita: true,
      ),
    ];
  }

  List<LineaComprobante> _lineasAnulacion(
    TransaccionCafe t,
    LiquidacionRegistro? reg,
  ) {
    final montoReversado = reg?.saldoNetoPagado ?? t.valorTotal;
    return [
      const LineaComprobante.texto('ANULACIÓN DE TRANSACCIÓN SALDADA'),
      LineaComprobante.campo('Cliente', t.nombreCliente),
      LineaComprobante.campo(
        'Operación',
        t.esCompra ? 'Compra de café' : 'Venta de café',
      ),
      LineaComprobante.campo('Tipo de café', t.tipoCafe.etiqueta),
      LineaComprobante.campo('Peso neto', '${t.pesoNeto.toStringAsFixed(1)} kg'),
      LineaComprobante.campo(
        'Monto reversado',
        CurrencyFormatter.formatValue(montoReversado.abs()),
        enNegrita: true,
      ),
    ];
  }

  Future<void> _compartirRecibo(
    String titulo,
    List<LineaComprobante> lineas,
  ) async {
    final config = ref.read(configuracionesProvider);
    final ok = await ComprobanteServicio.instancia.compartirPdf(
      encabezado: config.factura.aEncabezadoComprobante,
      titulo: titulo,
      lineas: lineas,
    );
    if (!mounted) return;
    if (!ok) {
      Notificaciones.error(
        context,
        'No fue posible generar o compartir el PDF del comprobante.',
      );
    }
  }

  Future<void> _imprimirRecibo(
    String titulo,
    List<LineaComprobante> lineas,
  ) async {
    final config = ref.read(configuracionesProvider);
    final datos = TicketEscPosBuilder.construir(
      titulo: titulo,
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
      if (!mounted) return;
      Notificaciones.error(
        context,
        'No se pudo imprimir. Verifica la conexión con la impresora.',
      );
    }
  }

  // ==========================================================================
  // VISTA PRINCIPAL — DOS PESTAÑAS (§3.4.4)
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Liquidaciones'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendientes de Liquidar'),
              Tab(text: 'Liquidadas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPendientesTab(),
            _buildLiquidadasTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendientesTab() {
    final estado = ref.watch(procesosProvider);
    final pendientes = estado.liquidacionesPendientes;
    final saldoTotal = pendientes.fold<double>(
      0,
      (s, t) => s + t.saldoPendiente,
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppPaletaOficial.cafe,
          padding: const EdgeInsets.all(AppEspaciado.m),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: AppPaletaOficial.blanco),
              const SizedBox(width: AppEspaciado.s),
              Expanded(
                child: Text(
                  'Pendientes de Liquidar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPaletaOficial.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                CurrencyFormatter.formatValue(saldoTotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppPaletaOficial.blanco,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pendientes.isEmpty
              ? const _SinLista(
                  icono: Icons.receipt_long_outlined,
                  mensaje: 'No hay liquidaciones pendientes',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppEspaciado.m),
                  itemCount: pendientes.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppEspaciado.s),
                  itemBuilder: (context, index) {
                    final transaccion = pendientes[index];
                    return _PendienteCard(
                      transaccion: transaccion,
                      enProceso: _transaccionEnProceso == transaccion.id,
                      precioController: _precioController,
                      onLiquidar: () => _liquidar(transaccion),
                      onToggle: () => _alternarProceso(transaccion.id),
                      onCancelar: () => _cancelarTransaccion(transaccion),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLiquidadasTab() {
    final estado = ref.watch(procesosProvider);
    final liquidadas = estado.liquidacionesLiquidadas;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppPaletaOficial.verde,
          padding: const EdgeInsets.all(AppEspaciado.m),
          child: Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                color: AppPaletaOficial.blanco,
              ),
              const SizedBox(width: AppEspaciado.s),
              Expanded(
                child: Text(
                  'Liquidadas (${liquidadas.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPaletaOficial.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: liquidadas.isEmpty
              ? const _SinLista(
                  icono: Icons.verified_outlined,
                  mensaje: 'No hay transacciones liquidadas',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppEspaciado.m),
                  itemCount: liquidadas.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppEspaciado.s),
                  itemBuilder: (context, index) {
                    final transaccion = liquidadas[index];
                    final registro = _registroDe(transaccion.id);
                    return _LiquidadaCard(
                      transaccion: transaccion,
                      registro: registro,
                      onCompartir: () => _compartirRecibo(
                        'TRANSACCIÓN SALDADA',
                        _lineasLiquidacionHistorial(transaccion, registro),
                      ),
                      onImprimir: () => _imprimirRecibo(
                        'TRANSACCIÓN SALDADA',
                        _lineasLiquidacionHistorial(transaccion, registro),
                      ),
                      onAnular: () => _anularTransaccion(transaccion),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SinLista extends StatelessWidget {
  final IconData icono;
  final String mensaje;

  const _SinLista({required this.icono, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 56, color: const Color(0xFFB0ACA7)),
          const SizedBox(height: AppEspaciado.m),
          Text(
            mensaje,
            style: const TextStyle(fontSize: AppEscalaTipografica.cuerpo),
          ),
        ],
      ),
    );
  }
}

class _PendienteCard extends StatelessWidget {
  final TransaccionCafe transaccion;
  final bool enProceso;
  final TextEditingController precioController;
  final VoidCallback onLiquidar;
  final VoidCallback onToggle;
  final VoidCallback onCancelar;

  const _PendienteCard({
    required this.transaccion,
    required this.enProceso,
    required this.precioController,
    required this.onLiquidar,
    required this.onToggle,
    required this.onCancelar,
  });

  /// §3.4.4: una transacción sin cliente asignado no se puede liquidar.
  bool get _hayCliente {
    final nombre = transaccion.nombreCliente.trim();
    return nombre.isNotEmpty && nombre != 'Sin cliente';
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
                    transaccion.nombreCliente,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.subtitulo,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.s,
                    vertical: AppEspaciado.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppPaletaOficial.amarillo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      AppEspaciado.radioEstandar,
                    ),
                  ),
                  child: const Text(
                    'Pendiente',
                    style: TextStyle(
                      color: AppPaletaOficial.amarillo,
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.notas,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              '${transaccion.esCompra ? 'Compra' : 'Venta'} · '
              '${transaccion.tipoCafe.etiqueta} · '
              '${_formatearPeso(transaccion.pesoNeto)} kg',
              style: const TextStyle(fontSize: AppEscalaTipografica.cuerpo),
            ),
            const SizedBox(height: AppEspaciado.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Anticipo: '
                    '${CurrencyFormatter.formatValue(transaccion.anticipo)}',
                    style: const TextStyle(
                      fontSize: AppEscalaTipografica.notas,
                      color: Color(0xFF8D8D8D),
                    ),
                  ),
                ),
                Text(
                  'Saldo: '
                  '${CurrencyFormatter.formatValue(transaccion.saldoPendiente)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.cuerpo,
                    color: AppPaletaOficial.cafe,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.m),
            if (!enProceso)
              _hayCliente
                  ? Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onToggle,
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text('Liquidar'),
                          ),
                        ),
                        const SizedBox(width: AppEspaciado.s),
                        IconButton.outlined(
                          tooltip: 'Cancelar transacción pendiente',
                          onPressed: onCancelar,
                          icon: const Icon(Icons.cancel_outlined),
                          color: AppPaletaOficial.negro,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppEspaciado.m,
                              vertical: AppEspaciado.s,
                            ),
                            decoration: BoxDecoration(
                              color: AppPaletaOficial.rojo
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppEspaciado.radioEstandar,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 18,
                                  color: AppPaletaOficial.rojo,
                                ),
                                SizedBox(width: AppEspaciado.s),
                                Expanded(
                                  child: Text(
                                    'No se puede liquidar sin un cliente '
                                    'asignado',
                                    style: TextStyle(
                                      color: AppPaletaOficial.rojo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppEscalaTipografica.notas,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppEspaciado.s),
                        IconButton.outlined(
                          tooltip: 'Cancelar transacción pendiente',
                          onPressed: onCancelar,
                          icon: const Icon(Icons.cancel_outlined),
                          color: AppPaletaOficial.negro,
                        ),
                      ],
                    )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: precioController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Precio final de carga',
                      border: OutlineInputBorder(),
                      hintText: '0',
                    ),
                  ),
                  const SizedBox(height: AppEspaciado.m),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onToggle,
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: AppEspaciado.s),
                      Expanded(
                        child: FilledButton(
                          onPressed: onLiquidar,
                          child: const Text('Confirmar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _formatearPeso(double peso) {
    return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 1);
  }
}

class _LiquidadaCard extends StatelessWidget {
  final TransaccionCafe transaccion;
  final LiquidacionRegistro? registro;
  final VoidCallback onCompartir;
  final VoidCallback onImprimir;
  final VoidCallback onAnular;

  const _LiquidadaCard({
    required this.transaccion,
    required this.registro,
    required this.onCompartir,
    required this.onImprimir,
    required this.onAnular,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaccion;
    final montoEnCaja = registro?.saldoNetoPagado ?? t.valorTotal;
    final fecha = registro?.fechaLiquidacion ?? t.fechaRegistro;
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
                    t.nombreCliente,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.subtitulo,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.s,
                    vertical: AppEspaciado.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppPaletaOficial.verde.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      AppEspaciado.radioEstandar,
                    ),
                  ),
                  child: const Text(
                    'Liquidada',
                    style: TextStyle(
                      color: AppPaletaOficial.verde,
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.notas,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              '${t.esCompra ? 'Compra' : 'Venta'} · '
              '${t.tipoCafe.etiqueta} · '
              '${_formatearPeso(t.pesoNeto)} kg',
              style: const TextStyle(fontSize: AppEscalaTipografica.cuerpo),
            ),
            const SizedBox(height: AppEspaciado.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Anticipos: '
                    '${CurrencyFormatter.formatValue(t.anticipo)}',
                    style: const TextStyle(
                      fontSize: AppEscalaTipografica.notas,
                      color: Color(0xFF8D8D8D),
                    ),
                  ),
                ),
                Text(
                  'Saldo en Caja: '
                  '${CurrencyFormatter.formatValue(montoEnCaja)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.cuerpo,
                    color: AppPaletaOficial.cafe,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.xs),
            Text(
              'Saldada: ${_formatearFechaHora(fecha)}',
              style: const TextStyle(
                color: Color(0xFF8D8D8D),
                fontSize: AppEscalaTipografica.notas,
              ),
            ),
            const SizedBox(height: AppEspaciado.s),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                tooltip: 'Opciones de la liquidación',
                onSelected: (v) {
                  switch (v) {
                    case 'compartir':
                      onCompartir();
                    case 'imprimir':
                      onImprimir();
                    case 'anular':
                      onAnular();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'compartir',
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf_outlined),
                      title: Text('Compartir PDF'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'imprimir',
                    child: ListTile(
                      leading: Icon(Icons.print_outlined),
                      title: Text('Imprimir'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'anular',
                    child: ListTile(
                      leading: Icon(Icons.cancel_outlined),
                      title: Text('Cancelar/Anular'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatearPeso(double peso) {
    return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 1);
  }

  static String _formatearFechaHora(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} $hora:$minuto';
  }
}