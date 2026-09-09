// ==================== ARCHIVO: lib/features/configuraciones/complementos_screen.dart ====================
// Complementos — Informe Global §3.6. Permite activar/desactivar
// funcionalidades complementarias de la aplicación.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/seguridad/licencia_pin.dart';
import '../pos/pos_provider.dart';
import 'configuraciones_provider.dart';
import 'licencia_provider.dart';

class ComplementosScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const ComplementosScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(configuracionesProvider);
    final complementos = estado.complementos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complementos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        children: [
          _ComplementoTile(
            titulo: 'Cotizaciones',
            descripcion: 'Muestra las cotizaciones del precio del café.',
            icon: Icons.trending_up_outlined,
            valor: complementos.cotizaciones,
            onChanged: (v) => ref
                .read(configuracionesProvider.notifier)
                .guardarComplementos(complementos.copyWith(cotizaciones: v)),
          ),
          const SizedBox(height: AppEspaciado.s),
          _ComplementoTile(
            titulo: 'Redondear a la Unidad de Mil',
            descripcion: 'Ajusta los resultados monetarios al múltiplo de '
                '\$1.000 más cercano (la entrada siempre queda exacta).',
            icon: Icons.one_k_outlined,
            valor: complementos.redondeoMiles,
            onChanged: (v) => ref
                .read(configuracionesProvider.notifier)
                .guardarComplementos(complementos.copyWith(redondeoMiles: v)),
          ),
          const SizedBox(height: AppEspaciado.s),
          _ComplementoTile(
            titulo: 'Ventas POS',
            descripcion: complementos.ventasPos
                ? 'Habilita el registro de ventas POS desde el menú POS. '
                    'Desactivarlo solo con el ID de dispositivo: si el ciclo '
                    'vigente ya tiene ventas, se aplica tras el Cierre del '
                    'Ciclo Operativo.'
                : 'Ventas POS desactivadas (no se muestra en ninguna '
                    'pantalla). Actívala en cualquier momento.',
            icon: Icons.storefront_outlined,
            valor: complementos.ventasPos,
            pendienteDesactivacion:
                complementos.ventasPosPendienteDesactivacion,
            permisoProtegido: true,
            onChanged: (v) => _cambiarVentasPos(context, ref, complementos, v),
          ),
          if (complementos.ventasPos == false &&
              complementos.ventasPosPendienteDesactivacion == false)
            _ReactivarVentasPosTile(
              onReactivar: () => ref
                  .read(configuracionesProvider.notifier)
                  .guardarComplementos(
                    complementos.copyWith(ventasPos: true),
                  ),
            ),
          const SizedBox(height: AppEspaciado.m),
          Text(
            'NOTA DE INTEGRACIÓN PENDIENTE: los complementos ya se '
            'persisten (SharedPreferences); el resto de la configuración '
            'se integrará en el Módulo 5.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPaletaOficial.amarillo,
                  fontSize: AppEscalaTipografica.notas,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _cambiarVentasPos(
    BuildContext context,
    WidgetRef ref,
    ConfigComplementos complementos,
    bool activar,
  ) async {
    final notifier = ref.read(configuracionesProvider.notifier);

    // Desactivación ya diferida al Cierre del Ciclo Operativo: togglear
    // el interruptor ahora permite cancelar la desactivación pendiente.
    if (complementos.ventasPosPendienteDesactivacion) {
      final cancelar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancelar desactivación pendiente'),
          content: const Text(
            'Ventas POS está programado para desactivarse al Cierre del '
            'Ciclo Operativo. ¿Desea cancelar esa desactivación?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Mantener pendiente'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancelar desactivación'),
            ),
          ],
        ),
      );
      if (cancelar == true) {
        notifier.guardarComplementos(
          complementos.copyWith(
            ventasPos: true,
            ventasPosPendienteDesactivacion: false,
          ),
        );
        if (context.mounted) {
          Notificaciones.exito(
            context,
            'Desactivación cancelada. Ventas POS continúa activo.',
          );
        }
      }
      return;
    }

    if (activar) {
      // Reactivación: se aplica de inmediato y se limpia cualquier
      // desactivación pendiente heredada.
      notifier.guardarComplementos(
        complementos.copyWith(
          ventasPos: true,
          ventasPosPendienteDesactivacion: false,
        ),
      );
      return;
    }

    // §3.6 — Desactivar exige el ID de dispositivo (4 caracteres, N-L-N-L).
    final licencia = ref.read(licenciaProvider);
    var idGuardado = licencia.dispositivoId.trim().toUpperCase();
    if (idGuardado.isEmpty) {
      idGuardado = (await ref
              .read(licenciaProvider.notifier)
              .obtenerOCrearDispositivoId())
          .trim()
          .toUpperCase();
      if (!context.mounted) return;
    }
    final idIngresado = await _pedirIdDispositivo(context);
    if (idIngresado == null) return; // El usuario canceló.
    if (!context.mounted) return;

    if (!DispositivoId.esValido(idIngresado)) {
      if (context.mounted) {
        Notificaciones.error(context, 'El ID de dispositivo no es válido.');
      }
      return;
    }
    if (idIngresado != idGuardado) {
      if (context.mounted) {
        Notificaciones.error(
          context,
          'El ID de dispositivo no corresponde a este equipo.',
        );
      }
      return;
    }

    // Regla del ciclo: solo si el ciclo vigente NO tiene ventas POS se
    // desactiva de inmediato; de lo contrario se difiere al cierre.
    final hayVentas =
        ref.read(posProvider).ventasEnCicloActual > 0;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar Ventas POS'),
        content: Text(
          hayVentas
              ? 'El Ciclo Operativo vigente ya tiene ventas POS registradas. '
                  'La desactivación se aplicará automáticamente tras el '
                  'Cierre del Ciclo Operativo.'
              : '¿Desea desactivar Ventas POS? Dejará de mostrarse en '
                  'todas las pantallas y no se podrán registrar ventas '
                  'hasta reactivarla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    if (hayVentas) {
      // Continúa visible hasta el cierre del ciclo; el switch refleja
      // la desactivación pendiente.
      notifier.guardarComplementos(
        complementos.copyWith(
          ventasPos: true,
          ventasPosPendienteDesactivacion: true,
        ),
      );
      if (context.mounted) {
        Notificaciones.informacion(
          context,
          'Ventas POS se desactivará al cerrar el Ciclo Operativo.',
        );
      }
    } else {
      notifier.guardarComplementos(
        complementos.copyWith(
          ventasPos: false,
          ventasPosPendienteDesactivacion: false,
        ),
      );
      if (context.mounted) {
        Notificaciones.exito(context, 'Ventas POS desactivadas.');
      }
    }
  }

  /// Dialog integrado para pedir el ID de dispositivo al operador.
  Future<String?> _pedirIdDispositivo(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final controlador = TextEditingController();
        return AlertDialog(
          title: const Text('Confirmar con el ID de dispositivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingrese el ID de dispositivo (4 caracteres) del equipo '
                'para desactivar Ventas POS.',
              ),
              const SizedBox(height: AppEspaciado.m),
              TextField(
                controller: controlador,
                autofocus: true,
                maxLength: 4,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'ID de dispositivo',
                  hintText: 'Ej. 7K3M',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, controlador.text.trim().toUpperCase()),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}

class _ComplementoTile extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icon;
  final bool valor;
  final ValueChanged<bool> onChanged;

  /// Indica que el complemento está protegido por permisos: su cambio
  /// ignora el toggle directo y delega en [onChanged] (que valida).
  final bool permisoProtegido;

  /// Muestra la señal de "desactivación pendiente al cierre de ciclo".
  final bool pendienteDesactivacion;

  const _ComplementoTile({
    required this.titulo,
    required this.descripcion,
    required this.icon,
    required this.valor,
    required this.onChanged,
    this.permisoProtegido = false,
    this.pendienteDesactivacion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppPaletaOficial.blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: const BorderSide(color: Color(0xFFE0D8D0)),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descripcion,
              style: const TextStyle(fontSize: AppEscalaTipografica.notas),
            ),
            if (pendienteDesactivacion) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppPaletaOficial.amarillo,
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Pendiente de desactivar tras el Cierre del Ciclo '
                      'Operativo.',
                      style: TextStyle(
                        fontSize: AppEscalaTipografica.notas,
                        fontWeight: FontWeight.bold,
                        color: AppPaletaOficial.amarillo,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Toolbar de quitar el bloqueo protegido del componente de Ventas POS.
class _ReactivarVentasPosTile extends StatelessWidget {
  final VoidCallback onReactivar;

  const _ReactivarVentasPosTile({required this.onReactivar});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppPaletaOficial.blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        side: const BorderSide(color: Color(0xFFE0D8D0)),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.storefront_outlined,
          color: AppPaletaOficial.cafe,
        ),
        title: Text(
          'Reactivar Ventas POS',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppEscalaTipografica.cuerpo,
          ),
        ),
        subtitle: const Text(
          'Vuelve a habilitar el registro de ventas POS de inmediato.',
          style: TextStyle(fontSize: AppEscalaTipografica.notas),
        ),
        trailing: const Icon(Icons.refresh, color: AppPaletaOficial.cafe),
        onTap: onReactivar,
      ),
    );
  }
}
