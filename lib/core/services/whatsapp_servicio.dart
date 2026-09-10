// ==================== WHATSAPP — CONTACTO OFICIAL ====================
// Centraliza el número de WhatsApp de Coffee Control usado para:
//   • Adquisición de licencias (plan + comprobante + ID de dispositivo).
//   • Soporte y sugerencias desde Configuraciones.
// Chat directo vía url_launcher (wa.me) y comprobante adjunto vía
// share_plus (la imagen se comparte junto al texto).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/configuraciones/licencia_provider.dart';

class WhatsappServicio {
  WhatsappServicio._();

  static const String numeroWhatsApp = '3042913864';
  static const String numeroWhatsAppInternacional = '573042913864';

  static const String cuentaBancolombia = '912-214407-79';
  static const String titularCuenta = 'Jonattan Carmona';

  /// Abre el chat de WhatsApp con un texto predefinido (sin archivos).
  static Future<bool> abrirChat({required String texto}) async {
    final uri = Uri.parse(
      'https://wa.me/$numeroWhatsAppInternacional?text=${Uri.encodeComponent(texto)}',
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Comparte un texto junto con una imagen (comprobante/recibo de la
  /// consignación) usando la hoja de compartir de Android/iOS; el
  /// operador elige WhatsApp como destino.
  static Future<bool> compartirConImagen({
    required String texto,
    required String rutaImagen,
  }) async {
    final resultado = await SharePlus.instance.share(
      ShareParams(
        text: texto,
        files: [XFile(rutaImagen)],
      ),
    );
    // Éxito o cierre de la hoja = flujo completado; solo
    // "unavailable" indica un problema real.
    return resultado.status != ShareResultStatus.unavailable;
  }

  /// Compone el mensaje de solicitud de licencia con el plan elegido.
  static String mensajeSolicitudLicencia({
    required String dispositivoId,
    required String plan,
    required int valor,
  }) {
    return 'Solicitud de licencia — Coffee Control\n'
        'ID de dispositivo: $dispositivoId\n'
        'Plan elegido: $plan\n'
        'Valor consignado: ${_formatValor(valor)}\n'
        'Cuenta: Bancolombia (ahorros) $cuentaBancolombia\n'
        'Titular: $titularCuenta\n'
        'Adjunto el comprobante de la consignación.';
  }

  /// Compone el mensaje de soporte/sugerencia con el ID del equipo.
  static String mensajeSoporte({required String dispositivoId}) {
    return 'Hola, necesito ayuda/soporte con Coffee Control.\n'
        'ID de dispositivo: $dispositivoId';
  }

  /// Obtiene el ID de dispositivo garantizando que exista y esté
  /// sincronizado con el estado.
  static Future<String> obtenerDispositivoId(WidgetRef ref) async {
    final notifier = ref.read(licenciaProvider.notifier);
    return notifier.obtenerOCrearDispositivoId();
  }

  static String _formatValor(int valor) {
    final contador = valor.toString().replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < contador.length; i++) {
      if (i > 0 && (contador.length - i) % 3 == 0) buffer.write('.');
      buffer.write(contador[i]);
    }
    return '\$$buffer';
  }
}