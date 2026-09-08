part of '../app_database.dart';

/// Transacciones (Compras/Ventas de café) — Informe Global §5.5.7.
/// Índice §5.7: (estado_liquidacion, tipo_operacion).
@DataClassName('DBTransaccion')
@TableIndex(name: 'idx_transacciones_pendientes', columns: {#estadoLiquidacion, #tipoOperacion})
class Transacciones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigoTransaccion => text().unique()();
  IntColumn get cicloOperativoId => integer()();
  IntColumn get clienteId => integer().nullable()();
  IntColumn get loteBodegaId => integer().nullable()();
  TextColumn get tipoOperacion => text()
      .customConstraint(
          "NOT NULL CHECK (tipo_operacion IN ('COMPRA','VENTA'))")();
  TextColumn get tipoCafe => text()
      .customConstraint(
          "NOT NULL CHECK (tipo_cafe IN ('SECO','MOJADO','OREADO','PASILLA','SECADO'))")();
  RealColumn get pesoBruto =>
      real().customConstraint('NOT NULL CHECK (peso_bruto >= 0)')();
  RealColumn get descuentoEmpaque => real().withDefault(const Constant(0))();
  RealColumn get porcentajeHumedad => real().withDefault(const Constant(0))();
  RealColumn get gramera => real().withDefault(const Constant(0))();
  RealColumn get factorObtenido => real().withDefault(const Constant(0))();
  RealColumn get precioBase => real()();
  RealColumn get precioFinalKg => real().withDefault(const Constant(0))();
  RealColumn get pesoNetoFinal =>
      real().customConstraint('NOT NULL CHECK (peso_neto_final >= 0)')();
  RealColumn get totalPagarRecibir => real()();
  TextColumn get estadoLiquidacion => text()
      .customConstraint(
          "NOT NULL CHECK (estado_liquidacion IN ('PENDIENTE','LIQUIDADA'))")();
  IntColumn get anulado => integer().withDefault(const Constant(0))();
  IntColumn get fechaRegistro => integer()();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (ciclo_operativo_id) REFERENCES ciclos_operativos (id) ON DELETE RESTRICT',
        'FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE RESTRICT',
        'FOREIGN KEY (lote_bodega_id) REFERENCES lotes_bodega (id) ON DELETE RESTRICT',
      ];
}