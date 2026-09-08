part of '../app_database.dart';

/// Abonos — Informe Global §5.5.10. Cabecera de un abono con sus detalles.
@DataClassName('DBAbono')
class Abonos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer()();
  IntColumn get cajaId => integer()();
  RealColumn get montoTotal =>
      real().customConstraint('NOT NULL CHECK (monto_total > 0)')();
  IntColumn get anulado => integer().withDefault(const Constant(0))();
  IntColumn get fechaAnulacion => integer().nullable()();
  TextColumn get motivoAnulacion => text().nullable()();
  IntColumn get fechaAbono => integer()();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE RESTRICT',
        'FOREIGN KEY (caja_id) REFERENCES cajas (id) ON DELETE RESTRICT',
      ];
}