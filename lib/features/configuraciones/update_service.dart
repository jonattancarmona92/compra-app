// ==================== ACTUALIZACIONES OTA ====================
// Servicio que consulta Firebase Remote Config (proyecto
// coffee-control-2d1d4) para comparar la versión instalada con la
// publicada y, si procede, descarga e instala el APK con ota_update.
// Antes de descargar se crea una copia local de la base SQLite.
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Estado de la versión publicada en Remote Config.
class InfoActualizacion {
  const InfoActualizacion({
    required this.versionCodigo,
    required this.versionNombre,
    required this.apkUrl,
    required this.cambios,
    required this.esCritica,
  });

  final int versionCodigo;
  final String versionNombre;
  final String apkUrl;
  final String cambios;
  final bool esCritica;

  bool hayNueva(int codigoInstalado) =>
      apkUrl.trim().isNotEmpty && versionCodigo > codigoInstalado;

  /// Compara la versión semántica del release vs. la instalada (GitHub).
  bool hayNuevaVersion(String versionInstalada) =>
      apkUrl.trim().isNotEmpty &&
      UpdateService.compararVersiones(versionInstalada, versionNombre) < 0;
}

class UpdateException implements Exception {
  const UpdateException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class UpdateService {
  static const String repoGitHub = 'jonattancarmona92/compra-app';
  static const String githubApiUrl =
      'https://api.github.com/repos/$repoGitHub/releases/latest';
  static const String apkAssetNombre = 'Coffe.Control.apk';

  static bool _firebaseListo = false;

  final OtaUpdate _ota = OtaUpdate();

  /// Compara dos versiones semánticas ("1.2.3" vs "v1.20.0").
  /// Devuelve < 0 si a < b, 0 si son iguales y > 0 si a > b.
  static int compararVersiones(String a, String b) {
    String limpiar(String s) => s.trim().replaceFirst(RegExp('^[vV]'), '');
    final pa = limpiar(a).split('.');
    final pb = limpiar(b).split('.');
    final n = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < n; i++) {
      final x = i < pa.length ? int.tryParse(pa[i]) ?? 0 : 0;
      final y = i < pb.length ? int.tryParse(pb[i]) ?? 0 : 0;
      if (x != y) return x.compareTo(y);
    }
    return 0;
  }

  /// Inicializa Firebase una sola vez. No lanza; devuelve si quedó listo
  /// para que la pantalla informe (la app funciona offline sin Firebase).
  Future<bool> asegurarFirebase() async {
    if (_firebaseListo) return true;
    try {
      await Firebase.initializeApp();
      _firebaseListo = true;
    } catch (_) {
      _firebaseListo = false;
    }
    return _firebaseListo;
  }

  /// Versión instalada (buildNumber = versionCode en Play / pubspec).
  Future<int> codigoVersionInstalado() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 1;
  }

  Future<String> etiquetaVersionInstalada() async {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version} · Build ${info.buildNumber}';
  }

  /// Versión (nombre) instalada, p.ej. "1.1.0".
  Future<String> versionInstaladaNombre() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Consulta el último release publicado en GitHub Releases del repo
  /// jonattancarmona92/compra-app.
  Future<InfoActualizacion> obtenerDisponibleGitHub() async {
    try {
      final resp = await http.get(
        Uri.parse(githubApiUrl),
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'CoffeeControl',
        },
      );
      if (resp.statusCode != 200) {
        throw UpdateException(
          'GitHub respondió ${resp.statusCode} '
          '(¿existe un release publicado en el repositorio?).',
        );
      }
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final tag = (json['tag_name'] as String?) ?? '';
      final cuerpo = (json['body'] as String?) ?? '';
      final assets = (json['assets'] as List<dynamic>?) ?? [];
      String url = '';
      for (final a in assets) {
        final asset = a as Map<String, dynamic>;
        final nombre = (asset['name'] as String?) ?? '';
        if (nombre.toLowerCase() == apkAssetNombre.toLowerCase()) {
          url = (asset['browser_download_url'] as String?) ?? '';
          break;
        }
      }
      if (tag.isEmpty || url.isEmpty) {
        throw UpdateException(
          'El release no trae el APK esperado ($apkAssetNombre).',
        );
      }
      return InfoActualizacion(
        versionCodigo: 0,
        versionNombre: tag.replaceFirst(RegExp('^[vV]'), ''),
        apkUrl: url,
        cambios: cuerpo,
        esCritica: false,
      );
    } on UpdateException {
      rethrow;
    } catch (e) {
      throw UpdateException('No se pudo consultar GitHub: $e');
    }
  }

  /// Consulta y activa Remote Config. Lanza [UpdateException] si el
  /// servidor no está disponible.
  Future<InfoActualizacion> obtenerDisponible() async {
    if (!await asegurarFirebase()) {
      throw const UpdateException(
        'Firebase no está disponible. Verifique la configuración del '
        'proyecto coffee-control-2d1d4 y la conexión.',
      );
    }
    final rc = FirebaseRemoteConfig.instance;
    try {
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 15),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await rc.setDefaults(const {
        'latest_version_code': 0,
        'latest_version_name': '',
        'apk_download_url': '',
        'changelog': '',
        'is_critical_update': false,
      });
      await rc.fetchAndActivate();
    } on FirebaseException catch (e) {
      throw UpdateException('No se pudo consultar el servidor: ${e.code}');
    }
    return InfoActualizacion(
      versionCodigo: rc.getInt('latest_version_code'),
      versionNombre: rc.getString('latest_version_name'),
      apkUrl: rc.getString('apk_download_url'),
      cambios: rc.getString('changelog'),
      esCritica: rc.getBool('is_critical_update'),
    );
  }

  /// Copia de seguridad de la base SQLite antes de instalar la actualización.
  Future<String> crearRespaldo() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'coffee_control.sqlite'));
    if (!await dbFile.exists()) {
      throw const UpdateException('No se encontró la base de datos local.');
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
    return destino.path;
  }

  /// Inicia la descarga e instalación del APK. El progreso (% descargado)
  /// y los estados llegan por el Stream de [OtaEvent].
  Stream<OtaEvent> descargarEInstalar(String url) => _ota.execute(url);
}