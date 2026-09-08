part of '../app_database.dart';

/// Detalles de Venta POS — Informe Global §5.5.14.
/// Al eliminar la venta se eliminan sus detalles (CASCADE).
@DataClassName('DBVentaPosDetalle')
class VentasPosDetalles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ventaPosId => integer()();
  IntColumn get productoPosId => integer()();
  RealColumn get cantidad =>
      real().customConstraint('NOT NULL CHECK (cantidad > 0)')();
  RealColumn get precioUnitarioHistorico => real()();
  RealColumn get subtotal => real()();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (venta_pos_id) REFERENCES ventas_pos (id) ON DELETE CASCADE',
        'FOREIGN KEY (producto_pos_id) REFERENCES productos_pos (id) ON DELETE RESTRICT',
      ];
}