// ==================== CONFIGURACIONES > LICENCIA ====================
// Documento "Pin de recarga". Centraliza el estado del software y el
// proceso de recarga: estado/plan/vencimiento y formulario de PIN con
// validación offline. El ID de dispositivo NO se muestra aquí: se genera
// al validar la Clave Maestra (Día Cero) y se expone en esa pantalla.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/diseno.dart';
import '../../core/services/whatsapp_servicio.dart';
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

  /// §3.8 — planes de adquisición de licencia por consignación:
  /// precio, días de vigencia, plan del sistema que se activará y el QR
  /// de pago (Bancolombia) correspondiente.
  static const _planes = [
    _PlanLicencia('1 mes', 30, 30000, 'assets/qr/30.jpg'),
    _PlanLicencia('6 meses', 180, 150000, 'assets/qr/150.jpg'),
    _PlanLicencia('12 meses', 365, 240000, 'assets/qr/240.jpg'),
  ];
  int _planSeleccionado = 0;

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
            const SizedBox(height: AppEspaciado.m),
            _CardSeccion(
              titulo: 'Adquirir Licencia',
              icono: Icons.storefront_outlined,
              child: _buildAdquirirLicencia(),
            ),
          ],
        ),
      ),
    );
  }

  /// §3.8 — adquisición de licencia por consignación a Bancolombia:
  /// el cliente elige el plan, consigna, adjunta el comprobante (foto o
  /// galería) y lo envía por WhatsApp junto con el ID de dispositivo.
  Widget _buildAdquirirLicencia() {
    final plan = _planes[_planSeleccionado];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '1. Elija el plan y pague escaneando el QR o consignando en la '
          'cuenta indicada.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppEspaciado.m),
        RadioGroup<int>(
          groupValue: _planSeleccionado,
          onChanged: (v) => setState(() => _planSeleccionado = v ?? 0),
          child: Column(
            children: [
              for (var i = 0; i < _planes.length; i++)
                RadioListTile<int>(
                  value: i,
                  dense: true,
                  title: Text(
                    '${_planes[i].nombre} — '
                    '${CurrencyFormatter.formatValue(_planes[i].valor.toDouble())}',
                  ),
                  subtitle: Text('${_planes[i].dias} días de vigencia'),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        Center(
          child: Text(
            'Escanea el QR para pagar el plan seleccionado',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppEspaciado.m),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
              border: Border.all(
                color: AppDiseno.bordeTarjeta(context),
              ),
            ),
            child: Image.asset(
              plan.qrAsset,
              width: 240,
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(
                width: 240,
                height: 240,
                child: Center(child: Text('QR no disponible')),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        Container(
          padding: const EdgeInsets.all(AppEspaciado.m),
          decoration: BoxDecoration(
            color: AppDiseno.superficie(context),
            borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: AppEspaciado.s),
                  const Text(
                    'Consignación a Bancolombia (referencia)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppEspaciado.s),
              const Text('Cuenta de ahorros N.º ${WhatsappServicio.cuentaBancolombia}'),
              const Text('Titular: ${WhatsappServicio.titularCuenta}'),
              const SizedBox(height: AppEspaciado.s),
              Text(
                'ⓘ Valor a consignar: '
                '${CurrencyFormatter.formatValue(plan.valor.toDouble())}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        Text(
          '2. Envíe por WhatsApp: foto del recibo o comprobante. '
          'Su ID de dispositivo se adjuntará automáticamente al mensaje '
          '(por seguridad no se muestra en pantalla).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppEspaciado.m),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copiarDatosBancarios(context, plan),
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: const Text('Copiar datos'),
              ),
            ),
            const SizedBox(width: AppEspaciado.m),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _enviarComprobante(context),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Enviar comprobante'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppEspaciado.s),
        Text(
          'Se abrirá la hoja de compartir: elija WhatsApp. Se adjuntará la '
          'foto del comprobante con los datos del plan y el ID del equipo.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _copiarDatosBancarios(BuildContext context, _PlanLicencia plan) async {
    await Clipboard.setData(
      ClipboardData(
        text: 'Coffee Control — Consignación\n'
            'Banco: Bancolombia\n'
            'Cuenta de ahorros: ${WhatsappServicio.cuentaBancolombia}\n'
            'Titular: ${WhatsappServicio.titularCuenta}\n'
            'Valor: ${CurrencyFormatter.formatValue(plan.valor.toDouble())}',
      ),
    );
    if (!context.mounted) return;
    Notificaciones.exito(context, 'Datos bancarios copiados.');
  }

  /// Flujo de envío del comprobante: selecciona la fuente (cámara o
  /// galería), toma/adjunta el recibo y lo comparte por WhatsApp con el
  /// mensaje de solicitud (plan + valor + ID de dispositivo).
  Future<void> _enviarComprobante(BuildContext context) async {
    final dispositivoId = await WhatsappServicio.obtenerDispositivoId(ref);
    if (!context.mounted) return;
    final plan = _planes[_planSeleccionado];

    final origen = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto al recibo'),
              onTap: () => Navigator.pop(context, 'camara'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Adjuntar desde la galería'),
              onTap: () => Navigator.pop(context, 'galeria'),
            ),
          ],
        ),
      ),
    );

    final fuente = origen == 'camara'
        ? ImageSource.camera
        : origen == 'galeria'
            ? ImageSource.gallery
            : null;
    if (fuente == null) return;

    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: fuente,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (imagen == null) return;

    final mensaje = WhatsappServicio.mensajeSolicitudLicencia(
      dispositivoId: dispositivoId,
      plan: plan.nombre,
      valor: plan.valor,
    );
    final compartio = await WhatsappServicio.compartirConImagen(
      texto: mensaje,
      rutaImagen: imagen.path,
    );
    if (!context.mounted) return;
    if (!compartio) {
      Notificaciones.error(
        context,
        'No se pudo compartir el comprobante. Intente de nuevo.',
      );
    } else {
      Notificaciones.informacion(
        context,
        'Elija WhatsApp como destino para enviar la solicitud.',
      );
    }
  }
}

class _PlanLicencia {
  const _PlanLicencia(this.nombre, this.dias, this.valor, this.qrAsset);

  final String nombre;
  final int dias;
  final int valor;

  /// Ruta del código QR de pago (Bancolombia) para este plan.
  final String qrAsset;
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