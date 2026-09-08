// ==================== ARCHIVO: lib/features/caja/widgets/menu_tres_puntos_widget.dart ====================
// Menú de tres puntos — Informe Global §3.3 (estándar del módulo de Caja).
// Reutilizado por todas las pantallas del módulo que exigen acciones
// por registro: Editar, Cancelar/Anular, Compartir como PDF, Imprimir.
import 'package:flutter/material.dart';

class MenuTresPuntosWidget extends StatelessWidget {
  final VoidCallback onEditar;
  final VoidCallback onAnular;
  final VoidCallback onCompartirPdf;
  final VoidCallback onImprimir;

  const MenuTresPuntosWidget({
    super.key,
    required this.onEditar,
    required this.onAnular,
    required this.onCompartirPdf,
    required this.onImprimir,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (opcion) {
        switch (opcion) {
          case 'editar':
            onEditar();
            break;
          case 'anular':
            onAnular();
            break;
          case 'pdf':
            onCompartirPdf();
            break;
          case 'imprimir':
            onImprimir();
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'editar', child: Text('Editar')),
        PopupMenuItem(
          value: 'anular',
          child: Text('Cancelar/Anular'),
        ),
        PopupMenuItem(value: 'pdf', child: Text('Compartir como PDF')),
        PopupMenuItem(value: 'imprimir', child: Text('Imprimir')),
      ],
    );
  }
}
