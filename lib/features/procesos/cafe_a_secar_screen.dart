// ==================== ARCHIVO: lib/features/procesos/cafe_a_secar_screen.dart ====================
// Café a Secar — Informe Global §3.4.2. Gestiona el café que ingresa al
// proceso de secado: permite registrar la Entrada de Lote (ventana
// emergente con peso, tipo de café de origen y precio estimado de costo
// inicial) y lista los lotes pendientes de pasar al proceso de secado.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../caja/caja_provider.dart';
import '../clientes/providers/cliente_provider.dart';
import '../configuraciones/configuraciones_provider.dart';
import 'procesos_provider.dart';

class CafeASecarScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const CafeASecarScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(procesosProvider);
    final lotesSecado = estado.cafeASecar;
    final pesoTotal = lotesSecado.fold<double>(0, (s, l) => s + l.pesoNeto);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Café a Secar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppPaletaOficial.cafe,
            padding: const EdgeInsets.all(AppEspaciado.m),
            child: Row(
              children: [
                const Icon(Icons.dry_cleaning, color: AppPaletaOficial.blanco),
                const SizedBox(width: AppEspaciado.s),
                Expanded(
                  child: Text(
                    'Pendiente de Secar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppPaletaOficial.blanco,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '${lotesSecado.length} lotes · ${_formatearPeso(pesoTotal)} kg',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPaletaOficial.blanco,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppEspaciado.m,
              AppEspaciado.m,
              AppEspaciado.m,
              0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _mostrarDialogoIngreso(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Ingresar café a secar'),
              ),
            ),
          ),
          Expanded(
            child: lotesSecado.isEmpty
                ? const _SinSecado()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppEspaciado.m),
                    itemCount: lotesSecado.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppEspaciado.s),
                    itemBuilder: (context, index) {
                      final lote = lotesSecado[index];
                      final enSecado = lote.estado == EstadoBodega.secado;
                      return Card(
                        elevation: 0,
                        color: AppPaletaOficial.blanco,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppEspaciado.radioEstandar,
                          ),
                          side: const BorderSide(color: Color(0xFFE0D8D0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppEspaciado.m),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lote.nombreCliente.isEmpty
                                              ? lote.tipoCafe.etiqueta
                                              : lote.nombreCliente,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                AppEscalaTipografica.subtitulo,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppEspaciado.xs,
                                        ),
                                        Text(
                                          '${lote.tipoCafe.etiqueta} · '
                                          '${_formatearPeso(lote.pesoNeto)} kg · '
                                          '${CurrencyFormatter.formatValue(lote.precioEstimadoInicial)}',
                                          style: const TextStyle(
                                            fontSize:
                                                AppEscalaTipografica.cuerpo,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (enSecado)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppEspaciado.m,
                                        vertical: AppEspaciado.s,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppPaletaOficial.verde,
                                        borderRadius: BorderRadius.circular(
                                          AppEspaciado.radioEstandar,
                                        ),
                                      ),
                                      child: const Text(
                                        'EN SECADO',
                                        style: TextStyle(
                                          color: AppPaletaOficial.blanco,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              AppEscalaTipografica.notas,
                                        ),
                                      ),
                                    )
                                  else
                                    FilledButton.icon(
                                      onPressed: () {
                                        ref
                                            .read(procesosProvider.notifier)
                                            .enviarASecado(lote.id);
                                        Notificaciones.exito(
                                          context,
                                          'Lote enviado a secado',
                                        );
                                      },
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Secar'),
                                    ),
                                ],
                              ),
                              if (enSecado) ...[
                                const SizedBox(height: AppEspaciado.s),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _mostrarDialogoCierre(
                                      context,
                                      ref,
                                      lote,
                                    ),
                                    icon: const Icon(Icons.lock_clock),
                                    label: const Text('Cerrar Lote'),
                                  ),
                                ),
                              ],
                            ],
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

  void _mostrarDialogoIngreso(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => const _DialogoIngresoASecar(),
    );
  }

  void _mostrarDialogoCierre(BuildContext context, WidgetRef ref, LoteBodega lote) {
    showDialog<void>(
      context: context,
      builder: (_) => _DialogoCierreLote(lote: lote),
    );
  }

  String _formatearPeso(double peso) {
    return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 1);
  }
}

class _DialogoIngresoASecar extends ConsumerStatefulWidget {
  const _DialogoIngresoASecar();

  @override
  ConsumerState<_DialogoIngresoASecar> createState() =>
      _DialogoIngresoASecarState();
}

class _DialogoIngresoASecarState extends ConsumerState<_DialogoIngresoASecar> {
  final _formulario = GlobalKey<FormState>();
  final _controladorPeso = TextEditingController();
  final _controladorPrecio = TextEditingController();
  TipoCafeProceso _tipoCafe = TipoCafeProceso.mojado;
  String? _error;

  @override
  void dispose() {
    _controladorPeso.dispose();
    _controladorPrecio.dispose();
    super.dispose();
  }

  double get _stockDisponible {
    return ref.read(procesosProvider).stockDisponibleDe(_tipoCafe);
  }

  double _parsearPeso(String texto) {
    return double.tryParse(texto.replaceAll(',', '.')) ?? 0;
  }

  String _formatearPeso(double peso) {
    return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 1);
  }

  void _confirmar() {
    if (!_formulario.currentState!.validate()) return;

    final mensajeError = ref
        .read(procesosProvider.notifier)
        .ingresarASecar(
          tipoCafe: _tipoCafe,
          peso: _parsearPeso(_controladorPeso.text),
          precioEstimado: CurrencyFormatter.parseValue(_controladorPrecio.text),
        );

    if (mensajeError != null) {
      setState(() => _error = mensajeError);
      return;
    }

    _mostrarExitoSecado(
      tipoCafe: _tipoCafe,
      peso: _parsearPeso(_controladorPeso.text),
      precioEstimado: CurrencyFormatter.parseValue(_controladorPrecio.text),
    );
  }

  // §3.4.2 — Transacción Exitosa: Compartir PDF / Salir.
  Future<void> _mostrarExitoSecado({
    required TipoCafeProceso tipoCafe,
    required double peso,
    required double precioEstimado,
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
              Text('Lote enviado al proceso de secado'),
              const SizedBox(height: AppEspaciado.s),
              Text(
                '${tipoCafe.etiqueta} · ${_formatearPeso(peso)} kg',
              ),
              const SizedBox(height: AppEspaciado.s),
              Text(
                'Precio estimado de costo inicial: '
                '${CurrencyFormatter.formatValue(precioEstimado)}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _compartirSecado(
                tipoCafe: tipoCafe,
                peso: peso,
                precioEstimado: precioEstimado,
              );
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
    // Cierra también el diálogo de ingreso que quedó debajo.
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _compartirSecado({
    required TipoCafeProceso tipoCafe,
    required double peso,
    required double precioEstimado,
  }) async {
    final config = ref.read(configuracionesProvider);
    final ok = await ComprobanteServicio.instancia.compartirPdf(
      encabezado: config.factura.aEncabezadoComprobante,
      titulo: 'Entrada de Lote a Secado',
      lineas: [
        const LineaComprobante.texto('ENTRADA DE LOTE A SECADO'),
        LineaComprobante.campo(
          'Tipo de café',
          tipoCafe.etiqueta,
        ),
        LineaComprobante.campo('Peso', '${_formatearPeso(peso)} kg'),
        LineaComprobante.campo(
          'Precio estimado de costo',
          CurrencyFormatter.formatValue(precioEstimado),
          enNegrita: true,
        ),
      ],
    );
    if (!mounted) return;
    if (!ok) {
      Notificaciones.error(
        context,
        'No fue posible generar o compartir el PDF del comprobante.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stock = _stockDisponible;
    return AlertDialog(
      title: const Text('Ingresar café a secar'),
      content: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<TipoCafeProceso>(
                initialValue: _tipoCafe,
                decoration: const InputDecoration(
                  labelText: 'Tipo de café de origen',
                ),
                items: [
                  for (final tipo in [
                    TipoCafeProceso.mojado,
                    TipoCafeProceso.oreado,
                    TipoCafeProceso.seco,
                    TipoCafeProceso.pasilla,
                  ])
                    DropdownMenuItem(value: tipo, child: Text(tipo.etiqueta)),
                ],
                onChanged: (valor) {
                  if (valor != null) setState(() => _tipoCafe = valor);
                },
              ),
              const SizedBox(height: AppEspaciado.xs),
              Text(
                'Disponible en bodega común: ${_formatearPeso(stock)} kg',
                style: const TextStyle(
                  fontSize: AppEscalaTipografica.notas,
                  color: AppPaletaOficial.cafe,
                ),
              ),
              const SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _controladorPeso,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Peso del café (kg)',
                  hintText: '0.0',
                  suffixText: 'kg',
                ),
                validator: (valor) {
                  final texto = valor?.trim() ?? '';
                  if (texto.isEmpty) return 'Ingrese el peso del café.';
                  final peso = _parsearPeso(texto);
                  if (peso <= 0) return 'El peso debe ser mayor a cero.';
                  if (peso > stock) {
                    return 'Solo hay ${_formatearPeso(stock)} kg disponibles '
                        'en la bodega común.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _controladorPrecio,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Precio estimado de costo inicial',
                ),
                validator: CurrencyFormatter.validar,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppEspaciado.m),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppPaletaOficial.rojo,
                    fontSize: AppEscalaTipografica.notas,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

class _SinSecado extends StatelessWidget {
  const _SinSecado();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.dry_cleaning_outlined,
            size: 56,
            color: Color(0xFFB0ACA7),
          ),
          SizedBox(height: AppEspaciado.m),
          Text(
            'No hay café en el proceso de secado',
            style: TextStyle(fontSize: AppEscalaTipografica.cuerpo),
          ),
        ],
      ),
    );
  }
}

/// §3.4.2 Cierre de Lote — diálogo que concluye el proceso de secado de
/// un lote con merma/rendimiento en vivo y las acciones "Almacenar"
/// (constituye el lote `pro-#####` en Almacenado) o "Vender" (lo cierra
/// y lo vende de contado como SECADO §3.4.1).
class _DialogoCierreLote extends ConsumerStatefulWidget {
  final LoteBodega lote;

  const _DialogoCierreLote({required this.lote});

  @override
  ConsumerState<_DialogoCierreLote> createState() =>
      _DialogoCierreLoteState();
}

class _DialogoCierreLoteState
    extends ConsumerState<_DialogoCierreLote> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _controladorPesoSeco;
  final _controladorPrecioCarga = TextEditingController();
  String? _clienteSeleccionado;
  bool _vender = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controladorPesoSeco = TextEditingController(
      text: widget.lote.pesoNeto.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _controladorPesoSeco.dispose();
    _controladorPrecioCarga.dispose();
    super.dispose();
  }

  double get _pesoHumedoSecado => widget.lote.pesoNeto;

  double get _pesoSecoFinal {
    return double.tryParse(_controladorPesoSeco.text.replaceAll(',', '.')) ??
        0;
  }

  double get _merma => _pesoHumedoSecado - _pesoSecoFinal;

  double get _rendimiento {
    if (_pesoHumedoSecado <= 0) return 0;
    return (_pesoSecoFinal / _pesoHumedoSecado) * 100;
  }

  double get _precioCarga {
    return CurrencyFormatter.parseValue(_controladorPrecioCarga.text);
  }

  String _formatearPeso(double peso) {
    return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 1);
  }

  Future<void> _confirmar() async {
    if (!_formulario.currentState!.validate()) return;
    if (_vender && _clienteSeleccionado == null) {
      setState(() => _error = 'Seleccione el cliente de la venta.');
      return;
    }

    final notifier = ref.read(procesosProvider.notifier);
    final pesoSeco = _pesoSecoFinal;

    try {
      if (_vender) {
        final clientes = ref.read(clienteProvider).clientes;
        final cliente = clientes.firstWhere(
          (c) => c.id == _clienteSeleccionado,
          orElse: () => clientes.first,
        );
        final precioCarga = _precioCarga;
        final precioKg = precioCarga / 125;
        final valor = pesoSeco * precioKg;
        final transaccion = await notifier.venderLoteSecado(
          loteId: widget.lote.id,
          pesoSecoFinal: pesoSeco,
          precioCarga: precioCarga,
          precioKg: precioKg,
          valorTotal: valor,
          factorRendimiento: 88,
          porcentajeAjuste: 0,
          precioFinalCarga: precioCarga,
          clienteId: cliente.id,
          nombreCliente: cliente.nombreCompleto,
        );
        if (!mounted) return;
        Navigator.of(context).pop();
        _mostrarResultado(
          titulo: 'Lote vendido',
          codigoLote: transaccion.loteBodegaId != null
              ? _codigoDeLote(transaccion.loteBodegaId!)
              : '--',
          detalle:
              '${_formatearPeso(pesoSeco)} kg SECADO vendidos por '
              '${CurrencyFormatter.formatValue(valor)}',
        );
      } else {
        final constituido = notifier.cerrarLoteSecado(
          loteId: widget.lote.id,
          pesoHumedoSecado: _pesoHumedoSecado,
          pesoSecoFinal: pesoSeco,
        );
        if (!mounted) return;
        Navigator.of(context).pop();
        _mostrarResultado(
          titulo: 'Lote almacenado',
          codigoLote: constituido.codigoLote ?? '--',
          detalle:
              '${_formatearPeso(pesoSeco)} kg SECADO · costo '
              '${construirCostoKg(constituido)}',
        );
      }
    } on InventarioInsuficienteException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.mensaje);
    } on SaldoInsuficienteException {
      if (!mounted) return;
      setState(() {
        _error = 'La Caja no tiene fondos suficientes para registrar la '
            'venta. Registre una Entrada manual primero.';
      });
    } on CajaNoAbiertaException {
      if (!mounted) return;
      setState(() => _error = 'Debe abrir la Caja antes de vender.');
    }
  }

  String _codigoDeLote(int id) {
    final estado = ref.read(procesosProvider);
    for (final l in estado.almacenados) {
      if (l.id == id) return l.codigoLote ?? '--';
    }
    return '--';
  }

  String construirCostoKg(LoteBodega lote) {
    return lote.costoKg > 0
        ? '\$${lote.costoKg.toStringAsFixed(2)}/kg'
        : 'no definido';
  }

  void _mostrarResultado({
    required String titulo,
    required String codigoLote,
    required String detalle,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppPaletaOficial.verde,
          size: 40,
        ),
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lote $codigoLote'),
            const SizedBox(height: AppEspaciado.s),
            Text(detalle),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final humedo = _pesoHumedoSecado;
    return AlertDialog(
      title: const Text('Cerrar Lote de Secado'),
      content: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Peso húmedo ingresado: ${_formatearPeso(humedo)} kg',
                style: const TextStyle(
                  fontSize: AppEscalaTipografica.cuerpo,
                ),
              ),
              const SizedBox(height: AppEspaciado.m),
              TextFormField(
                controller: _controladorPesoSeco,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Peso seco final (kg)',
                  suffixText: 'kg',
                ),
                onChanged: (_) => setState(() {}),
                validator: (valor) {
                  final texto = valor?.trim() ?? '';
                  if (texto.isEmpty) return 'Ingrese el peso seco final.';
                  final peso = double.tryParse(texto.replaceAll(',', '.')) ?? 0;
                  if (peso <= 0) return 'El peso seco debe ser mayor a cero.';
                  if (peso > humedo) {
                    return 'El peso seco no puede superar el peso húmedo '
                        '(${_formatearPeso(humedo)} kg).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppEspaciado.m),
              Container(
                padding: const EdgeInsets.all(AppEspaciado.m),
                decoration: BoxDecoration(
                  color: AppPaletaOficial.cafe.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(
                    AppEspaciado.radioEstandar,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merma: ${_formatearPeso(_merma)} kg',
                      style: const TextStyle(
                        fontSize: AppEscalaTipografica.cuerpo,
                      ),
                    ),
                    const SizedBox(height: AppEspaciado.xs),
                    Text(
                      'Rendimiento: ${_rendimiento.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: AppEscalaTipografica.cuerpo,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppEspaciado.m),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vender al cerrar'),
                subtitle: const Text(
                  'Se registra venta de contado como SECADO (§3.4.1).',
                  style: TextStyle(fontSize: AppEscalaTipografica.notas),
                ),
                value: _vender,
                onChanged: (v) => setState(() => _vender = v),
              ),
              if (_vender) ...[
                const SizedBox(height: AppEspaciado.m),
                DropdownButtonFormField<String>(
                  initialValue: _clienteSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Cliente de la venta',
                  ),
                  items: [
                    for (final c in ref.watch(clienteProvider).clientes)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nombreCompleto),
                      ),
                  ],
                  onChanged: (v) => setState(() => _clienteSeleccionado = v),
                ),
                const SizedBox(height: AppEspaciado.xs),
                if (ref.watch(clienteProvider).clientes.isEmpty)
                  const Text(
                    'No hay clientes registrados. Cree uno antes de vender.',
                    style: TextStyle(
                      color: AppPaletaOficial.rojo,
                      fontSize: AppEscalaTipografica.notas,
                    ),
                  ),
                const SizedBox(height: AppEspaciado.m),
                TextFormField(
                  controller: _controladorPrecioCarga,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Precio por Carga',
                  ),
                  validator: (_) => _precioCarga > 0
                      ? null
                      : 'Ingrese el precio por carga.',
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppEspaciado.m),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppPaletaOficial.rojo,
                    fontSize: AppEscalaTipografica.notas,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _confirmar,
          icon: Icon(_vender ? Icons.sell : Icons.archive),
          label: Text(_vender ? 'Vender' : 'Almacenar'),
        ),
      ],
    );
  }
}