// ==================== ESTADO "ACTUALIZACIÓN EN CURSO" ====================
// Estado global compartido que refleja si una actualización OTA está en
// progreso (descarga/instalación) y su porcentaje. Mientras `enCurso` sea
// true no se permite abrir la Caja (regla de negocio: la Caja debe quedar
// cerrada durante una actualización). La pantalla de Actualizaciones
// alimenta este estado; AperturaCajaScreen lo vigila para bloquear y
// mostrar el porcentaje.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Instantánea del estado de una actualización OTA en curso.
class ActualizacionEnCurso {
  const ActualizacionEnCurso({
    this.enCurso = false,
    this.progreso = 0,
    this.mensaje = '',
  });

  /// true mientras la descarga o instalación del APK esté activa.
  final bool enCurso;

  /// Porcentaje descargado (0..100), si la descarga está activa.
  final double progreso;

  /// Etiqueta de estado (p. ej. "Descargando… 45%", "Instalando…").
  final String mensaje;

  ActualizacionEnCurso copyWith({
    bool? enCurso,
    double? progreso,
    String? mensaje,
  }) {
    return ActualizacionEnCurso(
      enCurso: enCurso ?? this.enCurso,
      progreso: progreso ?? this.progreso,
      mensaje: mensaje ?? this.mensaje,
    );
  }
}

class ActualizacionEnCursoNotifier
    extends StateNotifier<ActualizacionEnCurso> {
  ActualizacionEnCursoNotifier() : super(const ActualizacionEnCurso());

  /// Marca el inicio de una descarga (conexión con el servidor).
  void iniciar() {
    state = const ActualizacionEnCurso(
      enCurso: true,
      progreso: 0,
      mensaje: 'Conectando con el servidor…',
    );
  }

  /// Actualiza el porcentaje descargado durante DOWNLOADING.
  void actualizarProgreso(double pct, String mensaje) {
    state = state.copyWith(enCurso: true, progreso: pct, mensaje: mensaje);
  }

  /// Marca el estado de instalación del APK.
  void instalando() {
    state = state.copyWith(
      enCurso: true,
      progreso: 100,
      mensaje: 'Instalando actualización…',
    );
  }

  /// Finaliza la actualización (éxito, error o cancelación).
  void finalizar() {
    state = const ActualizacionEnCurso();
  }
}

final actualizacionEnCursoProvider =
    StateNotifierProvider<ActualizacionEnCursoNotifier, ActualizacionEnCurso>(
  (ref) => ActualizacionEnCursoNotifier(),
);