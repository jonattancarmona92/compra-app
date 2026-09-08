// ==================== ARCHIVO: lib/features/caja/cierres_screen.dart ====================
// Cierres — Informe Global §3.3.4. Pantalla unificada con dos botones
// superiores ("Cierre de Caja" y "Cierre de Ciclo Operativo").
//
// "Cierre de Caja": corte financiero del día (resumen, efectivo
// contado, diferencia).
//
// "Cierre de Ciclo Operativo" (§3.3.4 opción 2, §8.2, §6.6.9):
// transacción atómica que cierra la Caja automáticamente, nivela la
// bodega a las existencias físicas confirmadas, lotea los remanentes
// en lotes constituidos (prefijos moj-/ore-/sec-/pas-/pro-), cierra el
// Ciclo Operativo actual y abre el siguiente en silencio, redirigiendo
// a la Apertura de Caja. Queda absolutamente bloqueado si existen
// compras pendientes de liquidación (las ventas pendientes se
// conservan).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../../core/widgets/pin_entry_widget.dart';
import '../configuraciones/configuraciones_provider.dart';
import '../configuraciones/impresora_bluetooth_servicio.dart';
import '../inicio/control_inicio_provider.dart';
import '../procesos/procesos_provider.dart';
import 'caja_provider.dart';
import 'widgets/banner_caja_widget.dart';

class CierresScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const CierresScreen({super.key, required this.onBack});

  @override
  ConsumerState<CierresScreen> createState() => _CierresScreenState();
}

class _CierresScreenState extends ConsumerState<CierresScreen> {
  // NOTA DE INTEGRACIÓN PENDIENTE: el operador autenticado debe venir
  // de control_inicio_provider.dart una vez exista un identificador de
  // usuario real. Por ahora se usa un valor fijo documentado.
  static const String _operadorActual = 'operador_demo';

  // Pestaña superior: 0 = Cierre de Caja, 1 = Cierre de Ciclo Operativo.
  int _tab = 0;

  // ----- Estado del Cierre de Caja -----
  final TextEditingController _efectivoContadoController =
      TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  double? _efectivoContado;
  bool _cerrandoCaja = false;

  // ----- Estado del Cierre de Ciclo Operativo -----
  final Map<TipoCafeProceso, TextEditingController> _existenciasControllers =
      {
    for (final tipo in TipoCafeProceso.values)
      tipo: TextEditingController(text: '0'),
  };

  bool _cerrandoCiclo = false;
  bool _cicloCerrado = false;

  @override
  void initState() {
    super.initState();
    _sincronizarExistenciasIniciales();
  }

  /// §8.2 — precarga la existencia física confirmada con la registrada
  /// en la bodega común, para que el operador solo ajuste desviaciones.
  void _sincronizarExistenciasIniciales() {
    final estado = ref.read(procesosProvider);
    for (final tipo in TipoCafeProceso.values) {
      final registrado = estado.stockDisponibleDe(tipo);
      _existenciasControllers[tipo]!.text =
          registrado == registrado.roundToDouble()
              ? registrado.toStringAsFixed(0)
              : registrado.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _efectivoContadoController.dispose();
    _observacionesController.dispose();
    for (final controller in _existenciasControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatearCantidad(double valor) {
    return valor.toStringAsFixed(valor == valor.roundToDouble() ? 0 : 1);
  }

  String _formatearFecha(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '${fecha.day}/${fecha.month}/${fecha.year} $h:$m';
  }

  // ==========================================================================
  // PIN DE SEGURIDAD
  // ==========================================================================

  // §1.2 — valida contra el PIN registrado en el primer inicio.
  Future<bool> _validarPin(String pin) async =>
      ref.read(controlInicioProvider.notifier).validarPinOperativo(pin);

  // ==========================================================================
  // CIERRE DE CAJA (§3.3.4) — CÁLCULO DE LA DIFERENCIA
  // ==========================================================================

  double? get _diferencia {
    final efectivo = _efectivoContado;
    if (efectivo == null) return null;
    final estado = ref.read(cajaProvider);
    return efectivo - estado.saldoActual;
  }

  (String, Color, String) _getDiferenciaInfo() {
    final diferencia = _diferencia;
    if (diferencia == null) {
      return ('--', AppPaletaOficial.cafe, 'Faltante por contabilizar');
    }
    if (diferencia > 0) {
      return (
        'Favorable',
        AppPaletaOficial.verde,
        'El efectivo contado supera el saldo teórico',
      );
    } else if (diferencia < 0) {
      return (
        'Desfavorable',
        AppPaletaOficial.rojo,
        'El efectivo contado es menor al saldo teórico',
      );
    }
    return (
      'Sin diferencia',
      AppPaletaOficial.cafe,
      'El efectivo contado cuadra con el saldo teórico',
    );
  }

  void _calcularDiferencia() {
    final texto = _efectivoContadoController.text;
    final valor = CurrencyFormatter.parseValue(texto);
    setState(() {
      _efectivoContado = texto.isEmpty ? null : valor;
    });
  }

  Future<void> _confirmarCierre() async {
    final estado = ref.read(cajaProvider);

    if (_efectivoContado == null) {
      Notificaciones.advertencia(
        context,
        'Registre el efectivo contado antes de cerrar la Caja.',
      );
      return;
    }

    if (_efectivoContado! > 0 && _efectivoContado! < CurrencyFormatter.minimo) {
      Notificaciones.advertencia(
        context,
        'El efectivo contado debe ser al menos '
        '${CurrencyFormatter.formatValue(CurrencyFormatter.minimo)}.',
      );
      return;
    }

    final (textoDiferencia, colorDiferencia, _) = _getDiferenciaInfo();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cierre de Caja'),
        content: Text(
          'Saldo teórico final: '
          '${CurrencyFormatter.formatValue(estado.saldoActual)}\n'
          'Efectivo contado: '
          '${CurrencyFormatter.formatValue(_efectivoContado!)}\n'
          'Diferencia: ${CurrencyFormatter.formatValue(_diferencia ?? 0)} '
          '($textoDiferencia)\n\n'
          'Esta acción requiere PIN de seguridad.',
          style: const TextStyle(color: AppPaletaOficial.negro),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Caja'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;
    if (!mounted) return;

    // §3.3.4/§8.4: validación obligatoria con PIN antes de cerrar.
    final pinValido = await showPinValidationDialog(
      context,
      onValidate: (pin) => _validarPin(pin),
    );

    if (!pinValido) return;
    if (!mounted) return;

    setState(() => _cerrandoCaja = true);

    try {
      await ref
          .read(cajaProvider.notifier)
          .cerrarCaja(operador: _operadorActual);
      if (mounted) {
        Notificaciones.exito(context, 'Caja cerrada correctamente.');
      }
    } on CajaNoAbiertaException {
      if (mounted) {
        Notificaciones.error(context, 'La Caja ya se encuentra cerrada.');
      }
    } catch (_) {
      if (mounted) {
        Notificaciones.error(context, 'No fue posible cerrar la Caja.');
      }
    } finally {
      if (mounted) setState(() => _cerrandoCaja = false);
    }
  }

  // ==========================================================================
  // CIERRE DE CICLO OPERATIVO (§3.3.4 opción 2 / §8.2 / §6.6.9)
  // ==========================================================================

  /// Bloqueo absoluto §6.6.9: con compras pendientes no se cierra.
  Future<void> _mostrarBloqueoCierre(int cantidad) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cierre bloqueado'),
        icon: const Icon(
          Icons.lock_outline,
          color: AppPaletaOficial.rojo,
        ),
        content: Text(
          'Hay $cantidad compra(s) de café con saldo pendiente de '
          'liquidación. El Ciclo Operativo no puede cerrarse hasta '
          'liquidar todas las compras.\n\n'
          'Las ventas pendientes no bloquean el cierre: se conservan '
          'para el siguiente Ciclo Operativo.',
          style: const TextStyle(color: AppPaletaOficial.negro),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// §8.2 — recoge las existencias físicas confirmadas (entre 0 y el
  /// registrado en la bodega común) por tipo de café.
  bool _recogerExistenciasNiveladas(
    ProcesosEstado estado,
    Map<TipoCafeProceso, double> result,
  ) {
    for (final tipo in TipoCafeProceso.values) {
      final texto = _existenciasControllers[tipo]!.text.trim();
      if (texto.isEmpty) {
        Notificaciones.advertencia(
          context,
          'Confirme las existencias físicas de ${tipo.etiqueta}.',
        );
        return false;
      }
      final valor = double.tryParse(texto);
      if (valor == null || valor < 0) {
        Notificaciones.advertencia(
          context,
          'La existencia física de ${tipo.etiqueta} no es válida.',
        );
        return false;
      }
      final registrado = estado.stockDisponibleDe(tipo);
      if (valor > registrado) {
        Notificaciones.advertencia(
          context,
          'La existencia física confirmada de ${tipo.etiqueta} '
          '(${_formatearCantidad(valor)} kg) no puede superar la '
          'registrada (${_formatearCantidad(registrado)} kg).',
        );
        return false;
      }
      result[tipo] = valor;
    }
    return true;
  }

  Future<void> _confirmarCicloOperativo() async {
    final estadoProcesos = ref.read(procesosProvider);
    final estadoCaja = ref.read(cajaProvider);

    // 1) Bloqueo absoluto: compras pendientes de liquidar (§6.6.9).
    final comprasPendientes = estadoProcesos.comprasPendientes;
    if (comprasPendientes.isNotEmpty) {
      await _mostrarBloqueoCierre(comprasPendientes.length);
      return;
    }

    // 2) Nivelación de bodega: existencias físicas confirmadas.
    final existencias = <TipoCafeProceso, double>{};
    if (!_recogerExistenciasNiveladas(estadoProcesos, existencias)) {
      return;
    }

    final ventasPendientes = estadoProcesos.ventasPendientes;
    final totalRemanente = estadoProcesos.totalBodegaComun;

    final pasos = StringBuffer();
    pasos.write('1. Cierre automático de la Caja actual.\n');
    pasos.write(
      '2. Nivelación de bodega a las existencias físicas confirmadas '
      '(${_formatearCantidad(totalRemanente)} kg de remanente en la '
      'bodega común).\n',
    );
    pasos.write(
      '3. Loteado de Remanentes: el café residual se convierte en '
      'lotes constituidos (estado Listo) para el siguiente ciclo.\n',
    );
    pasos.write(
      '4. Cierre del Ciclo Operativo actual y apertura del siguiente '
      'de forma inmediata.\n',
    );

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cierre de Ciclo Operativo'),
        content: Text(
          'Esta transacción atómica ejecutará en orden:\n\n$pasos'
          '${ventasPendientes.isEmpty ? '' : '\n'
              '${ventasPendientes.length} venta(s) pendientes se '
              'conservarán en el nuevo ciclo.\n'}\n'
          'Esta acción requiere PIN de seguridad.',
          style: const TextStyle(color: AppPaletaOficial.negro),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Ciclo'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;
    if (!mounted) return;

    // §3.3.4/§8.4: validación obligatoria con PIN.
    final pinValido = await showPinValidationDialog(
      context,
      onValidate: (pin) => _validarPin(pin),
    );

    if (!pinValido) return;
    if (!mounted) return;

    final saldoTeorico = estadoCaja.saldoActual;
    final fechaCierre = DateTime.now();

    setState(() => _cerrandoCiclo = true);

    try {
      // a) Nivelación + Loteado de Remanentes (§6.6.9).
      final lotesConstituidos = ref
          .read(procesosProvider.notifier)
          .lotearRemanentes(existencias);

      // b) Cierre automático de la última Caja (§3.3.4).
      try {
        await ref
            .read(cajaProvider.notifier)
            .cerrarCaja(operador: _operadorActual);
      } on CajaNoAbiertaException {
        // La última Caja ya estaba cerrada; el cierre de ciclo sigue.
      }

      // c) Nuevo Ciclo Operativo ACTIVO en silencio + reflejo en UI.
      ref.read(controlInicioProvider.notifier).cerrarCaja();
      ref.read(controlInicioProvider.notifier).crearPeriodoOperativoSilencioso();

      if (mounted) {
        setState(() => _cicloCerrado = true);
        await _mostrarExitoCiclo(
          lotesConstituidos: lotesConstituidos,
          saldoTeorico: saldoTeorico,
          fechaCierre: fechaCierre,
        );
      }
    } catch (_) {
      if (mounted) {
        Notificaciones.error(
          context,
          'No fue posible cerrar el Ciclo Operativo.',
        );
      }
    } finally {
      if (mounted) setState(() => _cerrandoCiclo = false);
    }
  }

  Future<void> _mostrarExitoCiclo({
    required List<LoteBodega> lotesConstituidos,
    required double saldoTeorico,
    required DateTime fechaCierre,
  }) async {
    final resumen = ref
        .read(procesosProvider)
        .resumenPorTipoDeCafe
        .where((r) => r.kilosCompra > 0 || r.kilosVenta > 0)
        .toList();

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
              const Text(
                'Cierre de Ciclo Operativo completado. El siguiente '
                'Ciclo Operativo quedó abierto en silencio.',
              ),
              const Divider(height: AppEspaciado.l),
              _FilaReporte(
                label: 'Fecha de cierre',
                valor: _formatearFecha(fechaCierre),
              ),
              _FilaReporte(
                label: 'Saldo teórico final de Caja',
                valor: CurrencyFormatter.formatValue(saldoTeorico),
              ),
              const SizedBox(height: AppEspaciado.m),
              Text(
                'Cafés del ciclo por tipo',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (resumen.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppEspaciado.s),
                  child: Text('Sin movimientos de café en el ciclo.'),
                )
              else
                for (final r in resumen)
                  _FilaReporte(
                    label: r.tipo.etiqueta,
                    valor:
                        'Compra: ${_formatearCantidad(r.kilosCompra)} kg '
                        '(${CurrencyFormatter.formatValue(r.valorCompra)}) · '
                        'Venta: ${_formatearCantidad(r.kilosVenta)} kg '
                        '(${CurrencyFormatter.formatValue(r.valorVenta)})',
                    justColor: false,
                  ),
              const SizedBox(height: AppEspaciado.m),
              Text(
                'Remanente loteado',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (lotesConstituidos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppEspaciado.s),
                  child: Text('No quedó remanente en la bodega común.'),
                )
              else
                for (final lote in lotesConstituidos)
                  _FilaReporte(
                    label: lote.codigoLote ?? 'Lote #${lote.id}',
                    valor:
                        '${lote.tipoCafe.etiqueta} · '
                        '${_formatearCantidad(lote.pesoNeto)} kg',
                    justColor: false,
                  ),
              const SizedBox(height: AppEspaciado.m),
              const Text(
                'Caja cerrada automáticamente. Se abrirá la Apertura '
                'de Caja para la nueva jornada.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _imprimirReporteCierre(
                resumen: resumen,
                lotesConstituidos: lotesConstituidos,
                saldoTeorico: saldoTeorico,
                fechaCierre: fechaCierre,
              );
            },
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Imprimir Ticket'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _compartirReporteCierre(
                resumen: resumen,
                lotesConstituidos: lotesConstituidos,
                saldoTeorico: saldoTeorico,
                fechaCierre: fechaCierre,
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Compartir PDF'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onBack();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // REPORTES DE CIERRE
  // ==========================================================================

  /// §3.3.4/§8.3: construye las líneas del reporte de cierre de ciclo.
  List<LineaComprobante> _lineasReporteCierre({
    required List<dynamic> resumen,
    required List<LoteBodega> lotesConstituidos,
    required double saldoTeorico,
    required DateTime fechaCierre,
  }) {
    final lineas = <LineaComprobante>[
      LineaComprobante.texto('CIERRE DE CICLO OPERATIVO'),
      LineaComprobante.campo(
        'Fecha de cierre',
        _formatearFecha(fechaCierre),
      ),
      LineaComprobante.campo(
        'Saldo teórico final',
        CurrencyFormatter.formatValue(saldoTeorico),
        enNegrita: true,
      ),
      const LineaComprobante.separador(),
      const LineaComprobante.texto('Cafés del ciclo por tipo'),
    ];
    if (resumen.isEmpty) {
      lineas.add(const LineaComprobante.texto('Sin movimientos de café.'));
    } else {
      for (final r in resumen) {
        lineas.add(
          LineaComprobante.campo(
            r.tipo.etiqueta,
            'Compra: ${_formatearCantidad(r.kilosCompra)} kg '
            '(${CurrencyFormatter.formatValue(r.valorCompra)}) · '
            'Venta: ${_formatearCantidad(r.kilosVenta)} kg '
            '(${CurrencyFormatter.formatValue(r.valorVenta)})',
          ),
        );
      }
    }
    lineas.add(const LineaComprobante.separador());
    lineas.add(const LineaComprobante.texto('Remanente loteado'));
    if (lotesConstituidos.isEmpty) {
      lineas.add(const LineaComprobante.texto('Sin remanente.'));
    } else {
      for (final lote in lotesConstituidos) {
        lineas.add(
          LineaComprobante.campo(
            lote.codigoLote ?? 'Lote #${lote.id}',
            '${lote.tipoCafe.etiqueta} · '
            '${_formatearCantidad(lote.pesoNeto)} kg',
          ),
        );
      }
    }
    return lineas;
  }

  Future<void> _compartirReporteCierre({
    required List<dynamic> resumen,
    required List<LoteBodega> lotesConstituidos,
    required double saldoTeorico,
    required DateTime fechaCierre,
  }) async {
    final config = ref.read(configuracionesProvider);
    final ok = await ComprobanteServicio.instancia.compartirPdf(
      encabezado: config.factura.aEncabezadoComprobante,
      titulo: 'Reporte de Cierre',
      lineas: _lineasReporteCierre(
        resumen: resumen,
        lotesConstituidos: lotesConstituidos,
        saldoTeorico: saldoTeorico,
        fechaCierre: fechaCierre,
      ),
    );
    if (!mounted) return;
    if (!ok) {
      Notificaciones.error(
        context,
        'No fue posible generar o compartir el PDF del cierre.',
      );
    }
  }

  Future<void> _imprimirReporteCierre({
    required List<dynamic> resumen,
    required List<LoteBodega> lotesConstituidos,
    required double saldoTeorico,
    required DateTime fechaCierre,
  }) async {
    final config = ref.read(configuracionesProvider);
    final datos = TicketEscPosBuilder.construir(
      titulo: 'CIERRE DE CICLO',
      lineas: [
        for (final l in _lineasReporteCierre(
          resumen: resumen,
          lotesConstituidos: lotesConstituidos,
          saldoTeorico: saldoTeorico,
          fechaCierre: fechaCierre,
        ))
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
  // CONSTRUCCIÓN
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estadoCaja = ref.watch(cajaProvider);
    final estadoProcesos = ref.watch(procesosProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Cierres'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: estadoCaja.isCargando || estadoProcesos.isCargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppEspaciado.m,
                    AppEspaciado.m,
                    AppEspaciado.m,
                    0,
                  ),
                  child: _SelectorCierres(
                    actual: _tab,
                    onChanged: (seleccion) {
                      setState(() => _tab = seleccion);
                    },
                  ),
                ),
                Expanded(
                  child: _tab == 0
                      ? _buildCierreCaja(theme: theme, estadoCaja: estadoCaja)
                      : _buildCicloOperativo(
                          theme: theme,
                          estadoCaja: estadoCaja,
                          estadoProcesos: estadoProcesos,
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCierreCaja({
    required ThemeData theme,
    required CajaEstado estadoCaja,
  }) {
    final yaCerrada = !estadoCaja.isCajaAbierta;
    final sesion = estadoCaja.sesionActual;
    final diferenciaInfo = _getDiferenciaInfo();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppEspaciado.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // §3.3: banner obligatorio "Caja Actual: $[Valor]".
          BannerCajaWidget(saldoActual: estadoCaja.saldoActual),
          const SizedBox(height: AppEspaciado.l),

          if (yaCerrada) ...[
            const SizedBox(height: AppEspaciado.xl),
            const Icon(
              Icons.check_circle_outline,
              size: 56,
              color: AppPaletaOficial.verde,
            ),
            const SizedBox(height: AppEspaciado.m),
            Text(
              'La Caja de esta jornada ya fue cerrada.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppPaletaOficial.verde,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              'Fecha de cierre: ${_formatearFechaLibre(sesion?.fechaCierre)}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            _Resumen(
              saldoInicial: sesion?.saldoInicial ?? 0,
              entradas: estadoCaja.totalEntradas,
              salidas: estadoCaja.totalSalidas,
              saldoTeoricoFinal: estadoCaja.saldoActual,
            ),
            const SizedBox(height: AppEspaciado.l),
            _EfectivoContado(
              controller: _efectivoContadoController,
              onChanged: _calcularDiferencia,
            ),
            const SizedBox(height: AppEspaciado.m),
            _DiferenciaResumen(
              diferencia: _diferencia,
              efectivoContado: _efectivoContado,
              textoDiferencia: diferenciaInfo.$1,
              colorDiferencia: diferenciaInfo.$2,
              ayuda: diferenciaInfo.$3,
            ),
            const SizedBox(height: AppEspaciado.l),
            _Observaciones(
              controller: _observacionesController,
            ),
            const SizedBox(height: AppEspaciado.l),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _cerrandoCaja ? null : _confirmarCierre,
                icon: _cerrandoCaja
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: const Text('Cerrar Caja'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatearFechaLibre(DateTime? fecha) {
    if (fecha == null) return '--';
    return _formatearFecha(fecha);
  }

  Widget _buildCicloOperativo({
    required ThemeData theme,
    required CajaEstado estadoCaja,
    required ProcesosEstado estadoProcesos,
  }) {
    final comprasPendientes = estadoProcesos.comprasPendientes.length;
    final ventasPendientes = estadoProcesos.ventasPendientes.length;

    if (_cicloCerrado) {
      return Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          children: [
            const SizedBox(height: AppEspaciado.xl),
            const Icon(
              Icons.event_available,
              size: 56,
              color: AppPaletaOficial.verde,
            ),
            const SizedBox(height: AppEspaciado.m),
            Text(
              'El Ciclo Operativo fue cerrado.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppPaletaOficial.verde,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              'La Caja se cerró automáticamente y se abrió un nuevo '
              'Ciclo Operativo. La aplicación le redirigirá a la '
              'Apertura de Caja.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppEspaciado.l),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppEspaciado.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BannerCajaWidget(saldoActual: estadoCaja.saldoActual),
          const SizedBox(height: AppEspaciado.l),

          _CardCondiciones(
            comprasPendientes: comprasPendientes,
            ventasPendientes: ventasPendientes,
          ),
          const SizedBox(height: AppEspaciado.l),

          Text(
            'Nivelación de Bodega',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppEspaciado.s),
          Text(
            'Confirme las existencias físicas de la bodega común. Al '
            'cerrar el ciclo, el inventario se nivela a estos kilos y '
            'el remanente se convierte en lotes constituidos.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppEspaciado.m),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppEspaciado.m),
              child: Column(
                children: [
                  for (final tipo in TipoCafeProceso.values)
                    _FilaExistencias(
                      tipo: tipo,
                      registrado: estadoProcesos.stockDisponibleDe(tipo),
                      controller: _existenciasControllers[tipo]!,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppEspaciado.l),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _cerrandoCiclo ? null : _confirmarCicloOperativo,
              icon: _cerrandoCiclo
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.event_repeat),
              label: const Text('Cerrar Ciclo Operativo'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SELECTOR DE LOS DOS BOTONES SUPERIORES (§3.3.4)
// ============================================================================

class _SelectorCierres extends StatelessWidget {
  final int actual;
  final ValueChanged<int> onChanged;

  const _SelectorCierres({required this.actual, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BotonSelector(
            activo: actual == 0,
            icono: Icons.account_balance_outlined,
            etiqueta: 'Cierre de Caja',
            onTap: () => onChanged(0),
          ),
        ),
        const SizedBox(width: AppEspaciado.s),
        Expanded(
          child: _BotonSelector(
            activo: actual == 1,
            icono: Icons.event_repeat,
            etiqueta: 'Cierre de Ciclo Operativo',
            onTap: () => onChanged(1),
          ),
        ),
      ],
    );
  }
}

class _BotonSelector extends StatelessWidget {
  final bool activo;
  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;

  const _BotonSelector({
    required this.activo,
    required this.icono,
    required this.etiqueta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final boton = activo
        ? FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icono, size: 18),
            label: Text(etiqueta),
          )
        : OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icono, size: 18),
            label: Text(etiqueta),
          );
    return SizedBox(height: 48, child: boton);
  }
}

// ============================================================================
// CONDICIONES PREVIAS AL CIERRE DE CICLO (§6.6.9)
// ============================================================================

class _CardCondiciones extends StatelessWidget {
  final int comprasPendientes;
  final int ventasPendientes;

  const _CardCondiciones({
    required this.comprasPendientes,
    required this.ventasPendientes,
  });

  @override
  Widget build(BuildContext context) {
    final bloqueado = comprasPendientes > 0;

    return Card(
      elevation: 0,
      color: bloqueado
          ? AppPaletaOficial.rojo.withValues(alpha: 0.06)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  bloqueado ? Icons.lock_outline : Icons.lock_open_outlined,
                  size: 18,
                  color: bloqueado
                      ? AppPaletaOficial.rojo
                      : AppPaletaOficial.cafe,
                ),
                const SizedBox(width: AppEspaciado.s),
                Expanded(
                  child: Text(
                    bloqueado
                        ? 'Cierre bloqueado hasta liquidar compras'
                        : 'Condiciones de cierre cumplidas',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: bloqueado
                              ? AppPaletaOficial.rojo
                              : null,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.s),
            _FilaCondicion(
              ok: comprasPendientes == 0,
              color: comprasPendientes == 0
                  ? AppPaletaOficial.verde
                  : AppPaletaOficial.rojo,
              texto: comprasPendientes == 0
                  ? 'Todas las compras están liquidadas.'
                  : '$comprasPendientes compra(s) con saldo pendiente — '
                        'el cierre queda absolutamente bloqueado.',
            ),
            const SizedBox(height: AppEspaciado.xs),
            _FilaCondicion(
              ok: true,
              color: ventasPendientes > 0
                  ? AppPaletaOficial.cafe
                  : AppPaletaOficial.verde,
              texto: ventasPendientes > 0
                  ? '$ventasPendientes venta(s) pendientes: se conservarán '
                        'en el nuevo Ciclo Operativo.'
                  : 'Sin ventas pendientes.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaCondicion extends StatelessWidget {
  final bool ok;
  final Color color;
  final String texto;

  const _FilaCondicion({
    required this.ok,
    required this.color,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          ok ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: AppEspaciado.s),
        Expanded(
          child: Text(
            texto,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FILA DE EXISTENCIAS FÍSICAS (NIVELACIÓN DE BODEGA)
// ============================================================================

class _FilaExistencias extends StatelessWidget {
  final TipoCafeProceso tipo;
  final double registrado;
  final TextEditingController controller;

  const _FilaExistencias({
    required this.tipo,
    required this.registrado,
    required this.controller,
  });

  String _formatear(double valor) {
    return valor.toStringAsFixed(valor == valor.roundToDouble() ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppEspaciado.s),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo.etiqueta,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Registrado: ${_formatear(registrado)} kg',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppEspaciado.m),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Confirmado',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RESUMEN FINANCIERO (§3.3.4)
// ============================================================================

class _Resumen extends StatelessWidget {
  final double saldoInicial;
  final double entradas;
  final double salidas;
  final double saldoTeoricoFinal;

  const _Resumen({
    required this.saldoInicial,
    required this.entradas,
    required this.salidas,
    required this.saldoTeoricoFinal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen Financiero',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppEspaciado.m),
            child: Column(
              children: [
                _FilaResumen(label: 'Saldo Inicial', value: saldoInicial),
                _FilaResumen(label: 'Entradas', value: entradas),
                _FilaResumen(label: 'Salidas', value: salidas),
                const Divider(height: AppEspaciado.l),
                _FilaResumen(
                  label: 'Saldo Teórico Final',
                  value: saldoTeoricoFinal,
                  destacado: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilaResumen extends StatelessWidget {
  final String label;
  final double value;
  final bool destacado;

  const _FilaResumen({
    required this.label,
    required this.value,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppEspaciado.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            CurrencyFormatter.formatValue(value),
            style: theme.textTheme.titleMedium?.copyWith(
              color: destacado ? AppPaletaOficial.cafe : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EFECTIVO CONTADO
// ============================================================================

class _EfectivoContado extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _EfectivoContado({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Efectivo Contado',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [CurrencyFormatter()],
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Efectivo contado en caja',
            border: OutlineInputBorder(),
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

// ============================================================================
// DIFERENCIA (FAVORABLE / DESFAVORABLE)
// ============================================================================

class _DiferenciaResumen extends StatelessWidget {
  final double? diferencia;
  final double? efectivoContado;
  final String textoDiferencia;
  final Color colorDiferencia;
  final String ayuda;

  const _DiferenciaResumen({
    required this.diferencia,
    required this.efectivoContado,
    required this.textoDiferencia,
    required this.colorDiferencia,
    required this.ayuda,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: colorDiferencia.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diferencia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  diferencia == null
                      ? '--'
                      : CurrencyFormatter.formatValue(diferencia!),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorDiferencia,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.s),
            Row(
              children: [
                Icon(
                  diferencia == null ? Icons.info_outline : Icons.info,
                  size: 16,
                  color: colorDiferencia,
                ),
                const SizedBox(width: AppEspaciado.s),
                Expanded(
                  child: Text(
                    diferencia == null
                        ? 'Ingrese el efectivo contado para calcular '
                            'la diferencia.'
                        : '$textoDiferencia — $ayuda.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorDiferencia,
                    ),
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

// ============================================================================
// OBSERVACIONES
// ============================================================================

class _Observaciones extends StatelessWidget {
  final TextEditingController controller;

  const _Observaciones({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observaciones',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Observaciones del cierre (opcional)',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

// ============================================================================
// FILA DE REPORTE DEL DIÁLOGO DE ÉXITO
// ============================================================================

class _FilaReporte extends StatelessWidget {
  final String label;
  final String valor;
  final bool justColor;

  const _FilaReporte({
    required this.label,
    required this.valor,
    this.justColor = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppEspaciado.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: justColor ? theme.colorScheme.onSurfaceVariant : null,
            ),
          ),
          const SizedBox(width: AppEspaciado.m),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}