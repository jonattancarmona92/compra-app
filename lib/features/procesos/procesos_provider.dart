// ==================== ARCHIVO: lib/features/procesos/procesos_provider.dart ====================
// Procesos — Informe Global §3.4 (Transacciones, Café a Secar, Bodega,
// Liquidaciones) y §5.5.6/§5.5.7/§5.5.8.
// Administra la compra/venta de café, el inventario en bodega, el café
// pendiente de secado y las liquidaciones por saldos pendientes.
//
// NOTA DE INTEGRACIÓN PENDIENTE: este provider usa un repositorio en
// memoria que reproduce los campos de las tablas de Procesos. En el
// Módulo 5 (Drift) se reemplaza por consultas reales sin cambiar la
// interfaz pública del Notifier.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../caja/caja_provider.dart';

// ============================================================================
// ENUMERACIONES
// ============================================================================

enum TipoCafeProceso { mojado, oreado, seco, pasilla, secado }

extension TipoCafeProcesoLabel on TipoCafeProceso {
  String get etiqueta {
    switch (this) {
      case TipoCafeProceso.mojado:
        return 'Mojado';
      case TipoCafeProceso.oreado:
        return 'Oreado';
      case TipoCafeProceso.seco:
        return 'Seco';
      case TipoCafeProceso.pasilla:
        return 'Pasilla';
      case TipoCafeProceso.secado:
        return 'Secado';
    }
  }
}

/// §6.6.9 — prefijo del código de lote constituido según el tipo de
/// café: `moj-` (Mojado), `ore-` (Oreado), `sec-` (Seco), `pas-`
/// (Pasilla) y `pro-` (Secado/Procesado). Se asigna en el Loteado de
/// Remanentes del Cierre de Ciclo Operativo (§3.3.4/§8.2).
String prefijoLoteDe(TipoCafeProceso tipo) {
  switch (tipo) {
    case TipoCafeProceso.mojado:
      return 'moj';
    case TipoCafeProceso.oreado:
      return 'ore';
    case TipoCafeProceso.seco:
      return 'sec';
    case TipoCafeProceso.pasilla:
      return 'pas';
    case TipoCafeProceso.secado:
      return 'pro';
  }
}

enum EstadoPagoProceso { contado, pendiente }

/// §5.5.7: `estado_liquidacion` de la tabla `transacciones`. Una
/// transacción de contado nace LIQUIDADA; una pendiente queda en
/// PENDIENTE hasta su liquidación financiera o anulación.
enum EstadoLiquidacion { pendiente, liquidada }

extension EstadoLiquidacionLabel on EstadoLiquidacion {
  String get etiqueta {
    switch (this) {
      case EstadoLiquidacion.pendiente:
        return 'Pendiente de Liquidar';
      case EstadoLiquidacion.liquidada:
        return 'Liquidada';
    }
  }
}

enum EstadoBodega { pendiente, secado, listo, vendido }

enum EstadoSecado { pendiente, enSecado, terminado }

/// §5.5.8: estado de un registro de liquidación validado en Caja.
enum EstadoLiquidacionRegistro { validada, anulada }

/// Regla crítica de inventario (§3.4.1/§3.4.3): la venta desde un lote
/// de Almacenado no puede superar la existencia física del lote. Los
/// lotes constituidos tienen `peso_actual >= 0` y jamás pueden quedar
/// negativos (§5.5.6).
class InventarioInsuficienteException implements Exception {
  final String mensaje;
  const InventarioInsuficienteException(this.mensaje);

  @override
  String toString() => mensaje;
}

// ============================================================================
// MODELOS — espejo de §5.5.6 (transacciones), §5.5.7 (transacciones_pago)
// ============================================================================

class TransaccionCafe {
  final int id;
  final String clienteId;
  final String nombreCliente;
  final bool esCompra;
  final TipoCafeProceso tipoCafe;

  // Peso y descuentos físicos (§5.5.7).
  final double pesoBruto;
  final double descuentoHumedadKg; // solo café mojado (kg)
  final double pesoNeto;
  final double gramera; // solo café seco/secado (g, rango 100-250)
  final double descuentoEmpaqueKg; // solo café seco/secado (kg)

  // Precio y liquidación.
  final double precioCarga; // por carga (125 kg)
  final double factorRendimiento;
  final double porcentajeAjuste;
  final double precioFinalCarga;
  final double precioKg;
  final double valorTotal;

  // Pago.
  final EstadoPagoProceso estadoPago;
  final double anticipo;

  /// §5.5.7: 1 si la transacción fue anulada (0 si está vigente). Las
  /// transacciones anuladas se conservan para auditoría pero se
  /// excluyen de todas las consultas operativas.
  final bool anulado;

  final DateTime fechaRegistro;
  final String operador;

  /// §3.4.1 — id del lote de "Almacenado" del cual se vendió el café
  /// (venta desde lote constituido). `null` si la venta descontó de la
  /// bodega común o si es una compra. Permite reintegrar el grano al
  /// lote original al anular/cancelar (§3.4.4) y restaurar el estado
  /// AGOTADO -> DISPONIBLE (§3.4.3).
  final int? loteBodegaId;

  const TransaccionCafe({
    required this.id,
    required this.clienteId,
    required this.nombreCliente,
    required this.esCompra,
    required this.tipoCafe,
    required this.pesoBruto,
    this.descuentoHumedadKg = 0,
    required this.pesoNeto,
    this.gramera = 0,
    this.descuentoEmpaqueKg = 0,
    required this.precioCarga,
    required this.factorRendimiento,
    required this.porcentajeAjuste,
    required this.precioFinalCarga,
    required this.precioKg,
    required this.valorTotal,
    required this.estadoPago,
    required this.anticipo,
    this.anulado = false,
    required this.fechaRegistro,
    required this.operador,
    this.loteBodegaId,
  });

  /// §5.5.7: `estado_liquidacion`. De contado = LIQUIDADA; con saldo
  /// pendiente = PENDIENTE.
  EstadoLiquidacion get estadoLiquidacion =>
      estadoPago == EstadoPagoProceso.pendiente
          ? EstadoLiquidacion.pendiente
          : EstadoLiquidacion.liquidada;

  double get saldoPendiente => valorTotal - anticipo;

  TransaccionCafe copyWith({bool? anulado, int? loteBodegaId}) {
    return TransaccionCafe(
      id: id,
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      esCompra: esCompra,
      tipoCafe: tipoCafe,
      pesoBruto: pesoBruto,
      descuentoHumedadKg: descuentoHumedadKg,
      pesoNeto: pesoNeto,
      gramera: gramera,
      descuentoEmpaqueKg: descuentoEmpaqueKg,
      precioCarga: precioCarga,
      factorRendimiento: factorRendimiento,
      porcentajeAjuste: porcentajeAjuste,
      precioFinalCarga: precioFinalCarga,
      precioKg: precioKg,
      valorTotal: valorTotal,
      estadoPago: estadoPago,
      anticipo: anticipo,
      anulado: anulado ?? this.anulado,
      fechaRegistro: fechaRegistro,
      operador: operador,
      loteBodegaId: loteBodegaId ?? this.loteBodegaId,
    );
  }
}

/// §5.5.8 — registro de una liquidación validada en Caja. Se crea al
/// cerrar financieramente una transacción pendiente (compra o venta).
class LiquidacionRegistro {
  final int id;
  final int transaccionId;
  final String clienteId;
  final String nombreCliente;
  final bool esCompra;
  final TipoCafeProceso tipoCafe;
  final double pesoNeto;

  /// Importe final de la transacción en el momento de liquidar.
  final double montoTotalTransaccion;

  /// Anticipos de efectivo ya entregados antes de la liquidación.
  final double montoAnticiposPrevios;

  /// Efectivo final entregado o recibido en Caja (monto total - anticipos).
  final double saldoNetoPagado;

  final EstadoLiquidacionRegistro estado;
  final DateTime fechaLiquidacion;
  final String? motivoAnulacion;

  const LiquidacionRegistro({
    required this.id,
    required this.transaccionId,
    required this.clienteId,
    required this.nombreCliente,
    required this.esCompra,
    required this.tipoCafe,
    required this.pesoNeto,
    required this.montoTotalTransaccion,
    required this.montoAnticiposPrevios,
    required this.saldoNetoPagado,
    required this.estado,
    required this.fechaLiquidacion,
    this.motivoAnulacion,
  });

  LiquidacionRegistro copyWith({
    EstadoLiquidacionRegistro? estado,
    String? motivoAnulacion,
  }) {
    return LiquidacionRegistro(
      id: id,
      transaccionId: transaccionId,
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      esCompra: esCompra,
      tipoCafe: tipoCafe,
      pesoNeto: pesoNeto,
      montoTotalTransaccion: montoTotalTransaccion,
      montoAnticiposPrevios: montoAnticiposPrevios,
      saldoNetoPagado: saldoNetoPagado,
      estado: estado ?? this.estado,
      fechaLiquidacion: fechaLiquidacion,
      motivoAnulacion: motivoAnulacion ?? this.motivoAnulacion,
    );
  }
}

/// Lote de café en bodega — §5.5.8 (lotes / inventario).
class LoteBodega {
  final int id;
  final int transaccionId;
  final String clienteId;
  final String nombreCliente;
  final TipoCafeProceso tipoCafe;
  final double pesoNeto;
  final EstadoBodega estado;
  final DateTime fechaIngreso;

  /// Precio estimado de costo inicial registrado en la Entrada de Lote
  /// de secado (§3.4.2). Cero cuando el lote proviene de una transacción
  /// de compra/venta sin estimación de secado.
  final double precioEstimadoInicial;

  /// §5.5.6 `costo_inicial_kg` — costo unitario por kilogramo del lote
  /// constituido. En el Loteado de Remanentes se congela el costo medio
  /// ponderado de las compras del ciclo; en el lote secado se re-expresa
  /// sobre el peso seco (§7.4). No participa en el flujo de Caja.
  final double costoKg;

  /// Código de lote constituido (p. ej. `sec-00001`) asignado en el
  /// Loteado de Remanentes del Cierre de Ciclo Operativo (§6.6.9) o al
  /// Almacenar un lote de secado (§3.4.2). `null` mientras el café
  /// permanece en la bodega común sin serie.
  final String? codigoLote;

  const LoteBodega({
    required this.id,
    required this.transaccionId,
    required this.clienteId,
    required this.nombreCliente,
    required this.tipoCafe,
    required this.pesoNeto,
    required this.estado,
    required this.fechaIngreso,
    this.precioEstimadoInicial = 0,
    this.costoKg = 0,
    this.codigoLote,
  });

  LoteBodega copyWith({
    EstadoBodega? estado,
    double? pesoNeto,
    double? precioEstimadoInicial,
    double? costoKg,
    String? codigoLote,
  }) {
    return LoteBodega(
      id: id,
      transaccionId: transaccionId,
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      tipoCafe: tipoCafe,
      pesoNeto: pesoNeto ?? this.pesoNeto,
      estado: estado ?? this.estado,
      fechaIngreso: fechaIngreso,
      precioEstimadoInicial:
          precioEstimadoInicial ?? this.precioEstimadoInicial,
      costoKg: costoKg ?? this.costoKg,
      codigoLote: codigoLote ?? this.codigoLote,
    );
  }
}

// ============================================================================
// ESTADO
// ============================================================================

/// §6.6.9 — resumen del Cierre de Ciclo Operativo agrupado por tipo de
/// café: cafés comprados/vendidos del ciclo y remanente en bodega común.
class ResumenCicloPorTipo {
  final TipoCafeProceso tipo;
  final double kilosCompra;
  final double valorCompra;
  final double kilosVenta;
  final double valorVenta;

  /// Kilos de este tipo aún en la bodega común (sin lote constituido).
  final double kilosBodegaComun;

  const ResumenCicloPorTipo({
    required this.tipo,
    required this.kilosCompra,
    required this.valorCompra,
    required this.kilosVenta,
    required this.valorVenta,
    required this.kilosBodegaComun,
  });
}

class ProcesosEstado {
  final bool isCargando;
  final List<TransaccionCafe> transacciones;

  /// §5.5.8 — registros de liquidaciones validadas/anuladas en Caja.
  final List<LiquidacionRegistro> liquidaciones;
  final List<LoteBodega> lotes;

  const ProcesosEstado({
    this.isCargando = true,
    this.transacciones = const [],
    this.liquidaciones = const [],
    this.lotes = const [],
  });

  ProcesosEstado copyWith({
    bool? isCargando,
    List<TransaccionCafe>? transacciones,
    List<LiquidacionRegistro>? liquidaciones,
    List<LoteBodega>? lotes,
  }) {
    return ProcesosEstado(
      isCargando: isCargando ?? this.isCargando,
      transacciones: transacciones ?? this.transacciones,
      liquidaciones: liquidaciones ?? this.liquidaciones,
      lotes: lotes ?? this.lotes,
    );
  }

  List<TransaccionCafe> get transaccionesOrdenadas =>
      [...transacciones]
        .where((t) => !t.anulado)
        .toList()
        ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

  /// §3.4.2: café que está en el proceso de secado: el mojado pendiente
  /// de pasar a secado y los lotes ya ingresados a secar (de cualquier
  /// tipo de café de origen).
  List<LoteBodega> get cafeASecar {
    return lotes
        .where(
          (l) =>
              l.estado == EstadoBodega.secado ||
              (l.tipoCafe == TipoCafeProceso.mojado &&
                  l.estado == EstadoBodega.pendiente),
        )
        .toList();
  }

  /// §3.4.1 — existencia acumulada de la bodega común: los lotes aún sin
  /// serie (estado `pendiente`) provenientes de compras de contado.
  List<LoteBodega> get bodega =>
      [...lotes]
          .where((l) => l.estado == EstadoBodega.pendiente)
          .toList()
        ..sort((a, b) => b.fechaIngreso.compareTo(a.fechaIngreso));

  /// §3.4.3 Pestaña Almacenado — lotes constituidos (con `codigoLote`).
  /// Estados válidos: `listo` (Disponible) y `vendido` (Agotado).
  List<LoteBodega> get almacenados {
    return lotes.where((l) => l.codigoLote != null).toList()
      ..sort((a, b) => b.fechaIngreso.compareTo(a.fechaIngreso));
  }

  /// §3.4.3 — lotes constituidos con existencia física vendible.
  List<LoteBodega> get almacenadosDisponibles {
    return almacenados
        .where((l) => l.estado == EstadoBodega.listo && l.pesoNeto > 0)
        .toList();
  }

  /// §3.4.3 — histórico de lotes agotados/liquidados (estado `vendido`).
  List<LoteBodega> get almacenadosAgotados {
    return almacenados
        .where((l) => l.estado == EstadoBodega.vendido)
        .toList();
  }

  /// §3.4.3 Pestaña Bodega — cantidades físicas de la bodega común sin
  /// lote, agrupadas por tipo de café (solo existencias mayores a cero).
  Map<TipoCafeProceso, double> get bodegaComunPorTipo {
    final resumen = <TipoCafeProceso, double>{};
    for (final lote in lotes) {
      if (lote.estado != EstadoBodega.pendiente) continue;
      resumen[lote.tipoCafe] =
          (resumen[lote.tipoCafe] ?? 0) + lote.pesoNeto;
    }
    return resumen;
  }

  /// §3.4.2: stock disponible en la bodega común de un tipo de café
  /// (suma de los lotes pendientes). La Entrada de Lote descuenta de aquí.
  double stockDisponibleDe(TipoCafeProceso tipo) {
    return lotes
        .where((l) => l.tipoCafe == tipo && l.estado == EstadoBodega.pendiente)
        .fold<double>(0, (suma, l) => suma + l.pesoNeto);
  }

  /// §3.4: transacciones con saldo pendiente de liquidar.
  List<TransaccionCafe> get liquidacionesPendientes {
    return [...transacciones]
        .where(
          (t) =>
              !t.anulado &&
              t.estadoPago == EstadoPagoProceso.pendiente,
        )
        .toList()
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
  }

  /// §3.4.4 pestaña "Liquidadas": transacciones saldadas en Caja al 100%
  /// (no anuladas).
  List<TransaccionCafe> get liquidacionesLiquidadas {
    return [...transacciones]
        .where(
          (t) =>
              !t.anulado &&
              t.estadoPago == EstadoPagoProceso.contado,
        )
        .toList()
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
  }

  /// §5.5.8 — registros de liquidación validados vigentes (no anulados),
  /// ordenados del más reciente al más antiguo para el historial de la
  /// pestaña "Liquidadas".
  List<LiquidacionRegistro> get liquidacionesRegistradas {
    return [...liquidaciones]
        .where((l) => l.estado == EstadoLiquidacionRegistro.validada)
        .toList()
      ..sort(
        (a, b) => b.fechaLiquidacion.compareTo(a.fechaLiquidacion),
      );
  }

  /// §3.3.4/§6.6.9 — compras con saldo pendiente de liquidar. Su sola
  /// existencia bloquea absolutamente el Cierre de Ciclo Operativo.
  List<TransaccionCafe> get comprasPendientes {
    return [...transacciones]
        .where(
          (t) =>
              !t.anulado &&
              t.esCompra &&
              t.estadoPago == EstadoPagoProceso.pendiente,
        )
        .toList()
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
  }

  /// §3.3.4/§6.6.9 — ventas con saldo pendiente. No bloquean el Cierre
  /// de Ciclo Operativo: solo se informan y conservan en el nuevo ciclo.
  List<TransaccionCafe> get ventasPendientes {
    return [...transacciones]
        .where(
          (t) =>
              !t.anulado &&
              !t.esCompra &&
              t.estadoPago == EstadoPagoProceso.pendiente,
        )
        .toList()
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
  }

  /// §3.4 — kilos totales de café en la bodega común (lotes pendientes
  /// de constituir). Indicador del remanente por nivelar en el cierre.
  double get totalBodegaComun {
    return lotes
        .where((l) => l.estado == EstadoBodega.pendiente)
        .fold<double>(0, (suma, l) => suma + l.pesoNeto);
  }

  /// §6.6.9 — agrupación por tipo de café para el reporte del Cierre
  /// de Ciclo Operativo (cafés comprados/vendidos y remanente).
  List<ResumenCicloPorTipo> get resumenPorTipoDeCafe {
    return [
      for (final tipo in TipoCafeProceso.values)
        ResumenCicloPorTipo(
          tipo: tipo,
          kilosCompra: _sumar(tipo, true, (t) => t.pesoNeto),
          valorCompra: _sumar(tipo, true, (t) => t.valorTotal),
          kilosVenta: _sumar(tipo, false, (t) => t.pesoNeto),
          valorVenta: _sumar(tipo, false, (t) => t.valorTotal),
          kilosBodegaComun: stockDisponibleDe(tipo),
        ),
    ];
  }

  double _sumar(
    TipoCafeProceso tipo,
    bool esCompra,
    double Function(TransaccionCafe) selector,
  ) {
    return transacciones
        .where((t) => !t.anulado && t.tipoCafe == tipo && t.esCompra == esCompra)
        .fold<double>(0, (suma, t) => suma + selector(t));
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

class ProcesosNotifier extends StateNotifier<ProcesosEstado> {
  ProcesosNotifier(this._ref) : super(const ProcesosEstado()) {
    _cargarSimulado();
  }

  final Ref _ref;

  int _correlativo = 1;
  int _correlativoLiquidacion = 1;

  // NOTA DE INTEGRACIÓN PENDIENTE: el operador autenticado debe venir
  // de control_inicio_provider.dart. Por ahora se usa un valor fijo.
  static const String _operadorActual = 'operador_demo';

  /// §3.9.1 — canal abstracto hacia el Módulo de Caja (§6.4.1: Procesos
  /// depende de Caja para inyectar egresos/ingresos de contado,
  /// anticipos o abonos). Caja no conoce el negocio cafetero; solo
  /// recibe el movimiento ya resuelto.
  Future<void> _registrarEnCaja({
    required TipoMovimientoCaja tipo,
    required double monto,
    required String concepto,
    required int origenId,
  }) {
    return _ref.read(cajaProvider.notifier).registrarMovimientoAutomatico(
          tipo: tipo,
          monto: monto,
          concepto: concepto,
          origenTabla: 'transacciones',
          origenId: origenId,
          operador: _operadorActual,
        );
  }

  String _formatearCantidad(double valor) {
    return valor.toStringAsFixed(valor == valor.roundToDouble() ? 0 : 1);
  }

  void _cargarSimulado() {
    state = state.copyWith(
      isCargando: false,
      transacciones: const [],
      liquidaciones: const [],
      lotes: const [],
    );
  }

  // ==========================================================================
  // REGISTRO DE TRANSACCIÓN (Compra/Venta de café)
  // ==========================================================================

  /// §3.4.1/§3.9.1 — Registra una compra/venta de café aplicando los
  /// efectos físicos y financieros de forma atómica:
  ///
  /// Bodega (§3.4.1):
  ///   - Compra: aumenta de inmediato la disponibilidad de Bodega común
  ///     (lote en estado "pendiente", sin serie, listo para el Loteado
  ///     de Remanentes del cierre).
  ///   - Venta directa (sin [loteBodegaId]): descuenta de la existencia
  ///     acumulada común en orden FIFO con piso mínimo de 0 kg.
  ///   - Venta desde lote (con [loteBodegaId]): descuenta del lote de
  ///     "Almacenado" constituido (parcial: sigue DISPONIBLE; 100%: pasa
  ///     a AGOTADO §3.4.3). Si se vende el 100% del lote, la transacción
  ///     se registra SIEMPRE como LIQUIDADA (nunca pendiente, §3.4.1).
  ///
  /// Caja (§3.9.1):
  ///   - Compra de contado: salida por el valor total.
  ///   - Compra pendiente con anticipo: salida por el anticipo.
  ///   - Venta de contado: entrada por el valor total.
  ///   - Venta pendiente sin cobro / compra pendiente sin anticipo:
  ///     la Caja no cambia (cuenta por cobrar / por pagar).
  ///
  /// El movimiento a Caja se aplica ANTES de consolidar la transacción
  /// en el estado: si la Caja bloquea por insolvencia (§3.3.1), la
  /// transacción NO se registra. Lanza [SaldoInsuficienteException],
  /// [CajaNoAbiertaException] o [InventarioInsuficienteException]
  /// (regla crítica: prohibido el inventario negativo en lotes §3.4.3).
  Future<TransaccionCafe> registrarTransaccion({
    required String clienteId,
    required String nombreCliente,
    required bool esCompra,
    required TipoCafeProceso tipoCafe,
    required double pesoBruto,
    double descuentoHumedadKg = 0,
    double pesoNeto = 0,
    double gramera = 0,
    double descuentoEmpaqueKg = 0,
    required double precioCarga,
    required double precioKg,
    required double valorTotal,
    required double factorRendimiento,
    required double porcentajeAjuste,
    required double precioFinalCarga,
    required EstadoPagoProceso estadoPago,
    double anticipo = 0,
    String operador = 'operador_demo',
    int? loteBodegaId,
  }) async {
    // §3.4.1 — venta desde un lote constituido de "Almacenado".
    final ventaDesdeLote = !esCompra && loteBodegaId != null;
    LoteBodega? loteAlmacenado;
    double pesoRestanteLote = 0;
    if (ventaDesdeLote) {
      for (final l in state.lotes) {
        if (l.id == loteBodegaId && l.codigoLote != null) {
          loteAlmacenado = l;
          break;
        }
      }
      final lote = loteAlmacenado;
      if (lote == null) {
        throw InventarioInsuficienteException(
          'El lote seleccionado ya no existe en Almacenado.',
        );
      }
      if (lote.estado != EstadoBodega.listo) {
        throw InventarioInsuficienteException(
          'El lote ${lote.codigoLote} no está disponible para la venta '
          '(estado: ${lote.estado.name}).',
        );
      }
      if (pesoNeto > lote.pesoNeto) {
        throw InventarioInsuficienteException(
          'El lote ${lote.codigoLote} solo tiene '
          '${_formatearCantidad(lote.pesoNeto)} kg disponibles.',
        );
      }
      loteAlmacenado = lote;
      pesoRestanteLote = lote.pesoNeto - pesoNeto;
    }

    // §3.4.1: la venta del 100% de un lote se registra siempre como
    // LIQUIDADA (contado); nunca queda como venta pendiente.
    final ventaLoteCompleto = ventaDesdeLote && pesoRestanteLote <= 0;
    final estadoPagoReal = ventaLoteCompleto
        ? EstadoPagoProceso.contado
        : estadoPago;
    final anticipoReal = ventaLoteCompleto ? 0.0 : anticipo;

    final transaccion = TransaccionCafe(
      id: _correlativo++,
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      esCompra: esCompra,
      tipoCafe: tipoCafe,
      pesoBruto: pesoBruto,
      descuentoHumedadKg: descuentoHumedadKg,
      pesoNeto: pesoNeto,
      gramera: gramera,
      descuentoEmpaqueKg: descuentoEmpaqueKg,
      precioCarga: precioCarga,
      precioKg: precioKg,
      valorTotal: valorTotal,
      factorRendimiento: factorRendimiento,
      porcentajeAjuste: porcentajeAjuste,
      precioFinalCarga: precioFinalCarga,
      estadoPago: estadoPagoReal,
      anticipo: anticipoReal,
      fechaRegistro: DateTime.now(),
      operador: operador,
      loteBodegaId: ventaDesdeLote ? loteBodegaId : null,
    );

    // §3.9.1 — movimiento monetario real (si aplica). Un fallo de Caja
    // aquí aborta el registro completo (operación atómica, §6.6.x).
    final esContado = estadoPagoReal == EstadoPagoProceso.contado;
    if (esCompra) {
      if (esContado && valorTotal > 0) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.salida,
          monto: valorTotal,
          concepto:
              'Compra de café a $nombreCliente (contado) — '
              '${tipoCafe.etiqueta} · ${_formatearCantidad(pesoNeto)} kg',
          origenId: transaccion.id,
        );
      } else if (anticipoReal > 0) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.salida,
          monto: anticipoReal,
          concepto:
              'Anticipo de compra de café a $nombreCliente — '
              '${tipoCafe.etiqueta}',
          origenId: transaccion.id,
        );
      }
    } else {
      final origen =
          ventaDesdeLote ? ' · Lote ${loteAlmacenado!.codigoLote}' : '';
      if (esContado && valorTotal > 0) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.entrada,
          monto: valorTotal,
          concepto:
              'Venta de café a $nombreCliente (contado) — '
              '${tipoCafe.etiqueta} · ${_formatearCantidad(pesoNeto)} kg$origen',
          origenId: transaccion.id,
        );
      } else if (anticipoReal > 0) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.entrada,
          monto: anticipoReal,
          concepto:
              'Anticipo recibido por venta de café a $nombreCliente — '
              '${tipoCafe.etiqueta}$origen',
          origenId: transaccion.id,
        );
      }
    }

    // §3.4.1 — efecto sobre Bodega.
    final List<LoteBodega> lotesActualizados;
    if (esCompra) {
      // La compra ingresa a la bodega común sin lote (§3.4.3).
      lotesActualizados = [
        ...state.lotes,
        LoteBodega(
          id: _correlativo - 1,
          transaccionId: transaccion.id,
          clienteId: clienteId,
          nombreCliente: nombreCliente,
          tipoCafe: tipoCafe,
          pesoNeto: pesoNeto,
          estado: EstadoBodega.pendiente,
          fechaIngreso: DateTime.now(),
        ),
      ];
    } else if (ventaDesdeLote) {
      // §3.4.1 — venta parcial: el lote conserva su serie y cantidad
      // restante; venta total: el lote pasa a "Agotado".
      lotesActualizados = state.lotes.map((l) {
        if (l.id == loteBodegaId) {
          return l.copyWith(
            pesoNeto: pesoRestanteLote,
            estado: pesoRestanteLote <= 0
                ? EstadoBodega.vendido
                : EstadoBodega.listo,
          );
        }
        return l;
      }).toList();
    } else {
      // La venta resta de la existencia acumulada común (piso 0 kg,
      // §3.4.1 "Regla de Flexibilidad de Inventario en Bodega").
      lotesActualizados = _descontarBodegaComun(tipoCafe, pesoNeto);
    }

    state = state.copyWith(
      transacciones: [...state.transacciones, transaccion],
      lotes: lotesActualizados,
    );
    return transaccion;
  }

  /// §3.4.1 — descuenta [peso] de la bodega común del [tipoCafe]
  /// respetando el orden FIFO de ingreso y el piso mínimo de 0 kg.
  /// Retorna la lista de lotes actualizada (no modifica el estado).
  List<LoteBodega> _descontarBodegaComun(
    TipoCafeProceso tipoCafe,
    double peso,
  ) {
    var restante = peso;
    final actualizados = <LoteBodega>[];
    for (final lote in state.lotes) {
      if (lote.tipoCafe == tipoCafe &&
          lote.estado == EstadoBodega.pendiente &&
          restante > 0) {
        final descontar = lote.pesoNeto >= restante ? restante : lote.pesoNeto;
        restante -= descontar;
        final nuevoPeso = lote.pesoNeto - descontar;
        if (nuevoPeso > 0) {
          actualizados.add(lote.copyWith(pesoNeto: nuevoPeso));
        }
      } else {
        actualizados.add(lote);
      }
    }
    return actualizados;
  }

  // ==========================================================================
  // CONSULTAS
  // ==========================================================================

  // ==========================================================================
  // ACCIONES DE BODEGA / SECADO / LIQUIDACIÓN
  // ==========================================================================

  /// §3.4.2 Entrada de Lote: registra el ingreso de un lote al proceso de
  /// secado. El grano sale de la bodega común (se descuenta del inventario
  /// pendiente del tipo de café seleccionado) y se inicializa el proceso.
  /// Retorna `null` si se registró, o un mensaje de error en español.
  String? ingresarASecar({
    required TipoCafeProceso tipoCafe,
    required double peso,
    required double precioEstimado,
  }) {
    if (peso <= 0) return 'El peso debe ser mayor a cero.';
    if (precioEstimado < 0) return 'El precio no puede ser negativo.';

    final disponible = state.stockDisponibleDe(tipoCafe);
    if (peso > disponible) {
      return 'Solo hay ${_formatearCantidad(disponible)} kg de '
          '${tipoCafe.etiqueta} en la bodega común.';
    }

    var restante = peso;
    final actualizados = <LoteBodega>[];
    for (final lote in state.lotes) {
      if (lote.tipoCafe == tipoCafe &&
          lote.estado == EstadoBodega.pendiente &&
          restante > 0) {
        final descontar = lote.pesoNeto >= restante ? restante : lote.pesoNeto;
        restante -= descontar;
        final nuevoPeso = lote.pesoNeto - descontar;
        if (nuevoPeso > 0) {
          actualizados.add(lote.copyWith(pesoNeto: nuevoPeso));
        }
      } else {
        actualizados.add(lote);
      }
    }

    final nuevoLote = LoteBodega(
      id: _correlativo++,
      transaccionId: 0, // Entrada de secado sin transacción de compra/venta.
      clienteId: '',
      nombreCliente: '',
      tipoCafe: tipoCafe,
      pesoNeto: peso,
      estado: EstadoBodega.secado,
      fechaIngreso: DateTime.now(),
      precioEstimadoInicial: precioEstimado,
      costoKg: _costoMedioCompraTipo(tipoCafe),
    );

    state = state.copyWith(lotes: [...actualizados, nuevoLote]);
    return null;
  }

  /// §5.5.6 — costo medio ponderado de compra por kilogramo de un tipo
  /// en las transacciones de compra no anuladas. Se congela al constituir
  /// lotes (§6.6.9) o al ingresar café al secado (§3.4.2).
  double _costoMedioCompraTipo(TipoCafeProceso tipo) {
    double pesoTotal = 0;
    double costoTotal = 0;
    for (final t in state.transacciones) {
      if (!t.esCompra || t.anulado) continue;
      if (t.tipoCafe != tipo || t.pesoNeto <= 0) continue;
      pesoTotal += t.pesoNeto;
      costoTotal += t.pesoNeto * t.precioKg;
    }
    return pesoTotal > 0 ? costoTotal / pesoTotal : 0;
  }

  String _siguienteCodigoLote(TipoCafeProceso tipo) {
    final prefijo = prefijoLoteDe(tipo);
    final correlativo =
        state.lotes
                .where(
                  (l) =>
                      l.codigoLote != null &&
                      l.codigoLote!.startsWith('$prefijo-'),
                )
                .length +
            1;
    return '$prefijo-${correlativo.toString().padLeft(5, '0')}';
  }

  /// §3.3.4/§6.6.9 — Loteado de Remanentes del Cierre de Ciclo
  /// Operativo. Nivela la bodega común (lotes pendientes) a las
  /// existencias físicas confirmadas por el operador y convierte el
  /// remanente en lotes constituidos (estado `listo`) con código
  /// secuencial `prefijo-#####` según el tipo (§3.4.3). El descontado
  /// respeta el orden FIFO de ingreso. Retorna los lotes constituidos
  /// creados (vacío si no quedó remanente).
  ///
  /// Precondición (validada en la vista): `existenciasFisicas[tipo]`
  /// está entre 0 y el registrado en la bodega común, por lo que la
  /// nivelación nunca fabrica inventario sin respaldo.
  List<LoteBodega> lotearRemanentes(
    Map<TipoCafeProceso, double> existenciasFisicas,
  ) {
    final pendientes = state.lotes
        .where((l) => l.estado == EstadoBodega.pendiente)
        .toList()
      ..sort((a, b) {
        final porFecha = a.fechaIngreso.compareTo(b.fechaIngreso);
        return porFecha != 0 ? porFecha : a.id.compareTo(b.id);
      });

    final restantePorTipo = Map<TipoCafeProceso, double>.from(
      existenciasFisicas,
    );
    final nivelados = <LoteBodega>[];

    for (final lote in pendientes) {
      if (!restantePorTipo.containsKey(lote.tipoCafe)) continue;
      final restante = restantePorTipo[lote.tipoCafe]!;
      if (restante <= 0) continue; // bodega común del tipo nivelada a cero.

      final descontar = lote.pesoNeto >= restante ? restante : lote.pesoNeto;
      restantePorTipo[lote.tipoCafe] = restante - descontar;
      final nuevoPeso = lote.pesoNeto - descontar;
      if (nuevoPeso > 0) {
        nivelados.add(lote.copyWith(pesoNeto: nuevoPeso));
      }
    }

    final constituidos = <LoteBodega>[];
    for (final tipo in TipoCafeProceso.values) {
      final fisico = existenciasFisicas[tipo] ?? 0;
      if (fisico <= 0) continue;
      constituidos.add(
        LoteBodega(
          id: _correlativo++,
          transaccionId: 0, // Remanente del ciclo sin compra asociada.
          clienteId: '',
          nombreCliente: '',
          tipoCafe: tipo,
          pesoNeto: fisico,
          estado: EstadoBodega.listo,
          fechaIngreso: DateTime.now(),
          costoKg: _costoMedioCompraTipo(tipo),
          codigoLote: _siguienteCodigoLote(tipo),
        ),
      );
    }

    state = state.copyWith(lotes: [...nivelados, ...constituidos]);
    return constituidos;
  }

  /// Mueve un lote al proceso de secado (estado `secado`).
  void enviarASecado(int loteId) {
    state = state.copyWith(
      lotes: state.lotes
          .map((l) => l.id == loteId ? l.copyWith(estado: EstadoBodega.secado) : l)
          .toList(),
    );
  }

  /// §3.4.2 Cierre de Lote — concluye el proceso de secado de un lote y
  /// lo constituye en "Almacenado" como `pro-#####` (Secado), estado
  /// DISPONIBLE (`listo`), congelando su `costo_inicial_kg` sobre el
  /// peso seco final (§5.5.6). Calcula la merma y el rendimiento en
  /// vivo en la vista; aquí solo se consolida el resultado.
  ///
  /// Retorna el lote constituido (listo para Almacenar o Vender).
  LoteBodega cerrarLoteSecado({
    required int loteId,
    required double pesoHumedoSecado,
    required double pesoSecoFinal,
  }) {
    final indice = state.lotes.indexWhere(
      (l) => l.id == loteId && l.estado == EstadoBodega.secado,
    );
    if (indice == -1) {
      throw const InventarioInsuficienteException(
        'El lote de secado ya no existe o ya fue cerrado.',
      );
    }
    final lote = state.lotes[indice];

    // §7.4 re-expresión de costo sobre el peso seco facturable: el costo
    // de entrada es la estimación del operador, o el valor en fruta
    // húmeda re-expresado); se reparte sobre el peso seco final.
    final costoEntradaKg = lote.precioEstimadoInicial > 0
        ? lote.precioEstimadoInicial
        : lote.costoKg * pesoHumedoSecado;
    final costoKg = pesoSecoFinal > 0
        ? costoEntradaKg / pesoSecoFinal
        : lote.costoKg;

    final constituido = LoteBodega(
      id: lote.id,
      transaccionId: lote.transaccionId,
      clienteId: lote.clienteId,
      nombreCliente: lote.nombreCliente,
      tipoCafe: lote.tipoCafe,
      pesoNeto: pesoSecoFinal,
      estado: EstadoBodega.listo,
      fechaIngreso: DateTime.now(),
      precioEstimadoInicial: lote.precioEstimadoInicial,
      costoKg: costoKg,
      codigoLote: _siguienteCodigoLote(TipoCafeProceso.secado),
    );

    final actualizados = [...state.lotes];
    actualizados[indice] = constituido;
    state = state.copyWith(lotes: actualizados);
    return constituido;
  }

  /// §3.4.1/§3.4.2 — Cierra el lote de secado y lo vende de inmediato
  /// como SECADO. Por ser la venta del 100% del lote quedará registrada
  /// SIEMPRE como LIQUIDADA (contado). El precio debe venir del flujo
  /// de venta rápida del Cierre de Lote.
  Future<TransaccionCafe> venderLoteSecado({
    required int loteId,
    required double pesoSecoFinal,
    required double precioCarga,
    required double precioKg,
    required double valorTotal,
    required double factorRendimiento,
    required double porcentajeAjuste,
    required double precioFinalCarga,
    required String clienteId,
    required String nombreCliente,
    String operador = 'operador_demo',
  }) async {
    final loteHumedoSecado = state.lotes
        .where((l) => l.id == loteId && l.estado == EstadoBodega.secado)
        .fold<double>(0, (_, l) => l.pesoNeto);
    final lote = cerrarLoteSecado(
      loteId: loteId,
      pesoHumedoSecado: loteHumedoSecado,
      pesoSecoFinal: pesoSecoFinal,
    );
    return registrarTransaccion(
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      esCompra: false,
      tipoCafe: TipoCafeProceso.secado,
      pesoBruto: pesoSecoFinal,
      pesoNeto: pesoSecoFinal,
      precioCarga: precioCarga,
      precioKg: precioKg,
      valorTotal: valorTotal,
      factorRendimiento: factorRendimiento,
      porcentajeAjuste: porcentajeAjuste,
      precioFinalCarga: precioFinalCarga,
      estadoPago: EstadoPagoProceso.contado,
      anticipo: 0,
      operador: operador,
      loteBodegaId: lote.id,
    );
  }

  /// §3.4.4/§3.9.1/§6.6.1 — Liquida el saldo pendiente de una
  /// transacción con el precio final del momento, aplicando de forma
  /// atómica:
  ///   1. Movimiento monetario en Caja (§3.9.1): la liquidación de una
  ///      COMPRA es una salida por el saldo neto (precio - anticipo);
  ///      si el saldo es negativo se devuelve al cliente (entrada). El
  ///      cobro de una VENTA es una entrada por el saldo neto; si el
  ///      saldo es negativo se devuelve (salida).
  ///   2. Estado 'LIQUIDADA' en la transacción (§5.5.7).
  ///   3. Registro en `liquidaciones` con estado 'VALIDADA' (§5.5.8).
  /// El inventario físico NO se vuelve a modificar (§3.9.1). Retorna el
  /// saldo neto (ajuste) movido en Caja. Lanza
  /// [SaldoInsuficienteException] si la Caja no cubre el egreso.
  Future<double> liquidarTransaccion({
    required int transaccionId,
    required double precioFinalMomento,
  }) async {
    final indice = state.transacciones
        .indexWhere((t) => t.id == transaccionId && !t.anulado);
    if (indice == -1) return 0;

    final original = state.transacciones[indice];
    // §3.4.4: no se puede liquidar una transacción sin un cliente asignado.
    final sinCliente = original.nombreCliente.trim().isEmpty ||
        original.nombreCliente == 'Sin cliente';
    if (sinCliente) {
      throw ArgumentError(
        'No se puede liquidar una transacción sin un cliente asignado.',
      );
    }
    final nuevoPrecioKg = precioFinalMomento / 125;
    final nuevoValor = original.pesoNeto * nuevoPrecioKg;
    final saldoNeto = nuevoValor - original.anticipo;

    // §3.9.1 — tratamiento asimétrico compra/venta.
    if (original.esCompra) {
      if (saldoNeto > 0) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.salida,
          monto: saldoNeto,
          concepto:
              'Liquidación de compra de café a ${original.nombreCliente} — '
              'saldo neto',
          origenId: transaccionId,
        );
      } else if (saldoNeto < 0) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.entrada,
          monto: -saldoNeto,
          concepto:
              'Devolución por liquidación de compra de café a '
              '${original.nombreCliente}',
          origenId: transaccionId,
        );
      }
    } else {
      if (saldoNeto > 0) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.entrada,
          monto: saldoNeto,
          concepto:
              'Cobro de venta de café a ${original.nombreCliente} — saldo neto',
          origenId: transaccionId,
        );
      } else if (saldoNeto < 0) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.salida,
          monto: -saldoNeto,
          concepto:
              'Devolución por liquidación de venta de café a '
              '${original.nombreCliente}',
          origenId: transaccionId,
        );
      }
    }

    final actualizada = TransaccionCafe(
      id: original.id,
      clienteId: original.clienteId,
      nombreCliente: original.nombreCliente,
      esCompra: original.esCompra,
      tipoCafe: original.tipoCafe,
      pesoBruto: original.pesoBruto,
      descuentoHumedadKg: original.descuentoHumedadKg,
      pesoNeto: original.pesoNeto,
      gramera: original.gramera,
      descuentoEmpaqueKg: original.descuentoEmpaqueKg,
      precioCarga: precioFinalMomento,
      precioKg: nuevoPrecioKg,
      valorTotal: nuevoValor,
      factorRendimiento: original.factorRendimiento,
      porcentajeAjuste: original.porcentajeAjuste,
      precioFinalCarga: precioFinalMomento,
      estadoPago: EstadoPagoProceso.contado,
      anticipo: original.anticipo,
      anulado: original.anulado,
      fechaRegistro: original.fechaRegistro,
      operador: original.operador,
      loteBodegaId: original.loteBodegaId,
    );

    final actualizadas = [...state.transacciones];
    actualizadas[indice] = actualizada;

    final liquidacion = LiquidacionRegistro(
      id: _correlativoLiquidacion++,
      transaccionId: transaccionId,
      clienteId: original.clienteId,
      nombreCliente: original.nombreCliente,
      esCompra: original.esCompra,
      tipoCafe: original.tipoCafe,
      pesoNeto: original.pesoNeto,
      montoTotalTransaccion: nuevoValor,
      montoAnticiposPrevios: original.anticipo,
      saldoNetoPagado: saldoNeto,
      estado: EstadoLiquidacionRegistro.validada,
      fechaLiquidacion: DateTime.now(),
    );

    state = state.copyWith(
      transacciones: actualizadas,
      liquidaciones: [...state.liquidaciones, liquidacion],
    );
    return saldoNeto;
  }

  /// §3.4.4 — Reintegra el café de una venta anulada:
  ///   - Si la venta salió de un lote de "Almacenado"
  ///     (`transaccion.loteBodegaId != null`), el peso vuelve a ese lote
  ///     y se fuerza el estado DISPONIBLE (`listo`) incluso si estaba
  ///     AGOTADO (§3.4.3: AGOTADO -> DISPONIBLE automático).
  ///   - Si salió de la bodega común, se crea un lote `pendiente` sin
  ///     serie (stock acumulado).
  /// Devuelve la lista de lotes actualizada (no modifica el estado).
  List<LoteBodega> _reintegrarVentaAnulada(TransaccionCafe transaccion) {
    if (transaccion.loteBodegaId != null) {
      return state.lotes.map((l) {
        if (l.id == transaccion.loteBodegaId) {
          return l.copyWith(
            pesoNeto: l.pesoNeto + transaccion.pesoNeto,
            estado: EstadoBodega.listo,
          );
        }
        return l;
      }).toList();
    }
    return [
      ...state.lotes,
      LoteBodega(
        id: _correlativo++,
        transaccionId: transaccion.id,
        clienteId: transaccion.clienteId,
        nombreCliente: transaccion.nombreCliente,
        tipoCafe: transaccion.tipoCafe,
        pesoNeto: transaccion.pesoNeto,
        estado: EstadoBodega.pendiente,
        fechaIngreso: DateTime.now(),
      ),
    ];
  }

  /// §3.4.4 — Cancela una transacción PENDIENTE de liquidación
  /// (compromiso comercial). Aplica de forma atómica:
  ///   1. Reversa en Caja del anticipo movilizado (signo contrario).
  ///   2. Restauración física: una COMPRA cancelada retira su café de
  ///      la bodega común; una VENTA cancelada reintegra el café a la
  ///      bodega común.
  ///   3. La transacción se marca 'ANULADA' y deja de mostrarse
  ///      (§5.5.7: anulado = 1).
  /// Solo permite anular transacciones aún pendientes (no liquidadas).
  /// Lanza [SaldoInsuficienteException] si la Caja no cubre la reversión.
  Future<void> cancelarTransaccionPendiente({
    required int transaccionId,
  }) async {
    final indice = state.transacciones
        .indexWhere((t) => t.id == transaccionId && !t.anulado);
    if (indice == -1) return;

    final original = state.transacciones[indice];
    if (original.estadoPago != EstadoPagoProceso.pendiente) return;

    // Reversa del anticipo en Caja (§3.4.4: compensación de valores).
    if (original.anticipo > 0) {
      if (original.esCompra) {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.entrada,
          monto: original.anticipo,
          concepto:
              'Reversión por cancelación de compra pendiente a '
              '${original.nombreCliente} — anticipo devuelto',
          origenId: transaccionId,
        );
      } else {
        await _registrarEnCaja(
          tipo: TipoMovimientoCaja.salida,
          monto: original.anticipo,
          concepto:
              'Reversión por cancelación de venta pendiente a '
              '${original.nombreCliente} — anticipo reintegrado',
          origenId: transaccionId,
        );
      }
    }

    // Restauración física (§3.4.4): una COMPRA cancelada retira su café
    // de la bodega común; una VENTA cancelada reintegra el grano a su
    // lote de origen (si salió de "Almacenado") o a la bodega común.
    final List<LoteBodega> lotesActualizados;
    if (original.esCompra) {
      lotesActualizados = state.lotes
          .where(
            (l) =>
                !(l.transaccionId == transaccionId &&
                    l.estado == EstadoBodega.pendiente),
          )
          .toList();
    } else {
      lotesActualizados = _reintegrarVentaAnulada(original);
    }

    final actualizadas = [...state.transacciones];
    actualizadas[indice] = original.copyWith(anulado: true);

    state = state.copyWith(
      transacciones: actualizadas,
      lotes: lotesActualizados,
    );
  }

  /// §3.4.4 — Anula una liquidación ya efectuada: la transacción
  /// regresa al estado 'PENDIENTE', se genera un movimiento de signo
  /// contrario en la Caja por el saldo neto pagado (compra:
  /// devolución = entrada; venta: reintegro cobrado = salida, que exige
  /// saldo suficiente) y, en el caso de una venta, el café se reintegra
  /// a la bodega común. El registro de liquidación se marca 'ANULADA'
  /// conservando la auditoría (§5.5.8).
  Future<void> anularLiquidacion({
    required int liquidacionId,
    String? motivo,
  }) async {
    final indiceLiquidacion = state.liquidaciones
        .indexWhere((l) => l.id == liquidacionId);
    if (indiceLiquidacion == -1) return;

    final liq = state.liquidaciones[indiceLiquidacion];
    if (liq.estado != EstadoLiquidacionRegistro.validada) return;

    final indiceTransaccion = state.transacciones
        .indexWhere((t) => t.id == liq.transaccionId);
    if (indiceTransaccion == -1) return;

    // Compensación económica por signo contrario (§3.4.4): se revierte
    // la totalidad del dinero movilizado por la liquidación original.
    final saldo = liq.saldoNetoPagado;
    if (saldo != 0) {
      final monto = saldo.abs();
      // La liquidación original movió: compra → salida (+neto) / entrada
      // (-neto); venta → entrada (+neto) / salida (-neto). La reversa es
      // el movimiento opuesto.
      final tipoReversa = liq.esCompra
          ? (saldo > 0
              ? TipoMovimientoCaja.entrada
              : TipoMovimientoCaja.salida)
          : (saldo > 0
              ? TipoMovimientoCaja.salida
              : TipoMovimientoCaja.entrada);
      await _registrarEnCaja(
        tipo: tipoReversa,
        monto: monto,
        concepto:
            'Anulación de liquidación de ${liq.esCompra ? 'compra' : 'venta'} '
            'a ${liq.nombreCliente} — reversión de saldo',
        origenId: liq.transaccionId,
      );
    }

    // La transacción original regresa a 'PENDIENTE' (§3.4.4).
    final transaccionesActualizadas = [...state.transacciones];
    final original = transaccionesActualizadas[indiceTransaccion];
    transaccionesActualizadas[indiceTransaccion] = TransaccionCafe(
      id: original.id,
      clienteId: original.clienteId,
      nombreCliente: original.nombreCliente,
      esCompra: original.esCompra,
      tipoCafe: original.tipoCafe,
      pesoBruto: original.pesoBruto,
      descuentoHumedadKg: original.descuentoHumedadKg,
      pesoNeto: original.pesoNeto,
      gramera: original.gramera,
      descuentoEmpaqueKg: original.descuentoEmpaqueKg,
      precioCarga: original.precioCarga,
      precioKg: original.precioKg,
      valorTotal: original.valorTotal,
      factorRendimiento: original.factorRendimiento,
      porcentajeAjuste: original.porcentajeAjuste,
      precioFinalCarga: original.precioFinalCarga,
      estadoPago: EstadoPagoProceso.pendiente,
      anticipo: original.anticipo,
      anulado: original.anulado,
      fechaRegistro: original.fechaRegistro,
      operador: original.operador,
      loteBodegaId: original.loteBodegaId,
    );

    // Venta anulada: el café vuelve a su lote de origen (o a la bodega
    // común si salió sin serie) §3.4.4.
    var lotesActualizados = state.lotes;
    if (!liq.esCompra) {
      lotesActualizados = _reintegrarVentaAnulada(original);
    }

    final liquidacionesActualizadas = [...state.liquidaciones];
    liquidacionesActualizadas[indiceLiquidacion] = liq.copyWith(
      estado: EstadoLiquidacionRegistro.anulada,
      motivoAnulacion: motivo,
    );

    state = state.copyWith(
      transacciones: transaccionesActualizadas,
      lotes: lotesActualizados,
      liquidaciones: liquidacionesActualizadas,
    );
  }

  /// §3.4.4 — Cancela/anula una transacción ya saldada (pestaña
  /// "Liquidadas"). Si la transacción llegó a liquidarse desde el
  /// estado PENDIENTE (existe un registro en `liquidaciones` VALIDADA),
  /// delega en [anularLiquidacion] para que regrese a "Pendiente de
  /// liquidar". Si fue registrada directamente de contado (sin registro
  /// de liquidación), aplica una anulación completa: revierte en Caja
  /// el valor total movilizado y reintegra/retira el café en Bodega.
  Future<void> anularTransaccionLiquidada({
    required int transaccionId,
    String? motivo,
  }) async {
    final indice = state.transacciones
        .indexWhere((t) => t.id == transaccionId && !t.anulado);
    if (indice == -1) return;

    // Transacción liquidada desde PENDIENTE: regresa a "Pendiente de
    // liquidar" (compensación + clase física según §3.4.4).
    final registro = state.liquidaciones.where((l) {
      return l.transaccionId == transaccionId &&
          l.estado == EstadoLiquidacionRegistro.validada;
    }).toList();
    if (registro.isNotEmpty) {
      await anularLiquidacion(liquidacionId: registro.first.id, motivo: motivo);
      return;
    }

    final original = state.transacciones[indice];
    if (original.estadoPago != EstadoPagoProceso.contado) return;

    // Reversa íntegra del movimiento de contado (§3.4.4: compensación
    // de valores con bloqueo por insolvencia de Caja).
    if (original.esCompra) {
      await _registrarEnCaja(
        tipo: TipoMovimientoCaja.entrada,
        monto: original.valorTotal,
        concepto:
            'Anulación de compra de contado a ${original.nombreCliente} — '
            'reintegro de valor',
        origenId: transaccionId,
      );
    } else {
      await _registrarEnCaja(
        tipo: TipoMovimientoCaja.salida,
        monto: original.valorTotal,
        concepto:
            'Anulación de venta de contado a ${original.nombreCliente} — '
            'reintegro cobrado',
        origenId: transaccionId,
      );
    }

    // Restauración física (§3.4.4): compra retira su café de bodega
    // común; venta lo reintegra a su lote de origen (o bodega común).
    final List<LoteBodega> lotesActualizados;
    if (original.esCompra) {
      lotesActualizados = state.lotes
          .where(
            (l) =>
                !(l.transaccionId == transaccionId &&
                    l.estado == EstadoBodega.pendiente),
          )
          .toList();
    } else {
      lotesActualizados = _reintegrarVentaAnulada(original);
    }

    final transaccionesActualizadas = [...state.transacciones];
    transaccionesActualizadas[indice] = original.copyWith(anulado: true);

    state = state.copyWith(
      transacciones: transaccionesActualizadas,
      lotes: lotesActualizados,
    );
  }
}

final procesosProvider = StateNotifierProvider<ProcesosNotifier, ProcesosEstado>(
  (ref) {
    return ProcesosNotifier(ref);
  },
);
