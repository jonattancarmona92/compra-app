part of '../app_database.dart';

/// Pines de recarga ya canjeados — Documento "Pin de recarga".
/// Uso único: cualquier PIN presente en esta tabla es rechazado.
@DataClassName('DBPinCanjeado')
class PinesCanjeados extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pin => text().unique()();
  TextColumn get tipo => text()();
  IntColumn get dias => integer()();
  IntColumn get fechaCanje => integer()();
}