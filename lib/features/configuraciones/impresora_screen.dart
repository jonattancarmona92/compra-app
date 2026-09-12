// ==================== ARCHIVO: lib/features/configuraciones/impresora_screen.dart ====================
// Impresora — Informe Global §3.6. Configura la impresora térmica
// Bluetooth (POS y TSL): escaneo, conexión, copias, corte y logo.
import 'dart:async';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'configuraciones_provider.dart';
import 'impresora_bluetooth_servicio.dart';

class ImpresoraScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const ImpresoraScreen({super.key, required this.onBack});

  @override
  ConsumerState<ImpresoraScreen> createState() => _ImpresoraScreenState();
}

class _ImpresoraScreenState extends ConsumerState<ImpresoraScreen> {
  final ImpresoraBluetoothServicio _servicio =
      ImpresoraBluetoothServicio.instancia;

  final List<BluetoothDevice> _dispositivos = [];
  final List<BluetoothDevice> _vinculados = [];
  final List<StreamSubscription<dynamic>> _suscripciones = [];

  bool _escaneando = false;
  bool _conectando = false;
  bool _avisoEscaneoMostrado = false;
  bool _bluetoothActivo = true;
  bool _cargandoVinculados = false;
  bool _desconexionManual = false;
  ConnectState _estadoConexion = ConnectState.disconnected;
  Timer? _vigiaEscaneo;
  Timer? _vigiaConexion;
  BluetoothDevice? _dispositivoEnConexion;
  int _pasosSonda = 0;

  /// Reintentos automáticos de conexión: en Xiaomi/MIUI el primer intento
  /// de socket SPP suele caerse (el adaptador se apaga/enciende solo);
  /// el segundo o tercero se establecen. Total de intentos = 1 + este valor.
  static const int _maxReintentosConexion = 2;
  int _reintentoConexion = 0;
  bool _falloEnProceso = false;

  @override
  void initState() {
    super.initState();
    _estadoConexion = _servicio.estaConectado
        ? ConnectState.connected
        : ConnectState.disconnected;
    _suscripciones.add(_servicio.resultados.listen((dispositivos) {
      if (!mounted) return;
      setState(() {
        _dispositivos
          ..clear()
          ..addAll(dispositivos);
      });
    }, onError: (_) {
      // §6.x: un error del stream del plugin no debe tumbar la app.
      if (!mounted) return;
      _finalizarEscaneo();
    }));
    _suscripciones.add(_servicio.escaneando.listen((escaneando) {
      if (!mounted) return;
      setState(() => _escaneando = escaneando);
      if (!escaneando && !_conectando) {
        _finalizarEscaneo();
      }
    }, onError: (_) {
      if (!mounted) return;
      _finalizarEscaneo();
    }));
    _suscripciones.add(
      _servicio.estadoConexion.listen(
        _alCambiarConexion,
        onError: (_) {},
      ),
    );
    _suscripciones.add(_servicio.estadoBluetooth.listen((estado) {
      if (!mounted) return;
      setState(() => _bluetoothActivo = estado == BlueState.blueOn);
    }, onError: (_) {}));
    // Prima el estado real del adaptador y activa el canal de eventos para
    // que el indicador reaccione a cambios de encendido/apagado del
    // Bluetooth, incluso antes de escanear.
    _servicio.consultarEstadoBluetooth().then((activo) {
      if (!mounted) return;
      setState(() => _bluetoothActivo = activo);
    });
    // El socket real es la fuente veraz: si ya hay un puerto abierto (la
    // impresora quedó conectada a nivel de sistema), la app muestra
    // "En línea" aunque el evento `connected` se haya perdido al arrancar.
    _servicio.estaConectadoReal().then((conectado) {
      if (!mounted || !conectado) return;
      setState(() => _estadoConexion = ConnectState.connected);
      final impresora = ref.read(configuracionesProvider).impresora;
      if (impresora.direccionBluetooth.isNotEmpty && !impresora.enlinea) {
        ref
            .read(configuracionesProvider.notifier)
            .guardarImpresora(impresora.copyWith(enlinea: true));
      }
    });
    _cargarVinculados();
    // Si ya se guardó una impresora en una sesión anterior, se intenta
    // reconectar en silencio sin volver a escanear.
    _reconectarGuardada();
  }

  @override
  void dispose() {
    _vigiaEscaneo?.cancel();
    _vigiaConexion?.cancel();
    for (final suscripcion in _suscripciones) {
      suscripcion.cancel();
    }
    super.dispose();
  }

  void _alCambiarConexion(ConnectState estado) {
    _vigiaConexion?.cancel();
    if (!mounted) return;
    final huboIntento = _conectando && !_desconexionManual;
    setState(() {
      _estadoConexion = estado;
      _conectando = false;
      _desconexionManual = false;
    });
    if (huboIntento && estado == ConnectState.disconnected) {
      final dispositivo = _dispositivoEnConexion;
      if (dispositivo != null) {
        final impresora = ref.read(configuracionesProvider).impresora;
        // Sigue el mismo cauce que un timeout: reintenta (Xiaomi) o informa.
        _decidirTrasFallo(dispositivo, impresora);
      }
    }
    if (estado == ConnectState.connected) {
      _reintentoConexion = 0;
      _falloEnProceso = false;
      _dispositivoEnConexion = null;
    }
    final impresora = ref.read(configuracionesProvider).impresora;
    ref
        .read(configuracionesProvider.notifier)
        .guardarImpresora(
          impresora.copyWith(enlinea: estado == ConnectState.connected),
        );
  }

  Future<void> _escanear() async {
    // §3.6: sin los permisos runtime el plugin lanza una
    // SecurityException nativa y cierra la app (java.lang.*), y si el
    // plugin intentara pedirlos por su cuenta, el crash conocido por
    // `MethodChannel.Result` nulo. Por eso se solicitan y re-verifican
    // antes de tocar el adaptador Bluetooth.
    final permisosOk = await _servicio.solicitarPermisosBluetooth();
    if (!mounted) return;
    if (!permisosOk) {
      Notificaciones.advertencia(
        context,
        'Sin los permisos de Bluetooth no se puede buscar impresoras. '
        'Permite el acceso en los ajustes de la app e inténtalo de nuevo.',
      );
      return;
    }
    final bluetoothOk = await _servicio.consultarEstadoBluetooth();
    if (!mounted) return;
    if (!bluetoothOk) {
      Notificaciones.advertencia(
        context,
        'El Bluetooth está apagado. Actívalo en los ajustes del teléfono y '
        'presiona Escanear de nuevo.',
      );
      return;
    }
    setState(() {
      _dispositivos.clear();
      _avisoEscaneoMostrado = false;
      _escaneando = true;
    });
    // Vigía: si el plugin no reporta el fin del escaneo (por ejemplo cuando
    // el Bluetooth está apagado o el sistema no permite la búsqueda), se
    // corta el "Buscando..." y se informa al usuario.
    _vigiaEscaneo?.cancel();
    _vigiaEscaneo = Timer(const Duration(seconds: 15), () {
      _finalizarEscaneo();
    });
    final inicioOk = await _servicio.iniciarEscaneo();
    if (!mounted) return;
    if (!inicioOk) {
      _finalizarEscaneo();
      Notificaciones.error(
        context,
        'No se pudo iniciar la búsqueda. Verifica el Bluetooth de tu '
        'dispositivo e inténtalo de nuevo. En algunos Xiaomi/MIUI, activa '
        'también los servicios de ubicación del sistema.',
      );
    }
  }

  Future<void> _detenerEscaneo() async {
    _vigiaEscaneo?.cancel();
    await _servicio.detenerEscaneo();
  }

  void _finalizarEscaneo() {
    _vigiaEscaneo?.cancel();
    if (!mounted) return;
    setState(() => _escaneando = false);
    if (_dispositivos.isEmpty && !_avisoEscaneoMostrado) {
      _avisoEscaneoMostrado = true;
      Notificaciones.advertencia(
        context,
        'No se encontraron impresoras. Verifica que el Bluetooth esté activo '
        'y que la impresora esté encendida y en modo emparejamiento '
        '(parpadeando).',
      );
    }
  }

  Future<void> _conectar(
    BluetoothDevice dispositivo,
    ConfigImpresora impresora,
  ) async {
    _dispositivoEnConexion = dispositivo;
    _reintentoConexion = 0;
    _falloEnProceso = false;
    await _iniciarConexion(dispositivo, impresora);
  }

  Future<void> _iniciarConexion(
    BluetoothDevice dispositivo,
    ConfigImpresora impresora,
  ) async {
    _desconexionManual = false;
    _falloEnProceso = false;
    _pasosSonda = 0;
    if (!mounted) return;
    setState(() => _conectando = true);
    _iniciarSondaConexion(dispositivo, impresora);
    final inicioOk = await _servicio.conectar(dispositivo);
    if (!mounted) return;
    if (!inicioOk) {
      _vigiaConexion?.cancel();
      setState(() => _conectando = false);
      _decidirTrasFallo(dispositivo, impresora);
      return;
    }
    ref
        .read(configuracionesProvider.notifier)
        .guardarImpresora(
          impresora.copyWith(
            nombre: dispositivo.name.isEmpty
                ? dispositivo.address
                : dispositivo.name,
            direccionBluetooth: dispositivo.address,
            enlinea: true,
          ),
        );
  }

  /// Vigía + sonda del socket real. El plugin avisa "conectado" con un
  /// evento que en algunos equipos no llega a la app (canal de estado sin
  /// suscriptores o firmware que no emite `onSuccess`). Para no depender de
  /// ese evento, se pregunta al lado nativo cada medio segundo si el puerto
  /// SPP está abierto: si lo está, la impresora está operativa. Si el socket
  /// cuelga (habitual en Xiaomi/MIUI), el fin del conteo se reencauza por
  /// [_decidirTrasFallo] en vez de dejarlo trabado en "Conectando...".
  void _iniciarSondaConexion(
    BluetoothDevice dispositivo,
    ConfigImpresora impresora,
  ) {
    _vigiaConexion?.cancel();
    _vigiaConexion = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final conectado = await _servicio.estaConectadoReal();
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (conectado) {
        timer.cancel();
        if (_conectando) {
          _alCambiarConexion(ConnectState.connected);
        }
        return;
      }
      _pasosSonda++;
      // 40 pasos x 500 ms = 20 s, mismo límite que el antiguo vigía.
      if (_pasosSonda >= 40) {
        timer.cancel();
        if (!mounted || !_conectando || _falloEnProceso) return;
        setState(() => _conectando = false);
        _decidirTrasFallo(dispositivo, impresora);
      }
    });
  }

  /// Decide tras un intento fallido: reintenta (el adaptador de los
  /// Xiaomi se estabiliza en el 2.º o 3.º intento) o muestra la orientación
  /// final para la impresora térmica.
  void _decidirTrasFallo(
    BluetoothDevice dispositivo,
    ConfigImpresora impresora,
  ) {
    if (_falloEnProceso) return;
    _falloEnProceso = true;
    if (_reintentoConexion < _maxReintentosConexion) {
      _reintentoConexion++;
      // Espaciado amplio: en los Xiaomi el adaptador necesita estabilizarse
      // tras un socket colgado en INIT; reintentar a los 1,2 s se pisaba
      // a sí mismo.
      Future<void>.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        _iniciarConexion(dispositivo, impresora);
      });
      return;
    }
    _reintentoConexion = 0;
    _falloEnProceso = false;
    Notificaciones.advertencia(
      context,
      'No se pudo conectar con ${dispositivo.name}. Verifica que esté '
      'encendida y cargada, que la luz ya no esté parpadeando (si parpadea, '
      'apágala y enciéndela) y que no esté conectada a otro teléfono. Si '
      'pide código de vinculación, usa 0000.',
    );
  }

  /// Antes de conectar a un dispositivo del escaneo (que puede no estar
  /// vinculado aún) se anticipa el diálogo de emparejamiento del sistema:
  /// la PT-210 pide PIN 0000 y el usuario debe saberlo antes de que aparezca.
  Future<void> _conectarConGuia(
    BluetoothDevice dispositivo,
    ConfigImpresora impresora,
  ) async {
    final yaVinculado =
        _vinculados.any((d) => d.address == dispositivo.address);
    if (yaVinculado) {
      await _conectar(dispositivo, impresora);
      return;
    }
    final continuar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vincular impresora'),
        content: const Text(
          'Al conectar, el teléfono pedirá un código de vinculación.\n\n'
          'Ingresa el código 0000.\n\n'
          'Verifica que la impresora esté encendida, cargada y cerca.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
    if (continuar != true || !mounted) return;
    await _conectar(dispositivo, impresora);
  }

  Future<void> _desconectar() async {
    _desconexionManual = true;
    setState(() => _conectando = true);
    await _servicio.desconectar();
  }

  /// Reintenta en silencio la conexión a la impresora guardada al abrir la
  /// pantalla, sin escanear ni mostrar diálogos: la impresora fija se usa
  /// siempre en el mismo local. Un fallo solo deja la impresora
  /// "Desconectada", que es el estado correcto si está apagada.
  Future<void> _reconectarGuardada() async {
    final impresora = ref.read(configuracionesProvider).impresora;
    if (impresora.direccionBluetooth.isEmpty || impresora.enlinea) return;
    if (!await _servicio.permisosBluetoothConcedidos()) return;
    if (!_bluetoothActivo) return;
    // Si el socket ya está abierto a nivel nativo no se reconecta (eso
    // cerraría y volvería a abrir el puerto): solo se refleja el estado real
    // en la interfaz y se guarda la impresora como en línea.
    if (await _servicio.estaConectadoReal()) {
      if (!mounted) return;
      setState(() => _estadoConexion = ConnectState.connected);
      ref
          .read(configuracionesProvider.notifier)
          .guardarImpresora(impresora.copyWith(enlinea: true));
      return;
    }
    final dispositivo = BluetoothDevice(
      impresora.nombre.isEmpty
          ? impresora.direccionBluetooth
          : impresora.nombre,
      impresora.direccionBluetooth,
    );
    await _servicio.conectar(dispositivo);
    // Tras conectar se sondea el socket real unos segundos: el evento
    // `connected` puede no llegar a la app, pero si el puerto quedó abierto
    // la impresora está lista y debe verse "En línea".
    for (int i = 0; i < 10; i++) {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (await _servicio.estaConectadoReal()) {
        if (!mounted) return;
        setState(() => _estadoConexion = ConnectState.connected);
        ref
            .read(configuracionesProvider.notifier)
            .guardarImpresora(
              impresora.copyWith(enlinea: true),
            );
        return;
      }
    }
  }

  /// Carga los dispositivos ya vinculados con el teléfono. Si faltan
  /// permisos los solicita en ese momento (o a petición del usuario).
  Future<void> _cargarVinculados({bool pedirPermisos = false}) async {
    if (!await _servicio.permisosBluetoothConcedidos() || pedirPermisos) {
      final permisosOk = await _servicio.solicitarPermisosBluetooth();
      if (!mounted) return;
      if (!permisosOk) {
        setState(() {
          _cargandoVinculados = false;
          _vinculados.clear();
        });
        Notificaciones.advertencia(
          context,
          'Sin los permisos de Bluetooth no se pueden ver los dispositivos '
          'vinculados.',
        );
        _servicio.abrirAjustesApp();
        return;
      }
    }
    setState(() => _cargandoVinculados = true);
    final vinculados = await _servicio.obtenerDispositivosVinculados();
    if (!mounted) return;
    setState(() {
      _vinculados
        ..clear()
        ..addAll(vinculados);
      _cargandoVinculados = false;
    });
  }

  /// Elimina (desvincula) un dispositivo del listado del teléfono.
  Future<void> _eliminarVinculado(
    BluetoothDevice dispositivo,
    ConfigImpresora impresora,
  ) async {
    setState(() => _cargandoVinculados = true);
    final ok = await _servicio.eliminarDispositivoVinculado(dispositivo);
    if (!mounted) return;
    setState(() {
      _vinculados.removeWhere(
        (d) => d.address == dispositivo.address,
      );
      _cargandoVinculados = false;
    });
    final nombre =
        dispositivo.name.isEmpty ? dispositivo.address : dispositivo.name;
    if (ok) {
      if (impresora.direccionBluetooth == dispositivo.address &&
          _estadoConexion == ConnectState.connected) {
        await _servicio.desconectar();
        if (!mounted) return;
        ref
            .read(configuracionesProvider.notifier)
            .guardarImpresora(impresora.copyWith(
              enlinea: false,
              direccionBluetooth: '',
            ));
      }
      Notificaciones.exito(
        context,
        '$nombre se eliminó de los dispositivos vinculados.',
      );
    } else {
      Notificaciones.error(
        context,
        'No se pudo eliminar $nombre. Verifica los permisos de Bluetooth e '
        'inténtalo de nuevo.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final impresora = ref.watch(configuracionesProvider).impresora;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impresora'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        children: [
          _buildCardImpresora(impresora),
          const SizedBox(height: AppEspaciado.m),
          _buildBotonPrueba(impresora),
          const SizedBox(height: AppEspaciado.l),
          const Text(
            'Formato de impresión',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppEscalaTipografica.subtitulo,
            ),
          ),
          const SizedBox(height: AppEspaciado.m),
          _buildSelectorFormato(impresora),
          const SizedBox(height: AppEspaciado.l),
          _buildEncabezadoVinculados(),
          const SizedBox(height: AppEspaciado.s),
          _buildListaVinculados(impresora),
          const SizedBox(height: AppEspaciado.l),
          _buildEncabezadoDispositivos(),
          const SizedBox(height: AppEspaciado.s),
          _buildListaDispositivos(impresora),
          const SizedBox(height: AppEspaciado.l),
          const Text(
            'Opciones de impresión',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppEscalaTipografica.subtitulo,
            ),
          ),
          const SizedBox(height: AppEspaciado.m),
          Row(
            children: [
              const Text('Copias por defecto'),
              const Spacer(),
              DropdownButton<int>(
                value: impresora.copias,
                items: [1, 2, 3]
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c,
                        child: Text('$c'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    ref
                        .read(configuracionesProvider.notifier)
                        .guardarImpresora(impresora.copyWith(copias: v));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardImpresora(ConfigImpresora impresora) {
    final Color colorEstado;
    final String textoEstado;
    if (_conectando) {
      colorEstado = AppPaletaOficial.amarillo;
      textoEstado = 'Conectando...';
    } else if (_estadoConexion == ConnectState.connected) {
      colorEstado = AppPaletaOficial.verde;
      textoEstado = 'En línea';
    } else {
      colorEstado = AppPaletaOficial.rojo;
      textoEstado = 'Desconectada';
    }

    return Card(
      elevation: 0,
      color: AppDiseno.superficie(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: BorderSide(color: AppDiseno.bordeTarjeta(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Row(
          children: [
            const Icon(Icons.print, size: 40, color: AppPaletaOficial.cafe),
            const SizedBox(width: AppEspaciado.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    impresora.nombre.isEmpty
                        ? 'Impresora Térmica (Bluetooth)'
                        : impresora.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.cuerpo,
                    ),
                  ),
                  const SizedBox(height: AppEspaciado.xs),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          size: 10, color: colorEstado),
                      const SizedBox(width: AppEspaciado.s),
                      Text(
                        textoEstado,
                        style: TextStyle(
                          color: colorEstado,
                          fontSize: AppEscalaTipografica.secundario,
                        ),
                      ),
                    ],
                  ),
                  if (impresora.direccionBluetooth.isNotEmpty) ...[
                    const SizedBox(height: AppEspaciado.xs),
                    Text(
                      impresora.direccionBluetooth,
                      style: TextStyle(
                        fontSize: AppEscalaTipografica.notas,
                        color: AppDiseno.textoSecundario(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonPrueba(ConfigImpresora impresora) {
    final conectada =
        impresora.enlinea && _estadoConexion == ConnectState.connected;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: conectada && !_conectando ? _imprimirPrueba : null,
        icon: const Icon(Icons.local_printshop_outlined),
        label: Text(
          conectada
              ? 'Imprimir prueba'
              : 'Imprimir prueba (conecta una impresora)',
        ),
      ),
    );
  }

  Future<void> _imprimirPrueba() async {
    final estado = ref.read(configuracionesProvider);
    final impresora = estado.impresora;
    final ok = await _servicio.imprimirPrueba(
      copias: impresora.copias,
      cortarPapel: impresora.cortarPapel,
      razonSocial: estado.factura.razonSocial,
      mensajePie: estado.factura.mensajePie,
    );
    if (!mounted) return;
    if (ok) {
      Notificaciones.exito(context, 'Impresión de prueba enviada.');
    } else {
      Notificaciones.error(
        context,
        'No se pudo imprimir. Verifica la conexión con la impresora '
        '(${impresora.nombre}).',
      );
    }
  }

  Widget _buildSelectorFormato(ConfigImpresora impresora) {
    return Row(
      children: [
        Expanded(
          child: _buildTarjetaFormato(
            titulo: 'POS',
            subtitulo: 'Tickets térmicos',
            formato: FormatoImpresion.pos,
            impresora: impresora,
          ),
        ),
        const SizedBox(width: AppEspaciado.m),
        Expanded(
          child: _buildTarjetaFormato(
            titulo: 'TSL',
            subtitulo: 'Etiquetas',
            formato: FormatoImpresion.tsl,
            impresora: impresora,
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaFormato({
    required String titulo,
    required String subtitulo,
    required FormatoImpresion formato,
    required ConfigImpresora impresora,
  }) {
    final seleccionado = impresora.formato == formato;
    return InkWell(
      onTap: () => ref
          .read(configuracionesProvider.notifier)
          .guardarImpresora(impresora.copyWith(formato: formato)),
      borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      child: Ink(
        padding: const EdgeInsets.all(AppEspaciado.m),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppPaletaOficial.cafe
              : AppDiseno.superficie(context),
          borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
          border: Border.all(
            color: seleccionado
                ? AppPaletaOficial.cafe
                : AppDiseno.bordeTarjeta(context),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppEscalaTipografica.cuerpo,
                color: seleccionado
                    ? AppPaletaOficial.blanco
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppEspaciado.xs),
            Text(
              subtitulo,
              style: TextStyle(
                fontSize: AppEscalaTipografica.notas,
                color: seleccionado
                    ? const Color(0x99FFFFFF)
                    : AppDiseno.textoSecundario(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezadoVinculados() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Dispositivos vinculados',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppEscalaTipografica.subtitulo,
            ),
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('Actualizar'),
          onPressed: _cargandoVinculados
              ? null
              : () => _cargarVinculados(pedirPermisos: true),
        ),
      ],
    );
  }

  Widget _buildListaVinculados(ConfigImpresora impresora) {
    if (_cargandoVinculados) {
      return Card(
        elevation: 0,
        color: AppDiseno.superficie(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
          side: BorderSide(
            color: AppDiseno.bordeTarjeta(context),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppEspaciado.m),
          child: Text(
            'Consultando dispositivos vinculados...',
            style: TextStyle(fontSize: AppEscalaTipografica.secundario),
          ),
        ),
      );
    }
    if (_vinculados.isEmpty) {
      return Card(
        elevation: 0,
        color: AppDiseno.superficie(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
          side: BorderSide(
            color: AppDiseno.bordeTarjeta(context),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppEspaciado.m),
          child: Text(
            'Sin dispositivos vinculados. Vincula tu impresora con el '
            'teléfono o búscala en la sección de abajo.',
            style: TextStyle(fontSize: AppEscalaTipografica.secundario),
          ),
        ),
      );
    }
    return Card(
      elevation: 0,
      color: AppDiseno.superficie(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: BorderSide(color: AppDiseno.bordeTarjeta(context)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _vinculados.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _buildFilaVinculado(_vinculados[i], impresora),
          ],
        ],
      ),
    );
  }

  Widget _buildFilaVinculado(
    BluetoothDevice dispositivo,
    ConfigImpresora impresora,
  ) {
    final nombre = dispositivo.name.isEmpty
        ? dispositivo.address
        : dispositivo.name;
    final esActual =
        impresora.direccionBluetooth == dispositivo.address &&
        _estadoConexion == ConnectState.connected;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppEspaciado.m,
        vertical: AppEspaciado.xs,
      ),
      leading: Icon(
        Icons.bluetooth,
        color: esActual ? AppPaletaOficial.verde : AppPaletaOficial.cafe,
      ),
      title: Text(
        nombre,
        style: const TextStyle(fontSize: AppEscalaTipografica.cuerpo),
      ),
      subtitle: Text(
        dispositivo.address,
        style: TextStyle(
          fontSize: AppEscalaTipografica.notas,
          color: AppDiseno.textoSecundario(context),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppPaletaOficial.rojo),
            tooltip: 'Eliminar',
            onPressed: _cargandoVinculados
                ? null
                : () => _eliminarVinculado(dispositivo, impresora),
          ),
          if (esActual)
            TextButton(
              onPressed: _conectando ? null : _desconectar,
              child: const Text('Desconectar'),
            )
          else
            OutlinedButton(
              onPressed: (_escaneando || _conectando || !_bluetoothActivo)
                  ? null
                  : () => _conectar(dispositivo, impresora),
              child: const Text('Conectar'),
            ),
        ],
      ),
    );
  }

  Widget _buildEncabezadoDispositivos() {
    final Color colorBluetooth =
        _bluetoothActivo ? AppPaletaOficial.verde : AppPaletaOficial.rojo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Dispositivos Bluetooth',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppEscalaTipografica.subtitulo,
              ),
            ),
            const Spacer(),
            if (_escaneando)
              TextButton.icon(
                icon: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppPaletaOficial.cafe,
                  ),
                ),
                label: const Text('Detener'),
                onPressed: _detenerEscaneo,
              )
            else
              TextButton.icon(
                icon: const Icon(Icons.bluetooth_searching),
                label: const Text('Escanear'),
                onPressed: _escanear,
              ),
          ],
        ),
        const SizedBox(height: AppEspaciado.xs),
        Row(
          children: [
            Icon(
              _bluetoothActivo ? Icons.bluetooth : Icons.bluetooth_disabled,
              size: 16,
              color: colorBluetooth,
            ),
            const SizedBox(width: AppEspaciado.s),
            Expanded(
              child: Text(
                _bluetoothActivo
                    ? 'Bluetooth activo'
                    : 'Bluetooth apagado: toca Activar para encenderlo en '
                        'los ajustes del sistema',
                style: TextStyle(
                  fontSize: AppEscalaTipografica.notas,
                  color: colorBluetooth,
                ),
              ),
            ),
            if (!_bluetoothActivo)
              TextButton(
                onPressed: () async {
                  final ok = await _servicio.abrirAjustesBluetooth();
                  if (!ok && mounted) {
                    Notificaciones.error(
                      context,
                      'No se pudieron abrir los ajustes de Bluetooth.',
                    );
                  }
                },
                child: const Text('Activar'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildListaDispositivos(ConfigImpresora impresora) {
    if (_escaneando && _dispositivos.isEmpty) {
      return Card(
        elevation: 0,
        color: AppDiseno.superficie(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
          side: BorderSide(
            color: AppDiseno.bordeTarjeta(context),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppEspaciado.m),
          child: Text(
            'Buscando impresoras cercanas...',
            style: TextStyle(fontSize: AppEscalaTipografica.secundario),
          ),
        ),
      );
    }
    if (_dispositivos.isEmpty) {
      return Card(
        elevation: 0,
        color: AppDiseno.superficie(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
          side: BorderSide(
            color: AppDiseno.bordeTarjeta(context),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppEspaciado.m),
          child: Text(
            'Sin dispositivos. Presiona Escanear para buscar impresoras '
            'Bluetooth. Asegúrate de que la impresora esté encendida y en '
            'modo emparejamiento; en algunos Xiaomi/MIUI activa además los '
            'servicios de ubicación del sistema.',
            style: TextStyle(fontSize: AppEscalaTipografica.secundario),
          ),
        ),
      );
    }
    return Card(
      elevation: 0,
      color: AppDiseno.superficie(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: BorderSide(color: AppDiseno.bordeTarjeta(context)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _dispositivos.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _buildFilaDispositivo(_dispositivos[i], impresora),
          ],
        ],
      ),
    );
  }

  Widget _buildFilaDispositivo(
    BluetoothDevice dispositivo,
    ConfigImpresora impresora,
  ) {
    final nombre = dispositivo.name.isEmpty
        ? dispositivo.address
        : dispositivo.name;
    final esActual =
        impresora.direccionBluetooth == dispositivo.address &&
        _estadoConexion == ConnectState.connected;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppEspaciado.m,
        vertical: AppEspaciado.xs,
      ),
      leading: Icon(
        Icons.print,
        color: esActual ? AppPaletaOficial.verde : AppPaletaOficial.cafe,
      ),
      title: Text(
        nombre,
        style: const TextStyle(fontSize: AppEscalaTipografica.cuerpo),
      ),
      subtitle: Text(
        dispositivo.address,
        style: TextStyle(
          fontSize: AppEscalaTipografica.notas,
          color: AppDiseno.textoSecundario(context),
        ),
      ),
      trailing: esActual
          ? TextButton(
              onPressed: _conectando ? null : _desconectar,
              child: const Text('Desconectar'),
            )
          : OutlinedButton(
              onPressed: (_escaneando || _conectando || !_bluetoothActivo)
                  ? null
                  : () => _conectarConGuia(dispositivo, impresora),
              child: const Text('Conectar'),
            ),
    );
  }
}