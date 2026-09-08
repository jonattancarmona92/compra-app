// Base de datos local de Coffee Control — Informe Global Módulo 5.
//
// Persistencia relacional offline basada en SQLite vía DRIFT (§5.1, §6.8.1).
// Un único archivo: coffee_control.sqlite en ApplicationDocumentsDirectory.
//
// Regla de arquitectura (§6.3.1/§6.3.2): ninguna pantalla ni provider
// consulta SQL directo; todo el acceso pasa por repositorios que usan
// esta clase. Los cálculos de negocio viven en lib/core/utilitarios
// (calculos_operaciones.dart, §7.8).
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';
part 'tablas/ciclos_operativos.dart';
part 'tablas/cajas.dart';
part 'tablas/cierres_caja.dart';
part 'tablas/movimientos_caja.dart';
part 'tablas/clientes.dart';
part 'tablas/lotes_bodega.dart';
part 'tablas/transacciones.dart';
part 'tablas/liquidaciones.dart';
part 'tablas/prestamos.dart';
part 'tablas/abonos.dart';
part 'tablas/abonos_detalles.dart';
part 'tablas/productos_pos.dart';
part 'tablas/ventas_pos.dart';
part 'tablas/ventas_pos_detalles.dart';
part 'tablas/lotes_secado.dart';
part 'tablas/audit_logs.dart';
part 'tablas/licencia.dart';
part 'tablas/pines_canjeados.dart';

/// Esquema físico completo. Las 16 tablas del §5.5 en su orden lógico.
@DriftDatabase(
  tables: [
    CiclosOperativos,
    Cajas,
    CierresCaja,
    MovimientosCaja,
    Clientes,
    LotesBodega,
    Transacciones,
    Liquidaciones,
    Prestamos,
    Abonos,
    AbonosDetalles,
    ProductosPos,
    VentasPos,
    VentasPosDetalles,
    LotesSecado,
    AuditLogs,
    Licencia,
    PinesCanjeados,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _crearConexion());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Documento "Pin de recarga": licencia + pines canjeados.
            await m.createTable(licencia);
            await m.createTable(pinesCanjeados);
          }
        },
        beforeOpen: (details) async {
          // Optimizaciones del motor SQLite recomendadas por §5.3.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Proveedor global (Riverpod) de la base de datos. Se cierra al desechar.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

LazyDatabase _crearConexion() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(dir.path, 'coffee_control.sqlite'));
    return NativeDatabase.createInBackground(archivo);
  });
}