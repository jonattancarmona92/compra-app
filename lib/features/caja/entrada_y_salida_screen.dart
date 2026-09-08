// ==================== ARCHIVO: lib/features/caja/entrada_y_salida_screen.dart ====================
// Entradas y Salidas — Informe Global §3.3.1.
// Movimientos manuales de efectivo que no proceden de la compraventa
// directa de café o tienda (fletes, nómina, servicios, aportes).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../configuraciones/configuraciones_provider.dart';
import '../configuraciones/impresora_bluetooth_servicio.dart';
import 'caja_provider.dart';

class EntradaYSalidaScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const EntradaYSalidaScreen({super.key, required this.onBack});

  @override
  ConsumerState<EntradaYSalidaScreen> createState() =>
      _EntradaYSalidaScreenState();
}

class _EntradaYSalidaScreenState extends ConsumerState<EntradaYSalidaScreen> {
  // NOTA DE INTEGRACIÓN PENDIENTE: el operador autenticado debe venir
  // de control_inicio_provider.dart (credenciales locales) una vez
  // exista un identificador de usuario real. Por ahora se usa un
  // valor fijo documentado explícitamente.
  static const String _operadorActual = 'operador_demo';

  Future<void> _compartirPdf(BuildContext context, MovimientoCaja m) async {
    final config = ref.read(configuracionesProvider);
    final esEntrada = m.tipo == TipoMovimientoCaja.entrada;
    final ok = await ComprobanteServicio.instancia.compartirPdf(
      encabezado: config.factura.aEncabezadoComprobante,
      titulo: esEntrada ? 'Comprobante de Entrada' : 'Comprobante de Salida',
      lineas: _lineasMovimiento(m),
    );
    if (context.mounted && !ok) {
      Notificaciones.error(
        context,
        'No fue posible generar o compartir el PDF del comprobante.',
      );
    }
  }

  Future<void> _imprimir(BuildContext context, MovimientoCaja m) async {
    final config = ref.read(configuracionesProvider);
    final esEntrada = m.tipo == TipoMovimientoCaja.entrada;
    final datos = TicketEscPosBuilder.construir(
      titulo: esEntrada ? 'ENTRADA DE CAJA' : 'SALIDA DE CAJA',
      lineas: [
        'Concepto: ${m.concepto}',
        'Valor: ${CurrencyFormatter.formatValue(m.monto)}',
        'Operador: ${m.operador}',
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

  List<LineaComprobante> _lineasMovimiento(MovimientoCaja m) {
    final esEntrada = m.tipo == TipoMovimientoCaja.entrada;
    return [
      LineaComprobante.texto(
        esEntrada ? 'ENTRADA DE CAJA' : 'SALIDA DE CAJA',
      ),
      LineaComprobante.campo('Concepto', m.concepto),
      if (m.categoria != null)
        LineaComprobante.campo('Categoría', m.categoria!.etiqueta),
      LineaComprobante.campo(
        'Valor',
        CurrencyFormatter.formatValue(m.monto),
        enNegrita: true,
      ),
      LineaComprobante.campo(
        'Fecha',
        '${m.fechaRegistro.day}/${m.fechaRegistro.month}'
        '/${m.fechaRegistro.year}',
      ),
      LineaComprobante.campo('Operador', m.operador),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = ref.watch(cajaProvider);
    final custom = theme.extension<CoffeeCustomTheme>()!;

    // §3.3.1: esta pantalla lista únicamente movimientos MANUALES
    // (sin origen_tabla), no los automáticos generados por otros
    // módulos (Transacciones, Abonos, POS).
    final movimientosManuales = estado.movimientosVisibles
        .where((m) => m.origenTabla == null)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Entradas y Salidas'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: estado.isCargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // §3.3.1: banner obligatorio "Caja Actual: $[Valor]".
                Container(
                  width: double.infinity,
                  color: custom.cajaBannerBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.l,
                    vertical: AppEspaciado.m,
                  ),
                  child: Text(
                    'Caja Actual: ${CurrencyFormatter.formatValue(estado.saldoActual)}',
                    style: custom.cajaBannerTextStyle,
                  ),
                ),
                Expanded(
                  child: movimientosManuales.isEmpty
                      ? _buildVacio(theme)
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppEspaciado.m),
                          itemCount: movimientosManuales.length,
                          itemBuilder: (context, index) {
                            return _MovimientoTile(
                              movimiento: movimientosManuales[index],
                              onEditar: () => _abrirFormulario(
                                context,
                                editar: movimientosManuales[index],
                              ),
                              onAnular: () => _confirmarAnulacion(
                                context,
                                movimientosManuales[index],
                              ),
                              onCompartirPdf: () =>
                                  _compartirPdf(context, movimientosManuales[index]),
                              onImprimir: () =>
                                  _imprimir(context, movimientosManuales[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo movimiento'),
      ),
    );
  }

  Widget _buildVacio(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppEspaciado.m),
          Text(
            'Sin movimientos manuales registrados en esta jornada.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FORMULARIO DE REGISTRO / EDICIÓN
  // ==========================================================================

  void _abrirFormulario(BuildContext context, {MovimientoCaja? editar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppEspaciado.radioEstandar),
        ),
      ),
      builder: (context) => _MovimientoFormSheet(
        movimientoAEditar: editar,
        operador: _operadorActual,
      ),
    );
  }

  Future<void> _confirmarAnulacion(
    BuildContext context,
    MovimientoCaja movimiento,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anular movimiento'),
        content: Text(
          '¿Confirma anular "${movimiento.concepto}" por '
          '${CurrencyFormatter.formatValue(movimiento.monto)}? '
          'Esta acción requiere PIN de seguridad.',
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

    // NOTA DE INTEGRACIÓN PENDIENTE: el §3.3.1/§8.4 exige validación
    // de PIN de seguridad antes de anular. La captura real de PIN se
    // conecta cuando integremos control_inicio_provider aquí (Módulo
    // 6). Por ahora se procede directo para poder probar el flujo.
    try {
      await ref
          .read(cajaProvider.notifier)
          .anularMovimiento(
            movimientoId: movimiento.id,
            operador: _operadorActual,
          );
      if (context.mounted) {
        Notificaciones.exito(context, 'Movimiento anulado correctamente.');
      }
    } on SaldoInsuficienteException {
      if (context.mounted) {
        Notificaciones.error(
          context,
          'No es posible anular: la Caja no tiene fondos suficientes '
          'para cubrir la reversión. Registre una Entrada manual primero.',
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
// FILA DE MOVIMIENTO
// ============================================================================

class _MovimientoTile extends StatelessWidget {
  final MovimientoCaja movimiento;
  final VoidCallback onEditar;
  final VoidCallback onAnular;
  final VoidCallback onCompartirPdf;
  final VoidCallback onImprimir;

  const _MovimientoTile({
    required this.movimiento,
    required this.onEditar,
    required this.onAnular,
    required this.onCompartirPdf,
    required this.onImprimir,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esEntrada = movimiento.tipo == TipoMovimientoCaja.entrada;

    return Card(
      margin: const EdgeInsets.only(bottom: AppEspaciado.s),
      child: ListTile(
        leading: Icon(
          esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
          color: esEntrada ? AppPaletaOficial.verde : AppPaletaOficial.rojo,
        ),
        title: Text(movimiento.concepto),
        subtitle: Text(
          [
            if (movimiento.categoria != null) movimiento.categoria!.etiqueta,
            _formatearFechaHora(movimiento.fechaRegistro),
          ].join(' · '),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${esEntrada ? '+' : '-'} ${CurrencyFormatter.formatValue(movimiento.monto)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: esEntrada
                    ? AppPaletaOficial.verde
                    : AppPaletaOficial.rojo,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (opcion) {
                switch (opcion) {
                  case 'editar':
                    onEditar();
                    break;
                  case 'anular':
                    onAnular();
                    break;
                  case 'pdf':
                    onCompartirPdf();
                    break;
                  case 'imprimir':
                    onImprimir();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'anular', child: Text('Cancelar/Anular')),
                PopupMenuItem(value: 'pdf', child: Text('Compartir como PDF')),
                PopupMenuItem(value: 'imprimir', child: Text('Imprimir')),
              ],
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
// FORMULARIO (BOTTOM SHEET) — Registro y Edición
// ============================================================================

class _MovimientoFormSheet extends ConsumerStatefulWidget {
  final MovimientoCaja? movimientoAEditar;
  final String operador;

  const _MovimientoFormSheet({this.movimientoAEditar, required this.operador});

  @override
  ConsumerState<_MovimientoFormSheet> createState() =>
      _MovimientoFormSheetState();
}

class _MovimientoFormSheetState extends ConsumerState<_MovimientoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _conceptoController = TextEditingController();

  TipoMovimientoCaja _tipo = TipoMovimientoCaja.entrada;
  CategoriaMovimiento? _categoria;
  bool _guardando = false;

  bool get _esEdicion => widget.movimientoAEditar != null;

  @override
  void initState() {
    super.initState();
    final editar = widget.movimientoAEditar;
    if (editar != null) {
      _tipo = editar.tipo;
      _categoria = editar.categoria;
      _montoController.text = editar.monto.toStringAsFixed(0);
      _conceptoController.text = editar.concepto;
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _guardando) return;

    // §5.5.4: categoría obligatoria solo para salidas.
    if (_tipo == TipoMovimientoCaja.salida && _categoria == null) {
      Notificaciones.error(context, 'Seleccione una categoría para la salida.');
      return;
    }

    setState(() => _guardando = true);

    final monto = CurrencyFormatter.parseValue(_montoController.text);
    final concepto = _conceptoController.text.trim();

    try {
      if (_esEdicion) {
        await ref
            .read(cajaProvider.notifier)
            .editarMovimiento(
              movimientoId: widget.movimientoAEditar!.id,
              nuevoMonto: monto,
              nuevoConcepto: concepto,
              operador: widget.operador,
            );
      } else {
        await ref
            .read(cajaProvider.notifier)
            .registrarMovimiento(
              tipo: _tipo,
              monto: monto,
              concepto: concepto,
              categoria: _categoria,
              operador: widget.operador,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        Notificaciones.exito(
          context,
          _esEdicion ? 'Movimiento actualizado.' : 'Movimiento registrado.',
        );
      }
    } on SaldoInsuficienteException catch (e) {
      if (mounted) {
        Notificaciones.error(
          context,
          'Fondos insuficientes: disponible '
          '${CurrencyFormatter.formatValue(e.saldoDisponible)}.',
        );
      }
    } on ValorInvalidoException catch (e) {
      if (mounted) Notificaciones.error(context, e.mensaje);
    } catch (_) {
      if (mounted) {
        Notificaciones.error(context, 'No fue posible guardar el movimiento.');
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppEspaciado.l,
        right: AppEspaciado.l,
        top: AppEspaciado.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppEspaciado.l,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _esEdicion ? 'Editar movimiento' : 'Nuevo movimiento',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: AppEscalaTipografica.subtitulo + 2,
              ),
            ),
            const SizedBox(height: AppEspaciado.l),
            SegmentedButton<TipoMovimientoCaja>(
              segments: const [
                ButtonSegment(
                  value: TipoMovimientoCaja.entrada,
                  label: Text('Entrada'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TipoMovimientoCaja.salida,
                  label: Text('Salida'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_tipo},
              onSelectionChanged: _esEdicion
                  ? null
                  : (seleccion) => setState(() {
                      _tipo = seleccion.first;
                      _categoria = null;
                    }),
            ),
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
            TextFormField(
              controller: _conceptoController,
              enabled: !_guardando,
              decoration: const InputDecoration(
                labelText: 'Concepto',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Campo obligatorio'
                  : null,
            ),
            if (_tipo == TipoMovimientoCaja.salida) ...[
              const SizedBox(height: AppEspaciado.m),
              DropdownButtonFormField<CategoriaMovimiento>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría de gasto',
                  border: OutlineInputBorder(),
                ),
                items: CategoriaMovimiento.values
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c, child: Text(c.etiqueta)),
                    )
                    .toList(),
                onChanged: _guardando
                    ? null
                    : (v) => setState(() => _categoria = v),
              ),
            ],
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
                    : Text(_esEdicion ? 'Guardar cambios' : 'Registrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
