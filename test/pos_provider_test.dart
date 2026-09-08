// Pruebas del repositorio en memoria del módulo POS — Informe Global §3.6.
//
// Valida el catálogo (registro de productos con código y tipo de
// comercialización), la composición de Kits, el descuento de inventario
// al vender (incluido el consumo de productos base de un Kit) y el
// historial de ventas registradas.

import 'package:flutter_test/flutter_test.dart';

import 'package:compra/features/pos/pos_provider.dart';

void main() {
  group('Catálogo de productos (§3.6.2)', () {
    test('Registra un producto de venta por unidad con código', () {
      final notifier = PosNotifier();
      final id = notifier.registrarProducto(
        nombre: 'Gaseosa',
        codigo: 'GAS-001',
        precio: 3000,
        stock: 10,
      );

      final producto = notifier.buscarProductoPorId(id)!;
      expect(producto.nombre, 'Gaseosa');
      expect(producto.codigo, 'GAS-001');
      expect(producto.tipo, TipoProductoPos.unidad);
      expect(producto.componentes, isEmpty);
      expect(producto.stock, 10);
    });

    test('Rechaza un producto duplicado por nombre', () {
      final notifier = PosNotifier();
      notifier.registrarProducto(nombre: 'Café', precio: 2000);
      expect(
        () => notifier.registrarProducto(nombre: 'café', precio: 2000),
        throwsA(isA<ProductoDuplicadoException>()),
      );
    });

    test('Rechaza un código ya registrado', () {
      final notifier = PosNotifier();
      notifier.registrarProducto(nombre: 'Cerveza', codigo: 'CZV-1', precio: 4000);
      expect(
        () => notifier.registrarProducto(
          nombre: 'Mixta',
          codigo: 'czv-1',
          precio: 4500,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Registra un producto gramero y un kit compuesto por dos bases', () {
      final notifier = PosNotifier();
      notifier.registrarProducto(
        nombre: 'Café molido',
        tipo: TipoProductoPos.gramera,
        precio: 30, // precio por gramo
        stock: 2000,
      );
      notifier.registrarProducto(
        nombre: 'Vaso 12 oz',
        precio: 500,
        stock: 100,
      );
      notifier.registrarProducto(
        nombre: 'Tapa domo',
        precio: 200,
        stock: 100,
      );

      final kitId = notifier.registrarProducto(
        nombre: 'Café para llevar',
        tipo: TipoProductoPos.kit,
        componentes: const [
          KitComponente(productoId: 1, cantidad: 14),
          KitComponente(productoId: 2, cantidad: 1),
          KitComponente(productoId: 3, cantidad: 1),
        ],
        precio: 2500,
        stock: 10,
      );

      final kit = notifier.buscarProductoPorId(kitId)!;
      expect(kit.esKit, isTrue);
      expect(kit.tipo, TipoProductoPos.kit);
      expect(kit.componentes.length, 3);
    });

    test('Rechaza un kit con menos de dos productos base', () {
      final notifier = PosNotifier();
      notifier.registrarProducto(nombre: 'Cerveza', precio: 2000, stock: 20);
      final base = notifier.buscarProductoPorId(1)!;
      expect(base.nombre, 'Cerveza');

      expect(
        () => notifier.registrarProducto(
          nombre: 'Half pack',
          tipo: TipoProductoPos.kit,
          componentes: const [KitComponente(productoId: 1, cantidad: 6)],
          precio: 12000,
          stock: 5,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Edición y baja de productos (§3.6.2 / §5.5.13)', () {
    test('Edita nombre, precio y stock de un producto existente', () {
      final notifier = PosNotifier();
      final id = notifier.registrarProducto(
        nombre: 'Gaseosa',
        codigo: 'GAS-001',
        precio: 3000,
        stock: 10,
      );

      notifier.editarProducto(
        id: id,
        nombre: 'Gaseosa 400 ml',
        codigo: 'GAS-001',
        precio: 3500,
        stock: 25,
      );

      final editado = notifier.buscarProductoPorId(id)!;
      expect(editado.nombre, 'Gaseosa 400 ml');
      expect(editado.precio, 3500);
      expect(editado.stock, 25);
      expect(editado.id, id);
      expect(notifier.state.productos.length, 1);
    });

    test('Editar valida duplicados excluyéndose a sí mismo', () {
      final notifier = PosNotifier();
      notifier.registrarProducto(nombre: 'Café', precio: 2000);
      final segundoId = notifier.registrarProducto(nombre: 'Pan', precio: 1500);

      // Conservar el propio nombre es válido.
      notifier.editarProducto(
        id: segundoId,
        nombre: 'Pan',
        precio: 1500,
      );

      // Tomar un nombre ya usado por otro producto es bloqueante.
      expect(
        () => notifier.editarProducto(id: segundoId, nombre: 'café', precio: 1500),
        throwsA(isA<ProductoDuplicadoException>()),
      );
    });

    test('Elimina un producto sin ventas asociadas', () {
      final notifier = PosNotifier();
      final id = notifier.registrarProducto(nombre: 'Gaseosa', precio: 3000);

      notifier.eliminarProducto(id);

      expect(notifier.buscarProductoPorId(id), isNull);
      expect(notifier.state.productos, isEmpty);
    });

    test('Bloquea eliminar un producto con ventas registradas', () {
      final notifier = PosNotifier();
      final id = notifier.registrarProducto(nombre: 'Gaseosa', precio: 3000, stock: 5);
      notifier.registrarVenta(
        items: [
          ItemVentaPos(
            productoId: id,
            nombre: 'Gaseosa',
            precioUnitario: 3000,
            cantidad: 1,
          ),
        ],
      );

      expect(
        () => notifier.eliminarProducto(id),
        throwsA(isA<ProductoEnUsoException>()),
      );
      expect(notifier.buscarProductoPorId(id), isNotNull);
    });

    test('Bloquea eliminar una base usada por un kit', () {
      final notifier = PosNotifier();
      notifier.registrarProducto(nombre: 'Cerveza', precio: 2000, stock: 20);
      notifier.registrarProducto(nombre: 'Empaque', precio: 500, stock: 30);
      notifier.registrarProducto(
        nombre: 'Six pack de cerveza',
        tipo: TipoProductoPos.kit,
        componentes: const [
          KitComponente(productoId: 1, cantidad: 6),
          KitComponente(productoId: 2, cantidad: 1),
        ],
        precio: 15000,
        stock: 5,
      );

      expect(
        () => notifier.eliminarProducto(1),
        throwsA(isA<ProductoEnUsoException>()),
      );
      expect(notifier.buscarProductoPorId(1), isNotNull);
    });

    test('Reactivar vuelve disponible al producto inactivo', () {
      final notifier = PosNotifier();
      final id = notifier.registrarProducto(nombre: 'Gaseosa', precio: 3000, stock: 5);
      notifier.inactivarProducto(id);
      expect(notifier.buscarProductoPorId(id)!.activo, isFalse);

      notifier.reactivarProducto(id);
      expect(notifier.buscarProductoPorId(id)!.activo, isTrue);
    });
  });

  group('Ventas POS (§3.6.1)', () {
    test('Registra una venta y descontó el inventario', () {
      final notifier = PosNotifier();
      final id = notifier.registrarProducto(
        nombre: 'Gaseosa',
        codigo: 'GAS-001',
        precio: 3000,
        stock: 10,
      );

      final venta = notifier.registrarVenta(
        items: [
          ItemVentaPos(
            productoId: id,
            nombre: 'Gaseosa',
            codigo: 'GAS-001',
            precioUnitario: 3000,
            cantidad: 2,
          ),
        ],
      );

      expect(venta.id, 1);
      expect(venta.total, 6000);
      expect(notifier.buscarProductoPorId(id)!.stock, 8);
      expect(notifier.state.ventasOrdenadas.length, 1);
    });

    test('Vender un kit consume el stock de sus productos base', () {
      final notifier = PosNotifier();
      notifier.registrarProducto(nombre: 'Cerveza', precio: 2000, stock: 20);
      notifier.registrarProducto(nombre: 'Empaque six pack', precio: 500, stock: 30);
      final kitId = notifier.registrarProducto(
        nombre: 'Six pack de cerveza',
        tipo: TipoProductoPos.kit,
        componentes: const [
          KitComponente(productoId: 1, cantidad: 6),
          KitComponente(productoId: 2, cantidad: 1),
        ],
        precio: 15000,
        stock: 5,
      );

      final venta = notifier.registrarVenta(
        items: [
          ItemVentaPos(
            productoId: kitId,
            nombre: 'Six pack de cerveza',
            tipo: TipoProductoPos.kit,
            precioUnitario: 15000,
            cantidad: 2,
          ),
        ],
      );

      expect(venta.total, 30000);
      expect(notifier.buscarProductoPorId(kitId)!.stock, 3);
      expect(notifier.buscarProductoPorId(1)!.stock, 8);
      expect(notifier.buscarProductoPorId(2)!.stock, 28);
    });

    test('Bloquea la venta de un kit si faltan productos base', () {
      final notifier = PosNotifier();
      notifier.registrarProducto(nombre: 'Cerveza', precio: 2000, stock: 3);
      notifier.registrarProducto(nombre: 'Empaque', precio: 500, stock: 30);
      final kitId = notifier.registrarProducto(
        nombre: 'Six pack de cerveza',
        tipo: TipoProductoPos.kit,
        componentes: const [
          KitComponente(productoId: 1, cantidad: 6),
          KitComponente(productoId: 2, cantidad: 1),
        ],
        precio: 15000,
        stock: 5,
      );

      expect(
        () => notifier.registrarVenta(
          items: [
            ItemVentaPos(
              productoId: kitId,
              nombre: 'Six pack de cerveza',
              tipo: TipoProductoPos.kit,
              precioUnitario: 15000,
              cantidad: 1,
            ),
          ],
        ),
        throwsA(isA<StockInsuficienteException>()),
      );
    });
  });

  group('Historial de ventas (§3.6.3)', () {
    test('Ordena las ventas de la más reciente a la más antigua', () async {
      final notifier = PosNotifier();
      notifier.registrarProducto(nombre: 'Gaseosa', precio: 3000, stock: 10);

      notifier.registrarVenta(
        items: [
          ItemVentaPos(
            productoId: 1,
            nombre: 'Gaseosa',
            precioUnitario: 3000,
            cantidad: 1,
          ),
        ],
      );

      await Future<void>.delayed(const Duration(milliseconds: 5));

      notifier.registrarVenta(
        clienteId: 'C1',
        nombreCliente: 'Pedro',
        items: [
          ItemVentaPos(
            productoId: 1,
            nombre: 'Gaseosa',
            precioUnitario: 3000,
            cantidad: 2,
          ),
        ],
      );

      final ventas = notifier.state.ventasOrdenadas;
      expect(ventas.length, 2);
      expect(ventas.first.id, 2);
      expect(ventas.first.nombreCliente, 'Pedro');
      expect(ventas.last.id, 1);
    });
  });
}