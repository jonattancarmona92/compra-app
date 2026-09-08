part of '../app_database.dart';

/// Clientes — Informe Global §5.5.5.
/// Índice §5.7: (activo, documento, nombre_completo).
@DataClassName('DBCliente')
@TableIndex(name: 'idx_clientes_busqueda', columns: {#activo, #documento, #nombreCompleto})
class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombreCompleto => text()();
  TextColumn get documento => text().unique()();
  TextColumn get telefono => text().nullable()();
  TextColumn get direccion => text().nullable()();
  IntColumn get creditoAutorizado => integer().withDefault(const Constant(0))();
  RealColumn get cupoMaximo => real().withDefault(const Constant(0))();
  IntColumn get activo => integer().withDefault(const Constant(1))();
}