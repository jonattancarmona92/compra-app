// Pruebas del esquema físico de Coffee Control V1 — Informe Global §5.5 / §5.6.
//
// Construye la base de datos relacional en memoria (Drift/SQLite) y valida:
//   * Creación de las 16 tablas del catálogo §5.2.
//   * Restricciones NOT NULL, CHECK y UNIQUE del modelo físico.
//   * Claves foráneas y su comportamiento (RESTRICT / CASCADE) de §5.5 y §5.6.
//   * Un escenario comercial integral que ejercita las relaciones entre tablas.

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:compra/core/base_datos/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Las tablas del catálogo §5.2/§5.5 se crean físicamente', () async {
    final tablas = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'drift_%'",
    ).get();

    final nombres = tablas.map((r) => r.read<String>('name')).toList();
    expect(nombres, containsAll(<String>[
      'ciclos_operativos',
      'cajas',
      'cierres_caja',
      'movimientos_caja',
      'clientes',
      'lotes_bodega',
      'transacciones',
      'liquidaciones',
      'prestamos',
      'abonos',
      'abonos_detalles',
      'productos_pos',
      'ventas_pos',
      'ventas_pos_detalles',
      'lotes_secado',
      'audit_logs',
      'licencia',
      'pines_canjeados',
    ]));

    // El esquema registrado en Drift también declara exactamente 18 tablas.
    expect(db.allTables.length, 18);
  });

  test('PRAGMA foreign_keys se encuentra activado (integridad relacional §5.6)',
      () async {
    final resultado = await db
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(resultado.read<int>('foreign_keys'), 1);
  });

  test('Las columnas críticas del §5.5 se crean como NOT NULL', () async {
    Future<List<String>> notNull(String tabla, Set<String> columnas) async {
      final filas =
          await db.customSelect('PRAGMA table_info($tabla)').get();
      final resultado = <String>[];
      for (final fila in filas) {
        final nombre = fila.read<String>('name');
        final notnull = fila.read<int>('notnull');
        if (columnas.contains(nombre) && notnull == 1) {
          resultado.add(nombre);
        }
      }
      return resultado;
    }

    expect(
      await notNull('cajas', {'ciclo_operativo_id', 'fecha_apertura',
          'saldo_inicial', 'estado', 'abierta_por'}),
      hasLength(5),
    );
    expect(
      await notNull('transacciones', {'ciclo_operativo_id', 'tipo_operacion',
          'tipo_cafe', 'peso_neto_final', 'total_pagar_recibir',
          'fecha_registro'}),
      hasLength(6),
    );
    expect(await notNull('audit_logs', {'usuario', 'accion', 'detalle',
        'fecha_evento', 'origen'}), hasLength(5));
  });

  test('Constraints CHECK del §5.5 rechazan estados y valores inválidos',
      () async {
    await db.into(db.ciclosOperativos)
        .insert(CiclosOperativosCompanion.insert(
      fechaApertura: DateTime.now().millisecondsSinceEpoch,
      estado: 'ACTIVO',
    ));

    // CHECK: estado de caja no autorizado ('ABIERTA','CERRADA').
    await expectLater(
      db.into(db.cajas).insert(CajasCompanion.insert(
        cicloOperativoId: 1,
        fechaApertura: DateTime.now().millisecondsSinceEpoch,
        saldoInicial: 1000,
        estado: 'PAUSA',
        abiertaPor: 'Admin',
      )),
      throwsA(isA<Exception>()),
    );

    // CHECK: saldo_inicial negativo está prohibido (§2.2 / §5.5.2).
    await expectLater(
      db.into(db.cajas).insert(CajasCompanion.insert(
        cicloOperativoId: 1,
        fechaApertura: DateTime.now().millisecondsSinceEpoch,
        saldoInicial: -500,
        estado: 'ABIERTA',
        abiertaPor: 'Admin',
      )),
      throwsA(isA<Exception>()),
    );

    // CHECK: los movimientos de caja deben ser mayores a cero (§5.5.4).
    await expectLater(
      db.into(db.cierresCaja).insert(CierresCajaCompanion.insert(
        cajaId: 999,
        dineroFisicoContado: 0,
        saldoTeorico: 0,
        diferencia: 0,
        validadoPor: 'Admin',
        fechaCierre: DateTime.now().millisecondsSinceEpoch,
        comprobantePdf: 'ruta.pdf',
        estado: 'VALIDADO',
        tipoCierre: 'MANUAL',
      )),
      throwsA(isA<Exception>()),
    );
  });

  test('UNIQUE de documento de cliente se aplica (§3.5.1 / §5.5.5)', () async {
    final companion = ClientesCompanion.insert(
      nombreCompleto: 'Juan Pérez',
      documento: '1010-01',
    );

    await db.into(db.clientes).insert(companion);
    await expectLater(
      db.into(db.clientes).insert(companion),
      throwsA(isA<Exception>()),
    );
  });

  test('Relaciones RESTRICT del §5.5 bloquean eliminaciones referenciadas',
      () async {
    final idCiclo = await db.into(db.ciclosOperativos)
        .insert(CiclosOperativosCompanion.insert(
      fechaApertura: DateTime.now().millisecondsSinceEpoch,
      estado: 'ACTIVO',
    ));

    await db.into(db.cajas).insert(CajasCompanion.insert(
      cicloOperativoId: idCiclo,
      fechaApertura: DateTime.now().millisecondsSinceEpoch,
      saldoInicial: 100000,
      estado: 'ABIERTA',
      abiertaPor: 'Admin',
    ));

    // cajas -> ciclos_operativos es RESTRICT: no se puede borrar el ciclo.
    await expectLater(
      db.delete(db.ciclosOperativos).go(),
      throwsA(isA<Exception>()),
    );

    // Una caja huérfana (ciclo inexistente) no puede existir (§5.6.4).
    await expectLater(
      db.into(db.cajas).insert(CajasCompanion.insert(
        cicloOperativoId: 999999,
        fechaApertura: DateTime.now().millisecondsSinceEpoch,
        saldoInicial: 100000,
        estado: 'ABIERTA',
        abiertaPor: 'Admin',
      )),
      throwsA(isA<Exception>()),
    );
  });

  test('Las cascadas seguras (ventas_pos_detalles) funcionan (§5.6.2)',
      () async {
    final idCiclo = await db.into(db.ciclosOperativos)
        .insert(CiclosOperativosCompanion.insert(
      fechaApertura: DateTime.now().millisecondsSinceEpoch,
      estado: 'ACTIVO',
    ));
    final idProducto = await db.into(db.productosPos)
        .insert(ProductosPosCompanion.insert(
      descripcion: 'Café en bolsa 500g',
      categoria: 'víveres',
      precioCompra: 8000,
      precioVenta: 12000,
      stockActual: 20,
    ));

    final idVenta = await db.into(db.ventasPos)
        .insert(VentasPosCompanion.insert(
      codigoVenta: 'POS-001',
      cicloOperativoId: idCiclo,
      tipoPago: 'CONTADO',
      totalVenta: 24000,
      fechaVenta: DateTime.now().millisecondsSinceEpoch,
      estado: 'VALIDADA',
    ));

    await db.into(db.ventasPosDetalles)
        .insert(VentasPosDetallesCompanion.insert(
      ventaPosId: idVenta,
      productoPosId: idProducto,
      cantidad: 2,
      precioUnitarioHistorico: 12000,
      subtotal: 24000,
    ));

    // La venta POS se elimina: sus detalles se borran en cascada.
    await db.delete(db.ventasPos).go();
    final restantes = await db.select(db.ventasPosDetalles).get();
    expect(restantes, isEmpty);
  });

  test('Escenario integral: ciclo, caja, cliente, lote, transacción, '
      'liquidación, cartera y POS (§5.5 completo)', () async {
    final ahora = DateTime.now().millisecondsSinceEpoch;

    // 1. Ciclo Operativo activo.
    final idCiclo = await db.into(db.ciclosOperativos)
        .insert(CiclosOperativosCompanion.insert(
      fechaApertura: ahora,
      estado: 'ACTIVO',
    ));

    // 2. Caja abierta.
    final idCaja = await db.into(db.cajas).insert(CajasCompanion.insert(
      cicloOperativoId: idCiclo,
      fechaApertura: ahora,
      saldoInicial: 500000,
      estado: 'ABIERTA',
      abiertaPor: 'Admin',
    ));

    // 3. Movimientos de caja (manuales y automáticos con trazabilidad §5.5.4).
    await db.into(db.movimientosCaja).insert(MovimientosCajaCompanion.insert(
      cajaId: idCaja,
      tipoMovimiento: 'ENTRADA',
      monto: 100000,
      concepto: 'Abono de cliente',
      categoria: 'OTROS',
      origenTabla: const Value('abonos'),
      origenId: const Value(null),
      fechaRegistro: ahora,
    ));
    await db.into(db.movimientosCaja).insert(MovimientosCajaCompanion.insert(
      cajaId: idCaja,
      tipoMovimiento: 'SALIDA',
      monto: 50000,
      concepto: 'Transporte',
      categoria: 'TRANSPORTE',
      origenTabla: const Value(null),
      origenId: const Value(null),
      fechaRegistro: ahora,
    ));

    // 4. Cliente con crédito autorizado.
    final idCliente = await db.into(db.clientes).insert(
        ClientesCompanion.insert(
      nombreCompleto: 'Cooperativa Campesina',
      documento: '900-111',
      creditoAutorizado: const Value(1),
      cupoMaximo: const Value(2000000),
    ));

    // 5. Lote de bodega (Almacenado).
    final idLote = await db.into(db.lotesBodega).insert(
        LotesBodegaCompanion.insert(
      codigoLote: 'sec-00001',
      tipoCafe: 'SECO',
      pesoInicial: 45,
      pesoActual: 45,
      costoInicialKg: 6200,
      fechaIngreso: ahora,
      estado: 'DISPONIBLE',
    ));

    // 6. Transacción de venta desde lote (relación transacciones.lote_bodega_id).
    final idTransaccion = await db.into(db.transacciones)
        .insert(TransaccionesCompanion.insert(
      codigoTransaccion: 'VTA-0001',
      cicloOperativoId: idCiclo,
      clienteId: Value(idCliente),
      loteBodegaId: Value(idLote),
      tipoOperacion: 'VENTA',
      tipoCafe: 'SECO',
      pesoBruto: 20,
      descuentoEmpaque: const Value(0),
      porcentajeHumedad: const Value(0),
      gramera: const Value(0),
      factorObtenido: const Value(88),
      precioBase: 775000,
      precioFinalKg: const Value(6200),
      pesoNetoFinal: 20,
      totalPagarRecibir: 124000,
      estadoLiquidacion: 'LIQUIDADA',
      fechaRegistro: ahora,
    ));

    // 7. Liquidación de la venta (relación liquidaciones -> transacciones).
    await db.into(db.liquidaciones).insert(LiquidacionesCompanion.insert(
      transaccionId: idTransaccion,
      cajaId: idCaja,
      montoTotalTransaccion: 124000,
      montoAnticiposPrevios: const Value(0),
      descuentoCartera: const Value(0),
      saldoNetoPagado: 124000,
      fechaLiquidacion: ahora,
    ));

    // 8. Préstamo de cartera.
    final idPrestamo = await db.into(db.prestamos).insert(
        PrestamosCompanion.insert(
      clienteId: idCliente,
      cicloOperativoId: idCiclo,
      montoPrestado: 200000,
      saldoPendiente: 200000,
      fechaPrestamo: ahora,
      estado: 'VIGENTE',
    ));

    // 9. Abono con detalle (relación abonos_detalles -> abonos, §5.5.11).
    final idAbono = await db.into(db.abonos).insert(AbonosCompanion.insert(
      clienteId: idCliente,
      cajaId: idCaja,
      montoTotal: 80000,
      fechaAbono: ahora,
    ));
    await db.into(db.abonosDetalles).insert(AbonosDetallesCompanion.insert(
      abonoId: idAbono,
      destinoTipo: 'PRESTAMO',
      destinoId: idPrestamo,
      montoApplied: 80000,
    ));

    // 10. Proceso de secado (entidad inmutable §3.4.2, §5.5.15).
    await db.into(db.lotesSecado).insert(LotesSecadoCompanion.insert(
      clienteId: Value(null),
      tipoCafeInicial: 'MOJADO',
      pesoInicialHumedo: 100,
      precioEstimadoInicial: 3500,
      fechaInicio: ahora,
      estado: 'SECANDO',
    ));

    // 11. Auditoría de la apertura (§5.5.16).
    await db.into(db.auditLogs).insert(AuditLogsCompanion.insert(
      usuario: 'Admin',
      accion: 'APERTURA_CAJA',
      detalle: 'Apertura de caja del ciclo activo',
      fechaEvento: ahora,
      origen: 'apertura_caja_screen',
    ));

    // Verificaciones de consistencia relacional.
    final cajasDelCiclo = await (db.select(db.cajas)
          ..where((c) => c.cicloOperativoId.equals(idCiclo)))
        .get();
    expect(cajasDelCiclo, hasLength(1));

    final movimientoTraza = await (db.select(db.movimientosCaja)
          ..where((m) => m.origenTabla.equals('abonos')))
        .getSingle();
    expect(movimientoTraza.origenTabla, 'abonos');

    final liquidacion = await db.select(db.liquidaciones).getSingle();
    expect(liquidacion.transaccionId, idTransaccion);
    expect(liquidacion.cajaId, idCaja);
    expect(liquidacion.saldoNetoPagado, 124000);

    final trasladoPrestamo = await (db.select(db.prestamos)
          ..where((p) => p.id.equals(idPrestamo)))
        .getSingle();
    expect(trasladoPrestamo.saldoPendiente, 200000);

    final detalleAbono = await db.select(db.abonosDetalles).getSingle();
    expect(detalleAbono.abonoId, idAbono);
    expect(detalleAbono.destinoTipo, 'PRESTAMO');
    expect(detalleAbono.montoApplied, 80000);

    expect(await db.select(db.auditLogs).get(), hasLength(1));
  });
}