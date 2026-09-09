// ==================== ARCHIVO: lib/features/pos/pos_provider.dart ====================
// POS — Informe Global §3.6 (Ventas POS §3.6.1, Catálogo de Productos
// §3.6.2) y §5.5.12/§5.5.13 (productos, ventas_pos / ventas_pos_detalles).
//
// NOTA DE INTEGRACIÓN PENDIENTE: el módulo usa un repositorio en memoria
// que reproduce las tablas de POS. En el Módulo 5 (Drift) se reemplaza
// sin cambiar la interfaz pública del Notifier.
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// MODELOS
// ============================================================================

/// §3.6.2 — forma de comercialización del producto:
///   - `unidad`: se vende por unidades enteras (ej. una gaseosa).
///   - `gramera`: se vende por peso/gramos (ej. café, granos).
///   - `kit`: producto compuesto por dos o más productos previamente
///     registrados que se venden como un producto común (ej. six pack de
///     cerveza compuesto por 6 cervezas).
enum TipoProductoPos { unidad, gramera, kit }

extension TipoProductoPosLabel on TipoProductoPos {
  String get etiqueta {
    switch (this) {
      case TipoProductoPos.unidad:
        return 'Unidad';
      case TipoProductoPos.gramera:
        return 'Gramera';
      case TipoProductoPos.kit:
        return 'Kit';
    }
  }
}

/// §3.6.2 — componente de un Kit: producto base y cantidad que lo
/// compone (ej. six pack: 6 × cerveza).
class KitComponente {
  final int productoId;
  final int cantidad;

  const KitComponente({required this.productoId, required this.cantidad});
}

class ProductoPos {
  final int id;
  final String nombre;
  final String codigo;
  final TipoProductoPos tipo;
  final List<KitComponente> componentes;
  final double precio;
  final int stock;
  final bool activo;

  const ProductoPos({
    required this.id,
    required this.nombre,
    this.codigo = '',
    this.tipo = TipoProductoPos.unidad,
    this.componentes = const [],
    required this.precio,
    this.stock = 0,
    this.activo = true,
  });

  bool get esKit => tipo == TipoProductoPos.kit;

  ProductoPos copyWith({
    String? nombre,
    String? codigo,
    TipoProductoPos? tipo,
    List<KitComponente>? componentes,
    double? precio,
    int? stock,
    bool? activo,
  }) {
    return ProductoPos(
      id: id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      tipo: tipo ?? this.tipo,
      componentes: componentes ?? this.componentes,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      activo: activo ?? this.activo,
    );
  }
}

class ItemVentaPos {
  final int productoId;
  final String nombre;
  final String? codigo;
  final TipoProductoPos tipo;
  final double precioUnitario;
  final int cantidad;

  const ItemVentaPos({
    required this.productoId,
    required this.nombre,
    this.codigo,
    this.tipo = TipoProductoPos.unidad,
    required this.precioUnitario,
    required this.cantidad,
  });

  double get subtotal => precioUnitario * cantidad;
}

class VentaPos {
  final int id;
  final String? clienteId;
  final String? nombreCliente;
  final List<ItemVentaPos> items;
  final double total;
  final DateTime fechaRegistro;
  final String operador;

  /// Ciclo Operativo en el que se registró la venta (§5.5.13:
  /// `ventas_pos.ciclo_operativo_id`).
  final int cicloOperativoId;

  const VentaPos({
    required this.id,
    this.clienteId,
    this.nombreCliente,
    required this.items,
    required this.total,
    required this.fechaRegistro,
    required this.operador,
    this.cicloOperativoId = 1,
  });
}

// ============================================================================
// ESTADO
// ============================================================================

class PosEstado {
  final bool isCargando;
  final List<ProductoPos> productos;
  final List<VentaPos> ventas;

  /// Ciclo Operativo vigente. Al cerrarse un ciclo (Cierres > Cierre de
  /// Ciclo Operativo) se incrementa con [PosNotifier.iniciarNuevoCiclo]
  /// y las ventas del ciclo anterior dejan de computar.
  final int cicloActual;

  const PosEstado({
    this.isCargando = true,
    this.productos = const [],
    this.ventas = const [],
    this.cicloActual = 1,
  });

  PosEstado copyWith({
    bool? isCargando,
    List<ProductoPos>? productos,
    List<VentaPos>? ventas,
    int? cicloActual,
  }) {
    return PosEstado(
      isCargando: isCargando ?? this.isCargando,
      productos: productos ?? this.productos,
      ventas: ventas ?? this.ventas,
      cicloActual: cicloActual ?? this.cicloActual,
    );
  }

  /// Número de ventas POS registradas en el Ciclo Operativo vigente.
  /// Condición del complemento "Ventas POS": si es > 0, la desactivación
  /// queda pendiente hasta el Cierre del Ciclo Operativo.
  int get ventasEnCicloActual =>
      ventas.where((v) => v.cicloOperativoId == cicloActual).length;

  List<VentaPos> get ventasOrdenadas =>
      [...ventas]..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

  /// §3.6.1: productos activos con stock disponible para la venta.
  List<ProductoPos> get productosDisponibles =>
      productos.where((p) => p.activo && p.stock > 0).toList();
}

/// §5.5.12: duplicado bloqueante por nombre de producto.
class ProductoDuplicadoException implements Exception {
  final String nombre;
  const ProductoDuplicadoException(this.nombre);
}

/// §5.5.13: eliminar un producto referenciado (ventas POS o composición
/// de kit) está bloqueado.
class ProductoEnUsoException implements Exception {
  final String mensaje;
  const ProductoEnUsoException(this.mensaje);
}

class StockInsuficienteException implements Exception {
  final String nombre;
  const StockInsuficienteException(this.nombre);
}

// ============================================================================
// PROVIDER
// ============================================================================

class PosNotifier extends StateNotifier<PosEstado> {
  PosNotifier() : super(const PosEstado()) {
    _inicializar();
  }

  int _correlativoProducto = 1;
  int _correlativoVenta = 1;

  void _inicializar() {
    state = state.copyWith(
      isCargando: false,
      productos: const [],
      ventas: const [],
    );
  }

  // ==========================================================================
  // PRODUCTOS — Catálogo (§3.6.2)
  // ==========================================================================

  ProductoPos? buscarProductoPorId(int id) {
    for (final p in state.productos) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// §3.6.2 / §5.5.12: registra un producto validando duplicados por
  /// nombre y por código. Soporta los tres tipos de comercialización
  /// (unidad, gramera, kit).
  int registrarProducto({
    required String nombre,
    String? codigo,
    TipoProductoPos tipo = TipoProductoPos.unidad,
    List<KitComponente> componentes = const [],
    required double precio,
    int stock = 0,
  }) {
    if (nombre.trim().isEmpty) {
      throw ArgumentError('El nombre del producto es obligatorio.');
    }
    final existe = state.productos.any(
      (p) => p.nombre.toLowerCase() == nombre.trim().toLowerCase(),
    );
    if (existe) {
      throw ProductoDuplicadoException(nombre.trim());
    }

    final codigoLimpio = (codigo ?? '').trim();
    if (codigoLimpio.isNotEmpty &&
        state.productos.any(
          (p) => p.codigo.toLowerCase() == codigoLimpio.toLowerCase(),
        )) {
      throw ArgumentError('Ya existe un producto con ese código.');
    }
    if (tipo == TipoProductoPos.kit && componentes.length < 2) {
      throw ArgumentError('El kit requiere al menos dos productos.');
    }

    final nuevo = ProductoPos(
      id: _correlativoProducto++,
      nombre: nombre.trim(),
      codigo: codigoLimpio,
      tipo: tipo,
      componentes: tipo == TipoProductoPos.kit ? componentes : const [],
      precio: precio < 0 ? 0 : precio,
      stock: stock < 0 ? 0 : stock,
    );
    state = state.copyWith(productos: [...state.productos, nuevo]);
    return nuevo.id;
  }

  void actualizarProducto(ProductoPos productoActualizado) {
    final actualizados = state.productos
        .map((p) => p.id == productoActualizado.id ? productoActualizado : p)
        .toList();
    state = state.copyWith(productos: actualizados);
  }

  void inactivarProducto(int id) {
    actualizarProducto(buscarProductoPorId(id)!.copyWith(activo: false));
  }

  /// §3.6.2 — edita los datos de un producto conservando su `id` y su
  /// estado (`activo`). Valida duplicados de nombre/código excluyendo al
  /// propio producto y el mínimo de dos componentes en kits.
  void editarProducto({
    required int id,
    required String nombre,
    String? codigo,
    TipoProductoPos? tipo,
    List<KitComponente>? componentes,
    required double precio,
    int? stock,
  }) {
    final actual = buscarProductoPorId(id);
    if (actual == null) {
      throw ArgumentError('No se encontró el producto a editar.');
    }
    if (nombre.trim().isEmpty) {
      throw ArgumentError('El nombre del producto es obligatorio.');
    }
    final tipoNuevo = tipo ?? actual.tipo;
    final nombreLimpio = nombre.trim();
    final duplicadoNombre = state.productos.any(
      (p) => p.id != id && p.nombre.toLowerCase() == nombreLimpio.toLowerCase(),
    );
    if (duplicadoNombre) {
      throw ProductoDuplicadoException(nombreLimpio);
    }
    final codigoLimpio = (codigo ?? actual.codigo).trim();
    if (codigoLimpio.isNotEmpty &&
        state.productos.any(
          (p) =>
              p.id != id &&
              p.codigo.toLowerCase() == codigoLimpio.toLowerCase(),
        )) {
      throw ArgumentError('Ya existe un producto con ese código.');
    }
    final componentesNuevos = tipoNuevo == TipoProductoPos.kit
        ? (componentes ?? actual.componentes)
        : const <KitComponente>[];
    if (tipoNuevo == TipoProductoPos.kit && componentesNuevos.length < 2) {
      throw ArgumentError('El kit requiere al menos dos productos.');
    }
    final stockNuevo = (stock ?? actual.stock) < 0 ? 0 : (stock ?? actual.stock);

    actualizarProducto(
      actual.copyWith(
        nombre: nombreLimpio,
        codigo: codigoLimpio,
        tipo: tipoNuevo,
        componentes: componentesNuevos,
        precio: precio < 0 ? 0 : precio,
        stock: stockNuevo,
      ),
    );
  }

  void reactivarProducto(int id) {
    final producto = buscarProductoPorId(id);
    if (producto == null) return;
    if (!producto.activo) actualizarProducto(producto.copyWith(activo: true));
  }

  /// §5.5.13 — elimina físicamente un producto solo si no está referenciado
  /// por ventas POS ni por la composición de un kit.
  void eliminarProducto(int id) {
    final producto = buscarProductoPorId(id);
    if (producto == null) {
      throw ArgumentError('No se encontró el producto a eliminar.');
    }
    final enVentas = state.ventas.any(
      (v) => v.items.any((i) => i.productoId == id),
    );
    if (enVentas) {
      throw ProductoEnUsoException(
        'No se puede eliminar: el producto tiene ventas registradas. '
        'Puede inactivarlo para ocultarlo del POS.',
      );
    }
    final enKits = state.productos.any(
      (p) => p.componentes.any((c) => c.productoId == id),
    );
    if (enKits) {
      throw ProductoEnUsoException(
        'No se puede eliminar: el producto forma parte de un kit. '
        'Retírelo del kit o inactivelo.',
      );
    }
    state = state.copyWith(
      productos: state.productos.where((p) => p.id != id).toList(),
    );
  }

  // ==========================================================================
  // VENTAS POS (§3.6.1 §5.5.13)
  // ==========================================================================

  /// Registra una venta POS validando stock y descuenta el inventario.
  /// Para productos tipo Kit también descuenta el stock de cada producto
  /// base que lo compone.
  VentaPos registrarVenta({
    String? clienteId,
    String? nombreCliente,
    required List<ItemVentaPos> items,
    String operador = 'operador_demo',
  }) {
    // Consumo indirecto acumulado de productos base por componentes de kit.
    final consumoBase = <int, int>{};
    // Verificación previa de stock antes de aplicar.
    for (final item in items) {
      final producto = buscarProductoPorId(item.productoId);
      if (producto == null || item.cantidad > producto.stock) {
        throw StockInsuficienteException(item.nombre);
      }
      if (producto.esKit) {
        for (final c in producto.componentes) {
          final base = buscarProductoPorId(c.productoId);
          if (base == null || base.esKit) {
            throw StockInsuficienteException(item.nombre);
          }
          consumoBase[c.productoId] =
              (consumoBase[c.productoId] ?? 0) + c.cantidad * item.cantidad;
        }
      }
    }
    consumoBase.forEach((productoId, cantidad) {
      final base = buscarProductoPorId(productoId);
      if (base == null || cantidad > base.stock) {
        throw StockInsuficienteException(base?.nombre ?? 'Producto');
      }
    });

    final total = items.fold<double>(0, (acc, i) => acc + i.subtotal);

    // Descuento de inventario (producto vendido + componentes de kites).
    final productosActualizados = state.productos.map((p) {
      var descontado = consumoBase[p.id] ?? 0;
      for (final i in items) {
        if (i.productoId == p.id) descontado += i.cantidad;
      }
      if (descontado == 0) return p;
      return p.copyWith(
        stock: (p.stock - descontado) < 0 ? 0 : p.stock - descontado,
      );
    }).toList();

    final venta = VentaPos(
      id: _correlativoVenta++,
      clienteId: clienteId,
      nombreCliente: nombreCliente,
      items: items,
      total: total,
      fechaRegistro: DateTime.now(),
      operador: operador,
      cicloOperativoId: state.cicloActual,
    );

    state = state.copyWith(
      productos: productosActualizados,
      ventas: [...state.ventas, venta],
    );
    return venta;
  }

  /// §3.3.4 — se invoca al completarse el Cierre del Ciclo Operativo:
  /// abre un nuevo ciclo POS en silencio (las ventas anteriores quedan
  /// asociadas al ciclo cerrado).
  void iniciarNuevoCiclo() {
    state = state.copyWith(cicloActual: state.cicloActual + 1);
  }
}

final posProvider = StateNotifierProvider<PosNotifier, PosEstado>((ref) {
  return PosNotifier();
});
