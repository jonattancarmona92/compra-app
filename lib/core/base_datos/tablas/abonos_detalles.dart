part of '../app_database.dart';

/// Detalles de Abono — Informe Global §5.5.11.
/// Al eliminar el abono se eliminan sus detalles (CASCADE).
@DataClassName('DBAbonoDetalle')
class AbonosDetalles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get abonoId => integer()();
  TextColumn get destinoTipo => text()
      .customConstraint(
          "NOT NULL CHECK (destino_tipo IN ('ANTICIPO_COMPRA','PRESTAMO','CREDITO_POS','VENTA_PENDIENTE'))")();
  IntColumn get destinoId => integer()();
  RealColumn get montoApplied =>
      real().customConstraint('NOT NULL CHECK (monto_applied >= 0)')();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (abono_id) REFERENCES abonos (id) ON DELETE CASCADE',
      ];
}