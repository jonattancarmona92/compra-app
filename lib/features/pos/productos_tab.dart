// ==================== ARCHIVO: lib/features/pos/productos_tab.dart ====================
// Pestaña "Catálogo" del Punto de Venta — Informe Global §3.6.2. Gestión
// del catálogo de productos de tienda dentro de la ventana única del POS:
// listado, registro, edición, inactivación/reactivación y baja física.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'pos_provider.dart';

class ProductosTab extends ConsumerWidget {
  const ProductosTab({super.key});

  void _agregarProducto(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPaletaOficial.blanco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppEspaciado.radioLg),
        ),
      ),
      builder: (context) => const _FormProducto(),
    );
  }

  void _editarProducto(BuildContext context, ProductoPos producto) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPaletaOficial.blanco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppEspaciado.radioLg),
        ),
      ),
      builder: (context) => _FormProducto(producto: producto),
    );
  }

  void _accion(
    BuildContext context,
    WidgetRef ref,
    ProductoPos producto,
    String opcion,
  ) {
    switch (opcion) {
      case 'editar':
        _editarProducto(context, producto);
        break;
      case 'activo':
        _cambiarActivo(context, ref, producto, !producto.activo);
        break;
      case 'eliminar':
        _confirmarEliminar(context, ref, producto);
        break;
    }
  }

  void _cambiarActivo(
    BuildContext context,
    WidgetRef ref,
    ProductoPos producto,
    bool activo,
  ) {
    ref
        .read(posProvider.notifier)
        .actualizarProducto(producto.copyWith(activo: activo));
    Notificaciones.informacion(
      context,
      'Producto ' '${producto.nombre}' ' ${activo ? 'reactivado' : 'inactivado'}',
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    ProductoPos producto,
  ) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Eliminar "${producto.nombre}" del catálogo?\n\n'
          'Esta acción no se puede deshacer. Si el producto tiene ventas '
          'registradas o forma parte de un kit, no se podrá eliminar y '
          'deberá inactivarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppPaletaOficial.rojo,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (resultado != true) return;
    if (!context.mounted) return;

    try {
      ref.read(posProvider.notifier).eliminarProducto(producto.id);
      Notificaciones.exito(context, 'Producto eliminado');
    } on ProductoEnUsoException catch (e) {
      Notificaciones.error(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(posProvider);
    final productos = estado.productos;

    return ListView(
      padding: const EdgeInsets.all(AppEspaciado.m),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Catálogo (${productos.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppEscalaTipografica.subtitulo,
                ),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _agregarProducto(context),
              icon: const Icon(Icons.add),
              label: const Text('Producto'),
            ),
          ],
        ),
        const SizedBox(height: AppEspaciado.m),
        if (productos.isEmpty)
          const _SinProductos()
        else
          for (var i = 0; i < productos.length; i++) ...[
            if (i > 0) const SizedBox(height: AppEspaciado.s),
            _construirTarjeta(context, ref, productos[i]),
          ],
      ],
    );
  }

  Widget _construirTarjeta(
    BuildContext context,
    WidgetRef ref,
    ProductoPos p,
  ) {
    return Card(
      elevation: 0,
      color: AppPaletaOficial.blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: BorderSide(
          color: p.activo
              ? const Color(0xFFE0D8D0)
              : AppPaletaOficial.rojo.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppPaletaOficial.cafe,
          child: Icon(
            Icons.inventory_2,
            color: AppPaletaOficial.blanco,
          ),
        ),
        title: Text(
          p.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppEscalaTipografica.cuerpo,
          ),
        ),
        subtitle: Text(
          '${p.tipo.etiqueta}'
          ' · Stock: ${p.stock}'
          '${p.codigo.isNotEmpty ? ' · Código: ${p.codigo}' : ''}'
          '${!p.activo ? ' · Inactivo' : ''}',
          style: const TextStyle(
            fontSize: AppEscalaTipografica.notas,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.formatValue(p.precio),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppPaletaOficial.cafe,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opciones de ' '${p.nombre}',
              color: AppPaletaOficial.blanco,
              onSelected: (opcion) => _accion(context, ref, p, opcion),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'activo',
                  child: Text(p.activo ? 'Inactivar' : 'Reactivar'),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormProducto extends ConsumerStatefulWidget {
  /// Producto a editar; cuando es `null` el formulario registra uno nuevo.
  final ProductoPos? producto;

  const _FormProducto({this.producto});

  @override
  ConsumerState<_FormProducto> createState() => _FormProductoState();
}

class _FormProductoState extends ConsumerState<_FormProducto> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _codigoController;
  late final TextEditingController _precioController;
  late final TextEditingController _stockController;

  late TipoProductoPos _tipo;

  /// productoId -> cantidad para la composición del kit.
  final _componentes = <int, int>{};

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final producto = widget.producto;
    _nombreController = TextEditingController(text: producto?.nombre ?? '');
    _codigoController = TextEditingController(text: producto?.codigo ?? '');
    _precioController = TextEditingController(
      text: producto == null
          ? ''
          : CurrencyFormatter.formatValue(producto.precio),
    );
    _stockController = TextEditingController(
      text: producto == null ? '' : '${producto.stock}',
    );
    _tipo = producto?.tipo ?? TipoProductoPos.unidad;
    if (producto != null) {
      for (final c in producto.componentes) {
        _componentes[c.productoId] = c.cantidad;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Productos ya registrados elegibles como componentes de un kit
  /// (activos, que no sean kits ni el propio producto que se edita).
  List<ProductoPos> get _productosBase {
    final estado = ref.read(posProvider);
    return estado.productos
        .where((p) => p.activo && !p.esKit && p.id != widget.producto?.id)
        .toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_tipo == TipoProductoPos.kit && _componentes.length < 2) {
      Notificaciones.advertencia(
        context,
        'El kit requiere al menos dos productos que lo compongan',
      );
      return;
    }
    final precio = CurrencyFormatter.parseValue(_precioController.text);
    final stock = int.tryParse(_stockController.text) ?? 0;

    final componentes = _tipo == TipoProductoPos.kit
        ? _componentes.entries
            .map((e) => KitComponente(productoId: e.key, cantidad: e.value))
            .toList()
        : const <KitComponente>[];

    try {
      if (_esEdicion) {
        ref.read(posProvider.notifier).editarProducto(
              id: widget.producto!.id,
              nombre: _nombreController.text,
              codigo: _codigoController.text,
              tipo: _tipo,
              componentes: componentes,
              precio: precio,
              stock: stock,
            );
        Notificaciones.exito(context, 'Producto actualizado');
      } else {
        ref.read(posProvider.notifier).registrarProducto(
              nombre: _nombreController.text,
              codigo: _codigoController.text,
              tipo: _tipo,
              componentes: componentes,
              precio: precio,
              stock: stock,
            );
        Notificaciones.exito(context, 'Producto registrado');
      }
      Navigator.of(context).pop();
    } on ProductoDuplicadoException {
      Notificaciones.error(context, 'El producto ya existe');
    } on ArgumentError catch (e) {
      Notificaciones.error(context, e.message);
    }
  }

  void _alternarComponente(int productoId, bool seleccionado) {
    setState(() {
      if (seleccionado) {
        _componentes[productoId] = 1;
      } else {
        _componentes.remove(productoId);
      }
    });
  }

  void _cambiarCantidadComponente(int productoId, int delta) {
    final actual = _componentes[productoId] ?? 1;
    final nuevo = actual + delta;
    if (nuevo < 1) return;
    setState(() => _componentes[productoId] = nuevo);
  }

  Widget _construirSelectorTipo() {
    return SegmentedButton<TipoProductoPos>(
      segments: TipoProductoPos.values
          .map(
            (t) => ButtonSegment(
              value: t,
              label: Text(
                t.etiqueta,
                style: const TextStyle(fontSize: AppEscalaTipografica.notas),
              ),
            ),
          )
          .toList(),
      selected: {_tipo},
      onSelectionChanged: (nuevo) => setState(() => _tipo = nuevo.first),
      showSelectedIcon: false,
    );
  }

  Widget _construirSeccionKit() {
    final base = _productosBase;
    if (base.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppEspaciado.s),
        child: Text(
          'Registra primero al menos dos productos para componer el kit.',
          style: const TextStyle(
            fontSize: AppEscalaTipografica.notas,
            color: AppPaletaOficial.rojo,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppEspaciado.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Productos que lo componen (mínimo 2)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppEscalaTipografica.cuerpo,
            ),
          ),
          const SizedBox(height: AppEspaciado.s),
          for (final p in base)
            Card(
              elevation: 0,
              color: AppPaletaOficial.blanco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
                side: const BorderSide(color: Color(0xFFE0D8D0)),
              ),
              child: CheckboxListTile(
                value: _componentes.containsKey(p.id),
                onChanged: (v) => _alternarComponente(p.id, v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  p.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.cuerpo,
                  ),
                ),
                subtitle: Text(
                  '${p.tipo.etiqueta}'
                  '${p.codigo.isNotEmpty ? ' · ${p.codigo}' : ''}',
                  style: const TextStyle(fontSize: AppEscalaTipografica.notas),
                ),
                secondary: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _componentes.containsKey(p.id)
                          ? () => _cambiarCantidadComponente(p.id, -1)
                          : null,
                    ),
                    Text(
                      '${_componentes[p.id] ?? 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _componentes.containsKey(p.id)
                          ? () => _cambiarCantidadComponente(p.id, 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppEspaciado.m,
          right: AppEspaciado.m,
          top: AppEspaciado.m,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppEspaciado.m,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _esEdicion ? 'Editar producto' : 'Nuevo producto',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.subtitulo,
                  ),
                ),
                const SizedBox(height: AppEspaciado.m),
                TextFormField(
                  controller: _nombreController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio'
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppEspaciado.m),
                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppEspaciado.m),
                TextFormField(
                  controller: _precioController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyFormatter()],
                  validator: CurrencyFormatter.validar,
                  decoration: const InputDecoration(
                    labelText: 'Precio de venta',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppEspaciado.m),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _tipo == TipoProductoPos.gramera
                        ? 'Stock en gramos'
                        : 'Stock inicial',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppEspaciado.m),
                const Text(
                  'Tipo de producto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.cuerpo,
                  ),
                ),
                const SizedBox(height: AppEspaciado.s),
                _construirSelectorTipo(),
                _tipo == TipoProductoPos.kit
                    ? _construirSeccionKit()
                    : const SizedBox.shrink(),
                const SizedBox(height: AppEspaciado.l),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _guardar,
                    icon: const Icon(Icons.check),
                    label: Text(_esEdicion ? 'Guardar cambios' : 'Guardar producto'),
                  ),
                ),
              ],
            ),
          ),
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
            Icons.inventory_2_outlined,
            size: 56,
            color: Color(0xFFB0ACA7),
          ),
          SizedBox(height: AppEspaciado.m),
          Text(
            'No hay productos en el catálogo',
            style: TextStyle(fontSize: AppEscalaTipografica.cuerpo),
          ),
        ],
      ),
    );
  }
}