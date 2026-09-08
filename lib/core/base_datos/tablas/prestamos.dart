part of '../app_database.dart';

/// Préstamos a clientes — Informe Global §5.5.9.
@DataClassName('DBPrestamo')
class Prestamos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer()();
  IntColumn get cicloOperativoId => integer()();
  RealColumn get montoPrestado =>
      real().customConstraint('NOT NULL CHECK (monto_prestado > 0)')();
  RealColumn get saldoPendiente =>
      real().customConstraint('NOT NULL CHECK (saldo_pendiente >= 0)')();
  IntColumn get fechaPrestamo => integer()();
  TextColumn get estado => text()
      .customConstraint("NOT NULL CHECK (estado IN ('VIGENTE','PAGADO','ANULADO'))")();
  IntColumn get fechaAnulacion => integer().nullable()();
  TextColumn get motivoAnulacion => text().nullable()();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE RESTRICT',
        'FOREIGN KEY (ciclo_operativo_id) REFERENCES ciclos_operativos (id) ON DELETE RESTRICT',
      ];
}