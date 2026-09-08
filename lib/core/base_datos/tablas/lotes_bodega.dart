part of '../app_database.dart';

/// Lotes en Bodega — Informe Global §5.5.6.
/// Índice §5.7: (estado, tipo_cafe).
@DataClassName('DBLoteBodega')
@TableIndex(name: 'idx_lotes_bodega_inventario', columns: {#estado, #tipoCafe})
class LotesBodega extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigoLote => text().unique()();
  TextColumn get tipoCafe => text()
      .customConstraint(
          "NOT NULL CHECK (tipo_cafe IN ('MOJADO','OREADO','SECADO','SECO','PASILLA'))")();
  RealColumn get pesoInicial =>
      real().customConstraint('NOT NULL CHECK (peso_inicial > 0)')();
  RealColumn get pesoActual =>
      real().customConstraint('NOT NULL CHECK (peso_actual >= 0)')();
  RealColumn get costoInicialKg =>
      real().customConstraint('NOT NULL CHECK (costo_inicial_kg >= 0)')();
  IntColumn get fechaIngreso => integer()();
  TextColumn get estado => text()
      .customConstraint("NOT NULL CHECK (estado IN ('DISPONIBLE','AGOTADO'))")();
}