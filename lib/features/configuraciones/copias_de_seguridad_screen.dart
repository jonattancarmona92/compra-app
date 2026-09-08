// ==================== ARCHIVO: lib/features/configuraciones/copias_de_seguridad_screen.dart ====================
// Copias de Seguridad — Informe Global §3.6. Permite realizar y restaurar
// copias de seguridad de los datos de la aplicación.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'configuraciones_provider.dart';

class CopiasDeSeguridadScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const CopiasDeSeguridadScreen({super.key, required this.onBack});

  @override
  ConsumerState<CopiasDeSeguridadScreen> createState() =>
      _CopiasDeSeguridadScreenState();
}

class _CopiasDeSeguridadScreenState
    extends ConsumerState<CopiasDeSeguridadScreen> {
  bool _procesando = false;

  Future<void> _realizarCopia() async {
    setState(() => _procesando = true);
    await ref.read(configuracionesProvider.notifier).realizarCopia();
    setState(() => _procesando = false);
    if (!mounted) return;
    Notificaciones.exito(context, 'Copia de seguridad realizada');
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} · $hora:$min';
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(configuracionesProvider);
    final ultimaCopia = estado.ultimaCopia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Copias de Seguridad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        children: [
          Card(
            elevation: 0,
            color: AppPaletaOficial.blanco,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
              side: const BorderSide(color: Color(0xFFE0D8D0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppEspaciado.m),
              child: Row(
                children: [
                  const Icon(
                    Icons.backup_outlined,
                    size: 40,
                    color: AppPaletaOficial.cafe,
                  ),
                  const SizedBox(width: AppEspaciado.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Última copia',
                          style: TextStyle(
                            fontSize: AppEscalaTipografica.notas,
                            color: Color(0xFF8D8D8D),
                          ),
                        ),
                        const SizedBox(height: AppEspaciado.xs),
                        Text(
                          ultimaCopia == null
                              ? 'No se han realizado copias'
                              : _formatearFecha(ultimaCopia),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppEscalaTipografica.subtitulo,
                            color: AppPaletaOficial.cafe,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppEspaciado.m),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _procesando ? null : _realizarCopia,
              icon: _procesando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
              label: Text(_procesando ? 'Copiando…' : 'Realizar copia'),
            ),
          ),
          const SizedBox(height: AppEspaciado.s),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _procesando
                  ? null
                  : () {
                      Notificaciones.informacion(
                        context,
                        'Restauración simulada completada',
                      );
                    },
              icon: const Icon(Icons.settings_backup_restore),
              label: const Text('Restaurar copia'),
            ),
          ),
          const SizedBox(height: AppEspaciado.l),
          Text(
            'NOTA DE INTEGRACIÓN PENDIENTE: la copia se realizará sobre la '
            'base de datos local (Módulo 5 - Drift).',
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
