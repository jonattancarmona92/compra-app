part of '../app_database.dart';

/// Ventas del Punto de Venta — Informe Global §5.5.13.
@DataClassName('DBVentaPos')
class VentasPos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigoVenta => text().unique()();
  IntColumn get cicloOperativoId => integer()();
  IntColumn get clienteId => integer().nullable()();
  TextColumn get tipoPago => text()
      .customConstraint("NOT NULL CHECK (tipo_pago IN ('CONTADO','CREDITO'))")();
  RealColumn get totalVenta => real()();
  IntColumn get fechaVenta => integer()();
  TextColumn get estado => text()
      .customConstraint("NOT NULL CHECK (estado IN ('VALIDADA','ANULADA'))")();
  IntColumn get fechaAnulacion => integer().nullable()();
  TextColumn get motivoAnulacion => text().nullable()();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (ciclo_operativo_id) REFERENCES ciclos_operativos (id) ON DELETE RESTRICT',
        'FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE RESTRICT',
      ];
}