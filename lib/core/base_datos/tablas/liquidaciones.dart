part of '../app_database.dart';

/// Liquidaciones — Informe Global §5.5.8.
/// Una liquidación por transacción (UNIQUE transaccion_id).
@DataClassName('DBLiquidacion')
class Liquidaciones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transaccionId => integer().unique()();
  IntColumn get cajaId => integer()();
  RealColumn get montoTotalTransaccion => real()();
  RealColumn get montoAnticiposPrevios => real().withDefault(const Constant(0))();
  RealColumn get descuentoCartera => real().withDefault(const Constant(0))();
  RealColumn get saldoNetoPagado => real()();
  TextColumn get estado => text()
      .clientDefault(() => 'VALIDADA')
      .customConstraint(
          "NOT NULL DEFAULT 'VALIDADA' CHECK (estado IN ('VALIDADA','ANULADA'))")();
  IntColumn get fechaAnulacion => integer().nullable()();
  TextColumn get motivoAnulacion => text().nullable()();
  IntColumn get fechaLiquidacion => integer()();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (transaccion_id) REFERENCES transacciones (id) ON DELETE RESTRICT',
        'FOREIGN KEY (caja_id) REFERENCES cajas (id) ON DELETE RESTRICT',
      ];
}