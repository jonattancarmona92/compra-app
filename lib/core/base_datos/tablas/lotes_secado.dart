part of '../app_database.dart';

/// Lotes en Secado — Informe Global §5.5.15.
@DataClassName('DBLoteSecado')
class LotesSecado extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().nullable()();
  TextColumn get tipoCafeInicial => text()
      .customConstraint(
          "NOT NULL CHECK (tipo_cafe_inicial IN ('MOJADO','OREADO','SECO','PASILLA'))")();
  RealColumn get pesoInicialHumedo =>
      real().customConstraint('NOT NULL CHECK (peso_inicial_humedo > 0)')();
  RealColumn get precioEstimadoInicial =>
      real().customConstraint('NOT NULL CHECK (precio_estimado_inicial >= 0)')();
  IntColumn get fechaInicio => integer()();
  IntColumn get fechaFinalizacion => integer().nullable()();
  RealColumn get pesoSecoObtenido => real().nullable()();
  RealColumn get mermaCalculada => real().nullable()();
  RealColumn get porcentajeRendimiento => real().nullable()();
  TextColumn get estado => text()
      .customConstraint("NOT NULL CHECK (estado IN ('SECANDO','FINALIZADO'))")();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE RESTRICT',
      ];
}