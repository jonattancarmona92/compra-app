// ==================== ARCHIVO: lib/core/seguridad/clave_maestra_cc01.dart ====================
// Algoritmo CC-MK-01 — Informe Global §1.4
// Componente clasificado como INMUTABLE por §6.9. No modificar la
// estructura de 12 posiciones, la tabla de conversión ni la ventana
// de validez sin autorización explícita del Informe Global.
import 'dart:math';

/// Tabla de conversión bidireccional Dígito ↔ Código — §1.4.
const Map<String, String> _tablaConversion = {
  '0': 'M',
  '1': 'R',
  '2': 'K',
  '3': 'T',
  '4': 'P',
  '5': 'V',
  '6': 'L',
  '7': 'X',
  '8': 'N',
  '9': 'Q',
};

Map<String, String> get _tablaInversa =>
    _tablaConversion.map((digito, codigo) => MapEntry(codigo, digito));

/// Conjunto autorizado de caracteres aleatorios para P2 y P6 — §1.4.
const List<String> _caracteresAleatoriosPermitidos = ['J', 'V', 'Y'];

/// Ventana máxima de vigencia de la Clave Maestra respecto a la
/// Hora Legal — §1.4: "vigencia máxima de 60 minutos".
const int ventanaValidezMinutosCC01 = 60;

/// Resultado de validar una Clave Maestra ingresada por el usuario.
class ClaveMaestraValidacion {
  final bool esValida;
  final String? motivoError;
  final DateTime? fechaHoraCodificada;

  const ClaveMaestraValidacion._({
    required this.esValida,
    this.motivoError,
    this.fechaHoraCodificada,
  });

  const ClaveMaestraValidacion.invalida(String motivo)
    : this._(esValida: false, motivoError: motivo);

  ClaveMaestraValidacion.valida(DateTime fecha)
    : this._(esValida: true, fechaHoraCodificada: fecha);
}

/// Implementación del algoritmo CC-MK-01 definido en el §1.4 del
/// Informe Global: generación y validación de la Clave Maestra de
/// 12 posiciones basada en la Hora Legal de Colombia.
class ClaveMaestraCC01 {
  const ClaveMaestraCC01._();

  /// Genera una Clave Maestra de 12 caracteres válida para el instante
  /// [horaLegal] recibido (debe provenir de [HoraLegalService], nunca
  /// de DateTime.now() del dispositivo — ver §1.4/§10.3).
  static String generar(DateTime horaLegal, {Random? random}) {
    final rnd = random ?? Random.secure();

    final dia = horaLegal.day.toString().padLeft(2, '0');
    final mes = horaLegal.month.toString().padLeft(2, '0');
    final anio = (horaLegal.year % 100).toString().padLeft(2, '0');
    final hora = horaLegal.hour.toString().padLeft(2, '0');
    final minuto = horaLegal.minute.toString().padLeft(2, '0');

    final dia1 = dia[0];
    final dia2 = dia[1];
    final mes1 = mes[0];
    final mes2 = mes[1];
    final anio1 = anio[0];
    final anio2 = anio[1];
    final hora1 = _tablaConversion[hora[0]]!;
    final hora2 = _tablaConversion[hora[1]]!;
    final minuto1 = _tablaConversion[minuto[0]]!;
    final minuto2 = _tablaConversion[minuto[1]]!;

    // P2 y P6: dos letras DISTINTAS del conjunto {J, V, Y} — §1.4.
    final opciones = List<String>.from(_caracteresAleatoriosPermitidos)
      ..shuffle(rnd);
    final aleatorio1 = opciones[0];
    final aleatorio2 = opciones[1];

    // Estructura de 12 posiciones — tabla exacta del §1.4.
    final posiciones = List<String>.filled(12, '');
    posiciones[0] = dia1; // Posición 1: Día 1
    posiciones[1] = aleatorio1; // Posición 2: Aleatorio 1
    posiciones[2] = anio2; // Posición 3: Año 2
    posiciones[3] = hora1; // Posición 4: Hora 1
    posiciones[4] = dia2; // Posición 5: Día 2
    posiciones[5] = aleatorio2; // Posición 6: Aleatorio 2
    posiciones[6] = hora2; // Posición 7: Hora 2
    posiciones[7] = mes1; // Posición 8: Mes 1
    posiciones[8] = minuto1; // Posición 9: Minuto 1
    posiciones[9] = mes2; // Posición 10: Mes 2
    posiciones[10] = anio1; // Posición 11: Año 1
    posiciones[11] = minuto2; // Posición 12: Minuto 2

    return posiciones.join();
  }

  /// Valida una Clave Maestra ingresada contra la Hora Legal actual.
  /// Aplica: estructura de 12 posiciones, conjunto {J,V,Y} sin
  /// repetición, coincidencia estricta de fecha, y ventana de 60 min.
  static ClaveMaestraValidacion validar(
    String claveIngresada,
    DateTime horaLegalActual,
  ) {
    final clave = claveIngresada.trim().toUpperCase();

    if (clave.length != 12) {
      return const ClaveMaestraValidacion.invalida(
        'La Clave Maestra debe tener exactamente 12 caracteres.',
      );
    }

    final dia1 = clave[0];
    final aleatorio1 = clave[1];
    final anio2 = clave[2];
    final hora1Cod = clave[3];
    final dia2 = clave[4];
    final aleatorio2 = clave[5];
    final hora2Cod = clave[6];
    final mes1 = clave[7];
    final minuto1Cod = clave[8];
    final mes2 = clave[9];
    final anio1 = clave[10];
    final minuto2Cod = clave[11];

    final digitosCrudos = [dia1, dia2, mes1, mes2, anio1, anio2];
    if (!digitosCrudos.every((c) => RegExp(r'^[0-9]$').hasMatch(c))) {
      return const ClaveMaestraValidacion.invalida(
        'Estructura numérica inválida en la fecha codificada.',
      );
    }

    if (!_caracteresAleatoriosPermitidos.contains(aleatorio1) ||
        !_caracteresAleatoriosPermitidos.contains(aleatorio2)) {
      return const ClaveMaestraValidacion.invalida(
        'Caracteres aleatorios fuera del conjunto permitido {J, V, Y}.',
      );
    }

    if (aleatorio1 == aleatorio2) {
      return const ClaveMaestraValidacion.invalida(
        'Los caracteres aleatorios no pueden repetirse.',
      );
    }

    final tablaInversa = _tablaInversa;
    final codigosHoraMinuto = [hora1Cod, hora2Cod, minuto1Cod, minuto2Cod];
    if (!codigosHoraMinuto.every(tablaInversa.containsKey)) {
      return const ClaveMaestraValidacion.invalida(
        'Códigos de hora/minuto inválidos.',
      );
    }

    final horaStr = tablaInversa[hora1Cod]! + tablaInversa[hora2Cod]!;
    final minutoStr = tablaInversa[minuto1Cod]! + tablaInversa[minuto2Cod]!;

    final dia = int.parse(dia1 + dia2);
    final mes = int.parse(mes1 + mes2);
    final anioCorto = int.parse(anio1 + anio2);
    final hora = int.parse(horaStr);
    final minuto = int.parse(minutoStr);

    if (dia < 1 ||
        dia > 31 ||
        mes < 1 ||
        mes > 12 ||
        hora > 23 ||
        minuto > 59) {
      return const ClaveMaestraValidacion.invalida(
        'Fecha u hora codificada fuera de rango.',
      );
    }

    late final DateTime fechaCodificada;
    try {
      fechaCodificada = DateTime(2000 + anioCorto, mes, dia, hora, minuto);
    } catch (_) {
      return const ClaveMaestraValidacion.invalida(
        'La fecha codificada no corresponde a una fecha real.',
      );
    }

    // Coincidencia ESTRICTA de fecha — §1.4.
    final coincideFecha =
        fechaCodificada.year == horaLegalActual.year &&
        fechaCodificada.month == horaLegalActual.month &&
        fechaCodificada.day == horaLegalActual.day;

    if (!coincideFecha) {
      return const ClaveMaestraValidacion.invalida(
        'La fecha codificada no coincide con la Hora Legal actual.',
      );
    }

    // Ventana de 60 minutos — §1.4.
    final diferenciaMinutos = horaLegalActual
        .difference(fechaCodificada)
        .inMinutes
        .abs();

    if (diferenciaMinutos > ventanaValidezMinutosCC01) {
      return const ClaveMaestraValidacion.invalida(
        'La Clave Maestra expiró: supera la ventana de 60 minutos.',
      );
    }

    return ClaveMaestraValidacion.valida(fechaCodificada);
  }
}
