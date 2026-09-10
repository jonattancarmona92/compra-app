// ==================== ARCHIVO: lib/features/configuraciones/seguridad_screen.dart ====================
// Seguridad — Informe Global §3.6. Configura las políticas de seguridad
// de la aplicación (PIN, notificaciones críticas, confirmaciones).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'configuraciones_provider.dart';
import 'seguridad_avanzadas_screen.dart';

class SeguridadScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const SeguridadScreen({super.key, required this.onBack});

  Future<void> _abrirAvanzadas(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeguridadAvanzadasScreen(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(configuracionesProvider);
    final seguridad = estado.seguridad;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        children: [
          _SeguridadTile(
            titulo: 'Exigir PIN',
            descripcion: 'Solicita el PIN para editar, anular y cerrar.',
            icon: Icons.lock_outline,
            valor: seguridad.pinRequerido,
            onChanged: (v) => ref
                .read(configuracionesProvider.notifier)
                .guardarSeguridad(seguridad.copyWith(pinRequerido: v)),
          ),
          const SizedBox(height: AppEspaciado.s),
          _SeguridadTile(
            titulo: 'Notificaciones críticas',
            descripcion: 'Alerta ante diferencias y saldos desfavorables.',
            icon: Icons.notifications_active_outlined,
            valor: seguridad.notificacionesCriticas,
            onChanged: (v) => ref
                .read(configuracionesProvider.notifier)
                .guardarSeguridad(
                  seguridad.copyWith(notificacionesCriticas: v),
                ),
          ),
          const SizedBox(height: AppEspaciado.s),
          _SeguridadTile(
            titulo: 'Confirmar cierres',
            descripcion: 'Solicita confirmación al cerrar caja y operativo.',
            icon: Icons.verified_user_outlined,
            valor: seguridad.confirmarCierres,
            onChanged: (v) => ref
                .read(configuracionesProvider.notifier)
                .guardarSeguridad(seguridad.copyWith(confirmarCierres: v)),
          ),
          const SizedBox(height: AppEspaciado.l),
          Card(
            elevation: 0,
            color: AppDiseno.superficie(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
              side: BorderSide(
                color: AppDiseno.bordeTarjeta(context),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.security_update_good,
                color: AppPaletaOficial.cafe,
              ),
              title: const Text(
                'Avanzadas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Cambio de credenciales, copias de seguridad, restauración '
                'y limpieza de datos. Protegido con el ID de dispositivo.',
                style: TextStyle(fontSize: AppEscalaTipografica.notas),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _abrirAvanzadas(context),
            ),
          ),
          const SizedBox(height: AppEspaciado.l),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos de la aplicación',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppEscalaTipografica.subtitulo,
                  ),
                ),
                const SizedBox(height: AppEspaciado.s),
                const Text(
                  'Esta acción borrará todos los datos locales de la '
                  'aplicación. Es reversible solo si realizaste una copia '
                  'de seguridad previa.',
                  style: TextStyle(fontSize: AppEscalaTipografica.notas),
                ),
                const SizedBox(height: AppEspaciado.m),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPaletaOficial.rojo,
                      side: const BorderSide(color: AppPaletaOficial.rojo),
                    ),
                    onPressed: () => _abrirAvanzadas(context),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('Limpiar datos'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppEspaciado.m),
          Text(
            'NOTA DE INTEGRACIÓN PENDIENTE: la política de seguridad se '
            'conectará al control de acceso real (Módulo 5).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPaletaOficial.amarillo,
                  fontSize: AppEscalaTipografica.notas,
                ),
          ),
        ],
      ),
    );
  }
}

class _SeguridadTile extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icon;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _SeguridadTile({
    required this.titulo,
    required this.descripcion,
    required this.icon,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppDiseno.superficie(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: BorderSide(
          color: AppDiseno.bordeTarjeta(context),
        ),
      ),
      child: SwitchListTile(
        value: valor,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppPaletaOficial.cafe),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppEscalaTipografica.cuerpo,
          ),
        ),
        subtitle: Text(
          descripcion,
          style: const TextStyle(fontSize: AppEscalaTipografica.notas),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;

  const SectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppDiseno.superficie(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: BorderSide(
          color: AppDiseno.bordeTarjeta(context),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: child,
      ),
    );
  }
}
