// ==================== ARCHIVO: lib/features/configuraciones/complementos_screen.dart ====================
// Complementos — Informe Global §3.6. Permite activar/desactivar
// funcionalidades complementarias de la aplicación.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'configuraciones_provider.dart';

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
            descripcion: 'Habilita o deshabilita el registro de ventas POS '
                'desde el menú POS.',
            icon: Icons.storefront_outlined,
            valor: complementos.ventasPos,
            onChanged: (v) => ref
                .read(configuracionesProvider.notifier)
                .guardarComplementos(complementos.copyWith(ventasPos: v)),
          ),
          const SizedBox(height: AppEspaciado.m),
          Text(
            'NOTA DE INTEGRACIÓN PENDIENTE: esta configuración se '
            'persistirá en el Módulo 5 (Drift/SharedPreferences).',
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

class _ComplementoTile extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icon;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _ComplementoTile({
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
        subtitle: Text(
          descripcion,
          style: const TextStyle(fontSize: AppEscalaTipografica.notas),
        ),
      ),
    );
  }
}
