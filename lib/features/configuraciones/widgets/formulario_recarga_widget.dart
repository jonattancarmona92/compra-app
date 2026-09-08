// ==================== FORMULARIO DE RECARGA (REUTILIZABLE) ====================
// Usado por la pantalla "Configuración > Licencia" y por la pantalla de
// bloqueo por licencia vencida. Maneja el campo PIN con máscara, el canje
// y el bloqueo de 1 hora tras 3 intentos fallidos.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/diseno.dart';
import '../../../core/widgets/pin_recarga_formatter.dart';
import '../licencia_provider.dart';

class FormularioRecargaWidget extends ConsumerStatefulWidget {
  const FormularioRecargaWidget({super.key});

  @override
  ConsumerState<FormularioRecargaWidget> createState() =>
      _FormularioRecargaWidgetState();
}

class _FormularioRecargaWidgetState
    extends ConsumerState<FormularioRecargaWidget> {
  final _controller = TextEditingController();
  bool _procesando = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final estado = ref.read(licenciaProvider);
      if (mounted && estado.enBloqueo) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cargarPin() async {
    final pin = _controller.text.trim();
    if (pin.length != 10) {
      Notificaciones.error(context, 'Ingrese el PIN completo (XXXXX-XXXX)');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _procesando = true);
    final resultado = await ref
        .read(licenciaProvider.notifier)
        .cargarPin(pin);
    if (!mounted) return;
    setState(() => _procesando = false);
    if (resultado.exito) {
      _controller.clear();
      // Si la pantalla fue desmontada (p. ej. el bloqueo se levantó al
      // renovar), el diálogo de éxito no tiene contexto: se omite.
      await _mostrarExito(resultado.mensaje);
    } else {
      Notificaciones.error(context, resultado.mensaje);
    }
  }

  Future<void> _mostrarExito(String mensaje) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppPaletaOficial.verde,
          size: 40,
        ),
        title: const Text('Recarga exitosa'),
        content: Text(mensaje),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(licenciaProvider);
    final bloqueado = estado.enBloqueo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CampoPinRecarga(controller: _controller, habilitado: !bloqueado),
        if (bloqueado) ...[
          const SizedBox(height: AppEspaciado.m),
          _BloqueoBanner(
            tiempo: estado.tiempoBloqueoRestante,
          ),
        ] else ...[
          SizedBox(height: AppEspaciado.m),
          FilledButton.icon(
            onPressed: _procesando ? null : _cargarPin,
            icon: _procesando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.redeem),
            label: const Text('Cargar PIN'),
          ),
          if (estado.intentosFallidos > 0) ...[
            const SizedBox(height: AppEspaciado.s),
            Text(
              'Intentos restantes: ${intentosMaximosRecarga - estado.intentosFallidos}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );
  }
}

class _BloqueoBanner extends StatelessWidget {
  const _BloqueoBanner({required this.tiempo});

  final Duration tiempo;

  String get _texto {
    final horas = tiempo.inHours.toString().padLeft(2, '0');
    final minutos = (tiempo.inMinutes % 60).toString().padLeft(2, '0');
    final segundos = (tiempo.inSeconds % 60).toString().padLeft(2, '0');
    return '$horas:$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppEspaciado.m),
      decoration: BoxDecoration(
        color: AppPaletaOficial.rojo.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
        border: Border.all(color: AppPaletaOficial.rojo),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_clock, color: AppPaletaOficial.rojo, size: 32),
          const SizedBox(height: AppEspaciado.s),
          Text(
            'Bloqueado por intentos fallidos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppPaletaOficial.rojo,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppEspaciado.xs),
          Text(
            'La recarga se reactiva en $_texto',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}