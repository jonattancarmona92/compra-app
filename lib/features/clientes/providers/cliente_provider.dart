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
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  }

  int _correlativo = 100;

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
    bool? tieneAnticipos,
  }) {
    final actualizada = state.clientes.map((c) {
      if (c.id != clienteId) return c;
      return c.copyWith(
        saldoDeuda: saldoDeuda ?? c.saldoDeuda,
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
