// ==================== ARCHIVO: lib/features/clientes/providers/cliente_provider.dart ====================
// ClienteProvider — Informe Global §5.5.5 (tabla `clientes`) y §3.5
// (Módulo de Clientes, Ficha Única 360).
//
// NOTA DE INTEGRACIÓN PENDIENTE: por ahora el catálogo de clientes se
// mantiene en MEMORIA con datos de demostración, reproduciendo los
// campos de la tabla `clientes`. El Módulo 5 (Drift) reemplazará el
// repositorio interno por consultas SQLite reales sin cambiar la
// interfaz pública del Notifier, gracias a la capa de servicio
// abstracta definida abajo.
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cliente_model.dart';

// ============================================================================
// ESTADO
// ============================================================================

class ClienteEstado {
  final bool isCargando;
  final List<ClienteModel> clientes;

  const ClienteEstado({
    this.isCargando = true,
    this.clientes = const [],
  });

  ClienteEstado copyWith({
    bool? isCargando,
    List<ClienteModel>? clientes,
  }) {
    return ClienteEstado(
      isCargando: isCargando ?? this.isCargando,
      clientes: clientes ?? this.clientes,
    );
  }
}

// ============================================================================
// EXCEPCIONES DE DOMINIO
// ============================================================================

/// §5.5.5: "Control de duplicados bloqueante en la base de datos sobre
/// el documento de identidad".
class DuplicadoClienteException implements Exception {
  final String documento;
  const DuplicadoClienteException(this.documento);
}

class ClienteNoEncontradoException implements Exception {
  const ClienteNoEncontradoException();
}

// ============================================================================
// PROVIDER
// ============================================================================

class ClienteNotifier extends StateNotifier<ClienteEstado> {
  ClienteNotifier() : super(const ClienteEstado()) {
    _inicializar();
    _restaurarPersistido();
  }

  int _correlativo = 100;

  static const String _keyEstado = 'clientes_estado_json_v1';

  /// Persiste el catálogo en disco tras cada mutación para sobrevivir a
  /// reinicios del proceso.
  @override
  set state(ClienteEstado value) {
    super.state = value;
    _persistirEstado();
  }

  Future<void> _persistirEstado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyEstado,
        jsonEncode({
          'correlativo': _correlativo,
          'clientes': state.clientes.map(_clienteAJson).toList(),
        }),
      );
    } catch (_) {
      // Entorno sin storage (tests): se omite la persistencia.
    }
  }

  Map<String, dynamic> _clienteAJson(ClienteModel c) => {
        'id': c.id,
        'nombreCompleto': c.nombreCompleto,
        'documento': c.documento,
        'telefono': c.telefono,
        'direccion': c.direccion,
        'creditoAutorizado': c.creditoAutorizado,
        'cupoMaximo': c.cupoMaximo,
        'activo': c.activo,
        'saldoDeuda': c.saldoDeuda,
        'saldoFavor': c.saldoFavor,
        'tieneAnticipos': c.tieneAnticipos,
      };

  ClienteModel _clienteDesdeJson(Map<String, dynamic> j) => ClienteModel(
        id: j['id'] as String,
        nombreCompleto: j['nombreCompleto'] as String,
        documento: j['documento'] as String,
        telefono: j['telefono'] as String?,
        direccion: j['direccion'] as String?,
        creditoAutorizado: j['creditoAutorizado'] as bool? ?? false,
        cupoMaximo: (j['cupoMaximo'] as num?)?.toDouble() ?? 0,
        activo: j['activo'] as bool? ?? true,
        saldoDeuda: (j['saldoDeuda'] as num?)?.toDouble() ?? 0,
        saldoFavor: (j['saldoFavor'] as num?)?.toDouble() ?? 0,
        tieneAnticipos: j['tieneAnticipos'] as bool? ?? false,
      );

  /// Restaura el catálogo guardado en disco. Si no hay datos o el
  /// entorno no tiene storage, parte de un catálogo vacío.
  Future<void> _restaurarPersistido() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = prefs.getString(_keyEstado);
      if (guardado == null || guardado.isEmpty) {
        _inicializar();
        return;
      }
      final json = jsonDecode(guardado) as Map<String, dynamic>;
      _correlativo = (json['correlativo'] as num?)?.toInt() ?? 100;
      state = ClienteEstado(
        isCargando: false,
        clientes: (json['clientes'] as List? ?? const [])
            .map((e) => _clienteDesdeJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      _inicializar();
    }
  }

  void _inicializar() {
    state = state.copyWith(isCargando: false, clientes: const []);
  }

  // ==========================================================================
  // CONSULTAS
  // ==========================================================================

  /// §3.3.2 (Préstamos): clientes activos con crédito autorizado.
  List<ClienteModel> clientesParaPrestamo() {
    return state.clientes
        .where((c) => c.activo && c.creditoAutorizado)
        .toList();
  }

  /// §3.3.2 (Abonos): clientes activos que son deudores o con anticipos.
  List<ClienteModel> clientesParaAbono() {
    return state.clientes
        .where((c) => c.activo && (c.saldoDeuda > 0 || c.tieneAnticipos))
        .toList();
  }

  ClienteModel? buscarPorId(String id) {
    for (final c in state.clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ==========================================================================
  // CRUD
  // ==========================================================================

  /// §3.5.1 / §5.5.5: registra un cliente nuevo validando duplicados por
  /// documento. Devuelve el id asignado.
  String registrarCliente({
    required String nombreCompleto,
    required String documento,
    String? telefono,
    String? direccion,
    bool creditoAutorizado = false,
    double cupoMaximo = 0,
  }) {
    if (nombreCompleto.trim().isEmpty) {
      throw ArgumentError('El nombre completo es obligatorio.');
    }
    final normalized = documento.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('El documento es obligatorio.');
    }
    // §5.5.5: control de duplicados bloqueante sobre el documento.
    final existe = state.clientes.any(
      (c) => c.documento.toLowerCase() == normalized.toLowerCase(),
    );
    if (existe) {
      throw DuplicadoClienteException(normalized);
    }

    final nuevo = ClienteModel(
      id: 'cli-${_correlativo++}',
      nombreCompleto: nombreCompleto.trim(),
      documento: normalized,
      telefono: telefono?.trim(),
      direccion: direccion?.trim(),
      creditoAutorizado: creditoAutorizado,
      cupoMaximo: cupoMaximo < 0 ? 0 : cupoMaximo,
      activo: true,
    );
    state = state.copyWith(clientes: [...state.clientes, nuevo]);
    return nuevo.id;
  }

  /// Actualiza el saldo de deuda y el flag de anticipos del cliente
  /// tras un movimiento de cartera (§3.3.2 "Recálculo de Cartera").
  void actualizarSaldos({
    required String clienteId,
    double? saldoDeuda,
    double? saldoFavor,
    bool? tieneAnticipos,
  }) {
    final actualizada = state.clientes.map((c) {
      if (c.id != clienteId) return c;
      return c.copyWith(
        saldoDeuda: saldoDeuda ?? c.saldoDeuda,
        saldoFavor: saldoFavor ?? c.saldoFavor,
        tieneAnticipos: tieneAnticipos ?? c.tieneAnticipos,
      );
    }).toList();
    state = state.copyWith(clientes: actualizada);
  }

  /// §3.5.2: inactiva lógicamente al cliente (activo = false).
  void inactivar(String clienteId) {
    final actualizada = state.clientes.map((c) {
      if (c.id != clienteId) return c;
      return c.copyWith(activo: false);
    }).toList();
    state = state.copyWith(clientes: actualizada);
  }
}

final clienteProvider =
    StateNotifierProvider<ClienteNotifier, ClienteEstado>((ref) {
  return ClienteNotifier();
});
