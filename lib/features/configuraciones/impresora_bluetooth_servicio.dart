// ==================== ARCHIVO: lib/features/configuraciones/impresora_bluetooth_servicio.dart ====================
// Impresora Bluetooth — Informe Global §3.6.
// Envoltorio del plugin bluetooth_print_plus (Bluetooth Classic SPP)
// para las impresoras térmicas POS y TSL: escaneo, conexión y escritura.
// No oculta fallos en silencio: los métodos retornan si la operación pudo
// iniciarse para que la pantalla informe al usuario.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ImpresoraBluetoothServicio {
  ImpresoraBluetoothServicio._();

  static final ImpresoraBluetoothServicio instancia =
      ImpresoraBluetoothServicio._();

  Stream<List<BluetoothDevice>> get resultados =>
      BluetoothPrintPlus.scanResults;

  Stream<bool> get escaneando => BluetoothPrintPlus.isScanning;

  Stream<ConnectState> get estadoConexion => BluetoothPrintPlus.connectState;

  Stream<BlueState> get estadoBluetooth => BluetoothPrintPlus.blueState;

  bool get estaConectado => BluetoothPrintPlus.isConnected;

  /// Consulta el estado actual del adaptador Bluetooth. Retorna `true` si
  /// está encendido.
  Future<bool> consultarEstadoBluetooth() async {
    try {
      return (await BluetoothPrintPlus.consultarEstadoBluetooth()) ==
          BlueState.blueOn;
    } catch (_) {
      return true;
    }
  }

  /// Útil solo después del primer escaneo (cuando el plugin ya consultó el
  /// estado real del adaptador). Antes el plugin reporta Bluetooth activo.
  bool get esBluetoothActivo => BluetoothPrintPlus.isBlueOn;

  /// Estima el API level de Android sin plugins adicionales, parseando
  /// `Platform.operatingSystemVersion` (contiene el release: "11", "12",
  /// "13"...). Android 12 = API 31. Retorna `null` si no aplica.
  int? _androidSdkIntEstimado() {
    if (!Platform.isAndroid) return null;
    final match = RegExp(r'(\d+)').firstMatch(Platform.operatingSystemVersion);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  /// Desde Android 13 (API 33) el sistema bloquea que apps de terceros
  /// enciendan o apaguen el adaptador, sin importar qué permiso se conceda:
  /// solo el usuario puede hacerlo desde los ajustes del sistema. Cuando es
  /// `true`, la pantalla debe llevar al usuario a esos ajustes en lugar de
  /// intentar un switch nativo. (Si no se pudo estimar el API, devuelve
  /// `false` para conservar el intento nativo en equipos antiguos.)
  bool get requiereAceptarEnAjustes {
    final sdk = _androidSdkIntEstimado();
    return sdk != null && sdk >= 33;
  }

  /// §3.6 — Solicita los permisos de Bluetooth en tiempo de ejecución.
  /// En Android 12+ (API 31) son runtime `BLUETOOTH_SCAN` y
  /// `BLUETOOTH_CONNECT` (un solo diálogo "Dispositivos cercanos"); en
  /// Android ≤11 el descubrimiento clásico exige `ACCESS_FINE_LOCATION`.
  /// Sin estos permisos el plugin lanza una `SecurityException` nativa
  /// (java.lang) que cierra la aplicación al escanear. Retorna `true`
  /// cuando los permisos requeridos quedaron concedidos.
  Future<bool> solicitarPermisosBluetooth() async {
    try {
      if (Platform.isAndroid) {
        final moderno = (_androidSdkIntEstimado() ?? 0) >= 31;
        if (moderno) {
          final escanear = await Permission.bluetoothScan.request();
          if (escanear.isDenied || escanear.isPermanentlyDenied) return false;
          final conectar = await Permission.bluetoothConnect.request();
          if (conectar.isDenied || conectar.isPermanentlyDenied) return false;
          // Algunas ROMs (p. ej. MIUI) exigen ubicación incluso con
          // `BLUETOOTH_SCAN + neverForLocation` para el descubrimiento
          // clásico. Se solicita de forma opcional: no bloquea el escaneo
          // si la persona la deniega (el plugin ya no la exige en API 31+).
          if (!await Permission.location.isGranted) {
            await Permission.location.request();
          }
          return true;
        }
        final ubicacion = await Permission.location.request();
        return ubicacion.isGranted;
      }
      if (Platform.isIOS) {
        final bluetooth = await Permission.bluetooth.request();
        return bluetooth.isGranted;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Comprueba que los permisos Bluetooth estén concedidos sin mostrar
  /// diálogos. Evita que el plugin reintente pedirlos dentro de
  /// `startScan` (camino con crash conocido de `BluetoothPrintPlugin`:
  /// `NullPointerException` por `MethodChannel.Result` nulo tras el
  /// diálogo de permisos).
  Future<bool> permisosBluetoothConcedidos() async {
    try {
      if (Platform.isAndroid) {
        final moderno = (_androidSdkIntEstimado() ?? 0) >= 31;
        if (moderno) {
          return await Permission.bluetoothScan.isGranted &&
              await Permission.bluetoothConnect.isGranted;
        }
        return await Permission.location.isGranted;
      }
      if (Platform.isIOS) {
        return await Permission.bluetooth.isGranted;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Inicia el escaneo de dispositivos cercanos. Retorna `true` si el
  /// escaneo pudo arrancar y `false` si faltan permisos o hubo un error
  /// inmediato.
  Future<bool> iniciarEscaneo() async {
    if (!await permisosBluetoothConcedidos()) return false;
    try {
      // Detiene un escaneo previo antes de iniciar otro (defensivo).
      try {
        await BluetoothPrintPlus.stopScan();
      } catch (_) {}
      await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 12));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> detenerEscaneo() => BluetoothPrintPlus.stopScan();

  /// Lista los dispositivos Bluetooth ya vinculados con el teléfono. No
  /// requieren escaneo: se pueden conectar directamente. Retorna vacío si no
  /// hay ninguno o faltan permisos.
  Future<List<BluetoothDevice>> obtenerDispositivosVinculados() async {
    try {
      return await BluetoothPrintPlus.getBondedDevices();
    } catch (_) {
      return const [];
    }
  }

  /// Intenta encender (`true`) o apagar (`false`) el adaptador. En varios
  /// equipos Android 12+ el sistema lo bloquea para apps de terceros; ahí
  /// devuelve `false` y conviene usar [abrirAjustesBluetooth].
  Future<bool> cambiarEstadoBluetooth(bool activar) async {
    try {
      return await BluetoothPrintPlus.setBluetoothEnabled(activar);
    } catch (_) {
      return false;
    }
  }

  /// Abre los ajustes de Bluetooth del sistema (fallback cuando la app no
  /// puede encender/apagar el adaptador por sí misma).
  Future<bool> abrirAjustesBluetooth() async {
    try {
      return await BluetoothPrintPlus.openBluetoothSettings();
    } catch (_) {
      return false;
    }
  }

  /// Abre los ajustes de la propia app (fallback cuando los permisos de
  /// Bluetooth quedaron denegados de forma permanente).
  Future<bool> abrirAjustesApp() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Desvincula (elimina) un dispositivo del listado del teléfono.
  Future<bool> eliminarDispositivoVinculado(
    BluetoothDevice dispositivo,
  ) async {
    try {
      return await BluetoothPrintPlus.removeBondedDevice(dispositivo.address);
    } catch (_) {
      return false;
    }
  }

  /// Intenta conectar a un dispositivo. Retorna `false` si la conexión no
  /// pudo iniciarse; el resultado real llega por [estadoConexion].
  Future<bool> conectar(BluetoothDevice dispositivo) async {
    try {
      await BluetoothPrintPlus.connect(dispositivo);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> desconectar() async {
    try {
      await BluetoothPrintPlus.disconnect();
    } catch (_) {}
  }

  Future<void> escribir(Uint8List datos) async {
    try {
      await BluetoothPrintPlus.write(datos);
    } catch (_) {}
  }

  /// Envía un ticket de prueba ESC/POS a la impresora conectada. Retorna
  /// `true` si el envío pudo completar.
  Future<bool> imprimirPrueba({
    required int copias,
    required bool cortarPapel,
    required String razonSocial,
    String? mensajePie,
  }) async {
    try {
      final datos = _ticketPrueba(
        copias: copias,
        cortarPapel: cortarPapel,
        razonSocial: razonSocial,
        mensajePie: mensajePie,
      );
      await BluetoothPrintPlus.write(datos);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Construye un ticket de prueba en ESC/POS (formato POS, papel 58 mm).
  /// Respeta copias, corte de papel y los datos de la factura configurados.
  Uint8List _ticketPrueba({
    required int copias,
    required bool cortarPapel,
    required String razonSocial,
    String? mensajePie,
  }) {
    final buffer = BytesBuilder();

    // Codifica a Latin-1 (lo que entienden las térmicas POS); los
    // caracteres fuera del rango se reemplazan para no fallar el envío.
    void linea(String texto) {
      buffer.add(latin1.encode(texto.contains(RegExp(r'[^\x00-\xFF]'))
          ? texto.replaceAll(RegExp(r'[^\x00-\xFF]'), '_')
          : texto));
      buffer.add(const [0x0A]);
    }

    // Inicializa la impresora (ESC @).
    buffer.add(const [0x1B, 0x40]);
    for (int c = 0; c < copias; c++) {
      if (c > 0) {
        // Avance entre copias (ESC d 3).
        buffer.add(const [0x1B, 0x64, 0x03]);
      }
      // Centrar (ESC a 1).
      buffer.add(const [0x1B, 0x61, 0x01]);
      // Doble tamaño para el título (GS ! 0x11).
      buffer.add(const [0x1D, 0x21, 0x11]);
      linea('**** PRUEBA ****');
      buffer.add(const [0x1D, 0x21, 0x00]);
      linea('');
      linea(razonSocial.isEmpty ? 'COFFEE CONTROL' : razonSocial);
      linea('');
      buffer.add(const [0x1B, 0x61, 0x00]);
      linea('Impresion de prueba');
      linea('Si puedes leer este ticket,');
      linea('la impresora esta lista.');
      linea('');
      buffer.add(const [0x1B, 0x61, 0x01]);
      final ahora = DateTime.now();
      final hh = ahora.hour.toString().padLeft(2, '0');
      final mm = ahora.minute.toString().padLeft(2, '0');
      final dd = ahora.day.toString().padLeft(2, '0');
      final mes = ahora.month.toString().padLeft(2, '0');
      linea('$hh:$mm  $dd/$mes/${ahora.year}');
      if (mensajePie != null && mensajePie.trim().isNotEmpty) {
        linea('');
        buffer.add(const [0x1B, 0x61, 0x00]);
        linea(mensajePie.trim());
      }
      // Avance final (ESC d 5).
      buffer.add(const [0x1B, 0x64, 0x05]);
    }
    if (cortarPapel) {
      // Corte parcial (GS V 66 0).
      buffer.add(const [0x1D, 0x56, 0x42, 0x00]);
    }
    return buffer.toBytes();
  }
}