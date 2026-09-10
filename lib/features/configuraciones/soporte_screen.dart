// ==================== CONFIGURACIONES > SOPORTE ====================
// Contacto directo con el equipo de Coffee Control por WhatsApp para
// dudas, sugerencias o inconvenientes. Se adjunta el ID de dispositivo
// al mensaje para poder identificar el equipo del cliente.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/whatsapp_servicio.dart';

class SoporteScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const SoporteScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardSeccion(
              titulo: 'Soporte y Sugerencias',
              icono: Icons.support_agent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '¿Tienes alguna duda, sugerencia o inconveniente con '
                    'Coffee Control? Escríbenos por WhatsApp y te '
                    'responderemos lo antes posible.',
                  ),
                  const SizedBox(height: AppEspaciado.m),
                  _FilaContacto(
                    icono: Icons.phone_in_talk_outlined,
                    etiqueta: 'WhatsApp',
                    valor: WhatsappServicio.numeroWhatsApp,
                  ),
                  const SizedBox(height: AppEspaciado.m),
                  ElevatedButton.icon(
                    onPressed: () => _contactar(context, ref),
                    icon: const Icon(Icons.chat),
                    label: const Text('Contactar por WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppEspaciado.m,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  Future<void> _contactar(BuildContext context, WidgetRef ref) async {
    final dispositivoId =
        await WhatsappServicio.obtenerDispositivoId(ref);
    final abrio = await WhatsappServicio.abrirChat(
      texto: WhatsappServicio.mensajeSoporte(
        dispositivoId: dispositivoId,
      ),
    );
    if (!context.mounted) return;
    if (!abrio) {
      Notificaciones.error(
        context,
        'No se pudo abrir WhatsApp. Verifica que esté instalado.',
      );
    }
  }
}

class _CardSeccion extends StatelessWidget {
  const _CardSeccion({
    required this.titulo,
    required this.icono,
    required this.child,
  });

  final String titulo;
  final IconData icono;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icono,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: AppEspaciado.s),
                Text(
                  titulo,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.m),
            child,
          ],
        ),
      ),
    );
  }
}

class _FilaContacto extends StatelessWidget {
  const _FilaContacto({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: AppEspaciado.s),
        Text('$etiqueta: '),
        Text(
          valor,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}