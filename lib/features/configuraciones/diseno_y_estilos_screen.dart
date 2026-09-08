// diseno_y_estilos_screen.dart
import 'package:flutter/material.dart';
import '../../core/diseno.dart';
import '../../core/estilos/estilo_1.dart' as estilo1;
import '../../core/estilos/estilo_2.dart' as estilo2;
import '../../core/estilos/estilo_3.dart' as estilo3;
import 'package:provider/provider.dart';

/// Pantalla que permite seleccionar cuál de los tres estilos se aplicará.
/// Usa ThemeController (ChangeNotifier) para aplicar el ThemeData y la extensión.
class DisenoYEstilosScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const DisenoYEstilosScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ThemeController>(context);
    final current = controller.currentStyle;

    return Theme(
      data: controller.themeData.copyWith(
        extensions: <ThemeExtension<dynamic>>[controller.extensionData],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diseño y Estilos'),
          leading: onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                )
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppEspaciado.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona un estilo',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppEspaciado.m),

              // --- MENÚ DESPLEGABLE (DROPDOWN) ---
              DropdownButtonFormField<CoffeeStyle>(
                initialValue: current,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppEspaciado.radioEstandar,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.m,
                    vertical: AppEspaciado.s,
                  ),
                ),
                items: CoffeeStyle.values.map((style) {
                  return DropdownMenuItem<CoffeeStyle>(
                    value: style,
                    child: Text(_labelFor(style)),
                  );
                }).toList(),
                onChanged: (selectedStyle) {
                  if (selectedStyle != null) {
                    controller.setStyle(selectedStyle);
                    Notificaciones.informacion(
                      context,
                      'Estilo aplicado: ${_labelFor(selectedStyle)}',
                    );
                  }
                },
              ),

              const SizedBox(height: AppEspaciado.l),

              // --- PREVISUALIZACIÓN ÚNICA DEL TEMA SELECCIONADO ---
              Expanded(
                child: SingleChildScrollView(
                  child: _previewFor(current, controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _labelFor(CoffeeStyle s) {
    switch (s) {
      case CoffeeStyle.oscuro:
        return 'Estilo 2 (Oscuro)';
      case CoffeeStyle.corporativo:
        return 'Estilo 3 (Corporativo)';
      case CoffeeStyle.claro:
        return 'Estilo 1 (Claro)';
    }
  }

  Widget _previewFor(CoffeeStyle style, ThemeController controller) {
    final theme = ThemeController.themeFromStyle(style);
    final ext = ThemeController.coffeeCustomFromEstilo(style);

    Widget preview;
    switch (style) {
      case CoffeeStyle.oscuro:
        preview = estilo2.Estilo2Preview(samplePrice: 12000);
        break;
      case CoffeeStyle.corporativo:
        preview = estilo3.Estilo3Preview(samplePrice: 10000);
        break;
      case CoffeeStyle.claro:
        preview = estilo1.Estilo1Preview(samplePrice: 8500);
        break;
    }

    return Theme(
      data: theme.copyWith(extensions: <ThemeExtension<dynamic>>[ext]),
      child: Builder(
        builder: (context) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: AppEspaciado.s),
            child: Padding(
              padding: const EdgeInsets.all(AppEspaciado.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelFor(style),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppEspaciado.s),
                  preview,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
