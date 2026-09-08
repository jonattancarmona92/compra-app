part of '../app_database.dart';

/// Ciclos Operativos — Informe Global §5.5.1 / §5.6.4.
/// Un ciclo agrupa compras, ventas, prestamos, abonos y cortes de caja.
@DataClassName('DBCicloOperativo')
class CiclosOperativos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fechaApertura => integer()();
  IntColumn get fechaCierre => integer().nullable()();
  TextColumn get estado => text()
      .customConstraint("NOT NULL CHECK (estado IN ('ACTIVO','CERRADO'))")();
  TextColumn get observaciones => text().nullable()();
}