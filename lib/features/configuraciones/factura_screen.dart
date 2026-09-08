// ==================== ARCHIVO: lib/features/configuraciones/factura_screen.dart ====================
// Factura — Informe Global §3.6. Configura los datos que aparecen en la
// factura (datos de la empresa / razón social, NIT, resolución DIAN, etc.).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'configuraciones_provider.dart';

class FacturaScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const FacturaScreen({super.key, required this.onBack});

  @override
  ConsumerState<FacturaScreen> createState() => _FacturaScreenState();
}

class _FacturaScreenState extends ConsumerState<FacturaScreen> {
  late final TextEditingController _razonSocial;
  late final TextEditingController _nit;
  late final TextEditingController _direccion;
  late final TextEditingController _telefono;
  late final TextEditingController _ciudad;
  late final TextEditingController _resolucion;
  late final TextEditingController _vigencia;
  late final TextEditingController _mensaje;

  @override
  void initState() {
    super.initState();
    final f = ref.read(configuracionesProvider).factura;
    _razonSocial = TextEditingController(text: f.razonSocial);
    _nit = TextEditingController(text: f.nit);
    _direccion = TextEditingController(text: f.direccion);
    _telefono = TextEditingController(text: f.telefono);
    _ciudad = TextEditingController(text: f.ciudad);
    _resolucion = TextEditingController(text: f.resolucionDian);
    _vigencia = TextEditingController(text: f.vigenciaResolucion);
    _mensaje = TextEditingController(text: f.mensajePie);
  }

  @override
  void dispose() {
    _razonSocial.dispose();
    _nit.dispose();
    _direccion.dispose();
    _telefono.dispose();
    _ciudad.dispose();
    _resolucion.dispose();
    _vigencia.dispose();
    _mensaje.dispose();
    super.dispose();
  }

  void _guardar() {
    ref.read(configuracionesProvider.notifier).guardarFactura(
          DatosFactura(
            razonSocial: _razonSocial.text,
            nit: _nit.text,
            direccion: _direccion.text,
            telefono: _telefono.text,
            ciudad: _ciudad.text,
            resolucionDian: _resolucion.text,
            vigenciaResolucion: _vigencia.text,
            mensajePie: _mensaje.text,
          ),
        );
    Notificaciones.exito(context, 'Datos de factura guardados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factura'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppEspaciado.m),
        children: [
          const Text(
            'Datos de la empresa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppEscalaTipografica.subtitulo,
            ),
          ),
          const SizedBox(height: AppEspaciado.m),
          _campo(_razonSocial, 'Razón social'),
          const SizedBox(height: AppEspaciado.m),
          _campo(_nit, 'NIT'),
          const SizedBox(height: AppEspaciado.m),
          _campo(_direccion, 'Dirección'),
          const SizedBox(height: AppEspaciado.m),
          Row(
            children: [
              Expanded(child: _campo(_telefono, 'Teléfono')),
              const SizedBox(width: AppEspaciado.m),
              Expanded(child: _campo(_ciudad, 'Ciudad')),
            ],
          ),
          const SizedBox(height: AppEspaciado.m),
          _campo(_resolucion, 'Resolución DIAN'),
          const SizedBox(height: AppEspaciado.m),
          _campo(_vigencia, 'Vigencia de la resolución'),
          const SizedBox(height: AppEspaciado.m),
          _campo(_mensaje, 'Mensaje al pie de factura'),
          const SizedBox(height: AppEspaciado.l),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar datos'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
