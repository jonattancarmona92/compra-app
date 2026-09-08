// ==================== CORE DE LICENCIA: ALGORITMO PIN DE RECARGA ====================
// Documento Maestro "Pin de recarga" — Coffee Control.
// Codificación/decodificación offline del PIN de 9 caracteres (XXXXX-XXXX)
// con reglas exactas: alfabeto seguro, vencimiento estricto de 24 h,
// hardware binding y plantillas M/S/A.
import 'dart:math';

/// Alfabeto seguro: se prohíben 0, 1, I y O.
class AlfabetoSeguro {
  static const String numeros = '23456789';
  static const String letras = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String completo = numeros + letras;

  static bool esPermitido(String c) => completo.contains(c);
}

/// 24 letras seguras para codificar la hora (formato 24 h, índice 0..23).
const String letrasHora = 'ABCDEFGHJKLMNPQRSTUVWXYZ';

/// Mes de generación: carácter → mes (1..12). Público para que el
/// generador de PINs (herramienta externa) use la misma tabla exacta.
const Map<String, int> mesesCodificacion = {
  '2': 1,
  '3': 2,
  '4': 3,
  '5': 4,
  '6': 5,
  '7': 6,
  '8': 7,
  '9': 8,
  'C': 9,
  'D': 10,
  'M': 11,
  'N': 12,
};

/// Cada dígito del día: A=0, B=1, 2..9 directo.
const Map<String, int> _digitosDia = {
  'A': 0,
  'B': 1,
  '2': 2,
  '3': 3,
  '4': 4,
  '5': 5,
  '6': 6,
  '7': 7,
  '8': 8,
  '9': 9,
};

// ==========================================================================
// GENERADOR Y VALIDADOR DEL ID DE DISPOSITIVO (4 caracteres: N-L-N-L)
// ==========================================================================

class DispositivoId {
  static const int longitud = 4;

  static String generar() {
    final rnd = Random.secure();
    String letra() =>
        AlfabetoSeguro.letras[rnd.nextInt(AlfabetoSeguro.letras.length)];
    String numero() =>
        AlfabetoSeguro.numeros[rnd.nextInt(AlfabetoSeguro.numeros.length)];
    return '${numero()}${letra()}${numero()}${letra()}';
  }

  /// Número - Letra - Número - Letra, con alfabeto seguro.
  static bool esValido(String id) {
    if (id.length != longitud) return false;
    return AlfabetoSeguro.numeros.contains(id[0]) &&
        AlfabetoSeguro.letras.contains(id[1]) &&
        AlfabetoSeguro.numeros.contains(id[2]) &&
        AlfabetoSeguro.letras.contains(id[3]);
  }
}

// ==========================================================================
// PIN DE RECARGA — ANÁLISIS
// ==========================================================================

/// Días que agrega cada tipo de licencia.
enum TipoLicencia {
  inicial(plan: 'INICIAL', dias: 30),
  mensual(plan: 'MENSUAL', dias: 30, letra: 'M'),
  semestral(plan: 'SEMESTRAL', dias: 180, letra: 'S'),
  anual(plan: 'ANUAL', dias: 365, letra: 'A');

  const TipoLicencia({
    required this.plan,
    required this.dias,
    this.letra,
  });

  final String plan;
  final int dias;
  final String? letra;
}

/// Resultado del análisis de un PIN.
class PinRecargaResult {
  const PinRecargaResult._(this.ok, {this.info, this.error});

  const PinRecargaResult.ok(PinRecargaInfo info)
      : this._(true, info: info);

  const PinRecargaResult.error(String error) : this._(false, error: error);

  final bool ok;
  final PinRecargaInfo? info;
  final String? error;
}

/// Información decodificada de un PIN válido.
class PinRecargaInfo {
  const PinRecargaInfo({
    required this.tipo,
    required this.generacion,
    required this.dispositivo,
    required this.pin,
  });

  final TipoLicencia tipo;
  final DateTime generacion;
  final String dispositivo;
  final String pin;
}

/// Ventana estricta de vigencia del PIN: máximo 24 horas.
const Duration vigenciaPin = Duration(hours: 24);

/// Analiza un PIN de recarga offline. Devuelve [PinRecargaResult.ok] con la
/// información decodificada, o un [PinRecargaResult.error] con el motivo.
///
/// Errores posibles:
///  - "El PIN tiene un formato no válido".
///  - "El PIN ha caducado".
PinRecargaResult analizarPin(String pinIngresado) {
  final limpio = pinIngresado
      .trim()
      .toUpperCase()
      .replaceAll(' ', '')
      .replaceAll('-', '');

  if (limpio.length != 9) {
    return const PinRecargaResult.error('El PIN tiene un formato no válido');
  }
  for (final c in limpio.split('')) {
    if (!AlfabetoSeguro.esPermitido(c)) {
      return const PinRecargaResult.error('El PIN tiene un formato no válido');
    }
  }

  // Letra de licencia en su posición exacta (Documento: 6).
  TipoLicencia tipo;
  int iMes, iDia1, iDia2, iHora;
  int iN1, iL1, iN2, iL2;
  if (limpio[2] == TipoLicencia.mensual.letra) {
    tipo = TipoLicencia.mensual;
    iMes = 0; iDia1 = 1; iN1 = 3; iHora = 4; iDia2 = 5; iL1 = 6; iN2 = 7; iL2 = 8;
  } else if (limpio[5] == TipoLicencia.semestral.letra) {
    tipo = TipoLicencia.semestral;
    iDia1 = 0; iMes = 1; iN1 = 2; iDia2 = 3; iHora = 4; iL1 = 6; iN2 = 7; iL2 = 8;
  } else if (limpio[7] == TipoLicencia.anual.letra) {
    tipo = TipoLicencia.anual;
    iN1 = 0; iMes = 1; iDia1 = 2; iDia2 = 3; iHora = 4; iL1 = 5; iN2 = 6; iL2 = 8;
  } else {
    return const PinRecargaResult.error('El PIN tiene un formato no válido');
  }

  final mes = mesesCodificacion[limpio[iMes]];
  if (mes == null) {
    return const PinRecargaResult.error('El PIN tiene un formato no válido');
  }

  final dia1 = _digitosDia[limpio[iDia1]];
  final dia2 = _digitosDia[limpio[iDia2]];
  if (dia1 == null || dia2 == null) {
    return const PinRecargaResult.error('El PIN tiene un formato no válido');
  }
  final dia = dia1 * 10 + dia2;
  if (dia < 1 || dia > 31) {
    return const PinRecargaResult.error('El PIN tiene un formato no válido');
  }

  final hora = letrasHora.indexOf(limpio[iHora]);
  if (hora == -1) {
    return const PinRecargaResult.error('El PIN tiene un formato no válido');
  }

  final dispositivo =
      '${limpio[iN1]}${limpio[iL1]}${limpio[iN2]}${limpio[iL2]}';

  // El algoritmo no codifica el año: se prueba el año actual y, para cubrir
  // el borde de Año Nuevo, el año anterior; basta con que uno esté vigente.
  final generacion = _generacionDentroDeVigencia(mes, dia, hora);
  if (generacion == null) {
    return const PinRecargaResult.error('El PIN ha caducado');
  }

  return PinRecargaResult.ok(
    PinRecargaInfo(
      tipo: tipo,
      generacion: generacion,
      dispositivo: dispositivo,
      pin: limpio,
    ),
  );
}

DateTime? _generacionDentroDeVigencia(int mes, int dia, int hora) {
  final ahora = DateTime.now();
  DateTime? candidata(int year) {
    final g = DateTime(year, mes, dia, hora);
    final edad = ahora.difference(g);
    if (!edad.isNegative && edad <= vigenciaPin) return g;
    return null;
  }

  return candidata(ahora.year) ?? candidata(ahora.year - 1);
}