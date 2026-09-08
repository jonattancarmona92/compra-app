// ==================== ARCHIVO: lib/core/seguridad/hora_legal_service.dart ====================
// Fuente de tiempo de validación — Informe Global §1.4 / §10.3
// Único proveedor autorizado de "Hora Legal" para el algoritmo CC-MK-01.
// Prohibido terminantemente sustituir con DateTime.now() del
// dispositivo si la consulta NTP falla (§10.3.1).
import 'package:ntp/ntp.dart';

/// Resultado de intentar obtener la Hora Legal de Colombia vía NTP.
class HoraLegalResultado {
  final bool exito;
  final DateTime? horaLegal;
  final String? error;

  const HoraLegalResultado._({required this.exito, this.horaLegal, this.error});

  const HoraLegalResultado.exitosa(DateTime hora)
    : this._(exito: true, horaLegal: hora);

  const HoraLegalResultado.fallida(String error)
    : this._(exito: false, error: error);
}

/// Servicio que obtiene la Hora Legal de la República de Colombia
/// exclusivamente desde los servidores NTP oficiales del Instituto
/// Nacional de Metrología (§1.4).
class HoraLegalService {
  static const List<String> _servidoresNtpOficiales = [
    'ntp1.inm.gov.co',
    'ntp2.inm.gov.co',
  ];

  static const Duration _timeoutPorServidor = Duration(seconds: 5);

  /// Intenta obtener la Hora Legal probando cada servidor NTP oficial
  /// en orden. Si ambos fallan, retorna un resultado fallido con el
  /// mensaje bloqueante exigido por §10.3.1: "No se puede validar la
  /// Hora Legal" — nunca recurre al reloj local como sustituto.
  Future<HoraLegalResultado> obtenerHoraLegal() async {
    for (final servidor in _servidoresNtpOficiales) {
      try {
        final offsetMs = await NTP.getNtpOffset(
          lookUpAddress: servidor,
          timeout: _timeoutPorServidor,
        );

        // El offset corrige el reloj local respecto al servidor NTP;
        // esto NO es "usar el reloj local como sustituto" (prohibido
        // por §10.3.1), sino la técnica estándar de sincronización:
        // Hora Legal = reloj local + desviación medida contra el
        // servidor oficial del INM.
        final horaLegal = DateTime.now().add(Duration(milliseconds: offsetMs));
        return HoraLegalResultado.exitosa(horaLegal);
      } catch (_) {
        continue;
      }
    }

    return const HoraLegalResultado.fallida(
      'No se puede validar la Hora Legal',
    );
  }
}
