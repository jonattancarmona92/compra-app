// ==================== TEST: ALGORITMO DE PIN DE RECARGA ====================
// Documento "Pin de recarga": formato XXXXX-XXXX, posiciones M/S/A,
// vigencia estricta de 24 h, alfabeto seguro y ID de dispositivo.
import 'package:flutter_test/flutter_test.dart';

import 'package:compra/core/seguridad/licencia_pin.dart';

String _carMes(int mes) =>
    mesesCodificacion.entries.firstWhere((e) => e.value == mes).key;

String _digitoDia(int d) {
  if (d <= 1) return String.fromCharCode('A'.codeUnitAt(0) + d);
  return '$d';
}

String _letraHora(int hora) => letrasHora[hora];

/// Reconstruye un PIN real con la misma tabla pública, para un [DateTime].
String _pintar(
  DateTime cuando,
  TipoLicencia tipo, {
  required String dispositivo,
  String separador = '-',
}) {
  final mes = _carMes(cuando.month);
  final hora = _letraHora(cuando.hour);
  final d1 = _digitoDia(cuando.day ~/ 10);
  final d2 = _digitoDia(cuando.day % 10);
  final n1 = dispositivo[0];
  final l1 = dispositivo[1];
  final n2 = dispositivo[2];
  final l2 = dispositivo[3];

  final List<String> pos = List.filled(9, '');
  switch (tipo) {
    case TipoLicencia.mensual:
      pos[0] = mes; pos[1] = d1; pos[2] = 'M';
      pos[3] = n1; pos[4] = hora; pos[5] = d2; pos[6] = l1; pos[7] = n2; pos[8] = l2;
    case TipoLicencia.semestral:
      pos[0] = d1; pos[1] = mes; pos[2] = n1;
      pos[3] = d2; pos[4] = hora; pos[5] = 'S'; pos[6] = l1; pos[7] = n2; pos[8] = l2;
    case TipoLicencia.anual:
      pos[0] = n1; pos[1] = mes; pos[2] = d1;
      pos[3] = d2; pos[4] = hora; pos[5] = l1; pos[6] = n2; pos[7] = 'A'; pos[8] = l2;
    case TipoLicencia.inicial:
      fail('inicial no es recargable por PIN');
  }
  final crudo = pos.join();
  return '${crudo.substring(0, 5)}$separador${crudo.substring(5)}';
}

void main() {
  group('DispositivoId', () {
    test('genera siempre N-L-N-L con alfabeto seguro', () {
      for (var i = 0; i < 100; i++) {
        final id = DispositivoId.generar();
        expect(id.length, 4);
        expect(DispositivoId.esValido(id), isTrue);
      }
    });

    test('esValido rechaza formatos inválidos y caracteres prohibidos', () {
      expect(DispositivoId.esValido('1A2B'), isFalse); // '1' no permitido
      expect(DispositivoId.esValido('A2B3'), isFalse); // empieza con letra
      expect(DispositivoId.esValido('2AB3'), isFalse); // N-L-N-L roto
      expect(DispositivoId.esValido('2IO3'), isFalse); // I/O no permitidos
      expect(DispositivoId.esValido('2A3'), isFalse); // longitud corta
    });
  });

  group('analizarPin', () {
    const dispositivo = '7KE5';

    test('decodifica un PIN mensual vigente', () {
      final pin = _pintar(DateTime.now(), TipoLicencia.mensual,
          dispositivo: dispositivo);
      final r = analizarPin(pin);
      expect(r.ok, isTrue);
      expect(r.info!.tipo, TipoLicencia.mensual);
      expect(r.info!.dispositivo, dispositivo);
    });

    test('decodifica un PIN semestral vigente', () {
      final pin = _pintar(DateTime.now(), TipoLicencia.semestral,
          dispositivo: dispositivo);
      final r = analizarPin(pin);
      expect(r.ok, isTrue);
      expect(r.info!.tipo, TipoLicencia.semestral);
      expect(r.info!.dispositivo, dispositivo);
    });

    test('decodifica un PIN anual vigente', () {
      final pin = _pintar(DateTime.now(), TipoLicencia.anual,
          dispositivo: dispositivo);
      final r = analizarPin(pin);
      expect(r.ok, isTrue);
      expect(r.info!.tipo, TipoLicencia.anual);
      expect(r.info!.dispositivo, dispositivo);
    });

    test('acepta mayúsculas y minúsculas, guiones o espacios', () {
      final pin = _pintar(DateTime.now(), TipoLicencia.mensual,
          dispositivo: dispositivo);
      final r = analizarPin(pin.toLowerCase().replaceAll('-', ' '));
      expect(r.ok, isTrue);
      expect(r.info!.tipo, TipoLicencia.mensual);
    });

    test('rechaza formato incorrecto (longitud)', () {
      final pin = _pintar(DateTime.now(), TipoLicencia.mensual,
          dispositivo: dispositivo);
      expect(analizarPin(pin.substring(0, 8)).ok, isFalse);
      expect(analizarPin('$pin${pin[0]}').ok, isFalse);
    });

    test('rechaza caracteres prohibidos (0, 1, I, O)', () {
      final pin = _pintar(DateTime.now(), TipoLicencia.mensual,
          dispositivo: dispositivo);
      expect(analizarPin(pin.replaceFirst(pin[0], '0')).ok, isFalse);
      expect(analizarPin(pin.replaceFirst(pin[0], '1')).ok, isFalse);
      expect(analizarPin(pin.replaceFirst(pin[0], 'I')).ok, isFalse);
      expect(analizarPin(pin.replaceFirst(pin[0], 'O')).ok, isFalse);
    });

    test('rechaza PIN sin letra de licencia en su posición', () {
      final pin = _pintar(DateTime.now(), TipoLicencia.mensual,
          dispositivo: dispositivo);
      final sinM = pin.replaceRange(2, 3, '9'); // la posición 2 deja de ser M
      expect(analizarPin(sinM).ok, isFalse);
    });

    test('rechaza día inválido (fuera de rango 1..31)', () {
      final fecha = DateTime.now();
      // Día "32": se fuerza con dígitos permitidos A/B/2..9.
      final pin32 = _pintar(fecha, TipoLicencia.semestral,
              dispositivo: dispositivo)
          .replaceRange(0, 1, '3')
          .replaceRange(3, 4, '2');
      final r = analizarPin(pin32);
      expect(r.ok, isFalse); // 32 > 31 → formato no válido
      expect(r.error, 'El PIN tiene un formato no válido');
    });

    test('rechaza PIN caducado (más de 24 horas)', () {
      final ayer = DateTime.now().subtract(const Duration(hours: 25));
      final pin = _pintar(ayer, TipoLicencia.mensual,
          dispositivo: dispositivo);
      final r = analizarPin(pin);
      expect(r.ok, isFalse);
      expect(r.error, 'El PIN ha caducado');
    });
  });
}