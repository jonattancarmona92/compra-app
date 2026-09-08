part of '../app_database.dart';

/// Cajas — Informe Global §5.5.2.
/// Cada caja pertenece a un ciclo operativo y se abre/cierra una sola vez.
@DataClassName('DBCaja')
class Cajas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cicloOperativoId => integer()();
  IntColumn get fechaApertura => integer()();
  IntColumn get fechaCierre => integer().nullable()();
  RealColumn get saldoInicial =>
      real().customConstraint('NOT NULL CHECK (saldo_inicial >= 0)')();
  RealColumn get saldoFinalTeorico => real().nullable()();
  TextColumn get estado => text()
      .customConstraint("NOT NULL CHECK (estado IN ('ABIERTA','CERRADA'))")();
  TextColumn get abiertaPor => text()();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (ciclo_operativo_id) REFERENCES ciclos_operativos (id) ON DELETE RESTRICT',
      ];
}