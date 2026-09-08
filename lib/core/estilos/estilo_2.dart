// ==================== ARCHIVO: lib/core/estilos/estilo_2.dart ====================
// Tema oficial: OSCURO — Informe Global §4.10
// "Fondo negro/café profundo, tarjetas oscuras, textos claros de alto
// contraste y acentos cromáticos rojos." Diseñado para bodegas o
// condiciones de baja iluminación (§4.2.2).
import 'package:flutter/material.dart';

import '../diseno.dart';

/// Paleta del tema Oscuro, construida a partir de AppPaletaOficial.
class Estilo2Colores {
  static const Color cafeProfundo = Color(0xFF3E2723);
  static const Color fondoOscuro = AppPaletaOficial.negro;
  static const Color superficie = Color(0xFF1B1B1B);
  static const Color acentoRojo = AppPaletaOficial.rojo;
  static const Color acentoAmarillo = AppPaletaOficial.amarillo;
  static const Color error = AppPaletaOficial.rojo;
  static const Color textoClaro = AppPaletaOficial.blanco;
  static const Color textoSecundario = Color(0xFFBDBDBD);
}

class Estilo2Dimens {
  static const double xs = AppEspaciado.xs;
  static const double s = AppEspaciado.s;
  static const double m = AppEspaciado.m;
  static const double l = AppEspaciado.l;
  static const double xl = AppEspaciado.xl;
  static const double radius = AppEspaciado.radioEstandar;
}

class Estilo2TextStyles {
  static const String familia = 'Roboto';

  static const TextStyle titulo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.titulo,
    fontWeight: FontWeight.bold,
    color: Estilo2Colores.textoClaro,
  );

  static const TextStyle subtitulo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.subtitulo,
    fontWeight: FontWeight.w500,
    color: Estilo2Colores.textoSecundario,
  );

  static const TextStyle cuerpo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.cuerpo,
    fontWeight: FontWeight.normal,
    color: Estilo2Colores.textoClaro,
  );

  static const TextStyle secundario = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.secundario,
    fontWeight: FontWeight.normal,
    color: Estilo2Colores.textoSecundario,
  );

  static const TextStyle notas = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.notas,
    fontWeight: FontWeight.normal,
    color: Estilo2Colores.textoSecundario,
  );

  static const TextStyle precio = TextStyle(
    fontFamily: familia,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Estilo2Colores.acentoAmarillo,
  );
}

/// ThemeData exportable para el tema Oscuro.
ThemeData estilo2Theme() {
  final base = ThemeData.dark();

  return base.copyWith(
    brightness: Brightness.dark,
    colorScheme: base.colorScheme.copyWith(
      primary: Estilo2Colores.cafeProfundo,
      secondary: Estilo2Colores.acentoAmarillo,
      surface: Estilo2Colores.superficie,
      error: Estilo2Colores.error,
      onPrimary: Estilo2Colores.textoClaro,
      onSecondary: AppPaletaOficial.negro,
      onSurface: Estilo2Colores.textoClaro,
    ),
    scaffoldBackgroundColor: Estilo2Colores.fondoOscuro,
    appBarTheme: AppBarTheme(
      backgroundColor: Estilo2Colores.cafeProfundo,
      foregroundColor: Estilo2Colores.textoClaro,
      elevation: 2,
      titleTextStyle: Estilo2TextStyles.titulo.copyWith(
        color: Estilo2Colores.textoClaro,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: Estilo2Colores.textoClaro),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppPaletaOficial.blanco,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Estilo2Colores.acentoAmarillo,
    ),
    cardTheme: const CardThemeData(
      color: Estilo2Colores.superficie,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Estilo2Dimens.radius)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Estilo2Colores.acentoAmarillo,
        foregroundColor: AppPaletaOficial.negro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: Estilo2TextStyles.subtitulo.copyWith(
          color: AppPaletaOficial.negro,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Estilo2Colores.acentoAmarillo,
        textStyle: Estilo2TextStyles.subtitulo.copyWith(
          color: Estilo2Colores.acentoAmarillo,
        ),
      ),
    ),
    textTheme: base.textTheme
        .copyWith(
          headlineMedium: Estilo2TextStyles.titulo,
          titleMedium: Estilo2TextStyles.subtitulo,
          bodyMedium: Estilo2TextStyles.cuerpo,
          bodySmall: Estilo2TextStyles.secundario,
          labelSmall: Estilo2TextStyles.notas,
        )
        .apply(
          bodyColor: Estilo2Colores.textoClaro,
          displayColor: Estilo2Colores.textoClaro,
        ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Estilo2Colores.superficie,
      contentPadding: const EdgeInsets.symmetric(
        vertical: Estilo2Dimens.m,
        horizontal: Estilo2Dimens.m,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Estilo2Dimens.radius),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Estilo2Colores.textoSecundario),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Estilo2Colores.cafeProfundo,
      contentTextStyle: Estilo2TextStyles.cuerpo.copyWith(
        color: Estilo2Colores.textoClaro,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Estilo2Colores.superficie,
      titleTextStyle: Estilo2TextStyles.titulo.copyWith(
        color: Estilo2Colores.textoClaro,
        fontSize: AppEscalaTipografica.subtitulo,
      ),
      contentTextStyle: Estilo2TextStyles.cuerpo.copyWith(
        color: Estilo2Colores.textoClaro,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Estilo2Colores.acentoAmarillo,
        textStyle: Estilo2TextStyles.subtitulo.copyWith(
          color: Estilo2Colores.acentoAmarillo,
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: Estilo2Colores.acentoAmarillo),
    dividerColor: Colors.white12,
  );
}

/// Mapa de valores para construir el CoffeeCustomTheme del tema Oscuro.
Map<String, dynamic> coffeeCustomValuesFromEstilo2() {
  return {
    'dashboardPagePadding': const EdgeInsets.all(Estilo2Dimens.m),
    'dashboardSectionSpacing': Estilo2Dimens.xl,
    'priceBannerGradient': const LinearGradient(
      colors: [Estilo2Colores.cafeProfundo, Estilo2Colores.superficie],
    ),
    'priceBannerIconColor': Estilo2Colores.textoClaro,
    'priceBannerTitleStyle': const TextStyle(
      color: Estilo2Colores.textoClaro,
      fontSize: AppEscalaTipografica.secundario,
    ),
    'priceBannerPriceStyle': Estilo2TextStyles.precio,
    'priceBannerUpdateStyle': const TextStyle(
      color: Estilo2Colores.textoSecundario,
      fontSize: AppEscalaTipografica.notas,
    ),
    'menuCardBackgroundColor': Estilo2Colores.superficie,
    'menuCardHoverBackgroundColor': Estilo2Colores.fondoOscuro,
    'menuCardShadowHover': null,
    'menuCardIconColor': Estilo2Colores.acentoAmarillo,
    'menuCardIconSize': 40.0,
    'menuCardTitleStyle': Estilo2TextStyles.subtitulo,
    'transaccionesTotalValueTextColor': Estilo2Colores.acentoAmarillo,
    'cajaBannerBackgroundColor': Estilo2Colores.cafeProfundo,
    'cajaBannerTextStyle': const TextStyle(
      color: Estilo2Colores.textoClaro,
      fontWeight: FontWeight.bold,
      fontSize: AppEscalaTipografica.subtitulo,
    ),
    'alertaObsolescenciaColor': Estilo2Colores.acentoAmarillo,
  };
}

/// Widget de previsualización del tema Oscuro (uso en Configuraciones).
class Estilo2Preview extends StatelessWidget {
  final double samplePrice;
  final VoidCallback? onAction;

  const Estilo2Preview({super.key, this.samplePrice = 12000, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Estilo2Dimens.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tema Oscuro', style: theme.textTheme.headlineMedium),
          const SizedBox(height: Estilo2Dimens.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Estilo2Dimens.m),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Estilo2Colores.acentoAmarillo.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      AppIconos.sacoDeCafe,
                      color: Estilo2Colores.acentoAmarillo,
                    ),
                  ),
                  const SizedBox(width: Estilo2Dimens.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reserva Nocturna',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tostado oscuro, cuerpo intenso, notas a cacao',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatValue(samplePrice),
                    style: Estilo2TextStyles.precio,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Estilo2Dimens.m),
          TextField(
            decoration: InputDecoration(
              hintText: CurrencyFormatter.formatValue(0),
              prefixIcon: const Icon(
                Icons.attach_money,
                color: Estilo2Colores.acentoAmarillo,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyFormatter()],
            style: const TextStyle(color: Estilo2Colores.textoClaro),
          ),
          const SizedBox(height: Estilo2Dimens.m),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAction ?? () {},
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: Estilo2Dimens.s),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Notificaciones.informacion(context, 'Guardado'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Estilo2Colores.textoClaro,
                    side: const BorderSide(color: Colors.white12),
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
