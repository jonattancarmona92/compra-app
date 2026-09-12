// ==================== ARCHIVO: lib/features/clientes/clientes_screen.dart ====================
// Clientes (Visión 360°) — Informe Global §3.5.2. Ficha Única del
// cliente: listado con buscador y detalle financiero completo (deuda,
// cupo máximo, cupo disponible, crédito autorizado y estado).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../caja/caja_provider.dart';
import 'models/cliente_model.dart';
import 'providers/cliente_provider.dart';

class ClientesScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const ClientesScreen({super.key, required this.onBack});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _busquedaController = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<ClienteModel> _filtrar(List<ClienteModel> clientes) {
    final termino = _filtro.trim().toLowerCase();
    if (termino.isEmpty) return clientes;
    return clientes
        .where((c) =>
            c.nombreCompleto.toLowerCase().contains(termino) ||
            c.documento.toLowerCase().contains(termino))
        .toList();
  }

  void _verFicha(ClienteModel cliente) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPaletaOficial.blanco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppEspaciado.radioLg),
        ),
      ),
      builder: (context) => _FichaCliente(
        cliente: cliente,
        saldoFavor: ref
            .read(cajaProvider.notifier)
            .saldoFavorDisponible(cliente.id),
        onInactivar: () {
          ref
              .read(clienteProvider.notifier)
              .inactivar(cliente.id);
          Navigator.of(context).pop();
          Notificaciones.informacion(
            this.context,
            'Cliente inactivado',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(clienteProvider);
    final visibles = _filtrar(estado.clientes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes (Visión 360°)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppEspaciado.m),
            child: TextField(
              controller: _busquedaController,
              onChanged: (v) => setState(() => _filtro = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar por nombre o documento',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppEspaciado.radioEstandar),
                ),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: visibles.isEmpty
                ? const _SinClientes()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppEspaciado.m,
                    ),
                    itemCount: visibles.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppEspaciado.s),
                    itemBuilder: (context, index) {
                      final c = visibles[index];
                      return Card(
                        elevation: 0,
                        color: AppPaletaOficial.blanco,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppEspaciado.radioEstandar,
                          ),
                          side: BorderSide(
                            color: c.activo
                                ? const Color(0xFFE0D8D0)
                                : AppPaletaOficial.rojo.withValues(
                                    alpha: 0.4,
                                  ),
                          ),
                        ),
                        child: ListTile(
                          onTap: () => _verFicha(c),
                          leading: CircleAvatar(
                            backgroundColor: AppPaletaOficial.cafe,
                            child: Text(
                              c.nombreCompleto.isNotEmpty
                                  ? c.nombreCompleto[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppPaletaOficial.blanco,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            c.nombreCompleto,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppEscalaTipografica.cuerpo,
                            ),
                          ),
                          subtitle: Text(
                            'Doc: ${c.documento}'
                            '${!c.activo ? ' · Inactivo' : ''}',
                            style: const TextStyle(
                              fontSize: AppEscalaTipografica.notas,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FichaCliente extends StatelessWidget {
  final ClienteModel cliente;
  final double saldoFavor;
  final VoidCallback onInactivar;

  const _FichaCliente({
    required this.cliente,
    required this.saldoFavor,
    required this.onInactivar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppPaletaOficial.cafe),
                const SizedBox(width: AppEspaciado.s),
                Expanded(
                  child: Text(
                    cliente.nombreCompleto,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.subtitulo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.xs),
            Text(
              'Documento: ${cliente.documento}'
              '${cliente.telefono != null && cliente.telefono!.isNotEmpty ? ' · Tel: ${cliente.telefono}' : ''}',
              style: const TextStyle(fontSize: AppEscalaTipografica.notas),
            ),
            if (cliente.direccion != null && cliente.direccion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppEspaciado.xs),
                child: Text(
                  'Dirección: ${cliente.direccion}',
                  style: const TextStyle(fontSize: AppEscalaTipografica.notas),
                ),
              ),
            const Divider(height: AppEspaciado.l),
            _fila('Deuda actual', cliente.saldoDeuda, destacado: true),
            _fila(
              'Saldo a favor',
              saldoFavor,
              positivo: saldoFavor > 0,
            ),
            _fila(
              'Cupo máximo',
              cliente.cupoMaximoEfectivo,
              nota: cliente.cupoMaximo <= 0 && cliente.creditoAutorizado
                  ? 'Por defecto: \$1\'000.000'
                  : null,
            ),
            _fila('Cupo disponible', cliente.cupoDisponible,
                positivo: cliente.cupoDisponible > 0),
            _fila(
              'Crédito autorizado',
              cliente.creditoAutorizado ? 1 : 0,
              esBooleano: cliente.creditoAutorizado,
            ),
            _fila(
              'Estado',
              cliente.activo ? 1 : 0,
              esActivo: cliente.activo,
            ),
            if (cliente.tieneAnticipos) ...[
              const SizedBox(height: AppEspaciado.s),
              const Text(
                'El cliente tiene anticipos por amortizar.',
                style: TextStyle(
                  fontSize: AppEscalaTipografica.notas,
                  color: AppPaletaOficial.amarillo,
                ),
              ),
            ],
            if (cliente.activo) ...[
              const SizedBox(height: AppEspaciado.m),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPaletaOficial.rojo,
                    side: const BorderSide(color: AppPaletaOficial.rojo),
                  ),
                  onPressed: onInactivar,
                  icon: const Icon(Icons.person_off_outlined),
                  label: const Text('Inactivar cliente'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fila(
    String etiqueta,
    double valor, {
    bool destacado = false,
    bool positivo = false,
    bool esBooleano = false,
    bool esActivo = false,
    String? nota,
  }) {
    final Widget derecha;
    if (esBooleano) {
      derecha = Text(
        valor == 1 ? 'Sí' : 'No',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: valor == 1
              ? AppPaletaOficial.verde
              : AppPaletaOficial.negro,
        ),
      );
    } else if (esActivo) {
      derecha = Text(
        valor == 1 ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color:
              valor == 1 ? AppPaletaOficial.verde : AppPaletaOficial.rojo,
        ),
      );
    } else {
      derecha = Text(
        CurrencyFormatter.formatValue(valor),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: destacado
              ? AppEscalaTipografica.subtitulo
              : AppEscalaTipografica.cuerpo,
          color: positivo ? AppPaletaOficial.verde : AppPaletaOficial.cafe,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppEspaciado.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: destacado
                        ? AppEscalaTipografica.cuerpo
                        : AppEscalaTipografica.notas,
                  ),
                ),
              ),
              derecha,
            ],
          ),
          if (nota != null) ...[
            const SizedBox(height: AppEspaciado.xs),
            Text(
              nota,
              style: TextStyle(
                fontSize: AppEscalaTipografica.notas,
                color: AppPaletaOficial.cafe,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SinClientes extends StatelessWidget {
  const _SinClientes();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 56,
            color: Color(0xFFB0ACA7),
          ),
          SizedBox(height: AppEspaciado.m),
          Text(
            'No se encontraron clientes',
            style: TextStyle(fontSize: AppEscalaTipografica.cuerpo),
          ),
        ],
      ),
    );
  }
}
