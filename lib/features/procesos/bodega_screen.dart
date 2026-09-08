// ==================== ARCHIVO: lib/features/procesos/bodega_screen.dart ====================
// Bodega — Informe Global §3.4.3. Dos pestañas:
//   - "Almacenado": lotes constituidos con serie (codigoLote pro-/sec-/
//     ore-/moj-/pas-). Estados DISPONIBLE / AGOTADO. Selector secundario
//     para historial de lotes agotados/liquidados.
//   - "Bodega": existencias acumuladas de la bodega común (compra sin
//     lote), mostradas por cantidad total por tipo.
// §3.4.1: la bodega común tiene piso 0 kg; los lotes constituidos tienen
// peso >= 0 (prohibido negativo, §5.5.6).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import 'procesos_provider.dart';

class BodegaScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const BodegaScreen({super.key, required this.onBack});

  String _estadoLabel(EstadoBodega estado) {
    switch (estado) {
      case EstadoBodega.pendiente:
        return 'En Bodega Común';
      case EstadoBodega.secado:
        return 'En Secado';
      case EstadoBodega.listo:
        return 'Disponible';
      case EstadoBodega.vendido:
        return 'Agotado';
    }
  }

  Color _estadoColor(EstadoBodega estado) {
    switch (estado) {
      case EstadoBodega.pendiente:
        return AppPaletaOficial.amarillo;
      case EstadoBodega.secado:
        return AppPaletaOficial.cafe;
      case EstadoBodega.listo:
        return AppPaletaOficial.verde;
      case EstadoBodega.vendido:
        return AppPaletaOficial.negro;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bodega'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Almacenado'),
              Tab(text: 'Bodega'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AlmacenadoTab(
              estadoLabel: _estadoLabel,
              estadoColor: _estadoColor,
            ),
            _BodegaComunTab(
              estadoLabel: _estadoLabel,
              estadoColor: _estadoColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// §3.4.3 — Tab "Almacenado": lotes constituidos disponibles de forma
/// predeterminada, con selector secundario para ver los agotados
/// (historial).
class _AlmacenadoTab extends ConsumerStatefulWidget {
  final String Function(EstadoBodega estado) estadoLabel;
  final Color Function(EstadoBodega estado) estadoColor;

  const _AlmacenadoTab({
    required this.estadoLabel,
    required this.estadoColor,
  });

  @override
  ConsumerState<_AlmacenadoTab> createState() => _AlmacenadoTabState();
}

class _AlmacenadoTabState extends ConsumerState<_AlmacenadoTab> {
  bool _verAgotados = false;

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(procesosProvider);
    final disponibles = estado.almacenadosDisponibles;
    final agotados = estado.almacenadosAgotados;
    final lista = _verAgotados ? agotados : disponibles;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppPaletaOficial.cafe,
          padding: const EdgeInsets.all(AppEspaciado.m),
          child: Row(
            children: [
              const Icon(Icons.warehouse, color: AppPaletaOficial.blanco),
              const SizedBox(width: AppEspaciado.s),
              Expanded(
                child: Text(
                  'Almacenado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPaletaOficial.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppEspaciado.s,
                  vertical: AppEspaciado.xs,
                ),
                decoration: BoxDecoration(
                  color: AppPaletaOficial.blanco.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(AppEspaciado.radioEstandar),
                ),
                child: Text(
                  '${disponibles.length} disponibles · '
                  '${agotados.length} agotados',
                  style: const TextStyle(
                    color: AppPaletaOficial.blanco,
                    fontSize: AppEscalaTipografica.notas,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppEspaciado.m),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Disponibles'),
                icon: Icon(Icons.check_circle_outline),
              ),
              ButtonSegment(
                value: true,
                label: Text('Agotados'),
                icon: Icon(Icons.history),
              ),
            ],
            selected: {_verAgotados},
            onSelectionChanged: (seleccion) {
              setState(() => _verAgotados = seleccion.first);
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppPaletaOficial.cafe,
              selectedForegroundColor: AppPaletaOficial.blanco,
              foregroundColor: AppPaletaOficial.cafe,
            ),
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? _SinDatos(
                  mensaje: _verAgotados
                      ? 'No hay lotes agotados o liquidados'
                      : 'No hay lotes almacenados',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppEspaciado.m,
                    0,
                    AppEspaciado.m,
                    AppEspaciado.m,
                  ),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppEspaciado.s),
                  itemBuilder: (context, index) => _AlmacenadoCard(
                    lote: lista[index],
                    estadoLabel: widget.estadoLabel(lista[index].estado),
                    estadoColor: widget.estadoColor(lista[index].estado),
                  ),
                ),
        ),
      ],
    );
  }
}

/// §3.4.3 — Tab "Bodega": existencias acumuladas de la bodega común sin
/// lote, mostradas por cantidad total por tipo (solo > 0 kg).
class _BodegaComunTab extends ConsumerWidget {
  final String Function(EstadoBodega estado) estadoLabel;
  final Color Function(EstadoBodega estado) estadoColor;

  const _BodegaComunTab({
    required this.estadoLabel,
    required this.estadoColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(procesosProvider);
    final porTipo = estado.bodegaComunPorTipo;
    final pesoTotal = porTipo.values.fold<double>(0, (a, b) => a + b);

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppPaletaOficial.cafe,
          padding: const EdgeInsets.all(AppEspaciado.m),
          child: Row(
            children: [
              const Icon(Icons.inventory_2, color: AppPaletaOficial.blanco),
              const SizedBox(width: AppEspaciado.s),
              Expanded(
                child: Text(
                  'Bodega Común',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPaletaOficial.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                '${_formatearPeso(pesoTotal)} kg',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPaletaOficial.blanco,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: porTipo.isEmpty
              ? const _SinDatos(mensaje: 'No hay existencias en bodega común')
              : ListView.separated(
                  padding: const EdgeInsets.all(AppEspaciado.m),
                  itemCount: porTipo.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppEspaciado.s),
                  itemBuilder: (context, index) {
                    final entrada = porTipo.entries.elementAt(index);
                    return Card(
                      elevation: 0,
                      color: AppPaletaOficial.blanco,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppEspaciado.radioEstandar,
                        ),
                        side: const BorderSide(color: Color(0xFFE0D8D0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppEspaciado.m),
                        child: Row(
                          children: [
                            Icon(
                              Icons.coffee,
                              color: AppPaletaOficial.cafe,
                            ),
                            const SizedBox(width: AppEspaciado.s),
                            Expanded(
                              child: Text(
                                entrada.key.etiqueta,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppEscalaTipografica.subtitulo,
                                ),
                              ),
                            ),
                            Text(
                              '${_formatearPeso(entrada.value)} kg',
                              style: const TextStyle(
                                color: AppPaletaOficial.cafe,
                                fontWeight: FontWeight.bold,
                                fontSize: AppEscalaTipografica.subtitulo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatearPeso(double peso) {
    return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 1);
  }
}

/// §3.4.3 — Tarjeta de un lote constituido de "Almacenado".
class _AlmacenadoCard extends StatelessWidget {
  final LoteBodega lote;
  final String estadoLabel;
  final Color estadoColor;

  const _AlmacenadoCard({
    required this.lote,
    required this.estadoLabel,
    required this.estadoColor,
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
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lote ${lote.codigoLote}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.subtitulo,
                      color: AppPaletaOficial.cafe,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.s,
                    vertical: AppEspaciado.xs,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppEspaciado.radioEstandar),
                  ),
                  child: Text(
                    estadoLabel,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppEscalaTipografica.notas,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              '${lote.tipoCafe.etiqueta} · ${_formatearPeso(lote.pesoNeto)} kg',
              style: const TextStyle(fontSize: AppEscalaTipografica.cuerpo),
            ),
            if (lote.costoKg > 0) ...[
              const SizedBox(height: AppEspaciado.xs),
              Text(
                'Costo inicial: \$${lote.costoKg.toStringAsFixed(2)}/kg',
                style: const TextStyle(
                  color: Color(0xFF8D8D8D),
                  fontSize: AppEscalaTipografica.notas,
                ),
              ),
            ],
            const SizedBox(height: AppEspaciado.xs),
            Text(
              'Constituido: ${_formatearFecha(lote.fechaIngreso)}',
              style: const TextStyle(
                color: Color(0xFF8D8D8D),
                fontSize: AppEscalaTipografica.notas,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearPeso(double peso) {
    return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 1);
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }
}

class _SinDatos extends StatelessWidget {
  final String mensaje;

  const _SinDatos({this.mensaje = 'No hay datos'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: Color(0xFFB0ACA7),
          ),
          const SizedBox(height: AppEspaciado.m),
          Text(
            mensaje,
            style: const TextStyle(fontSize: AppEscalaTipografica.cuerpo),
          ),
        ],
      ),
    );
  }
}