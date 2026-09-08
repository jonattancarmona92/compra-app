// ==================== BANNER DE LICENCIA ====================
// Documento "Pin de recarga". Se muestra solo cuando quedan 3, 2, 1 o 0 días
// de licencia (amarillo para 3/2, rojo para 1/0). Al tocarlo abre
// Configuración > Licencia. Nunca se muestra si ya venció (en ese caso la
// pantalla de bloqueo cubre el dashboard).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../diseno.dart';
import '../../features/configuraciones/licencia_provider.dart';

class BanerLicenciaWidget extends ConsumerWidget {
  final VoidCallback onRenovar;

  const BanerLicenciaWidget({super.key, required this.onRenovar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(licenciaProvider);

    // Visible solo con 3, 2, 1 o 0 días restantes (nunca si venció).
    if (!estado.bannerVisible) {
      return const SizedBox.shrink();
    }

    final dias = estado.diasRestantes;
    final esUrgente = dias <= 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspaciado.m,
        vertical: AppEspaciado.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
          onTap: onRenovar,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppEspaciado.m,
              vertical: AppEspaciado.s,
            ),
            decoration: BoxDecoration(
              color: esUrgente
                  ? AppPaletaOficial.rojo.withValues(alpha: 0.12)
                  : AppPaletaOficial.amarillo.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
              border: Border.all(
                color: esUrgente
                    ? AppPaletaOficial.rojo
                    : AppPaletaOficial.amarillo,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  esUrgente ? Icons.error_outline : Icons.info_outline,
                  color: esUrgente
                      ? AppPaletaOficial.rojo
                      : AppPaletaOficial.amarillo,
                ),
                const SizedBox(width: AppEspaciado.m),
                Expanded(
                  child: Text(
                    dias == 0
                        ? 'Tu licencia vence HOY. ¡Recárgala ya!'
                        : (dias == 1
                              ? 'Tu licencia vence mañana. ¡Recárgala!'
                              : 'Tu licencia vence en $dias días'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: esUrgente
                          ? AppPaletaOficial.rojo
                          : AppPaletaOficial.amarillo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppPaletaOficial.cafe,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}