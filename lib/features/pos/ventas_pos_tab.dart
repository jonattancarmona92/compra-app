// ==================== ARCHIVO: lib/features/pos/ventas_pos_tab.dart ====================
// Pestaña "Vender" del Punto de Venta — Informe Global §3.6.1. Registro
// de ventas de tienda dentro de la ventana única del POS: selección de
// productos del catálogo, desglose del carrito (precio × cantidad) y
// confirmación de la venta con descuento de inventario.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'pos_provider.dart';

class VentasPosTab extends ConsumerStatefulWidget {
  const VentasPosTab({super.key});

  @override
  ConsumerState<VentasPosTab> createState() => _VentasPosTabState();
}

class _VentasPosTabState extends ConsumerState<VentasPosTab>
    with AutomaticKeepAliveClientMixin {
  final _carrito = <int, int>{};

  @override
  bool get wantKeepAlive => true;

  void _agregarAlCarrito(ProductoPos producto) {
    if (producto.tipo == TipoProductoPos.gramera) {
      _showDialogoGramera(producto);
      return;
    }
    setState(() {
      _carrito[producto.id] = (_carrito[producto.id] ?? 0) + 1;
    });
  }

  void _showDialogoGramera(ProductoPos producto) {
    final controlador = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        title: Text(
          'Gramos de ${producto.nombre}',
          style: const TextStyle(fontSize: AppEscalaTipografica.subtitulo),
        ),
        content: TextField(
          controller: controlador,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cantidad en gramos',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final gramos = int.tryParse(controlador.text) ?? 0;
              if (gramos <= 0) {
                Notificaciones.advertencia(
                  dialogContext,
                  'Ingresa un peso válido',
                );
                return;
              }
              final existente = _carrito[producto.id] ?? 0;
              if (existente + gramos > producto.stock) {
                Notificaciones.error(
                  dialogContext,
                  'Stock insuficiente: dispones de ${producto.stock - existente} g',
                );
                return;
              }
              Navigator.of(dialogContext).pop();
              setState(() {
                _carrito[producto.id] = existente + gramos;
              });
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _restarDelCarrito(int productoId) {
    setState(() {
      final nuevo = (_carrito[productoId] ?? 0) - 1;
      if (nuevo <= 0) {
        _carrito.remove(productoId);
      } else {
        _carrito[productoId] = nuevo;
      }
    });
  }

  void _confirmarVenta() {
    if (_carrito.isEmpty) {
      Notificaciones.advertencia(context, 'El carrito está vacío');
      return;
    }

    final estado = ref.read(posProvider);
    final items = _carrito.entries.map((e) {
      final producto = estado.productos.firstWhere((p) => p.id == e.key);
      return ItemVentaPos(
        productoId: producto.id,
        nombre: producto.nombre,
        codigo: producto.codigo,
        tipo: producto.tipo,
        precioUnitario: producto.precio,
        cantidad: e.value,
      );
    }).toList();

    try {
      final venta = ref
          .read(posProvider.notifier)
          .registrarVenta(items: items);
      setState(() => _carrito.clear());
      Notificaciones.exito(
        context,
        'Venta registrada: ${CurrencyFormatter.formatValue(venta.total)}',
      );
    } on StockInsuficienteException catch (e) {
      Notificaciones.error(context, 'Stock insuficiente para ${e.nombre}');
    }
  }

  double get _totalCarrito {
    final estado = ref.read(posProvider);
    return _carrito.entries.fold<double>(0, (acc, e) {
      final producto = estado.productos.firstWhere((p) => p.id == e.key);
      return acc + producto.precio * e.value;
    });
  }

  String _subtituloProducto(ProductoPos p) {
    switch (p.tipo) {
      case TipoProductoPos.unidad:
        return '${CurrencyFormatter.formatValue(p.precio)}'
            ' · Unidad · Stock: ${p.stock}';
      case TipoProductoPos.gramera:
        return '${CurrencyFormatter.formatValue(p.precio)}'
            ' por gramo · Stock: ${p.stock} g';
      case TipoProductoPos.kit:
        return '${CurrencyFormatter.formatValue(p.precio)}'
            ' · Kit (${p.componentes.length} productos)'
            ' · Stock: ${p.stock}';
    }
  }

  String _cantidadEnCarrito(ProductoPos p, int cantidad) {
    return p.tipo == TipoProductoPos.gramera ? '$cantidad g' : '$cantidad';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final estado = ref.watch(posProvider);
    final disponibles = estado.productosDisponibles;

    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppEspaciado.m,
                  AppEspaciado.m,
                  AppEspaciado.m,
                  AppEspaciado.xs,
                ),
                child: Text(
                  'Catálogo disponible',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.subtitulo,
                  ),
                ),
              ),
              Expanded(
                child: disponibles.isEmpty
                    ? const _SinProductos()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppEspaciado.m,
                        ),
                        itemCount: disponibles.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppEspaciado.s),
                        itemBuilder: (context, index) {
                          final p = disponibles[index];
                          final enCarrito = _carrito[p.id] ?? 0;
                          return Card(
                            elevation: 0,
                            color: AppPaletaOficial.blanco,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppEspaciado.radioEstandar,
                              ),
                              side: const BorderSide(
                                color: Color(0xFFE0D8D0),
                              ),
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.nombre,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppEscalaTipografica.cuerpo,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppEspaciado.s,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.esKit
                                          ? AppPaletaOficial.amarillo
                                          : AppPaletaOficial.cafe
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p.tipo.etiqueta,
                                      style: TextStyle(
                                        fontSize: AppEscalaTipografica.notas,
                                        fontWeight: FontWeight.bold,
                                        color: p.esKit
                                            ? const Color(0xFF5D4E2A)
                                            : AppPaletaOficial.cafe,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${_subtituloProducto(p)}'
                                '${p.codigo.isNotEmpty ? ' · Código: ${p.codigo}' : ''}',
                                style: const TextStyle(
                                  fontSize: AppEscalaTipografica.notas,
                                ),
                              ),
                              trailing: enCarrito > 0
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          onPressed: () =>
                                              _restarDelCarrito(p.id),
                                        ),
                                        Text(
                                          _cantidadEnCarrito(p, enCarrito),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                          onPressed: () => setState(() {
                                            if (enCarrito < p.stock) {
                                              _carrito[p.id] = enCarrito + 1;
                                            }
                                          }),
                                        ),
                                      ],
                                    )
                                  : FilledButton(
                                      onPressed: () => _agregarAlCarrito(p),
                                      child: const Text('Agregar'),
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        // --- Desglose del carrito (precio por línea y subtotal) ---
        if (_carrito.isNotEmpty) _construirCarrito(estado),
        // --- Barra de total / confirmar ---
        Material(
          color: AppPaletaOficial.cafe,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppEspaciado.m),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppEscalaTipografica.notas,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatValue(_totalCarrito),
                          style: const TextStyle(
                            color: AppPaletaOficial.blanco,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPaletaOficial.blanco,
                      foregroundColor: AppPaletaOficial.cafe,
                    ),
                    onPressed: _confirmarVenta,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Registrar venta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirCarrito(PosEstado estado) {
    final lineas = _carrito.entries.map((e) {
      final p = estado.productos.firstWhere((x) => x.id == e.key);
      return (producto: p, cantidad: e.value);
    }).toList();
    return Material(
      color: AppPaletaOficial.blanco,
      elevation: 4,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE0D8D0))),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppEspaciado.m,
          AppEspaciado.s,
          AppEspaciado.m,
          AppEspaciado.s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < lineas.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == lineas.length - 1 ? 0 : AppEspaciado.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_cantidadEnCarrito(lineas[i].producto, lineas[i].cantidad)} × ${lineas[i].producto.nombre}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppEscalaTipografica.notas,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatValue(
                        lineas[i].producto.precio * lineas[i].cantidad,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppEscalaTipografica.notas,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SinProductos extends StatelessWidget {
  const _SinProductos();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 56,
            color: Color(0xFFB0ACA7),
          ),
          SizedBox(height: AppEspaciado.m),
          Text(
            'No hay productos disponibles',
            style: TextStyle(fontSize: AppEscalaTipografica.cuerpo),
          ),
        ],
      ),
    );
  }
}