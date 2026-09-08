// ==================== ARCHIVO: lib/core/estilos/estilo_1.dart ====================
// Tema oficial: CLARO — Informe Global §4.10
// "Fondo beige/blanco, tarjetas claras, tipografía oscura y acentos
// visuales verdes y amarillos."
import 'package:flutter/material.dart';

import '../diseno.dart';

/// Paleta del tema Claro, construida a partir de AppPaletaOficial.
class Estilo1Colores {
  static const Color primario = AppPaletaOficial.cafe;
  static const Color fondoBeige = Color(0xFFF7F3EE);
  static const Color superficie = AppPaletaOficial.blanco;
  static const Color acentoVerde = AppPaletaOficial.verde;
  static const Color acentoAmarillo = AppPaletaOficial.amarillo;
  static const Color error = AppPaletaOficial.rojo;
  static const Color textoPrincipal = Color(0xFF2E2E2E);
  static const Color textoSecundario = Color(0xFF6E6E6E);
}

class Estilo1Dimens {
  static const double xs = AppEspaciado.xs;
  static const double s = AppEspaciado.s;
  static const double m = AppEspaciado.m;
  static const double l = AppEspaciado.l;
  static const double xl = AppEspaciado.xl;
  static const double radius = AppEspaciado.radioEstandar;
}

class Estilo1TextStyles {
  static const String familia = 'Roboto';

  static const TextStyle titulo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.titulo,
    fontWeight: FontWeight.bold,
    color: Estilo1Colores.textoPrincipal,
  );

  static const TextStyle subtitulo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.subtitulo,
    fontWeight: FontWeight.w500,
    color: Estilo1Colores.textoSecundario,
  );

  static const TextStyle cuerpo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.cuerpo,
    fontWeight: FontWeight.normal,
    color: Estilo1Colores.textoPrincipal,
  );

  static const TextStyle secundario = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.secundario,
    fontWeight: FontWeight.normal,
    color: Estilo1Colores.textoSecundario,
  );

  static const TextStyle notas = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.notas,
    fontWeight: FontWeight.normal,
    color: Estilo1Colores.textoSecundario,
  );

  static const TextStyle precio = TextStyle(
    fontFamily: familia,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Estilo1Colores.primario,
  );
}

/// ThemeData exportable para el tema Claro.
ThemeData estilo1Theme() {
  final base = ThemeData.light();

  return base.copyWith(
    brightness: Brightness.light,
    colorScheme: base.colorScheme.copyWith(
      primary: Estilo1Colores.primario,
      secondary: Estilo1Colores.acentoAmarillo,
      surface: Estilo1Colores.superficie,
      onSurface: Estilo1Colores.textoPrincipal,
      error: Estilo1Colores.error,
    ),
    scaffoldBackgroundColor: Estilo1Colores.fondoBeige,
    appBarTheme: AppBarTheme(
      backgroundColor: Estilo1Colores.primario,
      foregroundColor: AppPaletaOficial.blanco,
      elevation: 2,
      titleTextStyle: Estilo1TextStyles.titulo.copyWith(
        color: AppPaletaOficial.blanco,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: AppPaletaOficial.blanco),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppPaletaOficial.blanco,
      unselectedLabelColor: Colors.white70,
      indicatorColor: AppPaletaOficial.amarillo,
    ),
    cardTheme: const CardThemeData(
      color: Estilo1Colores.superficie,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Estilo1Dimens.radius)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Estilo1Colores.primario,
        foregroundColor: AppPaletaOficial.blanco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: Estilo1TextStyles.subtitulo.copyWith(
          color: AppPaletaOficial.blanco,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Estilo1Colores.acentoAmarillo,
        textStyle: Estilo1TextStyles.subtitulo.copyWith(
          color: Estilo1Colores.acentoAmarillo,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Estilo1Colores.acentoAmarillo,
        textStyle: Estilo1TextStyles.subtitulo.copyWith(
          color: Estilo1Colores.acentoAmarillo,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Estilo1Colores.superficie,
      titleTextStyle: Estilo1TextStyles.titulo.copyWith(
        fontSize: AppEscalaTipografica.subtitulo,
      ),
      contentTextStyle: Estilo1TextStyles.cuerpo,
    ),
    textTheme: base.textTheme
        .copyWith(
          headlineMedium: Estilo1TextStyles.titulo,
          titleMedium: Estilo1TextStyles.subtitulo,
          bodyMedium: Estilo1TextStyles.cuerpo,
          bodySmall: Estilo1TextStyles.secundario,
          labelSmall: Estilo1TextStyles.notas,
        )
        .apply(
          bodyColor: Estilo1Colores.textoPrincipal,
          displayColor: Estilo1Colores.textoPrincipal,
        ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Estilo1Colores.superficie,
      contentPadding: const EdgeInsets.symmetric(
        vertical: Estilo1Dimens.m,
        horizontal: Estilo1Dimens.m,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Estilo1Dimens.radius),
        borderSide: BorderSide.none,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Estilo1Colores.primario,
      contentTextStyle: Estilo1TextStyles.cuerpo.copyWith(
        color: AppPaletaOficial.blanco,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    iconTheme: const IconThemeData(color: Estilo1Colores.primario),
    dividerColor: Colors.black12,
  );
}

/// Mapa de valores para construir el CoffeeCustomTheme del tema Claro.
Map<String, dynamic> coffeeCustomValuesFromEstilo1() {
  return {
    'dashboardPagePadding': const EdgeInsets.all(Estilo1Dimens.m),
    'dashboardSectionSpacing': Estilo1Dimens.xl,
    'priceBannerGradient': const LinearGradient(
      colors: [Color(0xFF8D6E63), Estilo1Colores.primario],
    ),
    'priceBannerIconColor': AppPaletaOficial.blanco,
    'priceBannerTitleStyle': const TextStyle(
      color: AppPaletaOficial.blanco,
      fontSize: AppEscalaTipografica.secundario,
    ),
    'priceBannerPriceStyle': Estilo1TextStyles.precio.copyWith(
      color: AppPaletaOficial.blanco,
    ),
    'priceBannerUpdateStyle': const TextStyle(
      color: Colors.white70,
      fontSize: AppEscalaTipografica.notas,
    ),
    'menuCardBackgroundColor': Estilo1Colores.superficie,
    'menuCardHoverBackgroundColor': Estilo1Colores.fondoBeige,
    'menuCardShadowHover': null,
    'menuCardIconColor': Estilo1Colores.primario,
    'menuCardIconSize': 40.0,
    'menuCardTitleStyle': Estilo1TextStyles.subtitulo,
    'transaccionesTotalValueTextColor': Estilo1Colores.primario,
    'cajaBannerBackgroundColor': Estilo1Colores.primario,
    'cajaBannerTextStyle': const TextStyle(
      color: AppPaletaOficial.blanco,
      fontWeight: FontWeight.bold,
      fontSize: AppEscalaTipografica.subtitulo,
    ),
    'alertaObsolescenciaColor': Estilo1Colores.acentoAmarillo,
  };
}

/// Widget de previsualización del tema Claro (uso en Configuraciones).
class Estilo1Preview extends StatelessWidget {
  final double samplePrice;
  final VoidCallback? onAction;

  const Estilo1Preview({super.key, this.samplePrice = 8500, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Estilo1Dimens.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tema Claro', style: theme.textTheme.headlineMedium),
          const SizedBox(height: Estilo1Dimens.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Estilo1Dimens.m),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Estilo1Colores.primario.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      AppIconos.granoDeCafe,
                      color: Estilo1Colores.primario,
                    ),
                  ),
                  const SizedBox(width: Estilo1Dimens.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Café de la casa',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mezcla especial con notas a chocolate',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatValue(samplePrice),
                    style: Estilo1TextStyles.precio,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Estilo1Dimens.m),
          TextField(
            decoration: InputDecoration(
              hintText: CurrencyFormatter.formatValue(0),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyFormatter()],
          ),
          const SizedBox(height: Estilo1Dimens.m),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAction ?? () {},
                  icon: const Icon(Icons.check),
                  label: const Text('Aceptar'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: Estilo1Dimens.s),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Notificaciones.informacion(context, 'Acción secundaria'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
