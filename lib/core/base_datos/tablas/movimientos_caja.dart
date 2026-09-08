part of '../app_database.dart';

/// Movimientos de Caja — Informe Global §5.5.4.
/// Índice §5.7: (caja_id, anulado).
@DataClassName('DBMovimientoCaja')
@TableIndex(name: 'idx_movimientos_caja_historial', columns: {#cajaId, #anulado})
class MovimientosCaja extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cajaId => integer()();
  TextColumn get tipoMovimiento => text()
      .customConstraint(
          "NOT NULL CHECK (tipo_movimiento IN ('ENTRADA','SALIDA'))")();
  RealColumn get monto =>
      real().customConstraint('NOT NULL CHECK (monto > 0)')();
  TextColumn get concepto => text()();
  TextColumn get categoria => text()();
  TextColumn get origenTabla => text().nullable()();
  IntColumn get origenId => integer().nullable()();
  IntColumn get fechaRegistro => integer()();
  IntColumn get anulado => integer().withDefault(const Constant(0))();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (caja_id) REFERENCES cajas (id) ON DELETE RESTRICT',
      ];
}