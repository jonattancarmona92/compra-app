// ==================== CONFIGURACIONES > ACTUALIZACIONES ====================
// Consulta la versión publicada en GitHub Releases y, si hay una nueva,
// permite descargarla e instalarla OTA. Reglas de negocio:
//   1. No se actualiza si hay un turno de caja abierto (alerta bloqueante).
//   2. Se solicita el ID de dispositivo (4 caracteres) y debe coincidir
//      con el guardado en la app (hardware binding).
//   3. Antes de descargar se ejecuta un respaldo de la base SQLite.
//   4. La descarga muestra progreso en tiempo real y lanza el instalador.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ota_update/ota_update.dart';
import 'package:path/path.dart' as p;

import '../../core/diseno.dart';
import '../../core/seguridad/licencia_pin.dart';
import '../../core/widgets/pin_entry_widget.dart';
import '../caja/caja_provider.dart';
import '../inicio/control_inicio_provider.dart';
import 'licencia_provider.dart';
import 'update_service.dart';

class ActualizacionesScreen extends ConsumerStatefulWidget {
  const ActualizacionesScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<ActualizacionesScreen> createState() =>
      _ActualizacionesScreenState();
}

class _ActualizacionesScreenState extends ConsumerState<ActualizacionesScreen> {
  static const String _operadorActual = 'operador_demo';

  final UpdateService _servicio = UpdateService();
  final _idController = TextEditingController();

  String _versionInstalada = '';
  String _versionInstaladaNombre = '';
  int _codigoInstalado = 1;
  InfoActualizacion? _disponible;
  bool _buscando = false;
  bool _descargando = false;
  double _progreso = 0;
  String _mensajeDescarga = '';
  String? _errorBusqueda;
  StreamSubscription<OtaEvent>? _subDescarga;

  @override
  void initState() {
    super.initState();
    _cargarVersionInstalada();
  }

  @override
  void dispose() {
    _subDescarga?.cancel();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _cargarVersionInstalada() async {
    try {
      final codigo = await _servicio.codigoVersionInstalado();
      final etiqueta = await _servicio.etiquetaVersionInstalada();
      final nombre = await _servicio.versionInstaladaNombre();
      if (!mounted) return;
      setState(() {
        _codigoInstalado = codigo;
        _versionInstalada = etiqueta;
        _versionInstaladaNombre = nombre;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _versionInstalada = 'No disponible');
    }
  }

  // =========================================================================
  // BUSCAR ACTUALIZACIÓN
  // =========================================================================

  Future<void> _buscarActualizacion() async {
    if (_buscando || _descargando) return;
    setState(() {
      _buscando = true;
      _errorBusqueda = null;
      _disponible = null;
    });
    try {
      final info = await _servicio.obtenerDisponibleGitHub();
      if (!mounted) return;
      setState(() {
        _disponible = info;
        _buscando = false;
      });
      if (!_hayNueva(info)) {
        Notificaciones.exito(context, 'Ya tiene la última versión');
      }
    } on UpdateException catch (e) {
      if (!mounted) return;
      setState(() {
        _buscando = false;
        _errorBusqueda = e.mensaje;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _buscando = false;
        _errorBusqueda = 'Error inesperado al buscar actualizaciones';
      });
    }
  }

  bool _hayNueva(InfoActualizacion info) =>
      info.hayNueva(_codigoInstalado) ||
      info.hayNuevaVersion(_versionInstaladaNombre);

  // =========================================================================
  // FLUJO DE ACTUALIZACIÓN
  // =========================================================================

  Future<void> _iniciarActualizacion() async {
    final info = _disponible;
    if (info == null || _descargando) return;

    // 1) Validación de caja cerrada (regla de negocio bloqueante).
    final caja = ref.read(cajaProvider);
    if (caja.isCajaAbierta) {
      await _mostrarBloqueoCaja();
      return;
    }

    // 2) Autorización por ID de dispositivo (hardware binding).
    final idIngresado = await _pedirDispositivoId();
    if (idIngresado == null || !mounted) return;
    final idReal = ref.read(licenciaProvider).dispositivoId;
    if (!DispositivoId.esValido(idIngresado) || idIngresado != idReal) {
      await _mostrarBloqueoId();
      return;
    }

    // 3) Respaldo automático de la base SQLite.
    final respaldoOk = await _realizarRespaldo();
    if (!respaldoOk || !mounted) return;

    // 4) Descarga e instalación con progreso.
    await _descargarEInstalar(info);
  }

  Future<void> _mostrarBloqueoCaja() async {
    final cerrar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        icon: const Icon(Icons.lock_outline, color: AppPaletaOficial.rojo),
        title: const Text('Turno de caja abierto'),
        content: const Text(
          'No es posible actualizar la aplicación mientras haya un turno '
          'de caja abierto. Puede cerrar la caja ahora (confirmará con su '
          'PIN) y continuar con la actualización, o cerrarla más tarde '
          'desde Configuración > Cierres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Más tarde'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar caja ahora'),
          ),
        ],
      ),
    );
    if (cerrar != true || !mounted) return;
    await _cerrarCajaParaActualizar();
  }

  /// Cierra la caja (misma convención del módulo Cierres §3.3.4: confirmación
  /// + PIN obligatorio) y, si se logra, reanuda el flujo de actualización.
  Future<void> _cerrarCajaParaActualizar() async {
    final estado = ref.read(cajaProvider);
    final saldoTeorico = estado.saldoActual;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        title: const Text('Confirmar cierre de Caja'),
        content: Text(
          'Saldo teórico final: '
          '${CurrencyFormatter.formatValue(saldoTeorico)}\n\n'
          'Cerrar la caja permite continuar con la actualización. '
          'Esta acción requiere PIN de seguridad.',
          style: const TextStyle(color: AppPaletaOficial.negro),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar Caja'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final pinValido = await showPinValidationDialog(
      context,
      onValidate: (pin) =>
          ref.read(controlInicioProvider.notifier).validarPinOperativo(pin),
    );
    if (!pinValido || !mounted) return;

    try {
      await ref
          .read(cajaProvider.notifier)
          .cerrarCaja(operador: _operadorActual);
      if (!mounted) return;
      Notificaciones.exito(context, 'Caja cerrada. Ahora puede actualizar.');
      // La caja ya está cerrada: reanuda el flujo de actualización.
      _iniciarActualizacion();
    } on CajaNoAbiertaException {
      if (!mounted) return;
      Notificaciones.error(context, 'La caja ya se encontraba cerrada.');
    } catch (_) {
      if (!mounted) return;
      Notificaciones.error(context, 'No fue posible cerrar la caja.');
    }
  }

  Future<String?> _pedirDispositivoId() {
    _idController.clear();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        title: const Text('Autorización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingrese el ID de este dispositivo (4 caracteres) para '
              'autorizar la actualización.',
              style: TextStyle(fontSize: AppEscalaTipografica.notas),
            ),
            const SizedBox(height: AppEspaciado.m),
            TextField(
              controller: _idController,
              maxLength: DispositivoId.longitud,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9A-Za-z]')),
                LengthLimitingTextInputFormatter(DispositivoId.longitud),
              ],
              style: const TextStyle(
                letterSpacing: 6,
                fontSize: AppEscalaTipografica.titulo,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Ej: 7K5E',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (v) => Navigator.of(ctx).pop(v.trim().toUpperCase()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_idController.text.trim().toUpperCase()),
            child: const Text('Autorizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarBloqueoId() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        icon: const Icon(Icons.gpp_bad_outlined, color: AppPaletaOficial.rojo),
        title: const Text('ID no válido'),
        content: const Text(
          'El ID ingresado no corresponde a este dispositivo o no cumple '
          'el formato (letras y números seguros, sin 0, 1, I u O). '
          'La actualización fue cancelada.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<bool> _realizarRespaldo() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        backgroundColor: AppPaletaOficial.blanco,
        content: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
            SizedBox(width: AppEspaciado.m),
            Expanded(child: Text('Creando respaldo de la base de datos…')),
          ],
        ),
      ),
    );
    try {
      final ruta = await _servicio.crearRespaldo();
      if (!mounted) return false;
      Navigator.of(context, rootNavigator: true).pop();
      Notificaciones.exito(
        context,
        'Respaldo creado: ${p.basename(ruta)}',
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      Navigator.of(context, rootNavigator: true).pop();
      Notificaciones.error(context, 'No se pudo crear el respaldo: $e');
      return false;
    }
  }

  Future<void> _descargarEInstalar(InfoActualizacion info) async {
    setState(() {
      _descargando = true;
      _progreso = 0;
      _mensajeDescarga = 'Conectando con el servidor…';
    });
    _subDescarga = _servicio
        .descargarEInstalar(info.apkUrl)
        .listen(_onEventoOta, onError: (Object e) {
      if (!mounted) return;
      setState(() {
        _descargando = false;
        _mensajeDescarga = '';
      });
      Notificaciones.error(context, 'Error al descargar: $e');
    });
  }

  void _onEventoOta(OtaEvent evento) {
    if (!mounted) return;
    switch (evento.status) {
      case OtaStatus.DOWNLOADING:
        final pct = double.tryParse(evento.value ?? '0') ?? 0;
        setState(() {
          _progreso = pct;
          _mensajeDescarga = 'Descargando… ${pct.round()}%';
        });
      case OtaStatus.INSTALLING:
        setState(() => _mensajeDescarga = 'Instalando actualización…');
      case OtaStatus.INSTALLATION_DONE:
        setState(() {
          _descargando = false;
          _mensajeDescarga = 'Instalación completada';
        });
        Notificaciones.exito(context, 'Actualización instalada');
      case OtaStatus.ALREADY_RUNNING_ERROR:
        _abortarDescarga(
          'La descarga ya está en curso en otra sesión. Espere a que termine.',
        );
      case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
        _abortarDescarga(
          'Permiso de instalación no concedido. Active "Instalar apps '
          'desconocidas" para esta aplicación.',
        );
      case OtaStatus.INSTALLATION_ERROR:
        _abortarDescarga('No se pudo instalar el APK descargado.');
      case OtaStatus.DOWNLOAD_ERROR:
        _abortarDescarga('No se pudo descargar el APK. Revise la conexión.');
      case OtaStatus.CHECKSUM_ERROR:
        _abortarDescarga('La verificación del APK falló. Intente nuevamente.');
      case OtaStatus.CANCELED:
        _abortarDescarga('Descarga cancelada.');
      case OtaStatus.INTERNAL_ERROR:
        _abortarDescarga(
          'Error interno durante la descarga: ${evento.value ?? ''}',
        );
    }
  }

  void _abortarDescarga(String motivo) {
    if (!mounted) return;
    setState(() {
      _descargando = false;
      _progreso = 0;
      _mensajeDescarga = '';
    });
    Notificaciones.error(context, motivo);
  }

  // =========================================================================
  // UI
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final estadoCaja = ref.watch(cajaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        children: [
          _buildTarjetaVersion(),
          const SizedBox(height: AppEspaciado.m),
          _buildBotonBuscar(),
          if (_buscando) ...[
            const SizedBox(height: AppEspaciado.m),
            const Padding(
              padding: EdgeInsets.all(AppEspaciado.s),
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (_errorBusqueda != null) ...[
            const SizedBox(height: AppEspaciado.m),
            Card(
              elevation: 0,
              color: AppPaletaOficial.blanco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
                side: const BorderSide(color: AppPaletaOficial.rojo),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppEspaciado.m),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppPaletaOficial.rojo),
                    const SizedBox(width: AppEspaciado.s),
                    Expanded(
                      child: Text(
                        _errorBusqueda!,
                        style: const TextStyle(
                          fontSize: AppEscalaTipografica.notas,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_disponible != null && !_descargando) ...[
            const SizedBox(height: AppEspaciado.m),
            _buildTarjetaNuevaVersion(_disponible!, estadoCaja),
          ],
          if (_descargando) ...[
            const SizedBox(height: AppEspaciado.l),
            _buildProgresoDescarga(),
          ],
        ],
      ),
    );
  }

  Widget _buildTarjetaVersion() {
    return Card(
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
                Icon(Icons.system_update_alt, color: AppPaletaOficial.cafe),
                SizedBox(width: AppEspaciado.s),
                Text(
                  'Versión Actual',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.subtitulo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              _versionInstalada,
              style: const TextStyle(fontSize: AppEscalaTipografica.notas),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonBuscar() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: (_buscando || _descargando) ? null : _buscarActualizacion,
        icon: const Icon(Icons.search),
        label: Text(_buscando ? 'Buscando…' : 'Buscar Actualizaciones'),
      ),
    );
  }

  Widget _buildTarjetaNuevaVersion(
    InfoActualizacion info,
    CajaEstado estadoCaja,
  ) {
    final hayNueva = _hayNueva(info);
    final etiquetaVersion =
        info.versionNombre.trim().isEmpty ? 'v${info.versionCodigo}' : info.versionNombre.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hayNueva)
          Card(
            elevation: 0,
            color: AppPaletaOficial.cafe,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppEspaciado.m,
                vertical: AppEspaciado.s,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10, color: AppPaletaOficial.verde),
                  SizedBox(width: AppEspaciado.s),
                  Text(
                    'Nueva versión disponible',
                    style: TextStyle(
                      color: AppPaletaOficial.blanco,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppEspaciado.s),
        Card(
          elevation: 0,
          color: AppPaletaOficial.blanco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
            side: BorderSide(
              color: hayNueva
                  ? info.esCritica
                      ? AppPaletaOficial.rojo
                      : AppPaletaOficial.cafe
                  : const Color(0xFFE0D8D0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppEspaciado.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.system_update_alt,
                        color: AppPaletaOficial.cafe),
                    const SizedBox(width: AppEspaciado.s),
                    Expanded(
                      child: Text(
                        hayNueva
                            ? 'Actualización $etiquetaVersion disponible'
                            : 'Estás al día ($etiquetaVersion)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (info.esCritica) ...[
                  const SizedBox(height: AppEspaciado.s),
                  const Row(
                    children: [
                      Icon(Icons.warning_amber,
                          size: 18, color: AppPaletaOficial.rojo),
                      SizedBox(width: AppEspaciado.s),
                      Expanded(
                        child: Text(
                          'Actualización crítica: corrija la aplicación '
                          'lo antes posible.',
                          style: TextStyle(
                            fontSize: AppEscalaTipografica.notas,
                            color: AppPaletaOficial.rojo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (info.cambios.trim().isNotEmpty) ...[
                  const SizedBox(height: AppEspaciado.m),
                  const Text(
                    'Notas de la versión',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.notas,
                    ),
                  ),
                  const SizedBox(height: AppEspaciado.s),
                  Text(
                    info.cambios,
                    style: const TextStyle(
                      fontSize: AppEscalaTipografica.notas,
                    ),
                  ),
                ],
                const SizedBox(height: AppEspaciado.m),
                Row(
                  children: [
                    if (estadoCaja.isCajaAbierta)
                      const Tooltip(
                        message: 'Cierre la caja antes de actualizar',
                        child: Icon(
                          Icons.lock_outline,
                          color: AppPaletaOficial.rojo,
                        ),
                      ),
                    const SizedBox(width: AppEspaciado.s),
                    const Expanded(
                      child: Text(
                        'Requisitos: caja cerrada · ID del dispositivo · '
                        'respaldo automático',
                        style: TextStyle(fontSize: AppEscalaTipografica.notas),
                      ),
                    ),
                  ],
                ),
                if (hayNueva) ...[
                  const SizedBox(height: AppEspaciado.m),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _iniciarActualizacion,
                      icon: const Icon(Icons.download),
                      label: const Text('Actualizar Ahora'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgresoDescarga() {
    return Card(
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
            Row(
              children: [
                const Icon(Icons.downloading, color: AppPaletaOficial.cafe),
                const SizedBox(width: AppEspaciado.s),
                Expanded(
                  child: Text(
                    _mensajeDescarga,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.m),
            LinearProgressIndicator(
              value: _progreso >= 0 ? _progreso / 100 : null,
              minHeight: 8,
              borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              '${_progreso.round()}%',
              style: const TextStyle(
                fontSize: AppEscalaTipografica.notas,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}