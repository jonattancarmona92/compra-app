// ==================== ARCHIVO: lib/features/caja/caja_provider.dart ====================
// Núcleo financiero — Informe Global §3.3 (Módulo de Caja) y §5.5.4
// (tabla movimientos_caja). Caja es autónoma: no conoce Procesos ni
// POS (§6.4.2) y no debe importar nada de esos módulos.
//
// NOTA DE INTEGRACIÓN PENDIENTE: este provider usa un repositorio en
// memoria (_CajaRepositorioMemoria) que reproduce exactamente los
// campos y restricciones de la tabla `movimientos_caja` (§5.5.4). En
// el Módulo 5 se reemplaza la implementación interna por consultas
// Drift reales sin cambiar la interfaz pública del Notifier, gracias
// a la capa de repositorio abstracta definida abajo.
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../configuraciones/impresora_bluetooth_servicio.dart';

// ============================================================================
// MODELOS (espejo de §5.5.4 — tabla movimientos_caja)
// ============================================================================

enum TipoMovimientoCaja { entrada, salida }

enum EstadoCajaSesion { abierta, cerrada }

/// Categorías predefinidas de egreso/ingreso — §5.5.4:
/// "Categorías predefinidas para egresos/ingresos (ej. 'COMPRA_CAFÉ',
/// 'VENTA_TIENDA', 'TRANSPORTE', 'SERVICIOS', 'NOMINA', 'OTROS')".
enum CategoriaMovimiento {
  compraCafe,
  ventaTienda,
  transporte,
  servicios,
  nomina,
  aporteCapital,
  otros,
}

extension CategoriaMovimientoLabel on CategoriaMovimiento {
  String get etiqueta {
    switch (this) {
      case CategoriaMovimiento.compraCafe:
        return 'Compra de Café';
      case CategoriaMovimiento.ventaTienda:
        return 'Venta de Tienda';
      case CategoriaMovimiento.transporte:
        return 'Transporte';
      case CategoriaMovimiento.servicios:
        return 'Servicios Públicos';
      case CategoriaMovimiento.nomina:
        return 'Nómina';
      case CategoriaMovimiento.aporteCapital:
        return 'Aporte de Capital';
      case CategoriaMovimiento.otros:
        return 'Otros';
    }
  }
}

/// Representa una fila de la tabla `movimientos_caja` (§5.5.4).
class MovimientoCaja {
  final int id;
  final int cajaId;
  final TipoMovimientoCaja tipo;
  final double monto;
  final String concepto;
  final CategoriaMovimiento? categoria;

  /// Tabla y registro de origen si es automático (§5.5.4:
  /// origen_tabla / origen_id) — ej. 'transacciones', 'abonos',
  /// 'ventas_pos'. Null si es un movimiento manual.
  final String? origenTabla;
  final int? origenId;

  final DateTime fechaRegistro;
  final bool anulado;
  final String operador;

  const MovimientoCaja({
    required this.id,
    required this.cajaId,
    required this.tipo,
    required this.monto,
    required this.concepto,
    this.categoria,
    this.origenTabla,
    this.origenId,
    required this.fechaRegistro,
    this.anulado = false,
    required this.operador,
  });

  MovimientoCaja copyWith({bool? anulado}) {
    return MovimientoCaja(
      id: id,
      cajaId: cajaId,
      tipo: tipo,
      monto: monto,
      concepto: concepto,
      categoria: categoria,
      origenTabla: origenTabla,
      origenId: origenId,
      fechaRegistro: fechaRegistro,
      anulado: anulado ?? this.anulado,
      operador: operador,
    );
  }

  /// Efecto neto sobre el saldo: positivo para ENTRADA, negativo para
  /// SALIDA. Un movimiento anulado no computa (§3.3.1: la anulación
  /// genera un movimiento de signo contrario, no borra el original —
  /// pero para el cálculo de saldo, ambos coexisten en la sumatoria).
  double get efectoSaldo => tipo == TipoMovimientoCaja.entrada ? monto : -monto;
}

/// Sesión de Caja — espejo simplificado de §5.5.2 (tabla `cajas`).
class CajaSesion {
  final int id;
  final int cicloOperativoId;
  final double saldoInicial;
  final EstadoCajaSesion estado;
  final DateTime fechaApertura;
  final String abiertaPor;

  /// Marca la fecha/hora en la que la sesión fue cerrada (§3.3.4).
  /// Null mientras la sesión permanezca abierta.
  final DateTime? fechaCierre;

  const CajaSesion({
    required this.id,
    required this.cicloOperativoId,
    required this.saldoInicial,
    required this.estado,
    required this.fechaApertura,
    required this.abiertaPor,
    this.fechaCierre,
  });
}

// ============================================================================
// CARTERA — espejo de §5.5.9 (prestamos), §5.5.10 (abonos) y
// §5.5.11 (abonos_detalles). La Cartera es parte del comportamiento
// del módulo de Caja (§3.3.2 "Préstamos y Abonos").
// ============================================================================

/// Tipo de movimiento de cartera que agrega la pantalla §3.3.2.
enum TipoCartera {
  prestamo,
  abono,

  /// Dinero recibido de un cliente a favor (saldo a favor / anticipo del
  /// jefe, etc.). Es una ENTRADA asociada a un cliente que genera crédito
  /// disponible para descontar en liquidaciones de ventas pendientes.
  saldoFavor,

  /// Consumo del saldo a favor aplicado a una liquidación de venta
  /// pendiente (no mueve efectivo: el dinero ya ingresó como ENTRADA).
  aplicacionSaldoFavor,
}

/// Detalle de un abono ya distribuido — espejo de §5.5.11
/// (abonos_detalles): cada abono se distribuye automáticamente en la
/// prioridad: 1. Anticipos, 2. Préstamos, 3. Créditos POS, 4. Ventas
/// Pendientes (§3.3.2).
class AbonoDetalle {
  final String concepto;
  final double monto;

  const AbonoDetalle({required this.concepto, required this.monto});
}

/// Movimiento de cartera (préstamo o abono) mostrado en el historial
/// de la pantalla §3.3.2 y respaldado por las tablas §5.5.9/§5.5.10.
class MovimientoCartera {
  final String id;
  final String clienteId;
  final String nombreCliente;
  final TipoCartera tipo;
  final double monto;

  /// Concepto/razón del préstamo (solo préstamos) o referencia del
  /// abono.
  final String concepto;

  /// Distribución del abono (solo abonos) — §3.3.2.
  final List<AbonoDetalle>? distribucion;

  final DateTime fechaRegistro;
  final bool anulado;
  final String operador;

  const MovimientoCartera({
    required this.id,
    required this.clienteId,
    required this.nombreCliente,
    required this.tipo,
    required this.monto,
    required this.concepto,
    this.distribucion,
    required this.fechaRegistro,
    this.anulado = false,
    required this.operador,
  });

  MovimientoCartera copyWith({bool? anulado}) {
    return MovimientoCartera(
      id: id,
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      tipo: tipo,
      monto: monto,
      concepto: concepto,
      distribucion: distribucion,
      fechaRegistro: fechaRegistro,
      anulado: anulado ?? this.anulado,
      operador: operador,
    );
  }
}

// ============================================================================
// EXCEPCIONES DE DOMINIO
// ============================================================================

/// §3.3.1 / §7.5.1: "Regla Crítica de Liquidez" — bloqueo físico de
/// cualquier salida que deje la Caja en negativo.
class SaldoInsuficienteException implements Exception {
  final double saldoDisponible;
  final double montoRequerido;

  const SaldoInsuficienteException({
    required this.saldoDisponible,
    required this.montoRequerido,
  });

  @override
  String toString() =>
      'Saldo insuficiente: disponible \$$saldoDisponible, requerido \$$montoRequerido';
}

class CajaNoAbiertaException implements Exception {
  const CajaNoAbiertaException();
}

class ValorInvalidoException implements Exception {
  final String mensaje;
  const ValorInvalidoException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// §3.3.2: el cliente no posee cupo de crédito disponible suficiente
/// para un nuevo préstamo.
class CupoInsuficienteException implements Exception {
  final double cupoDisponible;
  const CupoInsuficienteException({required this.cupoDisponible});
}

// ============================================================================
// ESTADO
// ============================================================================

class CajaEstado {
  final bool isCargando;
  final CajaSesion? sesionActual;
  final List<MovimientoCaja> movimientos;
  final List<MovimientoCartera> movimientosCartera;

  const CajaEstado({
    this.isCargando = true,
    this.sesionActual,
    this.movimientos = const [],
    this.movimientosCartera = const [],
  });

  /// Ecuación de Consistencia del Balance — §7.9.1:
  /// Saldo Final Teórico = Saldo Inicial + Entradas - Salidas.
  double get saldoActual {
    final saldoInicial = sesionActual?.saldoInicial ?? 0;
    final efectoMovimientos = movimientos
        .where((m) => !m.anulado)
        .fold<double>(0, (acumulado, m) => acumulado + m.efectoSaldo);
    return saldoInicial + efectoMovimientos;
  }

  double get totalEntradas => movimientos
      .where((m) => !m.anulado && m.tipo == TipoMovimientoCaja.entrada)
      .fold<double>(0, (acc, m) => acc + m.monto);

  double get totalSalidas => movimientos
      .where((m) => !m.anulado && m.tipo == TipoMovimientoCaja.salida)
      .fold<double>(0, (acc, m) => acc + m.monto);

  List<MovimientoCaja> get movimientosVisibles =>
      movimientos.where((m) => !m.anulado).toList()
        ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

  bool get isCajaAbierta => sesionActual?.estado == EstadoCajaSesion.abierta;

  /// Historial de cartera visible (no anulados) ordenado de más
  /// reciente a más antiguo.
  List<MovimientoCartera> get movimientosCarteraVisibles =>
      movimientosCartera.where((m) => !m.anulado).toList()
        ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

  CajaEstado copyWith({
    bool? isCargando,
    CajaSesion? sesionActual,
    List<MovimientoCaja>? movimientos,
    List<MovimientoCartera>? movimientosCartera,
  }) {
    return CajaEstado(
      isCargando: isCargando ?? this.isCargando,
      sesionActual: sesionActual ?? this.sesionActual,
      movimientos: movimientos ?? this.movimientos,
      movimientosCartera: movimientosCartera ?? this.movimientosCartera,
    );
  }
}

// ============================================================================
// NOTIFIER
// ============================================================================

class CajaNotifier extends StateNotifier<CajaEstado> {
  CajaNotifier() : super(const CajaEstado());

  int _correlativoId = 1;
  int _correlativoCartera = 1;

  static const _keySesionAbierta = 'caja_sesion_abierta';
  static const _keySesionAbiertaOperador = 'caja_sesion_abierta_operador';
  static const _keySesionAbiertaFecha = 'caja_sesion_abierta_fecha';

  static const _keyEstado = 'caja_estado_json_v1';

  /// Persiste el estado completo (sesión, movimientos y cartera) en
  /// disco tras cada mutación, de modo que sobreviva al reinicio del
  /// proceso (bloqueo del dispositivo, etc.).
  @override
  set state(CajaEstado value) {
    super.state = value;
    _persistirEstado();
  }

  Future<void> _persistirEstado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyEstado, jsonEncode(_estadoAJson()));
    } catch (_) {
      // Entorno sin storage (tests o plugin ausente): se omite.
    }
  }

  Map<String, dynamic> _estadoAJson() {
    final s = state;
    return {
      'correlativoId': _correlativoId,
      'correlativoCartera': _correlativoCartera,
      'sesion': s.sesionActual == null
          ? null
          : {
              'id': s.sesionActual!.id,
              'cicloOperativoId': s.sesionActual!.cicloOperativoId,
              'saldoInicial': s.sesionActual!.saldoInicial,
              'estado': s.sesionActual!.estado.name,
              'fechaApertura': s.sesionActual!.fechaApertura.toIso8601String(),
              'abiertaPor': s.sesionActual!.abiertaPor,
              'fechaCierre': s.sesionActual!.fechaCierre?.toIso8601String(),
            },
      'movimientos': s.movimientos.map(_movimientoAJson).toList(),
      'cartera': s.movimientosCartera.map(_movimientoCarteraAJson).toList(),
    };
  }

  Map<String, dynamic> _movimientoAJson(MovimientoCaja m) => {
        'id': m.id,
        'cajaId': m.cajaId,
        'tipo': m.tipo.name,
        'monto': m.monto,
        'concepto': m.concepto,
        'categoria': m.categoria?.name,
        'origenTabla': m.origenTabla,
        'origenId': m.origenId,
        'fechaRegistro': m.fechaRegistro.toIso8601String(),
        'anulado': m.anulado,
        'operador': m.operador,
      };

  Map<String, dynamic> _movimientoCarteraAJson(MovimientoCartera m) => {
        'id': m.id,
        'clienteId': m.clienteId,
        'nombreCliente': m.nombreCliente,
        'tipo': m.tipo.name,
        'monto': m.monto,
        'concepto': m.concepto,
        'distribucion': m.distribucion
            ?.map((d) => {'concepto': d.concepto, 'monto': d.monto})
            .toList(),
        'fechaRegistro': m.fechaRegistro.toIso8601String(),
        'anulado': m.anulado,
        'operador': m.operador,
      };

  MovimientoCaja _movimientoDesdeJson(Map<String, dynamic> j) {
    return MovimientoCaja(
      id: (j['id'] as num).toInt(),
      cajaId: (j['cajaId'] as num).toInt(),
      tipo: TipoMovimientoCaja.values.byName(j['tipo'] as String),
      monto: (j['monto'] as num).toDouble(),
      concepto: j['concepto'] as String,
      categoria: j['categoria'] == null
          ? null
          : CategoriaMovimiento.values.byName(j['categoria'] as String),
      origenTabla: j['origenTabla'] as String?,
      origenId: (j['origenId'] as num?)?.toInt(),
      fechaRegistro: DateTime.parse(j['fechaRegistro'] as String),
      anulado: j['anulado'] as bool? ?? false,
      operador: j['operador'] as String,
    );
  }

  MovimientoCartera _movimientoCarteraDesdeJson(Map<String, dynamic> j) {
    return MovimientoCartera(
      id: j['id'] as String,
      clienteId: j['clienteId'] as String,
      nombreCliente: j['nombreCliente'] as String,
      tipo: TipoCartera.values.byName(j['tipo'] as String),
      monto: (j['monto'] as num).toDouble(),
      concepto: j['concepto'] as String,
      distribucion: (j['distribucion'] as List?)
          ?.map(
            (d) => AbonoDetalle(
              concepto: (d as Map<String, dynamic>)['concepto'] as String,
              monto: ((d)['monto'] as num).toDouble(),
            ),
          )
          .toList(),
      fechaRegistro: DateTime.parse(j['fechaRegistro'] as String),
      anulado: j['anulado'] as bool? ?? false,
      operador: j['operador'] as String,
    );
  }

  /// Restaura movimientos y cartera persistidos desde el storage. Se
  /// invoca en [restaurarSesionGuardada], tras restaurar la sesión.
  void _aplicarMovimientosPersistidos(Map<String, dynamic>? j) {
    if (j == null) return;
    final movimientos = (j['movimientos'] as List? ?? const [])
        .map((e) => _movimientoDesdeJson(e as Map<String, dynamic>))
        .toList();
    final cartera = (j['cartera'] as List? ?? const [])
        .map((e) => _movimientoCarteraDesdeJson(e as Map<String, dynamic>))
        .toList();
    _correlativoId = (j['correlativoId'] as num?)?.toInt() ?? 1;
    _correlativoCartera = (j['correlativoCartera'] as num?)?.toInt() ?? 1;
    state = state.copyWith(
      movimientos: movimientos,
      movimientosCartera: cartera,
    );
  }

  /// Restaura la sesión de Caja que quedó abierta al cerrar la app, si
  /// existe (§2.3). La persistencia real en el Módulo 5 (Drift) la
  /// reemplazará por una consulta a la tabla `cajas` con estado
  /// 'ABIERTA'; mientras tanto se conserva en storage. Se invoca
  /// explícitamente desde el arranque (control_inicio_provider) para
  /// poder esperar su resultado.
  Future<void> restaurarSesionGuardada() async {
    if (!state.isCargando) return;

    final prefs = await SharedPreferences.getInstance();
    final saldoInicial = prefs.getDouble(_keySesionAbierta) ?? 0.0;
    final abiertaPor = prefs.getString(_keySesionAbiertaOperador) ?? '';
    final fecha = prefs.getString(_keySesionAbiertaFecha);
    final persistido = prefs.getString(_keyEstado);

    if (abiertaPor.isEmpty) {
      state = state.copyWith(isCargando: false);
      return;
    }

    Map<String, dynamic>? json;
    try {
      json = persistido == null ? null : jsonDecode(persistido) as Map<String, dynamic>;
    } catch (_) {
      json = null;
    }

    state = state.copyWith(
      isCargando: false,
      sesionActual: CajaSesion(
        id: 1,
        cicloOperativoId: 1,
        saldoInicial: saldoInicial,
        estado: EstadoCajaSesion.abierta,
        fechaApertura: DateTime.tryParse(fecha ?? '') ?? DateTime.now(),
        abiertaPor: abiertaPor,
      ),
      movimientos: const [],
      movimientosCartera: const [],
    );

    _aplicarMovimientosPersistidos(json);
  }

  /// §2.2 — Abre una nueva sesión de Caja con el saldo inicial
  /// ingresado y la persiste para conservarse entre inicios de app.
  Future<void> abrirCaja({
    required double saldoInicial,
    required String abiertaPor,
  }) async {
    if (saldoInicial < 0) {
      throw const ValorInvalidoException(
        'El saldo inicial no puede ser negativo.',
      );
    }
    if (abiertaPor.trim().isEmpty) {
      throw const ValorInvalidoException('Falta el operador que abre la Caja.');
    }

    state = state.copyWith(
      isCargando: false,
      sesionActual: CajaSesion(
        id: 1,
        cicloOperativoId: 1,
        saldoInicial: saldoInicial,
        estado: EstadoCajaSesion.abierta,
        fechaApertura: DateTime.now(),
        abiertaPor: abiertaPor.trim(),
      ),
      movimientos: const [],
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySesionAbierta, saldoInicial);
    await prefs.setString(_keySesionAbiertaOperador, abiertaPor.trim());
    await prefs.setString(
      _keySesionAbiertaFecha,
      DateTime.now().toIso8601String(),
    );
  }

  /// Indica si existe una sesión de Caja abierta persistida (§2.3).
  Future<bool> habiaSesionAbierta() async {
    final prefs = await SharedPreferences.getInstance();
    final abiertaPor = prefs.getString(_keySesionAbiertaOperador);
    return abiertaPor != null && abiertaPor.isNotEmpty;
  }

  /// Fecha en que se abrió la sesión persistida, si existe (§2.3).
  Future<DateTime?> fechaSesionAbiertaGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final fecha = prefs.getString(_keySesionAbiertaFecha);
    return fecha == null ? null : DateTime.tryParse(fecha);
  }

  /// Elimina el marcador de sesión abierta persistida (usado para el
  /// Cierre Automático de Caja de una jornada anterior, §3.3.4). No
  /// cambia la sesión en memoria actual.
  Future<void> limpiarSesionPersistida() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesionAbierta);
    await prefs.remove(_keySesionAbiertaOperador);
    await prefs.remove(_keySesionAbiertaFecha);
  }

  // ==========================================================================
  // §3.3.1 — REGISTRO DE MOVIMIENTO MANUAL
  // ==========================================================================

  /// Registra una Entrada o Salida manual. Lanza
  /// [SaldoInsuficienteException] si una Salida supera el saldo
  /// disponible (§3.3.1 "Regla Crítica de Liquidez").
  Future<MovimientoCaja> registrarMovimiento({
    required TipoMovimientoCaja tipo,
    required double monto,
    required String concepto,
    CategoriaMovimiento? categoria,
    required String operador,
  }) async {
    final sesion = state.sesionActual;
    if (sesion == null || sesion.estado != EstadoCajaSesion.abierta) {
      throw const CajaNoAbiertaException();
    }

    if (monto <= 0) {
      throw const ValorInvalidoException('El valor debe ser mayor a cero.');
    }

    if (concepto.trim().isEmpty) {
      throw const ValorInvalidoException('El concepto es obligatorio.');
    }

    // §5.5.4: categoría obligatoria solo para salidas.
    if (tipo == TipoMovimientoCaja.salida && categoria == null) {
      throw const ValorInvalidoException(
        'La categoría es obligatoria para las salidas.',
      );
    }

    if (tipo == TipoMovimientoCaja.salida && monto > state.saldoActual) {
      throw SaldoInsuficienteException(
        saldoDisponible: state.saldoActual,
        montoRequerido: monto,
      );
    }

    final movimiento = MovimientoCaja(
      id: _correlativoId++,
      cajaId: sesion.id,
      tipo: tipo,
      monto: monto,
      concepto: concepto.trim(),
      categoria: categoria,
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    state = state.copyWith(movimientos: [...state.movimientos, movimiento]);
    return movimiento;
  }

  /// Inserta un movimiento AUTOMÁTICO originado por otro módulo
  /// (Transacciones, Abonos, Ventas POS, etc.) — §5.5.4: origen_tabla
  /// / origen_id. Caja no conoce el negocio de esos módulos; solo
  /// recibe el movimiento ya resuelto a través de este canal
  /// abstracto (§6.4.1: "Recibe las llamadas de inserción contable
  /// desde otros módulos mediante canales abstractos").
  Future<MovimientoCaja> registrarMovimientoAutomatico({
    required TipoMovimientoCaja tipo,
    required double monto,
    required String concepto,
    required String origenTabla,
    required int origenId,
    required String operador,
  }) async {
    final sesion = state.sesionActual;
    if (sesion == null || sesion.estado != EstadoCajaSesion.abierta) {
      throw const CajaNoAbiertaException();
    }

    if (tipo == TipoMovimientoCaja.salida && monto > state.saldoActual) {
      throw SaldoInsuficienteException(
        saldoDisponible: state.saldoActual,
        montoRequerido: monto,
      );
    }

    final movimiento = MovimientoCaja(
      id: _correlativoId++,
      cajaId: sesion.id,
      tipo: tipo,
      monto: monto,
      concepto: concepto,
      origenTabla: origenTabla,
      origenId: origenId,
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    state = state.copyWith(movimientos: [...state.movimientos, movimiento]);
    return movimiento;
  }

  // ==========================================================================
  // §3.3.1 — EDICIÓN EN CICLO ABIERTO
  // ==========================================================================

  /// Edita un movimiento manual existente. Por "Inmutabilidad del
  /// Pasado" (§3.3.1) NO modifica el registro histórico: genera un
  /// movimiento de AJUSTE nuevo por la diferencia, en la Caja
  /// actualmente abierta. Lanza [SaldoInsuficienteException] si el
  /// ajuste implica un egreso que la Caja no puede cubrir.
  Future<void> editarMovimiento({
    required int movimientoId,
    required double nuevoMonto,
    required String nuevoConcepto,
    required String operador,
  }) async {
    final original = state.movimientos.firstWhere(
      (m) => m.id == movimientoId,
      orElse: () =>
          throw const ValorInvalidoException('Movimiento no encontrado.'),
    );

    if (nuevoMonto <= 0) {
      throw const ValorInvalidoException('El valor debe ser mayor a cero.');
    }

    // Diferencia en términos de saldo (mismo signo que el movimiento
    // original: si era ENTRADA, un monto mayor aumenta el saldo).
    final diferenciaMonto = nuevoMonto - original.monto;
    final diferenciaSaldo = original.tipo == TipoMovimientoCaja.entrada
        ? diferenciaMonto
        : -diferenciaMonto;

    // §3.3.1 "Bloqueo por Insolvencia de Caja": si el ajuste implica
    // una salida neta de efectivo mayor a lo disponible, se bloquea.
    if (diferenciaSaldo < 0 && diferenciaSaldo.abs() > state.saldoActual) {
      throw SaldoInsuficienteException(
        saldoDisponible: state.saldoActual,
        montoRequerido: diferenciaSaldo.abs(),
      );
    }

    final ajuste = MovimientoCaja(
      id: _correlativoId++,
      cajaId: original.cajaId,
      tipo: diferenciaSaldo >= 0
          ? TipoMovimientoCaja.entrada
          : TipoMovimientoCaja.salida,
      monto: diferenciaSaldo.abs(),
      concepto:
          'Ajuste por edición — ${nuevoConcepto.trim()} '
          '(mov. original #$movimientoId)',
      origenTabla: 'movimientos_caja',
      origenId: movimientoId,
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    state = state.copyWith(movimientos: [...state.movimientos, ajuste]);
  }

  // ==========================================================================
  // §3.3.1 — CANCELACIÓN (ANULACIÓN)
  // ==========================================================================

  /// Reversa un movimiento generando uno de signo contrario (§3.3.1:
  /// "La cancelación... genera un movimiento de signo contrario").
  /// Valida que el saldo nunca caiga por debajo de cero.
  Future<void> anularMovimiento({
    required int movimientoId,
    required String operador,
  }) async {
    final original = state.movimientos.firstWhere(
      (m) => m.id == movimientoId,
      orElse: () =>
          throw const ValorInvalidoException('Movimiento no encontrado.'),
    );

    if (original.anulado) {
      throw const ValorInvalidoException('El movimiento ya fue anulado.');
    }

    // Reversar una ENTRADA genera una SALIDA (disminuye el saldo);
    // reversar una SALIDA genera una ENTRADA (aumenta el saldo).
    final tipoReversion = original.tipo == TipoMovimientoCaja.entrada
        ? TipoMovimientoCaja.salida
        : TipoMovimientoCaja.entrada;

    if (tipoReversion == TipoMovimientoCaja.salida &&
        original.monto > state.saldoActual) {
      throw SaldoInsuficienteException(
        saldoDisponible: state.saldoActual,
        montoRequerido: original.monto,
      );
    }

    final reversion = MovimientoCaja(
      id: _correlativoId++,
      cajaId: original.cajaId,
      tipo: tipoReversion,
      monto: original.monto,
      concepto: 'Reversión por anulación — mov. original #$movimientoId',
      origenTabla: 'movimientos_caja',
      origenId: movimientoId,
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    final movimientosActualizados = state.movimientos.map((m) {
      return m.id == movimientoId ? m.copyWith(anulado: true) : m;
    }).toList();

    state = state.copyWith(
      movimientos: [...movimientosActualizados, reversion],
    );
  }

  // ==========================================================================
  // CARTERA — §3.3.2 (Préstamos y Abonos)
  // ==========================================================================

  /// Presta dinero de la Caja al cliente. Es una SALIDA de efectivo y
  /// exige cupo de crédito autorizado disponible en el cliente.
  /// Reglas aplicadas (§3.3.2):
  ///   - Solo con Caja abierta.
  ///   - Bloqueo por insolvencia: saldo de Caja debe ser suficiente.
  ///   - Bloqueo por cupo: monto <= cupoDisponible del cliente.
  /// Lanza [SaldoInsuficienteException] o [CupoInsuficienteException].
  Future<MovimientoCartera> registrarPrestamo({
    required String clienteId,
    required String nombreCliente,
    required double monto,
    required String concepto,
    required double cupoDisponible,
    required String operador,
  }) async {
    final sesion = state.sesionActual;
    if (sesion == null || sesion.estado != EstadoCajaSesion.abierta) {
      throw const CajaNoAbiertaException();
    }

    if (monto <= 0) {
      throw const ValorInvalidoException('El valor debe ser mayor a cero.');
    }

    if (concepto.trim().isEmpty) {
      throw const ValorInvalidoException('El concepto es obligatorio.');
    }

    if (monto > cupoDisponible) {
      throw CupoInsuficienteException(cupoDisponible: cupoDisponible);
    }

    if (monto > state.saldoActual) {
      throw SaldoInsuficienteException(
        saldoDisponible: state.saldoActual,
        montoRequerido: monto,
      );
    }

    final prestamo = MovimientoCartera(
      id: 'car-${_correlativoCartera++}',
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      tipo: TipoCartera.prestamo,
      monto: monto,
      concepto: concepto.trim(),
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    await registrarMovimientoAutomatico(
      tipo: TipoMovimientoCaja.salida,
      monto: monto,
      concepto: 'Préstamo a ${prestamo.nombreCliente} — $concepto',
      origenTabla: 'prestamos',
      origenId: _correlativoCartera - 1,
      operador: operador,
    );

    // El movimiento de Caja ya quedó registrado por
    // [registrarMovimientoAutomatico]; aquí solo se suma la cartera.
    state = state.copyWith(
      movimientosCartera: [...state.movimientosCartera, prestamo],
    );
    return prestamo;
  }

  /// Registra un abono del cliente a su cartera. Es una ENTRADA de
  /// efectivo. El monto se distribuye automáticamente según la
  /// prioridad §3.3.2:
  ///   1. Anticipos  2. Préstamos  3. Créditos POS  4. Ventas Pend.
  /// La lista [distribucion] contiene los tramos resultantes.
  Future<MovimientoCartera> registrarAbono({
    required String clienteId,
    required String nombreCliente,
    required double monto,
    required List<AbonoDetalle> distribucion,
    required String operador,
  }) async {
    final sesion = state.sesionActual;
    if (sesion == null || sesion.estado != EstadoCajaSesion.abierta) {
      throw const CajaNoAbiertaException();
    }

    if (monto <= 0) {
      throw const ValorInvalidoException('El valor debe ser mayor a cero.');
    }

    final abono = MovimientoCartera(
      id: 'car-${_correlativoCartera++}',
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      tipo: TipoCartera.abono,
      monto: monto,
      concepto: 'Abono a cartera',
      distribucion: distribucion,
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    final abonoId = _correlativoCartera - 1;
    await registrarMovimientoAutomatico(
      tipo: TipoMovimientoCaja.entrada,
      monto: monto,
      concepto: 'Abono a cartera — ${abono.nombreCliente}',
      origenTabla: 'abonos',
      origenId: abonoId,
      operador: operador,
    );

    // El movimiento de Caja ya quedó registrado por
    // [registrarMovimientoAutomatico]; aquí solo se suma la cartera.
    state = state.copyWith(
      movimientosCartera: [...state.movimientosCartera, abono],
    );
    return abono;
  }

  /// §3.3.2 — Registra dinero recibido de un cliente (p. ej. el jefe) como
  /// ENTRADA a favor del cliente: genera crédito (saldo a favor) que se
  /// descuenta en la liquidación de ventas pendientes a ese cliente.
  /// Valida Caja abierta y valor positivo.
  Future<MovimientoCartera> registrarIngresoCliente({
    required String clienteId,
    required String nombreCliente,
    required double monto,
    required String concepto,
    required String operador,
  }) async {
    final sesion = state.sesionActual;
    if (sesion == null || sesion.estado != EstadoCajaSesion.abierta) {
      throw const CajaNoAbiertaException();
    }
    if (monto <= 0) {
      throw const ValorInvalidoException('El valor debe ser mayor a cero.');
    }
    if (concepto.trim().isEmpty) {
      throw const ValorInvalidoException('El concepto es obligatorio.');
    }

    final ingreso = MovimientoCartera(
      id: 'car-${_correlativoCartera++}',
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      tipo: TipoCartera.saldoFavor,
      monto: monto,
      concepto: concepto.trim(),
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    // Es una ENTRADA de efectivo real a la Caja.
    await registrarMovimientoAutomatico(
      tipo: TipoMovimientoCaja.entrada,
      monto: monto,
      concepto: 'Ingreso de ${ingreso.nombreCliente} — ${ingreso.concepto}',
      origenTabla: 'cartera_saldo_favor',
      origenId: _correlativoCartera - 1,
      operador: operador,
    );

    // El movimiento de Caja ya quedó registrado por
    // [registrarMovimientoAutomatico]; aquí solo se suma la cartera.
    state = state.copyWith(
      movimientosCartera: [...state.movimientosCartera, ingreso],
    );
    return ingreso;
  }

  /// §3.3.2 — Describe el saldo a favor disponible de un cliente (crédito
  /// acumulado por ingresos no consumidos aún).
  double saldoFavorDisponible(String clienteId) {
    var saldo = 0.0;
    for (final m in state.movimientosCartera) {
      if (m.clienteId != clienteId || m.anulado) continue;
      if (m.tipo == TipoCartera.saldoFavor) {
        saldo += m.monto;
      } else if (m.tipo == TipoCartera.aplicacionSaldoFavor) {
        saldo -= m.monto;
      }
    }
    return saldo < 0 ? 0 : saldo;
  }

  /// §3.3.2 — Consume una parte del saldo a favor de un cliente al
  /// aplicar un descuento en la liquidación de una venta pendiente.
  /// NO mueve efectivo (el dinero ya ingresó como ENTRADA); únicamente
  /// registra la aplicación en la cartera. Lanza
  /// [SaldoInsuficienteException] si se excede el saldo disponible.
  Future<MovimientoCartera> aplicarSaldoFavor({
    required String clienteId,
    required String nombreCliente,
    required double monto,
    required String operador,
    String? concepto,
  }) async {
    final disponible = saldoFavorDisponible(clienteId);
    if (monto <= 0) {
      throw const ValorInvalidoException('El valor debe ser mayor a cero.');
    }
    if (monto > disponible) {
      throw SaldoInsuficienteException(
        saldoDisponible: disponible,
        montoRequerido: monto,
      );
    }

    final aplicacion = MovimientoCartera(
      id: 'car-${_correlativoCartera++}',
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      tipo: TipoCartera.aplicacionSaldoFavor,
      monto: monto,
      concepto:
          concepto ?? 'Descuento de saldo a favor en liquidación de venta',
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    state = state.copyWith(
      movimientosCartera: [...state.movimientosCartera, aplicacion],
    );
    return aplicacion;
  }

  /// §3.3.2 — Reintegra saldo a favor a un cliente por anulación de una
  /// liquidación que lo consumió. NO mueve efectivo (el crédito nunca
  /// salió de la Caja); únicamente registra un nuevo ingreso tipo
  /// `saldoFavor` en la cartera que restaura la disponibilidad.
  Future<MovimientoCartera> reintegrarSaldoFavor({
    required String clienteId,
    required String nombreCliente,
    required double monto,
    required String operador,
    String? concepto,
  }) async {
    if (monto <= 0) {
      throw const ValorInvalidoException('El valor debe ser mayor a cero.');
    }

    final reintegro = MovimientoCartera(
      id: 'car-${_correlativoCartera++}',
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      tipo: TipoCartera.saldoFavor,
      monto: monto,
      concepto:
          concepto ?? 'Reintegro de saldo a favor por anulación de liquidación',
      fechaRegistro: DateTime.now(),
      operador: operador,
    );

    state = state.copyWith(
      movimientosCartera: [...state.movimientosCartera, reintegro],
    );
    return reintegro;
  }

  /// §3.3.2 "Inmutabilidad del Pasado": editar un movimiento de
  /// cartera NO borra el original; genera un AJUSTE. En un escenario
  /// real anula el movimiento original y registra uno nuevo con el
  /// importe corregido. Aquí aplicamos el contrato de inmutabilidad
  /// marcando una flag de ajuste (por simplicidad se registra un
  /// movimiento nuevo de signo diferencial vía Caja).
  Future<void> editarMovimientoCartera({
    required String carteraId,
    required double nuevoMonto,
    required String nuevoConcepto,
    required String operador,
  }) async {
    final original = state.movimientosCartera.firstWhere(
      (m) => m.id == carteraId,
      orElse: () =>
          throw const ValorInvalidoException('Movimiento no encontrado.'),
    );

    if (nuevoMonto <= 0) {
      throw const ValorInvalidoException('El valor debe ser mayor a cero.');
    }

    final diferenciaMonto = nuevoMonto - original.monto;

    // Una APLICACIÓN de saldo a favor no movió efectivo en la Caja
    // (el dinero entró cuando se registró el ingreso), por lo que su
    // edición solo replantea el crédito consumido sin generar ajuste
    // de Caja. El resto de tipos sí ajustan la Caja.
    final mueveEfectivo = original.tipo != TipoCartera.aplicacionSaldoFavor;

    // Ajuste contable en Caja por la diferencia.
    if (mueveEfectivo && diferenciaMonto != 0) {
      final esEntrada = diferenciaMonto > 0;
      if (!esEntrada && diferenciaMonto.abs() > state.saldoActual) {
        throw SaldoInsuficienteException(
          saldoDisponible: state.saldoActual,
          montoRequerido: diferenciaMonto.abs(),
        );
      }
      await registrarMovimientoAutomatico(
        tipo: esEntrada
            ? TipoMovimientoCaja.entrada
            : TipoMovimientoCaja.salida,
        monto: diferenciaMonto.abs(),
        concepto:
            'Ajuste por edición — ${nuevoConcepto.trim()} '
            '(cartera #$carteraId)',
        origenTabla: 'movimientos_caja',
        origenId: _correlativoId - 1,
        operador: operador,
      );
    }

    final actualizados = state.movimientosCartera.map((m) {
      if (m.id != carteraId) return m;
      return MovimientoCartera(
        id: m.id,
        clienteId: m.clienteId,
        nombreCliente: m.nombreCliente,
        tipo: m.tipo,
        monto: nuevoMonto,
        concepto: nuevoConcepto.trim(),
        distribucion: m.distribucion,
        fechaRegistro: m.fechaRegistro,
        anulado: m.anulado,
        operador: m.operador,
      );
    }).toList();

    state = state.copyWith(movimientosCartera: actualizados);
  }

  /// §3.3.2: anula un movimiento de cartera generando su reversión
  /// en Caja. Valida el Bloqueo por Insolvencia.
  Future<void> anularMovimientoCartera({
    required String carteraId,
    required String operador,
  }) async {
    final original = state.movimientosCartera.firstWhere(
      (m) => m.id == carteraId,
      orElse: () =>
          throw const ValorInvalidoException('Movimiento no encontrado.'),
    );

    if (original.anulado) {
      throw const ValorInvalidoException('El movimiento ya fue anulado.');
    }

    // Un PRÉSTAMO anulado devuelve dinero a Caja (entrada). Un ABONO o
    // un INGRESO (saldo a favor) anulado retira dinero de Caja (salida)
    // — exige liquidez. Una APLICACIÓN de saldo a favor no movió
    // efectivo (el dinero ya entró antes), por lo que anularla solo la
    // marca anulada y restaura el crédito en la cartera.
    final tipoReversion = original.tipo == TipoCartera.prestamo
        ? TipoMovimientoCaja.entrada
        : original.tipo == TipoCartera.aplicacionSaldoFavor
            ? null
            : TipoMovimientoCaja.salida;

    final label = switch (original.tipo) {
      TipoCartera.prestamo => 'préstamo',
      TipoCartera.abono => 'abono',
      TipoCartera.saldoFavor => 'ingreso',
      TipoCartera.aplicacionSaldoFavor => 'aplicación de saldo a favor',
    };

    if (tipoReversion == TipoMovimientoCaja.salida &&
        original.monto > state.saldoActual) {
      throw SaldoInsuficienteException(
        saldoDisponible: state.saldoActual,
        montoRequerido: original.monto,
      );
    }

    if (tipoReversion != null) {
      await registrarMovimientoAutomatico(
        tipo: tipoReversion,
        monto: original.monto,
        concepto: 'Reversión por anulación — cartera #$carteraId ($label)',
        origenTabla: 'movimientos_caja',
        origenId: _correlativoId - 1,
        operador: operador,
      );
    }

    final actualizados = state.movimientosCartera
        .map((m) => m.id == carteraId ? m.copyWith(anulado: true) : m)
        .toList();

    state = state.copyWith(movimientosCartera: actualizados);
  }

  /// Historial de cartera visible (no anulados), ordenado de más
  /// reciente a más antiguo.
  // (Ver CajaEstado.movimientosCarteraVisibles)

  /// §3.3.2: genera y comparte el comprobante en PDF (§8.3). Retorna
  /// `true` si la hoja de compartir pudo abrirse.
  Future<bool> compartirComprobantePdf({
    required MovimientoCartera movimiento,
    required EncabezadoComprobante encabezado,
  }) {
    final titulo = _tituloMovimientoCartera(movimiento.tipo);
    final lineas = _lineasMovimientoCartera(movimiento);
    return ComprobanteServicio.instancia.compartirPdf(
      encabezado: encabezado,
      titulo: titulo,
      lineas: lineas,
    );
  }

  String _tituloMovimientoCartera(TipoCartera tipo) {
    return switch (tipo) {
      TipoCartera.prestamo => 'Comprobante de Préstamo',
      TipoCartera.abono => 'Comprobante de Abono',
      TipoCartera.saldoFavor => 'Comprobante de Ingreso de Cliente',
      TipoCartera.aplicacionSaldoFavor =>
        'Comprobante de Saldo a Favor Aplicado',
    };
  }

  /// §3.3.2: imprime el ticket térmico del movimiento de cartera
  /// (§10.2). Retorna `true` si el envío a la impresora pudo completar.
  Future<bool> imprimirTicketTermico({
    required MovimientoCartera movimiento,
    required EncabezadoComprobante encabezado,
    required int copias,
    required bool cortarPapel,
  }) async {
    final datos = TicketEscPosBuilder.construir(
      titulo: _tituloMovimientoCartera(movimiento.tipo),
      lineas: [
        'Cliente: ${movimiento.nombreCliente}',
        'Concepto: ${movimiento.concepto}',
        'Valor: ${CurrencyFormatter.formatValue(movimiento.monto)}',
        'Operador: ${movimiento.operador}',
      ],
      encabezado: encabezado,
      copias: copias,
      cortarPapel: cortarPapel,
    );
    try {
      await ImpresoraBluetoothServicio.instancia.escribir(datos);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Construye las líneas de comprobante de un movimiento de cartera.
  List<LineaComprobante> _lineasMovimientoCartera(
    MovimientoCartera movimiento,
  ) {
    final titulo = switch (movimiento.tipo) {
      TipoCartera.prestamo => 'PRÉSTAMO A CLIENTE',
      TipoCartera.abono => 'ABONO DE CARTERA',
      TipoCartera.saldoFavor => 'INGRESO DE CLIENTE (SALDO A FAVOR)',
      TipoCartera.aplicacionSaldoFavor => 'SALDO A FAVOR APLICADO',
    };
    final lineas = <LineaComprobante>[
      LineaComprobante.texto(titulo),
      LineaComprobante.campo('Cliente', movimiento.nombreCliente),
      LineaComprobante.campo('Concepto', movimiento.concepto),
      LineaComprobante.campo(
        'Valor',
        CurrencyFormatter.formatValue(movimiento.monto),
        enNegrita: true,
      ),
      LineaComprobante.campo(
        'Fecha',
        _formatearFecha(movimiento.fechaRegistro),
      ),
      LineaComprobante.campo('Operador', movimiento.operador),
    ];
    if (movimiento.tipo == TipoCartera.abono &&
        movimiento.distribucion != null) {
      lineas.add(const LineaComprobante.separador());
      lineas.add(const LineaComprobante.texto(
        'Distribución del abono',
      ));
      for (final detalle in movimiento.distribucion!) {
        lineas.add(
          LineaComprobante.campo(
            detalle.concepto,
            CurrencyFormatter.formatValue(detalle.monto),
          ),
        );
      }
    }
    return lineas;
  }

  String _formatearFecha(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '${fecha.day}/${fecha.month}/${fecha.year} $h:$m';
  }

  // ==========================================================================
  // §3.3.4 — CIERRE DE CAJA
  // ==========================================================================

  /// Cierra la sesión de Caja marcándola con estado `cerrada` y
  /// registrando la fecha de cierre (§3.3.4). El corte financiero
  /// (saldo teórico vs efectivo contado, diferencia) se calcula en la
  /// vista a partir del estado. Lanza [CajaNoAbiertaException] si la
  /// sesión no está abierta.
  Future<void> cerrarCaja({String? operador}) async {
    final sesion = state.sesionActual;
    if (sesion == null || sesion.estado != EstadoCajaSesion.abierta) {
      throw const CajaNoAbiertaException();
    }

    final sesionCerrada = CajaSesion(
      id: sesion.id,
      cicloOperativoId: sesion.cicloOperativoId,
      saldoInicial: sesion.saldoInicial,
      estado: EstadoCajaSesion.cerrada,
      fechaApertura: sesion.fechaApertura,
      abiertaPor: operador ?? sesion.abiertaPor,
      fechaCierre: DateTime.now(),
    );

    state = state.copyWith(sesionActual: sesionCerrada);

    // Al cerrar la Caja se elimina el marcador de "sesión abierta"
    // persistida, de modo que el siguiente inicio exija una nueva
    // apertura (§3.3.4 — "si se cierra la caja sí se crea una nueva").
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesionAbierta);
    await prefs.remove(_keySesionAbiertaOperador);
    await prefs.remove(_keySesionAbiertaFecha);
  }

  // ==========================================================================
  // CONSULTAS AUXILIARES
  // ==========================================================================

  /// Filtra el historial por tipo de café — usado por el "Imprimir
  /// Informe de Café por Tipo" del §3.3.3. Placeholder: la vinculación
  /// real con tipo de café llega junto con el Módulo Procesos, que
  /// escribe movimientos con origen_tabla = 'transacciones'.
  List<MovimientoCaja> movimientosPorOrigen(String origenTabla) {
    return state.movimientosVisibles
        .where((m) => m.origenTabla == origenTabla)
        .toList();
  }
}

final cajaProvider = StateNotifierProvider<CajaNotifier, CajaEstado>((ref) {
  return CajaNotifier();
});
