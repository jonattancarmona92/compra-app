// ==================== BLOQUEO POR LICENCIA VENCIDA ====================
// Documento "Pin de recarga". Se muestra POR ENCIMA del dashboard cuando la
// licencia está vencida y deja de haber días restantes: impide usar el
// sistema hasta recargar con un PIN (desbloqueo offline). Requiere el ID
// del dispositivo para solicitar el PIN.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../configuraciones/licencia_provider.dart';
import '../configuraciones/widgets/formulario_recarga_widget.dart';

class LicenciaBloqueoScreen extends ConsumerStatefulWidget {
  const LicenciaBloqueoScreen({super.key});

  @override
  ConsumerState<LicenciaBloqueoScreen> createState() =>
      _LicenciaBloqueoScreenState();
}

class _LicenciaBloqueoScreenState
    extends ConsumerState<LicenciaBloqueoScreen> {
  Future<void> _copiarId(String id) async {
    await Clipboard.setData(ClipboardData(text: id));
    if (!mounted) return;
    Notificaciones.exito(context, 'ID de dispositivo copiado');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = ref.watch(licenciaProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Licencia vencida'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppEspaciado.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: AppPaletaOficial.rojo.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.gpp_maybe_outlined,
                      size: 38,
                      color: AppPaletaOficial.rojo,
                    ),
                  ),
                  const SizedBox(height: AppEspaciado.l),
                  Text(
                    'La licencia ha vencido',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppEspaciado.m),
                  Text(
                    'Para continuar usando el sistema ingrese el PIN de '
                    'recarga que recibió. Si aún no lo tiene, comuníquele su '
                    'ID de dispositivo para generar uno.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppEspaciado.m),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ID de dispositivo: ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        estado.dispositivoId.isEmpty ? '----' : estado.dispositivoId,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: AppEspaciado.xs),
                      IconButton(
                        tooltip: 'Copiar ID',
                        visualDensity: VisualDensity.compact,
                        onPressed: estado.dispositivoId.isEmpty
                            ? null
                            : () => _copiarId(estado.dispositivoId),
                        icon: const Icon(Icons.copy, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppEspaciado.xl),
                  const FormularioRecargaWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}