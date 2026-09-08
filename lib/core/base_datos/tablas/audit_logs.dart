part of '../app_database.dart';

/// Auditoría de eventos — Informe Global §5.5.16.
/// Índice §5.7: (fecha_evento). Registro inmutable de acciones del usuario.
@DataClassName('DBAuditLog')
@TableIndex(name: 'idx_audit_logs_fecha', columns: {#fechaEvento})
class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get usuario => text()();
  TextColumn get accion => text()();
  TextColumn get detalle => text()();
  IntColumn get fechaEvento => integer()();
  TextColumn get origen => text()();
}