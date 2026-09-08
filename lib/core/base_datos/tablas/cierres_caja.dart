part of '../app_database.dart';

/// Cierres de Caja — Informe Global §5.5.3.
/// Un cierre por caja (UNIQUE caja_id). Comprobante PDF firmado.
@DataClassName('DBCierreCaja')
class CierresCaja extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cajaId => integer().unique()();
  RealColumn get dineroFisicoContado => real()
      .customConstraint('NOT NULL CHECK (dinero_fisico_contado >= 0)')();
  RealColumn get saldoTeorico => real()();
  RealColumn get diferencia => real()();
  TextColumn get validadoPor => text()();
  IntColumn get fechaCierre => integer()();
  TextColumn get comprobantePdf => text()();
  TextColumn get estado => text()
      .customConstraint("NOT NULL CHECK (estado IN ('VALIDADO','ANULADO'))")();
  TextColumn get observaciones => text().nullable()();
  TextColumn get tipoCierre => text()
      .customConstraint(
          "NOT NULL CHECK (tipo_cierre IN ('MANUAL','AUTOMATICO_SISTEMA'))")();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (caja_id) REFERENCES cajas (id) ON DELETE RESTRICT',
      ];
}