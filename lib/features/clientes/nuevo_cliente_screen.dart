// ==================== ARCHIVO: lib/features/clientes/nuevo_cliente_screen.dart ====================
// Nuevo Cliente — Informe Global §3.5.1. Formulario de registro de un
// nuevo cliente con control de duplicados por documento (§5.5.5).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'providers/cliente_provider.dart';

class NuevoClienteScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const NuevoClienteScreen({super.key, required this.onBack});

  @override
  ConsumerState<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends ConsumerState<NuevoClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _cupoController = TextEditingController();

  bool _creditoAutorizado = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _cupoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final id = ref.read(clienteProvider.notifier).registrarCliente(
            nombreCompleto: _nombreController.text,
            documento: _documentoController.text,
            telefono: _telefonoController.text.trim(),
            direccion: _direccionController.text.trim(),
            creditoAutorizado: _creditoAutorizado,
            cupoMaximo: CurrencyFormatter.parseValue(_cupoController.text),
          );
      Notificaciones.exito(context, 'Cliente registrado correctamente');
      ref
          .read(clienteProvider.notifier)
          .actualizarSaldos(clienteId: id, saldoDeuda: 0);
    } on DuplicadoClienteException catch (e) {
      Notificaciones.error(
        context,
        'Ya existe un cliente con el documento ${e.documento}.',
      );
    } on ArgumentError catch (e) {
      Notificaciones.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Cliente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppEspaciado.m),
          children: [
            _campo(
              _nombreController,
              'Nombre completo',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: AppEspaciado.m),
            _campo(
              _documentoController,
              'Documento de identidad',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: AppEspaciado.m),
            _campo(_telefonoController, 'Teléfono'),
            const SizedBox(height: AppEspaciado.m),
            _campo(_direccionController, 'Dirección'),
            const SizedBox(height: AppEspaciado.m),
            Card(
              elevation: 0,
              color: AppPaletaOficial.blanco,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppEspaciado.radioEstandar),
                side: const BorderSide(color: Color(0xFFE0D8D0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppEspaciado.m),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _creditoAutorizado,
                      onChanged: (v) =>
                          setState(() => _creditoAutorizado = v),
                      title: const Text('Autorizar crédito'),
                      subtitle: const Text(
                        'Permite al cliente tomar préstamos.',
                        style: TextStyle(fontSize: AppEscalaTipografica.notas),
                      ),
                    ),
                    if (_creditoAutorizado) ...[
                      const Divider(),
                      TextFormField(
                        controller: _cupoController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyFormatter()],
                        validator: CurrencyFormatter.validar,
                        decoration: const InputDecoration(
                          labelText: 'Cupo máximo de crédito',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppEspaciado.l),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Registrar cliente'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
