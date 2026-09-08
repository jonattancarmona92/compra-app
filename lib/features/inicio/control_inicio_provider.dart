// ==================== ARCHIVO: lib/features/inicio/control_inicio_provider.dart ====================
// Orquestador lógico del arranque — Informe Global §1 y §2.2/§2.3.
// Componente clasificado como de enrutamiento inmutable (§6.9).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/seguridad/clave_maestra_cc01.dart';
import '../../core/seguridad/credenciales_hash.dart';
import '../../core/seguridad/hora_legal_service.dart';
import '../caja/caja_provider.dart';
import '../configuraciones/licencia_provider.dart';

/// Nivel de autenticación cotidiana — §1.2: Patrón(1) → PIN(2) →
/// Clave Maestra(3).
class NivelAutenticacion {
  static const int patron = 1;
  static const int pin = 2;
  static const int claveMaestra = 3;
}

const int _intentosMaximosPorNivel = 3;
const int _segundosBloqueoTotal = 30;

class ControlInicioEstado {
  final bool isCargando;

  /// Día Cero completado: Código de Activación + Clave Maestra
  /// validados Y Patrón/PIN ya registrados (§2.2).
  final bool isConfigurado;

  /// Sub-paso interno de Día Cero: activación validada, pendiente de
  /// registrar Patrón/PIN (§1.5/§2.2).
  final bool isActivado;

  final bool isAutenticado;
  final bool isPeriodoActivo;
  final bool isCajaAbierta;

  final int nivelAutenticacion;
  final int intentosFallidos;
  final bool isBloqueado;
  final int segundosRestantesBloqueo;

  /// §1.2: tras recuperar acceso con Clave Maestra, se obliga a crear
  /// un nuevo Patrón y PIN antes de entrar al Dashboard.
  final bool requiereReconfiguracionCredenciales;

  /// Mensaje bloqueante de Hora Legal — §10.3.1: "No se puede validar
  /// la Hora Legal".
  final String? errorHoraLegal;

  final bool validandoHoraLegal;

  const ControlInicioEstado({
    this.isCargando = true,
    this.isConfigurado = false,
    this.isActivado = false,
    this.isAutenticado = false,
    this.isPeriodoActivo = false,
    this.isCajaAbierta = false,
    this.nivelAutenticacion = NivelAutenticacion.patron,
    this.intentosFallidos = 0,
    this.isBloqueado = false,
    this.segundosRestantesBloqueo = 0,
    this.requiereReconfiguracionCredenciales = false,
    this.errorHoraLegal,
    this.validandoHoraLegal = false,
  });

  int get intentosRestantes => _intentosMaximosPorNivel - intentosFallidos;

  ControlInicioEstado copyWith({
    bool? isCargando,
    bool? isConfigurado,
    bool? isActivado,
    bool? isAutenticado,
    bool? isPeriodoActivo,
    bool? isCajaAbierta,
    int? nivelAutenticacion,
    int? intentosFallidos,
    bool? isBloqueado,
    int? segundosRestantesBloqueo,
    bool? requiereReconfiguracionCredenciales,
    String? errorHoraLegal,
    bool limpiarErrorHoraLegal = false,
    bool? validandoHoraLegal,
  }) {
    return ControlInicioEstado(
      isCargando: isCargando ?? this.isCargando,
      isConfigurado: isConfigurado ?? this.isConfigurado,
      isActivado: isActivado ?? this.isActivado,
      isAutenticado: isAutenticado ?? this.isAutenticado,
      isPeriodoActivo: isPeriodoActivo ?? this.isPeriodoActivo,
      isCajaAbierta: isCajaAbierta ?? this.isCajaAbierta,
      nivelAutenticacion: nivelAutenticacion ?? this.nivelAutenticacion,
      intentosFallidos: intentosFallidos ?? this.intentosFallidos,
      isBloqueado: isBloqueado ?? this.isBloqueado,
      segundosRestantesBloqueo:
          segundosRestantesBloqueo ?? this.segundosRestantesBloqueo,
      requiereReconfiguracionCredenciales:
          requiereReconfiguracionCredenciales ??
          this.requiereReconfiguracionCredenciales,
      errorHoraLegal: limpiarErrorHoraLegal
          ? null
          : (errorHoraLegal ?? this.errorHoraLegal),
      validandoHoraLegal: validandoHoraLegal ?? this.validandoHoraLegal,
    );
  }
}

class ControlInicioNotifier extends StateNotifier<ControlInicioEstado> {
  ControlInicioNotifier(this._ref) : super(const ControlInicioEstado()) {
    inicializarSistema();
  }

  final Ref _ref;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final HoraLegalService _horaLegalService = HoraLegalService();

  Timer? _timerBloqueo;
  Timer? _timerCuentaRegresiva;

  static const _keyPatronHash = 'patron_hash';
  static const _keyPinHash = 'pin_hash';

  // NOTA DE INTEGRACIÓN PENDIENTE: identificador de operador real
  // vendrá de la autenticación (Módulo 6). Mientras tanto se usa un
  // valor fijo documentado.
  static const String _operadorActual = 'operador_demo';

  @override
  void dispose() {
    _timerBloqueo?.cancel();
    _timerCuentaRegresiva?.cancel();
    super.dispose();
  }

  // ==========================================================================
  // ARRANQUE (§2.2)
  // ==========================================================================

  Future<void> inicializarSistema() async {
    state = state.copyWith(isCargando: true);

    final patronGuardado = await _storage.read(key: _keyPatronHash);
    final pinGuardado = await _storage.read(key: _keyPinHash);
    final configurado = patronGuardado != null && pinGuardado != null;

    // §2.3 / §3.3.4 — Consulta del estado real de la Caja al arrancar:
    //  - Si quedó una sesión abierta, se restaura (NO se pide una nueva
    //    apertura en cada inicio).
    //  - Si esa sesión es de una jornada anterior y no se hizo el Cierre
    //    de Caja, se realiza el cierre automático (§3.3.4) y se exige
    //    una nueva apertura.
    final cajaNotifier = _ref.read(cajaProvider.notifier);
    await cajaNotifier.restaurarSesionGuardada();
    final habiaSesion = await cajaNotifier.habiaSesionAbierta();
    bool periodoActivo = false;
    bool cajaAbierta = false;

    if (habiaSesion) {
      final fechaApertura = await cajaNotifier.fechaSesionAbiertaGuardada();
      final hoy = DateTime.now();
      final esMismaJornada = fechaApertura != null &&
          fechaApertura.day == hoy.day &&
          fechaApertura.month == hoy.month &&
          fechaApertura.year == hoy.year;

      if (esMismaJornada) {
        // Caja abierta este mismo día: se restaura sin nueva apertura.
        periodoActivo = true;
        cajaAbierta = true;
      } else {
        // Jornada anterior sin Cierre de Caja: cierre automático.
        await _cerrarCajaAutomatica(cajaNotifier);
      }
    }

    if (!configurado) {
      // Día Cero: aún no hay credenciales; no se restaura sesión.
      cajaAbierta = false;
      periodoActivo = false;
    }

    // Nota: el ID de dispositivo y la licencia inicial NO se crean en el
    // arranque. Se generan únicamente tras validar la Clave Maestra
    // (Documento "Pin de recarga"): en `validarActivacion` (Día Cero).
    // Aquí la licencia solo se consulta (refrescar en LicenciaNotifier)
    // para el banner y el bloqueo por vencimiento.

    state = state.copyWith(
      isCargando: false,
      isConfigurado: configurado,
      isActivado: false,
      isAutenticado: false,
      isPeriodoActivo: periodoActivo,
      isCajaAbierta: cajaAbierta,
      nivelAutenticacion: NivelAutenticacion.patron,
      intentosFallidos: 0,
      isBloqueado: false,
      limpiarErrorHoraLegal: true,
    );
  }

  Future<void> _cerrarCajaAutomatica(CajaNotifier cajaNotifier) async {
    final caja = _ref.read(cajaProvider);
    if (caja.sesionActual != null &&
        caja.sesionActual!.estado == EstadoCajaSesion.abierta) {
      await cajaNotifier.cerrarCaja(operador: 'cierre_automatico');
    } else {
      await cajaNotifier.limpiarSesionPersistida();
    }
  }

  // ==========================================================================
  // DÍA CERO — PASO 1: Clave Maestra (§1.5/§2.2)
  // ==========================================================================

  /// Valida la Clave Maestra CC-MK-01, tal como exige el §1.5. Requiere
  /// Hora Legal vía NTP — si falla, bloquea con el mensaje del §10.3.1 y
  /// NUNCA usa el reloj local (§1.4).
  Future<bool> validarActivacion({
    required String claveMaestraIngresada,
  }) async {
    state = state.copyWith(
      validandoHoraLegal: true,
      limpiarErrorHoraLegal: true,
    );

    final resultadoHora = await _horaLegalService.obtenerHoraLegal();

    if (!resultadoHora.exito) {
      state = state.copyWith(
        validandoHoraLegal: false,
        errorHoraLegal: 'No se puede validar la Hora Legal',
      );
      return false;
    }

    final validacionClave = ClaveMaestraCC01.validar(
      claveMaestraIngresada,
      resultadoHora.horaLegal!,
    );

    if (!validacionClave.esValida) {
      state = state.copyWith(
        validandoHoraLegal: false,
        errorHoraLegal: validacionClave.motivoError,
      );
      return false;
    }

    // Licencia (Documento "Pin de recarga"): el ID de dispositivo se genera
    // la primera vez (y se cifra) y la licencia inicial de 30 días se crea
    // SOLO después de validar la Clave Maestra. Idempotente.
    final licencia = _ref.read(licenciaProvider.notifier);
    final dispositivoId = await licencia.obtenerOCrearDispositivoId();
    await licencia.inicializarLicencia(dispositivoId: dispositivoId);

    state = state.copyWith(
      validandoHoraLegal: false,
      isActivado: true,
      limpiarErrorHoraLegal: true,
    );
    return true;
  }

  // ==========================================================================
  // DÍA CERO — PASO 2: Registro de Patrón y PIN (§2.2)
  // ==========================================================================

  /// Finaliza Día Cero registrando las credenciales locales de uso
  /// diario. Solo puede invocarse tras una activación válida.
  Future<bool> registrarCredencialesIniciales({
    required String patronSerializado,
    required String pin,
  }) async {
    if (!state.isActivado) return false;

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }

    await _guardarPatron(patronSerializado);
    await _guardarPin(pin);

    state = state.copyWith(
      isConfigurado: true,
      isActivado: false,
      isAutenticado: false,
      isPeriodoActivo: false,
      isCajaAbierta: false,
      nivelAutenticacion: NivelAutenticacion.patron,
      intentosFallidos: 0,
      isBloqueado: false,
      requiereReconfiguracionCredenciales: false,
    );
    return true;
  }

  Future<void> _guardarPatron(String patronSerializado) async {
    final credencial = CredencialesHash.crear(patronSerializado);
    await _storage.write(key: _keyPatronHash, value: credencial.serializar());
  }

  Future<void> _guardarPin(String pin) async {
    final credencial = CredencialesHash.crear(pin);
    await _storage.write(key: _keyPinHash, value: credencial.serializar());
  }

  // ==========================================================================
  // CAMBIO VOLUNTARIO DE CREDENCIALES (Configuración > Seguridad > Avanzadas)
  // ==========================================================================

  /// Verifica una credencial (patrón o PIN) contra el hash almacenado
  /// SIN registrar fallos ni afectar la jerarquía de bloqueo.
  Future<bool> verificarCredencial(String valor, {required bool esPin}) async {
    final key = esPin ? _keyPinHash : _keyPatronHash;
    final guardado = await _storage.read(key: key);
    final credencial = CredencialHasheada.deserializar(guardado);
    if (credencial == null) return false;
    return CredencialesHash.verificar(valor, credencial);
  }

  /// Cambia el patrón de desbloqueo. Devuelve `false` si la credencial
  /// actual es incorrecta.
  Future<bool> cambiarPatron({
    required String patronActual,
    required String nuevoPatron,
    required String confirmarPatron,
  }) async {
    final actualOk = await verificarCredencial(patronActual, esPin: false);
    if (!actualOk) return false;
    if (nuevoPatron != confirmarPatron) return false;
    await _guardarPatron(nuevoPatron);
    return true;
  }

  /// Cambia el PIN de operación (4 dígitos). Devuelve `false` si la
  /// credencial actual es incorrecta o el PIN no cumple formato.
  Future<bool> cambiarPin({
    required String pinActual,
    required String nuevoPin,
    required String confirmarPin,
  }) async {
    if (!RegExp(r'^\d{4}$').hasMatch(nuevoPin)) return false;
    final actualOk = await verificarCredencial(pinActual, esPin: true);
    if (!actualOk) return false;
    if (nuevoPin != confirmarPin) return false;
    await _guardarPin(nuevoPin);
    return true;
  }

  // ==========================================================================
  // DESBLOQUEO COTIDIANO (§1.2)
  // ==========================================================================

  /// Valida el intento de acceso contra el nivel actual de la
  /// jerarquía. Para nivel 3 (Clave Maestra) exige Hora Legal vía NTP
  /// y, si tiene éxito, marca `requiereReconfiguracionCredenciales`
  /// en vez de autenticar directamente (§1.2).
  Future<bool> validarCredencial(String valorIngresado) async {
    if (state.isBloqueado) return false;

    switch (state.nivelAutenticacion) {
      case NivelAutenticacion.patron:
        return _validarPatronOPin(valorIngresado, _keyPatronHash);
      case NivelAutenticacion.pin:
        return _validarPatronOPin(valorIngresado, _keyPinHash);
      case NivelAutenticacion.claveMaestra:
        return _validarClaveMaestraRecuperacion(valorIngresado);
      default:
        return false;
    }
  }

  Future<bool> _validarPatronOPin(String valorIngresado, String key) async {
    final guardado = await _storage.read(key: key);
    final credencial = CredencialHasheada.deserializar(guardado);

    if (credencial == null) {
      _registrarFallo();
      return false;
    }

    final correcto = CredencialesHash.verificar(valorIngresado, credencial);

    if (correcto) {
      _registrarExito();
      return true;
    }

    _registrarFallo();
    return false;
  }

  Future<bool> _validarClaveMaestraRecuperacion(String claveIngresada) async {
    state = state.copyWith(
      validandoHoraLegal: true,
      limpiarErrorHoraLegal: true,
    );

    final resultadoHora = await _horaLegalService.obtenerHoraLegal();

    if (!resultadoHora.exito) {
      state = state.copyWith(
        validandoHoraLegal: false,
        errorHoraLegal: 'No se puede validar la Hora Legal',
      );
      return false;
    }

    final validacion = ClaveMaestraCC01.validar(
      claveIngresada,
      resultadoHora.horaLegal!,
    );

    state = state.copyWith(validandoHoraLegal: false);

    if (!validacion.esValida) {
      _registrarFallo();
      return false;
    }

    // §1.2: recuperar con Clave Maestra OBLIGA a reconfigurar Patrón
    // y PIN antes de entrar al Dashboard. No se marca isAutenticado
    // todavía.
    state = state.copyWith(
      requiereReconfiguracionCredenciales: true,
      isActivado: true, // reutiliza el flujo de registro de Día Cero
      intentosFallidos: 0,
      isBloqueado: false,
      nivelAutenticacion: NivelAutenticacion.patron,
    );
    return true;
  }

  void _registrarExito() {
    _timerBloqueo?.cancel();
    _timerCuentaRegresiva?.cancel();

    state = state.copyWith(
      isAutenticado: true,
      nivelAutenticacion: NivelAutenticacion.patron,
      intentosFallidos: 0,
      isBloqueado: false,
      segundosRestantesBloqueo: 0,
    );

    crearPeriodoOperativoSilencioso();
  }

  void _registrarFallo() {
    final nuevosIntentos = state.intentosFallidos + 1;

    if (nuevosIntentos >= _intentosMaximosPorNivel) {
      if (state.nivelAutenticacion < NivelAutenticacion.claveMaestra) {
        // Escala Patrón → PIN → Clave Maestra (§1.2).
        state = state.copyWith(
          nivelAutenticacion: state.nivelAutenticacion + 1,
          intentosFallidos: 0,
        );
      } else {
        // Agotados los 3 niveles: bloqueo físico de 30s (§1.2).
        _iniciarBloqueoTemporal();
      }
    } else {
      state = state.copyWith(intentosFallidos: nuevosIntentos);
    }
  }

  // ==========================================================================
  // BLOQUEO TEMPORAL DE 30 SEGUNDOS (§1.2)
  // ==========================================================================

  void _iniciarBloqueoTemporal() {
    state = state.copyWith(
      isBloqueado: true,
      segundosRestantesBloqueo: _segundosBloqueoTotal,
    );

    _timerCuentaRegresiva?.cancel();
    _timerCuentaRegresiva = Timer.periodic(const Duration(seconds: 1), (timer) {
      final restante = state.segundosRestantesBloqueo - 1;
      if (restante <= 0) {
        timer.cancel();
        state = state.copyWith(segundosRestantesBloqueo: 0);
      } else {
        state = state.copyWith(segundosRestantesBloqueo: restante);
      }
    });

    _timerBloqueo?.cancel();
    _timerBloqueo = Timer(Duration(seconds: _segundosBloqueoTotal), () {
      _timerCuentaRegresiva?.cancel();
      state = state.copyWith(
        isBloqueado: false,
        intentosFallidos: 0,
        segundosRestantesBloqueo: 0,
        nivelAutenticacion: NivelAutenticacion.patron,
      );
    });
  }

  // ==========================================================================
  // VALIDACIÓN DE PIN PARA OPERACIONES (§1.2)
  // ==========================================================================

  /// Valida un PIN de operación cotidiana (cancelaciones, liquidaciones,
  /// cierres, préstamos/abonos) contra el PIN registrado en Día Cero o
  /// en la reconfiguración obligatoria. Es el mismo que desbloquea la
  /// app en el nivel 2 (§1.2). NO interviene en la jerarquía de bloqueo
  /// del login: una falla aquí solo rechaza la operación.
  Future<bool> validarPinOperativo(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) return false;
    final guardado = await _storage.read(key: _keyPinHash);
    final credencial = CredencialHasheada.deserializar(guardado);
    if (credencial == null) return false;
    return CredencialesHash.verificar(pin, credencial);
  }

  // ==========================================================================
  // CICLO OPERATIVO Y CAJA (§2.2)
  // ==========================================================================

  Future<void> crearPeriodoOperativoSilencioso() async {
    if (!state.isAutenticado) return;
    state = state.copyWith(isPeriodoActivo: true);
  }

  Future<void> abrirCaja(int saldoInicial) async {
    if (!state.isPeriodoActivo) return;
    if (saldoInicial < 0) return;

    // §2.2: abre la sesión de Caja real (saldo inicial + persistencia).
    await _ref
        .read(cajaProvider.notifier)
        .abrirCaja(saldoInicial: saldoInicial.toDouble(), abiertaPor: _operadorActual);
    state = state.copyWith(isCajaAbierta: true);
  }

  /// §2.3 — Restauración Automática de Sesión: reservado para cuando
  /// el Módulo 5 (Drift) permita detectar una Caja que quedó abierta
  /// tras un cierre inesperado de la app.
  void restaurarCajaAbierta() {
    state = state.copyWith(
      isAutenticado: true,
      isPeriodoActivo: true,
      isCajaAbierta: true,
    );
  }

  void cerrarCaja() {
    // La sesión se cierra realmente en `cajaProvider.cerrarCaja` (que
    // además limpia el marcador persistido); aquí se refleja la UI.
    state = state.copyWith(isCajaAbierta: false);
  }

  void cerrarSesion() {
    state = state.copyWith(isAutenticado: false, isCajaAbierta: false);
  }
}

final controlInicioProvider =
    StateNotifierProvider<ControlInicioNotifier, ControlInicioEstado>((ref) {
      return ControlInicioNotifier(ref);
    });
