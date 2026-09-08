// ==================== LICENCIA — PROVEEDOR CENTRAL ====================
// Documento "Pin de recarga". Orquesta el ID de dispositivo, el estado de
// la licencia (vencimiento/plan), el canje de PINs (hardware binding,
// vigencia 24 h, uso único, bloqueo 1 h tras 3 fallos) y el banner.
// Persistencia: secure storage (ID) + SQLite (licencia y pines canjeados).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/base_datos/app_database.dart';
import '../../core/seguridad/licencia_pin.dart';
import 'package:drift/drift.dart' as drift;

/// Días de plazo inicial al configurar el sistema (Día Cero).
const int diasLicenciaInicial = 30;

/// Fallos permitidos antes de bloquear la recarga por 1 hora.
const int intentosMaximosRecarga = 3;

class LicenciaEstado {
  final String dispositivoId;
  final DateTime? fechaVencimiento;
  final String planActual;
  final bool cargando;
  final int intentosFallidos;
  final DateTime? bloqueadoHasta;

  const LicenciaEstado({
    this.dispositivoId = '',
    this.fechaVencimiento,
    this.planActual = '',
    this.cargando = true,
    this.intentosFallidos = 0,
    this.bloqueadoHasta,
  });

  /// Días naturales hasta el vencimiento (hoy=0, mañana=1, ...).
  int get diasRestantes {
    final v = fechaVencimiento;
    if (v == null) return 0;
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fin = DateTime(v.year, v.month, v.day);
    return fin.difference(hoy).inDays;
  }

  bool get enBloqueo {
    final h = bloqueadoHasta;
    return h != null && DateTime.now().isBefore(h);
  }

  Duration get tiempoBloqueoRestante {
    final h = bloqueadoHasta;
    if (!enBloqueo || h == null) return Duration.zero;
    return h.difference(DateTime.now());
  }

  /// Licencia vencida (sin días restantes): bloquea la operación.
  bool get esVencida =>
      fechaVencimiento != null && !cargando && diasRestantes < 0;

  /// El banner del dashboard solo aparece con 3, 2, 1 o 0 días restantes.
  bool get bannerVisible =>
      !cargando && fechaVencimiento != null && diasRestantes >= 0 && diasRestantes <= 3;

  LicenciaEstado copyWith({
    String? dispositivoId,
    DateTime? fechaVencimiento,
    String? planActual,
    bool? cargando,
    int? intentosFallidos,
    DateTime? bloqueadoHasta,
    bool limpiarBloqueo = false,
  }) {
    return LicenciaEstado(
      dispositivoId: dispositivoId ?? this.dispositivoId,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      planActual: planActual ?? this.planActual,
      cargando: cargando ?? this.cargando,
      intentosFallidos: intentosFallidos ?? this.intentosFallidos,
      bloqueadoHasta: limpiarBloqueo ? null : (bloqueadoHasta ?? this.bloqueadoHasta),
    );
  }
}

class ResultadoCanje {
  final bool exito;
  final bool bloqueado;
  final String mensaje;

  const ResultadoCanje.exito(this.mensaje) : exito = true, bloqueado = false;
  const ResultadoCanje.fallo(this.mensaje) : exito = false, bloqueado = false;
  const ResultadoCanje.bloqueo(this.mensaje) : exito = false, bloqueado = true;
}

class LicenciaNotifier extends StateNotifier<LicenciaEstado> {
  LicenciaNotifier(this._ref) : super(const LicenciaEstado()) {
    refrescar();
  }

  final Ref _ref;
  static const _keyDispositivoId = 'dispositivo_id';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  int _millis(DateTime d) => d.millisecondsSinceEpoch;

  // ==========================================================================
  // CARGA INICIAL / REFRESCO
  // ==========================================================================

  Future<void> refrescar() async {
    final idGuardado = await _storage.read(key: _keyDispositivoId);
    final fila = await (()
        async {
      try {
        return await (_db.select(_db.licencia)
              ..where((t) => t.id.equals(1)))
            .getSingleOrNull();
      } catch (_) {
        return null;
      }
    })();

    state = state.copyWith(
      dispositivoId: (idGuardado ?? fila?.dispositivoId) ?? '',
      fechaVencimiento: fila == null
          ? state.fechaVencimiento
          : DateTime.fromMillisecondsSinceEpoch(fila.fechaVencimiento),
      planActual: fila?.planActual ?? state.planActual,
      cargando: false,
    );
  }

  // ==========================================================================
  // ID DE DISPOSITIVO (Día Cero)
  // ==========================================================================

  /// Obtiene el ID del dispositivo; lo genera y lo cifra la primera vez.
  Future<String> obtenerOCrearDispositivoId() async {
    var id = await _storage.read(key: _keyDispositivoId);
    if (id == null || !DispositivoId.esValido(id)) {
      id = DispositivoId.generar();
      await _storage.write(key: _keyDispositivoId, value: id);
    }
    state = state.copyWith(dispositivoId: id);
    return id;
  }

  /// Crea la licencia con el plazo inicial de Día Cero (solo la primera vez).
  Future<void> inicializarLicencia({required String dispositivoId}) async {
    final existente = await (_db.select(_db.licencia)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (existente != null) {
      await refrescar();
      return;
    }
    final ahora = DateTime.now();
    final vencimiento = DateTime(ahora.year, ahora.month, ahora.day)
        .add(const Duration(days: diasLicenciaInicial));

    await _db.transaction(() async {
      await _guardarLicencia(
        dispositivoId: dispositivoId,
        vencimiento: vencimiento,
        plan: TipoLicencia.inicial.plan,
      );
    });
    await refrescar();
  }

  /// Inserta la fila única de licencia (id=1) o la actualiza si existe.
  Future<void> _guardarLicencia({
    required String dispositivoId,
    required DateTime vencimiento,
    required String plan,
  }) async {
    final existente = await (_db.select(_db.licencia)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (existente == null) {
      await _db.into(_db.licencia).insert(
            LicenciaCompanion.insert(
              id: 1,
              dispositivoId: dispositivoId,
              fechaVencimiento: _millis(vencimiento),
              planActual: plan,
            ),
          );
    } else {
      await (_db.update(_db.licencia)..where((t) => t.id.equals(1))).write(
            LicenciaCompanion(
              dispositivoId: drift.Value(dispositivoId),
              fechaVencimiento: drift.Value(_millis(vencimiento)),
              planActual: drift.Value(plan),
            ),
          );
    }
  }

  // ==========================================================================
  // CANJE DE PIN DE RECARGA
  // ==========================================================================

  Future<ResultadoCanje> cargarPin(String pinIngresado) async {
    if (state.enBloqueo) {
      return ResultadoCanje.bloqueo(
        'Demasiados intentos fallidos. Espere ${_formatearBloqueo(state.tiempoBloqueoRestante)}.',
      );
    }

    final analizado = analizarPin(pinIngresado);
    if (!analizado.ok) {
      return _registrarFallo(analizado.error!);
    }
    final info = analizado.info!;

    // Hardware binding: si el ID incrustado no coincide, no quema intento.
    if (info.dispositivo != state.dispositivoId) {
      return const ResultadoCanje.fallo('Este PIN no corresponde a este equipo');
    }

    // Uso único: PIN ya canjeado.
    final yaCanjeado = await (_db.select(_db.pinesCanjeados)
          ..where((t) => t.pin.equals(info.pin)))
        .getSingleOrNull();
    if (yaCanjeado != null) {
      return _registrarFallo('Este PIN ya fue utilizado');
    }

    // Canje: se suma el tiempo al vencimiento actual (o desde hoy si venció).
    final ahora = DateTime.now();
    final base = (state.fechaVencimiento != null &&
            state.fechaVencimiento!.isAfter(ahora))
        ? state.fechaVencimiento!
        : ahora;
    final nuevoVencimiento = base.add(Duration(days: info.tipo.dias));

    await _db.transaction(() async {
      await _guardarLicencia(
        dispositivoId: state.dispositivoId,
        vencimiento: nuevoVencimiento,
        plan: info.tipo.plan,
      );
      await _db.into(_db.pinesCanjeados).insert(
            PinesCanjeadosCompanion.insert(
              pin: info.pin,
              tipo: info.tipo.letra!,
              dias: info.tipo.dias,
              fechaCanje: _millis(ahora),
            ),
          );
    });

    state = state.copyWith(
      fechaVencimiento: nuevoVencimiento,
      planActual: info.tipo.plan,
      intentosFallidos: 0,
      limpiarBloqueo: true,
    );
    return ResultadoCanje.exito(
      '¡Licencia extendida por ${info.tipo.dias} días!',
    );
  }

  ResultadoCanje _registrarFallo(String mensaje) {
    if (state.enBloqueo) {
      return ResultadoCanje.bloqueo(
        'Demasiados intentos fallidos. Espere ${_formatearBloqueo(state.tiempoBloqueoRestante)}.',
      );
    }
    final nuevos = state.intentosFallidos + 1;
    if (nuevos >= intentosMaximosRecarga) {
      state = state.copyWith(
        intentosFallidos: 0,
        bloqueadoHasta: DateTime.now().add(const Duration(hours: 1)),
      );
      return const ResultadoCanje.bloqueo(
        'Demasiados intentos fallidos. La recarga se bloqueó por 1 hora.',
      );
    }
    state = state.copyWith(intentosFallidos: nuevos);
    return ResultadoCanje.fallo(mensaje);
  }

  static String _formatearBloqueo(Duration d) {
    final horas = d.inHours.toString().padLeft(2, '0');
    final minutos = (d.inMinutes % 60).toString().padLeft(2, '0');
    final segundos = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$horas:$minutos:$segundos';
  }
}

final licenciaProvider =
    StateNotifierProvider<LicenciaNotifier, LicenciaEstado>((ref) {
  return LicenciaNotifier(ref);
});