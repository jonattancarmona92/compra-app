part of '../app_database.dart';

/// Productos del Punto de Venta — Informe Global §5.5.12.
@DataClassName('DBProductoPos')
class ProductosPos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigoBarras => text().nullable().unique()();
  TextColumn get descripcion => text()();
  TextColumn get categoria => text()();
  RealColumn get precioCompra =>
      real().customConstraint('NOT NULL CHECK (precio_compra >= 0)')();
  RealColumn get precioVenta =>
      real().customConstraint('NOT NULL CHECK (precio_venta >= 0)')();
  RealColumn get existenciaInicial => real().withDefault(const Constant(0))();
  RealColumn get stockActual =>
      real().customConstraint('NOT NULL CHECK (stock_actual >= 0)')();
  RealColumn get stockMinimoAlerta => real().withDefault(const Constant(0))();
  IntColumn get activo => integer().withDefault(const Constant(1))();
}