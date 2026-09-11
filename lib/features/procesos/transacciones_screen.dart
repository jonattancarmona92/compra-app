import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../caja/caja_provider.dart';
import '../clientes/models/cliente_model.dart';
import '../clientes/nuevo_cliente_screen.dart';
import '../clientes/providers/cliente_provider.dart';
import '../configuraciones/configuraciones_provider.dart';
import '../configuraciones/impresora_bluetooth_servicio.dart';
import 'procesos_provider.dart';

class TransaccionesScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const TransaccionesScreen({super.key, required this.onBack});

  @override
  ConsumerState<TransaccionesScreen> createState() =>
      _TransaccionesScreenState();
}

class _TransaccionesScreenState extends ConsumerState<TransaccionesScreen> {
  bool _esCompra = true;
  String _tipoCafe = 'Mojado';
  String? _clienteSeleccionado;
  String _filtroCliente = '';

  /// §3.4.1/§3.4.3 — id del lote de "Almacenado" que será origen de la
  /// venta. `null` = la venta descuenta de la bodega común (FIFO).
  int? _loteVentaId;
  bool _origenLoteAlmacenado = false;

  final _clienteController = TextEditingController();
  final _pesoBrutoController = TextEditingController();
  final _descuentoHumedadKgController = TextEditingController();
  final _pesoFinalMojadoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _precioCargaController = TextEditingController();
  final _grameraController = TextEditingController();
  final _factorController = TextEditingController();
  final _descuentoEmpaqueKgController = TextEditingController();
  final _anticipoController = TextEditingController();
  final _valorTotalController = TextEditingController();

  bool _ajusteManualTotal = false;
  bool _pendientePago = false;
  bool _factorManual = false;
  bool _sincronizandoFactor = false;
  double _pesoNeto = 0.0;
  double _precioKg = 0.0;
  double _valorTotal = 0.0;
  double _factorRendimiento = 88.0;
  double _porcentajeAjuste = 0.0;
  double _precioFinalCarga = 0.0;
  double _anticipo = 0.0;

  @override
  void initState() {
    super.initState();
    _pesoBrutoController.addListener(_actualizarCalculos);
    _descuentoHumedadKgController.addListener(_actualizarCalculos);
    _pesoFinalMojadoController.addListener(_actualizarCalculos);
    _pesoController.addListener(_actualizarCalculos);
    _precioCargaController.addListener(_actualizarCalculos);
    _grameraController.addListener(_onGrameraEditada);
    _factorController.addListener(_onFactorEditado);
    _descuentoEmpaqueKgController.addListener(_actualizarCalculos);
    _anticipoController.addListener(_actualizarCalculos);
    _valorTotalController.addListener(_onValorTotalEditado);
  }

  void _onGrameraEditada() {
    final gramera = double.tryParse(_grameraController.text) ?? 0.0;
    _factorManual = false;
    if (gramera >= 100 && gramera <= 250) {
      _sincronizandoFactor = true;
      _factorController.text = (17500 / gramera).toStringAsFixed(2);
      _sincronizandoFactor = false;
    } else {
      _sincronizandoFactor = true;
      _factorController.clear();
      _sincronizandoFactor = false;
    }
    _actualizarCalculos();
  }

  void _onFactorEditado() {
    if (_sincronizandoFactor) return;
    _factorManual = true;
    _actualizarCalculos();
  }

  void _onValorTotalEditado() {
    if (_ajusteManualTotal) {
      final valor = _parseFormattedCurrency(_valorTotalController.text);
      if (valor > 0) {
        setState(() => _valorTotal = valor);
      }
    }
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _pesoBrutoController.dispose();
    _descuentoHumedadKgController.dispose();
    _pesoFinalMojadoController.dispose();
    _pesoController.dispose();
    _precioCargaController.dispose();
    _grameraController.dispose();
    _factorController.dispose();
    _descuentoEmpaqueKgController.dispose();
    _anticipoController.dispose();
    _valorTotalController.dispose();
    super.dispose();
  }

  void _actualizarCalculos() {
    setState(() {
      final precioCarga = _parseFormattedCurrency(
        _precioCargaController.text,
      );

      if (_tipoCafe == 'Mojado') {
        // §7.2 — el operador ingresa el descuento por humedad como
        // PORCENTAJE sobre el peso bruto. La merma en kg se calcula
        // automáticamente (8% de 100 kg = 8 kg). El "Peso final" sigue
        // siendo editable: corrige el peso YA descontado (peso real
        // registrado en la báscula) y tiene prioridad sobre el cálculo.
        final pesoBruto = double.tryParse(_pesoBrutoController.text) ?? 0.0;
        final descuentoPct =
            double.tryParse(_descuentoHumedadKgController.text) ?? 0.0;
        final descuentoKg = pesoBruto * (descuentoPct.clamp(0, 100) / 100);
        final pesoFinalEditado =
            double.tryParse(_pesoFinalMojadoController.text) ?? 0.0;
        _pesoNeto = pesoFinalEditado > 0
            ? pesoFinalEditado
            : pesoBruto - descuentoKg;
        if (_pesoNeto < 0) _pesoNeto = 0.0;

        _precioKg = precioCarga / 125;
      } else if (_tipoCafe == 'Seco') {
        // §7.1 — gramera en gramos (100-250). Factor editable: si el
        // operador ajustó el factor a mano se respeta; si no, se
        // recalcula Factor = 17500 / Gramera (default 88).
        final pesoInicial = double.tryParse(_pesoController.text) ?? 0.0;
        final empaqueKg =
            double.tryParse(_descuentoEmpaqueKgController.text) ?? 0.0;
        final gramera = double.tryParse(_grameraController.text) ?? 0.0;

        _pesoNeto = pesoInicial - empaqueKg;
        if (_pesoNeto < 0) _pesoNeto = 0.0;

        final factorManual = double.tryParse(_factorController.text) ?? 0.0;
        if (_factorManual && factorManual > 0) {
          _factorRendimiento = factorManual;
        } else if (gramera >= 100 && gramera <= 250) {
          _factorRendimiento = 17500 / gramera;
        } else {
          _factorRendimiento = 88.0;
        }

        _porcentajeAjuste = ((88.0 - _factorRendimiento) / 88.0) * 100;
        _precioFinalCarga = precioCarga * (1 + (_porcentajeAjuste / 100));
        _precioKg = _precioFinalCarga / 125;
      } else {
        // §7.3 — café oreado y pasilla: cálculo directo.
        _pesoNeto = double.tryParse(_pesoController.text) ?? 0.0;
        if (_pesoNeto < 0) _pesoNeto = 0.0;

        _precioKg = precioCarga / 125;
      }

      final valorTotalCalculado = _pesoNeto * _precioKg;
      if (_ajusteManualTotal) {
        final manual = _parseFormattedCurrency(_valorTotalController.text);
        _valorTotal = manual > 0 ? manual : valorTotalCalculado;
      } else {
        _valorTotal = valorTotalCalculado;
        _valorTotalController.text =
            CurrencyFormatter.formatValue(valorTotalCalculado);
      }

      // Cálculo de anticipo (solo se guarda si está pendiente de pago)
      if (_pendientePago) {
        _anticipo = _parseFormattedCurrency(_anticipoController.text);
      } else {
        _anticipo = 0.0;
      }
    });
  }

  double _parseFormattedCurrency(String text) {
    final numericString = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  /// §7.2 — merma en kg del café mojado = peso bruto × porcentaje de
  /// descuento por humedad ÷ 100 (ej. 8% de 100 kg = 8 kg).
  double get _descuentoHumedadKgCalculado {
    final pesoBruto = double.tryParse(_pesoBrutoController.text) ?? 0.0;
    final pct = double.tryParse(_descuentoHumedadKgController.text) ?? 0.0;
    return pesoBruto * (pct.clamp(0, 100)) / 100;
  }

  bool _validarFormulario() {
    // §3.4.1: el cliente es opcional solo en pagos de contado. Si no se
    // asigna, la transacción y el recibo se registran como "Sin cliente".
    // Con pago pendiente (liquidación posterior) el cliente es obligatorio.
    if (!_esCompra && _origenLoteAlmacenado && _loteVentaId == null) {
      Notificaciones.error(
        context,
        'No hay lotes disponibles de ${_tipoCafeProceso.etiqueta} en '
        'Almacenado. Seleccione "Bodega Común" o constituya lotes en el '
        'Cierre.',
      );
      return false;
    }

    if (_tipoCafe == 'Mojado') {
      if (_pesoBrutoController.text.isEmpty) {
        Notificaciones.error(context, 'Complete el peso bruto');
        return false;
      }
      if (_descuentoHumedadKgController.text.isEmpty) {
        Notificaciones.error(
          context,
          'Complete el descuento por humedad en porcentaje',
        );
        return false;
      }
      final pesoBruto = double.tryParse(_pesoBrutoController.text) ?? 0.0;
      final descuentoPct =
          double.tryParse(_descuentoHumedadKgController.text) ?? 0.0;
      if (descuentoPct < 0 || descuentoPct > 100) {
        Notificaciones.error(
          context,
          'El porcentaje de descuento debe estar entre 0 y 100.',
        );
        return false;
      }
      final pesoFinalMojado =
          double.tryParse(_pesoFinalMojadoController.text);
      if (pesoFinalMojado != null && pesoFinalMojado > pesoBruto) {
        Notificaciones.error(
          context,
          'El peso final no puede ser mayor que el peso bruto.',
        );
        return false;
      }
    } else {
      if (_pesoController.text.isEmpty) {
        Notificaciones.error(context, 'Complete el peso');
        return false;
      }
    }

    if (_tipoCafe == 'Seco' && _grameraController.text.isNotEmpty) {
      final gramera =
          double.tryParse(_grameraController.text) ?? 0.0;
      if (gramera < 100 || gramera > 250) {
        Notificaciones.error(
          context,
          'La gramera debe estar entre 100 y 250 gramos.',
        );
        return false;
      }
    }

    if (_tipoCafe == 'Seco' && _factorController.text.isNotEmpty) {
      final factor = double.tryParse(_factorController.text) ?? 0.0;
      if (factor <= 0) {
        Notificaciones.error(
          context,
          'El factor de rendimiento debe ser mayor a cero.',
        );
        return false;
      }
    }

    if (_precioCargaController.text.isEmpty) {
      Notificaciones.error(context, 'Complete el precio');
      return false;
    }

    final precioCarga = _parseFormattedCurrency(_precioCargaController.text);
    if (precioCarga < CurrencyFormatter.minimo) {
      Notificaciones.error(
        context,
        'El precio por carga debe ser al menos '
        '${CurrencyFormatter.formatValue(CurrencyFormatter.minimo)}.',
      );
      return false;
    }

    if (_pesoNeto <= 0) {
      Notificaciones.error(context, 'El peso debe ser mayor a cero');
      return false;
    }

    if (_precioKg <= 0) {
      Notificaciones.error(context, 'El precio debe ser mayor a cero');
      return false;
    }

    if (_pendientePago &&
        _anticipo > 0 &&
        _anticipo < CurrencyFormatter.minimo) {
      Notificaciones.error(
        context,
        'El anticipo debe ser al menos '
        '${CurrencyFormatter.formatValue(CurrencyFormatter.minimo)}.',
      );
      return false;
    }

    // §3.4.4: una transacción con pago pendiente no puede quedar sin un
    // cliente asignado, porque no podría liquidarse después.
    if (_pendientePago) {
      final nombreIngresado = _clienteController.text.trim();
      final sinCliente =
          (_clienteSeleccionado == null && nombreIngresado.isEmpty) ||
              nombreIngresado == 'Sin cliente';
      if (sinCliente) {
        Notificaciones.error(
          context,
          'Asigne un cliente. Una transacción con pago pendiente no puede '
          'quedar sin cliente asignado para su posterior liquidación.',
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _guardarTransaccion() async {
    if (_ajusteManualTotal && _valorTotal < CurrencyFormatter.minimo) {
      Notificaciones.error(
        context,
        'El valor total debe ser al menos '
        '${CurrencyFormatter.formatValue(CurrencyFormatter.minimo)}.',
      );
      return;
    }
    if (!_validarFormulario()) return;

    // §3.4.1: el cliente es opcional. Sin cliente asignado se registra
    // "Sin cliente" (el recibo lo muestra así).
    final clientes = ref.read(clienteProvider).clientes;
    String clienteId = '';
    String nombreCliente = 'Sin cliente';
    if (_clienteSeleccionado != null) {
      for (final c in clientes) {
        if (c.id == _clienteSeleccionado) {
          clienteId = c.id;
          nombreCliente = c.nombreCompleto;
          break;
        }
      }
    }
    if (_clienteController.text.trim().isNotEmpty) {
      nombreCliente = _clienteController.text.trim();
    }

    TransaccionCafe transaccion;
    try {
      transaccion = await ref
          .read(procesosProvider.notifier)
          .registrarTransaccion(
            clienteId: clienteId,
            nombreCliente: nombreCliente,
            esCompra: _esCompra,
            tipoCafe: _tipoCafeProceso,
            pesoBruto:
                double.tryParse(_pesoBrutoController.text) ??
                _pesoNeto,
            descuentoHumedadKg: _descuentoHumedadKgCalculado,
            pesoNeto: _pesoNeto,
            gramera: double.tryParse(_grameraController.text) ?? 0,
            descuentoEmpaqueKg:
                double.tryParse(_descuentoEmpaqueKgController.text) ?? 0,
            precioCarga: _parseFormattedCurrency(_precioCargaController.text),
            precioKg: _precioKg,
            valorTotal: _valorTotal,
            factorRendimiento: _factorRendimiento,
            porcentajeAjuste: _porcentajeAjuste,
            precioFinalCarga: _precioFinalCarga,
            estadoPago: _pendientePago
                ? EstadoPagoProceso.pendiente
                : EstadoPagoProceso.contado,
            anticipo: _anticipo,
            operador: _operadorActual,
            loteBodegaId: _origenLoteAlmacenado ? _loteVentaId : null,
          );
    } on InventarioInsuficienteException catch (e) {
      if (!mounted) return;
      Notificaciones.error(context, e.mensaje);
      return;
    } on SaldoInsuficienteException {
      if (!mounted) return;
      Notificaciones.error(
        context,
        'No fue posible guardar: la Caja no tiene fondos suficientes para '
        'cubrir este egreso. Registre una Entrada manual primero.',
      );
      return;
    } on CajaNoAbiertaException {
      if (!mounted) return;
      Notificaciones.error(
        context,
        'Debe abrir la Caja antes de registrar transacciones.',
      );
      return;
    }

    if (!mounted) return;
    _mostrarExitoTransaccion(transaccion);
  }

  TipoCafeProceso get _tipoCafeProceso {
    switch (_tipoCafe) {
      case 'Mojado':
        return TipoCafeProceso.mojado;
      case 'Oreado':
        return TipoCafeProceso.oreado;
      case 'Pasilla':
        return TipoCafeProceso.pasilla;
      case 'Secado':
        return TipoCafeProceso.secado;
      default:
        return TipoCafeProceso.seco;
    }
  }

  /// §3.4.1 — lotes de "Almacenado" disponibles (DISPONIBLE) del tipo de
  /// café seleccionado, ordenados por código para la venta desde lote.
  List<LoteBodega> get _lotesVentaDisponibles {
    final estado = ref.read(procesosProvider);
    final porTipo = estado.almacenadosDisponibles
        .where((l) => l.tipoCafe == _tipoCafeProceso)
        .toList()
      ..sort((a, b) =>
          (a.codigoLote ?? '').compareTo(b.codigoLote ?? ''));
    if (porTipo.isNotEmpty &&
        !porTipo.any((l) => l.id == _loteVentaId)) {
      _loteVentaId = porTipo.first.id;
    }
    return porTipo;
  }

  String get _origenLoteVentaLabel {
    final estado = ref.read(procesosProvider);
    for (final l in estado.almacenados) {
      if (l.id == _loteVentaId) return 'Lote ${l.codigoLote}';
    }
    return 'Lote --';
  }

  /// §3.4.3 — selector de origen de la venta: "Bodega común" (FIFO sin
  /// lote) o "Lote Almacenado" (venta desde lote constituido).
  Widget _buildOrigenVenta() {
    if (_esCompra) return const SizedBox.shrink();
    final lotes = _lotesVentaDisponibles;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Origen de la Venta',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: AppEspaciado.m),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Bodega Común'),
                  icon: Icon(Icons.inventory_2_outlined),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Lote Almacenado'),
                  icon: Icon(Icons.warehouse_outlined),
                ),
              ],
              selected: {_origenLoteAlmacenado},
              onSelectionChanged: (seleccion) {
                setState(() {
                  _origenLoteAlmacenado = seleccion.first;
                  _loteVentaId = seleccion.first && lotes.isNotEmpty
                      ? lotes.first.id
                      : null;
                  _actualizarCalculos();
                });
              },
            ),
            if (_origenLoteAlmacenado) ...[
              SizedBox(height: AppEspaciado.m),
              if (lotes.isEmpty) ...[
                Text(
                  'No hay lotes de ${_tipoCafeProceso.etiqueta} disponibles '
                  'en Almacenado. Constituya lotes en el Cierre de Ciclo o '
                  'almacene lotes de secado.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ] else ...[
                Text(
                  'Seleccione el lote a vender:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: AppEspaciado.s),
                DropdownButtonFormField<int>(
                  initialValue: _loteVentaId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppEspaciado.radioLg),
                    ),
                  ),
                  items: [
                    for (final l in lotes)
                      DropdownMenuItem(
                        value: l.id,
                        child: Text(
                          '${l.codigoLote} · '
                          '${l.pesoNeto.toStringAsFixed(1)} kg',
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _loteVentaId = v;
                      _actualizarCalculos();
                    });
                  },
                ),
                SizedBox(height: AppEspaciado.m),
                Text(
                  'Si vende el 100% del lote, esta venta se registrará '
                  'siempre como LIQUIDADA (§3.4.1).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // NOTA DE INTEGRACIÓN PENDIENTE: el operador autenticado debe venir
  // de control_inicio_provider.dart. Por ahora se usa un valor fijo.
  static const String _operadorActual = 'operador_demo';

  // ==========================================================================
  // §3.4.1 — TRANSACCIÓN EXITOSA (Imprimir Recibo / Compartir PDF / Salir)
  // ==========================================================================

  Future<void> _mostrarExitoTransaccion(TransaccionCafe transaccion) async {
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
              Text('Cliente: ${transaccion.nombreCliente}'),
              const SizedBox(height: AppEspaciado.s),
              Text(
                '${transaccion.esCompra ? 'Compra' : 'Venta'} de '
                '${transaccion.tipoCafe.etiqueta} · '
                '${transaccion.pesoNeto.toStringAsFixed(1)} kg',
              ),
              const SizedBox(height: AppEspaciado.s),
              Text(
                'Valor total: '
                '${CurrencyFormatter.formatValue(transaccion.valorTotal)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (transaccion.estadoPago == EstadoPagoProceso.pendiente) ...[
                const SizedBox(height: AppEspaciado.s),
                Text(
                  'Anticipo: '
                  '${CurrencyFormatter.formatValue(transaccion.anticipo)}',
                ),
                Text(
                  'Saldo por liquidar: '
                  '${CurrencyFormatter.formatValue(transaccion.saldoPendiente)}',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _imprimirRecibo(transaccion);
            },
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Imprimir Recibo'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _compartirRecibo(transaccion);
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Compartir PDF'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _limpiarFormulario();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  List<LineaComprobante> _lineasRecibo(TransaccionCafe t) {
    return [
      LineaComprobante.texto(
        t.esCompra ? 'RECIBO DE COMPRA' : 'RECIBO DE VENTA',
      ),
      LineaComprobante.campo('Cliente', t.nombreCliente),
      LineaComprobante.campo('Tipo de café', t.tipoCafe.etiqueta),
      // §7.2 — café mojado: la factura muestra peso inicial, kg
      // descontados (humedad) y peso final.
      if (t.tipoCafe == TipoCafeProceso.mojado) ...[
        LineaComprobante.campo(
          'Peso inicial',
          '${t.pesoBruto.toStringAsFixed(1)} kg',
        ),
        LineaComprobante.campo(
          'Merma (kg)',
          '${t.descuentoHumedadKg.toStringAsFixed(1)} kg',
        ),
        LineaComprobante.campo(
          'Peso final',
          '${t.pesoNeto.toStringAsFixed(1)} kg',
        ),
      ] else
        LineaComprobante.campo(
          'Peso neto',
          '${t.pesoNeto.toStringAsFixed(1)} kg',
        ),
      // §7.1 — café seco: el recibo muestra el factor de rendimiento
      // obtenido, el precio de carga de referencia y el precio de carga
      // obtenido tras el ajuste.
      if (t.tipoCafe == TipoCafeProceso.seco) ...[
        LineaComprobante.campo(
          'Factor obtenido',
          t.factorRendimiento.toStringAsFixed(2),
        ),
        LineaComprobante.campo(
          'Precio de carga referencia',
          CurrencyFormatter.formatValue(t.precioCarga),
        ),
        LineaComprobante.campo(
          'Precio de carga obtenido',
          CurrencyFormatter.formatValue(t.precioFinalCarga),
        ),
      ],
      LineaComprobante.campo(
        'Precio por kg',
        CurrencyFormatter.formatValue(t.precioKg),
      ),
      LineaComprobante.campo(
        'Valor total',
        CurrencyFormatter.formatValue(t.valorTotal),
        enNegrita: true,
      ),
      if (t.estadoPago == EstadoPagoProceso.pendiente) ...[
        LineaComprobante.campo(
          'Anticipo',
          CurrencyFormatter.formatValue(t.anticipo),
        ),
        LineaComprobante.campo(
          'Saldo pendiente',
          CurrencyFormatter.formatValue(t.saldoPendiente),
        ),
      ],
    ];
  }

  Future<void> _compartirRecibo(TransaccionCafe t) async {
    final config = ref.read(configuracionesProvider);
    final ok = await ComprobanteServicio.instancia.compartirPdf(
      encabezado: config.factura.aEncabezadoComprobante,
      titulo: t.esCompra ? 'Recibo de Compra' : 'Recibo de Venta',
      lineas: _lineasRecibo(t),
    );
    if (!mounted) return;
    if (!ok) {
      Notificaciones.error(
        context,
        'No fue posible generar o compartir el PDF del recibo.',
      );
    }
  }

  Future<void> _imprimirRecibo(TransaccionCafe t) async {
    final config = ref.read(configuracionesProvider);
    final datos = TicketEscPosBuilder.construir(
      titulo: t.esCompra ? 'RECIBO DE COMPRA' : 'RECIBO DE VENTA',
      lineas: [
        for (final l in _lineasRecibo(t))
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

  void _limpiarFormulario() {
    _clienteController.clear();
    _filtroCliente = '';
    _pesoBrutoController.clear();
    _descuentoHumedadKgController.clear();
    _pesoFinalMojadoController.clear();
    _pesoController.clear();
    _precioCargaController.clear();
    _grameraController.clear();
    _factorController.clear();
    _descuentoEmpaqueKgController.clear();
    _anticipoController.clear();
    _valorTotalController.clear();
    _clienteSeleccionado = null;
    setState(() {
      _ajusteManualTotal = false;
      _pendientePago = false;
      _factorManual = false;
      _origenLoteAlmacenado = false;
      _loteVentaId = null;
      _pesoNeto = 0.0;
      _precioKg = 0.0;
      _valorTotal = 0.0;
      _factorRendimiento = 88.0;
      _porcentajeAjuste = 0.0;
      _precioFinalCarga = 0.0;
      _anticipo = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Theme.of(context).extension<CoffeeCustomTheme>()!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: dashboard.dashboardPagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: AppEspaciado.l),
              _buildCaja(),
              SizedBox(height: AppEspaciado.l),
              _buildOperacion(),
              SizedBox(height: AppEspaciado.l),
              _buildCliente(),
              SizedBox(height: AppEspaciado.l),
              _buildTipoCafe(),
              SizedBox(height: AppEspaciado.l),
              _buildOrigenVenta(),
              SizedBox(height: AppEspaciado.l),
              _buildFormulario(),
              SizedBox(height: AppEspaciado.l),
              _buildLiquidacion(),
              SizedBox(height: AppEspaciado.l),
              _buildResumen(),
              SizedBox(height: AppEspaciado.xl),
              _buildBotones(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            ),
            const Expanded(child: CoffeeAppTitle(title: 'Transacciones')),
          ],
        ),
      ],
    );
  }

  Widget _buildCaja() {
    final banner = Theme.of(context).extension<CoffeeCustomTheme>()!;
    final saldoDisponible = ref.watch(cajaProvider).saldoActual;

    return Container(
      decoration: BoxDecoration(
        gradient: banner.priceBannerGradient,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppEspaciado.radioLg),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspaciado.xl,
        vertical: AppEspaciado.xxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Caja Disponible', style: banner.priceBannerTitleStyle),
              SizedBox(height: AppEspaciado.s),
              Text(
                CurrencyFormatter.formatValue(saldoDisponible),
                style: banner.priceBannerPriceStyle,
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: banner.priceBannerIconColor,
              size: 28,
            ),
            onPressed: () {
              Notificaciones.informacion(context, 'Actualizando saldo...');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOperacion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(
                      'Compra',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(
                      'Venta',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
                selected: {_esCompra},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _esCompra = newSelection.first;
                    _origenLoteAlmacenado = false;
                    _loteVentaId = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCliente() {
    final clientes = ref.watch(clienteProvider).clientes;
    final termino = _filtroCliente.trim().toLowerCase();
    final sugerencias = termino.isEmpty
        ? const <ClienteModel>[]
        : clientes
              .where(
                (c) =>
                    c.nombreCompleto.toLowerCase().contains(termino) ||
                    c.documento.toLowerCase().contains(termino),
              )
              .toList();

    ClienteModel? seleccionado;
    for (final c in clientes) {
      if (c.id == _clienteSeleccionado) {
        seleccionado = c;
        break;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Identificación de Cliente',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: AppEspaciado.m),
            TextFormField(
              controller: _clienteController,
              decoration: InputDecoration(
                labelText: 'Buscar cliente',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppEspaciado.radioLg),
                ),
              ),
              onChanged: (v) => setState(() => _filtroCliente = v),
              onTap: () {
                setState(() {
                  _filtroCliente = _clienteController.text;
                  _clienteSeleccionado = null;
                });
              },
            ),
            if (sugerencias.isNotEmpty) ...[
              const SizedBox(height: AppEspaciado.m),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(AppEspaciado.radioLg),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sugerencias.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = sugerencias[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline),
                      title: Text(c.nombreCompleto),
                      subtitle: Text('Doc: ${c.documento}'),
                      onTap: () {
                        setState(() {
                          _clienteSeleccionado = c.id;
                          _clienteController.text = c.nombreCompleto;
                          _filtroCliente = '';
                        });
                        Notificaciones.exito(
                          context,
                          'Cliente seleccionado',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
            if (sugerencias.isEmpty && _filtroCliente.trim().isNotEmpty) ...[
              const SizedBox(height: AppEspaciado.m),
              Text(
                'Sin coincidencias. Para registrar un cliente nuevo use "Nuevo".',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            SizedBox(height: AppEspaciado.m),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _crearClienteNuevo,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Nuevo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppEspaciado.m,
                      ),
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                SizedBox(width: AppEspaciado.m),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: seleccionado == null
                        ? null
                        : () {
                            setState(() {
                              _clienteController.text =
                                  seleccionado!.nombreCompleto;
                              _filtroCliente = '';
                            });
                            Notificaciones.exito(
                              context,
                              'Cliente seleccionado',
                            );
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('Seleccionar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppEspaciado.m,
                      ),
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (seleccionado != null) ...[
              SizedBox(height: AppEspaciado.m),
              Container(
                padding: const EdgeInsets.all(AppEspaciado.m),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(AppEspaciado.radioLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cliente: ${seleccionado.nombreCompleto}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: AppEspaciado.s),
                    Text(
                      'Documento: ${seleccionado.documento}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _crearClienteNuevo() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NuevoClienteScreen(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (!mounted) return;
    final clientes = ref.read(clienteProvider).clientes;
    if (clientes.isNotEmpty) {
      final ultimo = clientes.last;
      setState(() {
        _clienteSeleccionado = ultimo.id;
        _clienteController.text = ultimo.nombreCompleto;
        _filtroCliente = '';
      });
      Notificaciones.exito(context, 'Cliente listo para seleccionar');
    }
  }

  Widget _buildTipoCafe() {
    final tiposDisponibles = ['Mojado', 'Oreado', 'Seco', 'Pasilla'];

    return Wrap(
      spacing: AppEspaciado.m,
      children: tiposDisponibles.map((tipo) {
        return FilterChip(
          label: Text(tipo),
          selected: _tipoCafe == tipo,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _tipoCafe = tipo;
                _origenLoteAlmacenado = false;
                _loteVentaId = null;
                _pesoController.clear();
                _pesoBrutoController.clear();
                _descuentoHumedadKgController.clear();
                _pesoFinalMojadoController.clear();
                _grameraController.clear();
                _factorController.clear();
                _descuentoEmpaqueKgController.clear();
                _factorManual = false;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildFormulario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Detalles de la transacción',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: AppEspaciado.m),
            if (_tipoCafe == 'Mojado') ...[
              TextFormField(
                controller: _pesoBrutoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Peso Bruto (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
              SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _descuentoHumedadKgController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Descuento por Humedad (%)',
                  helperText: 'Porcentaje de merma sobre el peso bruto. '
                      'Ej: 8% de 100 kg = 8 kg de merma.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
              SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _pesoFinalMojadoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Peso Final (kg) — editable',
                  helperText: 'Se calcula Peso Bruto − Merma. Edítelo '
                      'solo para corregir el peso YA descontado si la '
                      'báscula arroja otro valor.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
            ] else if (_tipoCafe == 'Seco') ...[
              TextFormField(
                controller: _pesoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
              SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _descuentoEmpaqueKgController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Descuento por Empaque (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
              SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _grameraController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Gramera (g)',
                  helperText: 'Entre 100 y 250 gramos. '
                      'El Factor se calcula como 17500 / gramera.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
              SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _factorController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Factor de Rendimiento (editable)',
                  helperText: 'Se sugiere 88 por defecto o el calculado. '
                      'Puede ajustarlo manualmente.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _pesoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
            ],
            SizedBox(height: AppEspaciado.m),
            TextFormField(
              controller: _precioCargaController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyFormatter()],
              decoration: InputDecoration(
                labelText: 'Precio por Carga',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
      ),
      padding: const EdgeInsets.all(AppEspaciado.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(height: AppEspaciado.m),
          _resumenFila('Cliente', _clienteSeleccionado ?? 'Sin cliente'),
          _resumenFila('Operación', _esCompra ? 'Compra' : 'Venta'),
          _resumenFila('Tipo de Café', _tipoCafe),
          if (!_esCompra && _origenLoteAlmacenado &&
              _loteVentaId != null) ...[
            _resumenFila('Origen', _origenLoteVentaLabel),
          ],
          if (_tipoCafe == 'Seco') ...[
            _resumenFila(
              'Peso Inicial',
              '${double.tryParse(_pesoController.text) ?? 0.0} kg',
            ),
            _resumenFila(
              'Descuento Empaque',
              '${double.tryParse(_descuentoEmpaqueKgController.text) ?? 0.0} kg',
            ),
            _resumenFila(
              'Peso Final',
              '${_pesoNeto.toStringAsFixed(2)} kg',
            ),
            SizedBox(height: AppEspaciado.m),
            Container(
              padding: const EdgeInsets.all(AppEspaciado.m),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _resumenFila(
                    'Gramera',
                    _grameraController.text.isEmpty
                        ? '--'
                        : '${_grameraController.text} g',
                  ),
                  SizedBox(height: AppEspaciado.s),
                  _resumenFila(
                    'Factor',
                    _factorRendimiento.toStringAsFixed(2),
                  ),
                  SizedBox(height: AppEspaciado.s),
                  _resumenFila(
                    'Precio Inicial',
                    CurrencyFormatter.formatValue(
                      _parseFormattedCurrency(_precioCargaController.text),
                    ),
                  ),
                  SizedBox(height: AppEspaciado.s),
                  _resumenFila(
                    'Precio Final Carga',
                    CurrencyFormatter.formatValue(_precioFinalCarga),
                  ),
                ],
              ),
            ),
          ] else if (_tipoCafe == 'Mojado') ...[
            _resumenFila(
              'Peso Bruto',
              '${double.tryParse(_pesoBrutoController.text) ?? 0.0} kg',
            ),
            _resumenFila(
              'Descuento Humedad',
              '${double.tryParse(_descuentoHumedadKgController.text) ?? 0.0} %',
            ),
            _resumenFila(
              'Merma',
              '${_descuentoHumedadKgCalculado.toStringAsFixed(2)} kg',
            ),
            _resumenFila(
              'Peso Final',
              '${_pesoNeto.toStringAsFixed(2)} kg',
            ),
          ] else ...[
            _resumenFila('Peso Neto', '${_pesoNeto.toStringAsFixed(2)} kg'),
          ],
          _resumenFila('Precio/kg', CurrencyFormatter.formatValue(_precioKg)),
          if (_pendientePago) ...[
            SizedBox(height: AppEspaciado.m),
            Container(
              padding: const EdgeInsets.all(AppEspaciado.m),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _resumenFila('Estado', '🟡 Pendiente de Liquidar'),
                  SizedBox(height: AppEspaciado.s),
                  _resumenFila(
                    'Anticipo Entregado (caja)',
                    CurrencyFormatter.formatValue(_anticipo),
                  ),
                  SizedBox(height: AppEspaciado.s),
                  Text(
                    'Saldo final: se calcula en liquidación',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppEspaciado.m),
          Container(
            padding: const EdgeInsets.all(AppEspaciado.m),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
            ),
            child: _pendientePago
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTADO: PENDIENTE DE LIQUIDAR',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppEspaciado.m),
                      Text(
                        '• Los ${_pesoNeto.toStringAsFixed(2)} kg de $_tipoCafe quedan en bodega bajo estado "Pendiente"',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: AppEspaciado.s),
                      Text(
                        '• Anticipo entregado: ${CurrencyFormatter.formatValue(_anticipo)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: AppEspaciado.s),
                      Text(
                        '• El valor final se liquida según el precio en ese momento',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'VALOR TOTAL',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            CurrencyFormatter.formatValue(
                              _ajusteManualTotal
                                  ? _valorTotal
                                  : _parseFormattedCurrency(
                                      _valorTotalController.text,
                                    ),
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)
                                .copyWith(
                                  color: Theme.of(context)
                                      .extension<CoffeeCustomTheme>()!
                                      .transaccionesTotalValueTextColor,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppEspaciado.m),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Ajustar valor total manualmente'),
                        subtitle: const Text(
                          'Desactive para calcularlo automáticamente.',
                          style: TextStyle(fontSize: AppEscalaTipografica.notas),
                        ),
                        value: _ajusteManualTotal,
                        onChanged: (v) {
                          setState(() => _ajusteManualTotal = v);
                          _actualizarCalculos();
                        },
                      ),
                      if (_ajusteManualTotal) ...[
                        SizedBox(height: AppEspaciado.m),
                        TextFormField(
                          controller: _valorTotalController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CurrencyFormatter()],
                          decoration: InputDecoration(
                            labelText: 'Valor total',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppEspaciado.radioLg,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _resumenFila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppEspaciado.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            valor,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBotones() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _limpiarFormulario,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppEspaciado.m),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text('Limpiar'),
          ),
        ),
        SizedBox(width: AppEspaciado.m),
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppEspaciado.m),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text('Volver'),
          ),
        ),
        SizedBox(width: AppEspaciado.m),
        Expanded(
          child: ElevatedButton(
            onPressed: _guardarTransaccion,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppEspaciado.m),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Guardar'),
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidacion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estado de Liquidación',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _pendientePago,
                  onChanged: (value) {
                    setState(() => _pendientePago = value);
                    _actualizarCalculos();
                  },
                ),
              ],
            ),
            SizedBox(height: AppEspaciado.m),
            Text(
              _pendientePago
                  ? 'Pendiente de Pago - Se generará deuda'
                  : 'Pago de Contado - Se actualiza caja inmediatamente',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_pendientePago) ...[
              SizedBox(height: AppEspaciado.l),
              TextFormField(
                controller: _anticipoController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyFormatter()],
                decoration: InputDecoration(
                  labelText: 'Anticipo (Entrega Parcial)',
                  hintText: 'Monto a entregar ahora',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                  ),
                ),
              ),
              SizedBox(height: AppEspaciado.m),
              Container(
                padding: const EdgeInsets.all(AppEspaciado.m),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'El saldo final se calculará en liquidación según el precio de ese momento',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppEspaciado.m),
                    _resumenFilaLiquidacion(
                      'Valor Estimado del Café',
                      CurrencyFormatter.formatValue(_valorTotal),
                    ),
                    SizedBox(height: AppEspaciado.s),
                    _resumenFilaLiquidacion(
                      'Anticipo a Entregar',
                      CurrencyFormatter.formatValue(_anticipo),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resumenFilaLiquidacion(
    String label,
    String valor, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: AppEspaciado.xs),
        Text(
          valor,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight
                ? Theme.of(context).colorScheme.secondary
                : null,
          ),
        ),
      ],
    );
  }
}
