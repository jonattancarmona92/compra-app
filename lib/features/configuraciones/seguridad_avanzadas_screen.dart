// ==================== SEGURIDAD > AVANZADAS ====================
// Acceso restringido a opciones críticas del sistema. Requiere ingreso
// del ID de dispositivo (hardware binding, Documento "Pin de recarga")
// como autorización. Allí se centralizan: cambio de credenciales,
// copias/restauración de la base de datos y limpieza total de datos.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/base_datos/app_database.dart';
import '../../core/diseno.dart';
import '../../core/widgets/patron_lock_widget.dart';
import '../inicio/control_inicio_provider.dart';
import 'licencia_provider.dart';

class SeguridadAvanzadasScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  const SeguridadAvanzadasScreen({super.key, required this.onBack});

  @override
  ConsumerState<SeguridadAvanzadasScreen> createState() =>
      _SeguridadAvanzadasScreenState();
}

class _SeguridadAvanzadasScreenState
    extends ConsumerState<SeguridadAvanzadasScreen> {
  bool _verificado = false;
  final _idController = TextEditingController();
  String? _errorVerificacion;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _verificar() {
    final ingresado = _idController.text.trim();
    final real = ref.read(licenciaProvider).dispositivoId;
    if (ingresado == real && real.isNotEmpty) {
      setState(() {
        _verificado = true;
        _errorVerificacion = null;
      });
    } else {
      setState(
        () => _errorVerificacion =
            'El ID no coincide con este dispositivo.',
      );
    }
  }

  // =========================================================================
  // CAMBIO DE PATRÓN DE DESBLOQUEO
  // =========================================================================

  Future<String?> _pedirPatron(String instruccion) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPaletaOficial.blanco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppEspaciado.radioLg)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppEspaciado.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                instruccion,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppEscalaTipografica.subtitulo,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppEspaciado.m),
              PatronLockWidget(
                onPatronCompletado: (v) => Navigator.of(ctx).pop(v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _flujoCambiarPatron() async {
    final actual = await _pedirPatron('Trace su patrón actual');
    if (actual == null || !mounted) return;

    final actualOk = await ref
        .read(controlInicioProvider.notifier)
        .verificarCredencial(actual, esPin: false);
    if (!mounted) return;
    if (!actualOk) {
      Notificaciones.error(context, 'El patrón actual es incorrecto');
      return;
    }

    final nuevo = await _pedirPatron('Trace el nuevo patrón');
    if (nuevo == null || !mounted) return;
    final confirmado = await _pedirPatron('Confirme el nuevo patrón');
    if (confirmado == null || !mounted) return;

    final ok = await ref
        .read(controlInicioProvider.notifier)
        .cambiarPatron(
          patronActual: actual,
          nuevoPatron: nuevo,
          confirmarPatron: confirmado,
        );
    if (!mounted) return;
    if (ok) {
      Notificaciones.exito(context, 'Patrón de desbloqueo actualizado');
    } else {
      Notificaciones.error(context, 'Los patrones no coinciden');
    }
  }

  // =========================================================================
  // CAMBIO DE PIN DE OPERACIÓN
  // =========================================================================

  void _abrirCambioPin() {
    final actualCtrl = TextEditingController();
    final nuevoCtrl = TextEditingController();
    final confirmarCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        title: const Text('Cambiar PIN de Operación'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: actualCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'PIN actual',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.length != 4) ? '4 dígitos' : null,
              ),
              const SizedBox(height: AppEspaciado.s),
              TextFormField(
                controller: nuevoCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Nuevo PIN',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.length != 4) ? '4 dígitos' : null,
              ),
              const SizedBox(height: AppEspaciado.s),
              TextFormField(
                controller: confirmarCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nuevo PIN',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.length != 4) ? '4 dígitos' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await ref
                  .read(controlInicioProvider.notifier)
                  .cambiarPin(
                    pinActual: actualCtrl.text,
                    nuevoPin: nuevoCtrl.text,
                    confirmarPin: confirmarCtrl.text,
                  );
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              if (!mounted) return;
              if (ok) {
                Notificaciones.exito(
                  context,
                  'PIN de operación actualizado',
                );
              } else {
                Notificaciones.error(
                  context,
                  'PIN actual incorrecto o nuevo PIN inválido',
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // COPIA DE SEGURIDAD REAL
  // =========================================================================

  Future<void> _realizarCopia() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, 'coffee_control.sqlite'));
      if (!await dbFile.exists()) {
        if (!mounted) return;
        Notificaciones.error(context, 'No se encontró la base de datos');
        return;
      }
      final backupDir = Directory(p.join(dir.path, 'coffee_control_backups'));
      if (!await backupDir.exists()) await backupDir.create(recursive: true);
      final now = DateTime.now();
      final ts = '${now.year}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}'
          '${now.second.toString().padLeft(2, '0')}';
      final destino = File(
        p.join(backupDir.path, 'coffee_control_$ts.sqlite'),
      );
      await dbFile.copy(destino.path);
      if (!mounted) return;
      Notificaciones.exito(context, 'Copia de seguridad realizada');
    } catch (e) {
      if (!mounted) return;
      Notificaciones.error(context, 'Error al crear la copia: $e');
    }
  }

  Future<List<File>> _listarCopias() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'coffee_control_backups'));
    if (!await backupDir.exists()) return [];
    final archivos = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sqlite'))
        .toList();
    archivos.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );
    return archivos;
  }

  void _abrirRestaurar() async {
    final copias = await _listarCopias();
    if (!mounted) return;
    if (copias.isEmpty) {
      Notificaciones.informacion(context, 'No hay copias disponibles');
      return;
    }

    File? seleccionada;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        title: const Text('Restaurar copia de seguridad'),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<File>(
            groupValue: seleccionada,
            onChanged: (v) => seleccionada = v,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: copias.length,
              itemBuilder: (_, i) {
                final f = copias[i];
                final fecha = f.lastModifiedSync();
                return RadioListTile<File>(
                  value: f,
                  title: Text(
                    p.basename(f.path),
                    style: const TextStyle(
                      fontSize: AppEscalaTipografica.notas,
                    ),
                  ),
                  subtitle: Text(
                    '${fecha.day}/${fecha.month}/${fecha.year} '
                    '· ${fecha.hour.toString().padLeft(2, '0')}:'
                    '${fecha.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: AppEscalaTipografica.notas,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Seleccionar'),
          ),
        ],
      ),
    );

    if (seleccionada == null || !mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        title: const Text('¿Restaurar esta copia?'),
        content: const Text(
          'Se reemplazará la base de datos actual con la copia seleccionada. '
          'La aplicación se cerrará para aplicar los cambios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppPaletaOficial.rojo,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      final db = ref.read(appDatabaseProvider);
      await db.close();
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, 'coffee_control.sqlite'));
      if (await dbFile.exists()) await dbFile.delete();
      await seleccionada!.copy(dbFile.path);
      if (!mounted) return;
      Notificaciones.exito(
        context,
        'Copia restaurada. La aplicación se cerrará.',
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      SystemNavigator.pop();
    } catch (e) {
      if (!mounted) return;
      Notificaciones.error(context, 'Error al restaurar: $e');
    }
  }

  // =========================================================================
  // LIMPIAR DATOS
  // =========================================================================

  Future<void> _confirmarLimpiarDatos() async {
    final controlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        title: const Text('Limpiar todos los datos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta acción eliminará permanentemente toda la información '
              'de la aplicación: productos, ventas, cajas, clientes, '
              'lotes y la licencia actual.',
            ),
            const SizedBox(height: AppEspaciado.m),
            const Text(
              'Escriba ELIMINAR para confirmar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppEspaciado.s),
            TextField(
              controller: controlador,
              decoration: const InputDecoration(
                hintText: 'ELIMINAR',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppPaletaOficial.rojo,
            ),
            onPressed: () =>
                Navigator.of(ctx).pop(controlador.text == 'ELIMINAR'),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    try {
      final db = ref.read(appDatabaseProvider);
      await db.close();
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, 'coffee_control.sqlite'));
      if (await dbFile.exists()) await dbFile.delete();
      const storage = FlutterSecureStorage();
      await storage.deleteAll();
      if (!mounted) return;
      Notificaciones.exito(
        context,
        'Datos eliminados. La aplicación se cerrará.',
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      SystemNavigator.pop();
    } catch (e) {
      if (!mounted) return;
      Notificaciones.error(context, 'Error al limpiar: $e');
    }
  }

  // =========================================================================
  // UI
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avanzadas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: _verificado ? _buildOpciones() : _buildVerificacion(),
    );
  }

  Widget _buildVerificacion() {
    return ListView(
      padding: const EdgeInsets.all(AppEspaciado.m),
      children: [
        Card(
          elevation: 0,
          color: AppPaletaOficial.blanco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
            side: const BorderSide(color: Color(0xFFE0D8D0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppEspaciado.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppPaletaOficial.cafe),
                    SizedBox(width: AppEspaciado.s),
                    Text(
                      'Verificación de Dispositivo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppEscalaTipografica.subtitulo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppEspaciado.m),
                const Text(
                  'Ingrese el ID de este dispositivo para acceder a las '
                  'opciones avanzadas. Esta autorización protege las '
                  'operaciones críticas del sistema.',
                  style: TextStyle(fontSize: AppEscalaTipografica.notas),
                ),
                const SizedBox(height: AppEspaciado.m),
                TextFormField(
                  controller: _idController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'ID de Dispositivo',
                    hintText: 'Ej: 7K5E',
                    errorText: _errorVerificacion,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppEspaciado.m),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _verificar,
                    icon: const Icon(Icons.check),
                    label: const Text('Verificar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpciones() {
    return ListView(
      padding: const EdgeInsets.all(AppEspaciado.m),
      children: [
        _buildSeccion(
          icono: Icons.grid_view,
          titulo: 'Cambiar Patrón de Desbloqueo',
          descripcion:
              'Actualice el patrón de 9 puntos que se usa para desbloquear.',
          onPressed: _flujoCambiarPatron,
        ),
        const SizedBox(height: AppEspaciado.s),
        _buildSeccion(
          icono: Icons.pin,
          titulo: 'Cambiar PIN de Operación',
          descripcion:
              'Actualice el PIN de 4 dígitos para operaciones diarias.',
          onPressed: _abrirCambioPin,
        ),
        const SizedBox(height: AppEspaciado.l),
        const Text(
          'Base de Datos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppEscalaTipografica.subtitulo,
          ),
        ),
        const SizedBox(height: AppEspaciado.s),
        _buildSeccion(
          icono: Icons.save_alt,
          titulo: 'Crear Copia de Seguridad',
          descripcion:
              'Exporta la base de datos SQLite a un archivo de respaldo local.',
          onPressed: _realizarCopia,
        ),
        const SizedBox(height: AppEspaciado.s),
        _buildSeccion(
          icono: Icons.settings_backup_restore,
          titulo: 'Restaurar Copia de Seguridad',
          descripcion:
              'Reemplaza la base de datos actual con una copia previa. '
              'La app se cerrará.',
          onPressed: _abrirRestaurar,
        ),
        const SizedBox(height: AppEspaciado.l),
        const Text(
          'Zona de Peligro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppEscalaTipografica.subtitulo,
            color: AppPaletaOficial.rojo,
          ),
        ),
        const SizedBox(height: AppEspaciado.s),
        Card(
          elevation: 0,
          color: AppPaletaOficial.blanco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
            side: const BorderSide(color: AppPaletaOficial.rojo),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: AppPaletaOficial.rojo,
            ),
            title: const Text(
              'Limpiar Todos los Datos',
              style: TextStyle(color: AppPaletaOficial.rojo),
            ),
            subtitle: const Text(
              'Elimina permanentemente toda la información de la app.',
              style: TextStyle(fontSize: AppEscalaTipografica.notas),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _confirmarLimpiarDatos,
          ),
        ),
      ],
    );
  }

  Widget _buildSeccion({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 0,
      color: AppPaletaOficial.blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: const BorderSide(color: Color(0xFFE0D8D0)),
      ),
      child: ListTile(
        leading: Icon(icono, color: AppPaletaOficial.cafe),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          descripcion,
          style: const TextStyle(fontSize: AppEscalaTipografica.notas),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }
}