part of '../app_database.dart';

/// Licencia vigente del dispositivo — Documento "Pin de recarga".
/// Fila única (id = 1) con el vencimiento, el plan actual y el ID de
/// dispositivo (hardware binding). El ID también se guarda cifrado en
/// flutter_secure_storage (fuente autoritativa).
@DataClassName('DBLicencia')
class Licencia extends Table {
  IntColumn get id => integer()();
  TextColumn get dispositivoId => text()();
  IntColumn get fechaVencimiento => integer()();
  TextColumn get planActual => text()();
}