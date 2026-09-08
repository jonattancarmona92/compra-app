// ==================== CONFIGURACIONES > LICENCIA ====================
// Documento "Pin de recarga". Centraliza el estado del software y el
// proceso de recarga: estado/plan/vencimiento y formulario de PIN con
// validación offline. El ID de dispositivo NO se muestra aquí: se genera
// al validar la Clave Maestra (Día Cero) y se expone en esa pantalla.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/diseno.dart';
import 'licencia_provider.dart';
import 'widgets/formulario_recarga_widget.dart';

class LicenciaScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const LicenciaScreen({super.key, required this.onBack});

  @override
  ConsumerState<LicenciaScreen> createState() => _LicenciaScreenState();
}

class _LicenciaScreenState extends ConsumerState<LicenciaScreen> {
  final _formatoFecha = DateFormat('dd/MM/yyyy');

  String _labelPlan(String plan) {
    switch (plan) {
      case 'INICIAL':
        return 'Inicial (30 días)';
      case 'MENSUAL':
        return 'Mensual (30 días)';
      case 'SEMESTRAL':
        return 'Semestral (180 días)';
      case 'ANUAL':
        return 'Anual (365 días)';
      default:
        return plan.isEmpty ? '--' : plan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(licenciaProvider);
    final vencimiento = estado.fechaVencimiento;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Licencia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardSeccion(
              titulo: 'Estado de la Licencia',
              icono: Icons.verified_user_outlined,
              child: Column(
                children: [
                  _FilaEstado(
                    etiqueta: 'Estado',
                    valor: (estado.esVencida || (vencimiento == null))
                        ? 'Vencida'
                        : 'Activa',
                    color: (estado.esVencida || vencimiento == null)
                        ? AppPaletaOficial.rojo
                        : AppPaletaOficial.verde,
                  ),
                  const Divider(height: 24),
                  _FilaEstado(
                    etiqueta: 'Plan',
                    valor: _labelPlan(estado.planActual),
                  ),
                  const Divider(height: 24),
                  _FilaEstado(
                    etiqueta: 'Vencimiento',
                    valor: vencimiento == null
                        ? '--'
                        : _formatoFecha.format(vencimiento),
                  ),
                  const Divider(height: 24),
                  _FilaEstado(
                    etiqueta: 'Días restantes',
                    valor: vencimiento == null || estado.esVencida
                        ? '0'
                        : '${estado.diasRestantes}',
                    destacado: estado.diasRestantes <= 3 &&
                        estado.diasRestantes >= 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppEspaciado.m),
            _CardSeccion(
              titulo: 'Recarga',
              icono: Icons.redeem,
              child: const FormularioRecargaWidget(),
            ),
          ],
        ),
      ),
    );
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
                Icon(icono, size: 20, color: Theme.of(context).colorScheme.secondary),
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

class _FilaEstado extends StatelessWidget {
  const _FilaEstado({
    required this.etiqueta,
    required this.valor,
    this.color,
    this.destacado = false,
  });

  final String etiqueta;
  final String valor;
  final Color? color;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          valor,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color ?? (destacado
                ? AppPaletaOficial.rojo
                : Theme.of(context).colorScheme.onSurface),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}