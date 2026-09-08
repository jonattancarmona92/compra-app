// ==================== ARCHIVO: lib/core/estilos/estilo_3.dart ====================
// Tema oficial: CORPORATIVO — Informe Global §4.10
// "Identidad visual institucional con verdes de marca y amarillos
// cafeteros, diseñado para informes o presentaciones." Usa Montserrat
// para reportes según §4.5.
import 'package:flutter/material.dart';

import '../diseno.dart';

/// Paleta del tema Corporativo, construida a partir de AppPaletaOficial.
class Estilo3Colores {
  static const Color marcaVerde = AppPaletaOficial.verde;
  static const Color amarilloCafe = AppPaletaOficial.amarillo;
  static const Color beigeFondo = Color(0xFFF3EFE8);
  static const Color superficie = AppPaletaOficial.blanco;
  static const Color error = AppPaletaOficial.rojo;
  static const Color textoPrincipal = Color(0xFF263238);
  static const Color textoSecundario = Color(0xFF546E7A);
}

class Estilo3Dimens {
  static const double xs = AppEspaciado.xs;
  static const double s = AppEspaciado.s;
  static const double m = AppEspaciado.m;
  static const double l = AppEspaciado.l;
  static const double xl = AppEspaciado.xl;
  static const double radius = AppEspaciado.radioEstandar;
}

class Estilo3TextStyles {
  /// Tipografía corporativa alternativa (§4.5): informes, PDFs y
  /// presentaciones de marca usan Montserrat en lugar de Roboto.
  static const String familia = 'Montserrat';

  static const TextStyle titulo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.titulo,
    fontWeight: FontWeight.bold,
    color: Estilo3Colores.textoPrincipal,
  );

  static const TextStyle subtitulo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.subtitulo,
    fontWeight: FontWeight.w600,
    color: Estilo3Colores.textoSecundario,
  );

  static const TextStyle cuerpo = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.cuerpo,
    fontWeight: FontWeight.normal,
    color: Estilo3Colores.textoPrincipal,
  );

  static const TextStyle secundario = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.secundario,
    fontWeight: FontWeight.normal,
    color: Estilo3Colores.textoSecundario,
  );

  static const TextStyle notas = TextStyle(
    fontFamily: familia,
    fontSize: AppEscalaTipografica.notas,
    fontWeight: FontWeight.normal,
    color: Estilo3Colores.textoSecundario,
  );

  static const TextStyle precio = TextStyle(
    fontFamily: familia,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Estilo3Colores.marcaVerde,
  );
}

/// ThemeData exportable para el tema Corporativo.
ThemeData estilo3Theme() {
  final base = ThemeData.light();

  return base.copyWith(
    brightness: Brightness.light,
    colorScheme: base.colorScheme.copyWith(
      primary: Estilo3Colores.marcaVerde,
      secondary: Estilo3Colores.amarilloCafe,
      surface: Estilo3Colores.superficie,
      error: Estilo3Colores.error,
      onPrimary: AppPaletaOficial.blanco,
      onSecondary: AppPaletaOficial.negro,
      onSurface: Estilo3Colores.textoPrincipal,
    ),
    scaffoldBackgroundColor: Estilo3Colores.beigeFondo,
    appBarTheme: AppBarTheme(
      backgroundColor: Estilo3Colores.marcaVerde,
      foregroundColor: AppPaletaOficial.blanco,
      elevation: 2,
      titleTextStyle: Estilo3TextStyles.titulo.copyWith(
        color: AppPaletaOficial.blanco,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: AppPaletaOficial.blanco),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppPaletaOficial.blanco,
      unselectedLabelColor: Colors.white70,
      indicatorColor: AppPaletaOficial.amarillo,
    ),
    cardTheme: const CardThemeData(
      color: Estilo3Colores.superficie,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Estilo3Dimens.radius)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Estilo3Colores.marcaVerde,
        foregroundColor: AppPaletaOficial.blanco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: Estilo3TextStyles.subtitulo.copyWith(
          color: AppPaletaOficial.blanco,
        ),
      ),
    ),
    textTheme: base.textTheme
        .copyWith(
          headlineMedium: Estilo3TextStyles.titulo,
          titleMedium: Estilo3TextStyles.subtitulo,
          bodyMedium: Estilo3TextStyles.cuerpo,
          bodySmall: Estilo3TextStyles.secundario,
          labelSmall: Estilo3TextStyles.notas,
        )
        .apply(
          bodyColor: Estilo3Colores.textoPrincipal,
          displayColor: Estilo3Colores.textoPrincipal,
        ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Estilo3Colores.superficie,
      contentPadding: const EdgeInsets.symmetric(
        vertical: Estilo3Dimens.m,
        horizontal: Estilo3Dimens.m,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Estilo3Dimens.radius),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Estilo3Colores.marcaVerde,
      contentTextStyle: Estilo3TextStyles.cuerpo.copyWith(
        color: AppPaletaOficial.blanco,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerColor: Colors.black12,
    iconTheme: const IconThemeData(color: Estilo3Colores.marcaVerde),
  );
}

/// Mapa de valores para construir el CoffeeCustomTheme del tema Corporativo.
Map<String, dynamic> coffeeCustomValuesFromEstilo3() {
  return {
    'dashboardPagePadding': const EdgeInsets.all(Estilo3Dimens.m),
    'dashboardSectionSpacing': Estilo3Dimens.xl,
    'priceBannerGradient': const LinearGradient(
      colors: [Estilo3Colores.marcaVerde, Color(0xFF4CAF50)],
    ),
    'priceBannerIconColor': AppPaletaOficial.blanco,
    'priceBannerTitleStyle': const TextStyle(
      color: AppPaletaOficial.blanco,
      fontSize: AppEscalaTipografica.secundario,
    ),
    'priceBannerPriceStyle': Estilo3TextStyles.precio.copyWith(
      color: AppPaletaOficial.blanco,
    ),
    'priceBannerUpdateStyle': const TextStyle(
      color: Colors.white70,
      fontSize: AppEscalaTipografica.notas,
    ),
    'menuCardBackgroundColor': Estilo3Colores.superficie,
    'menuCardHoverBackgroundColor': Estilo3Colores.beigeFondo,
    'menuCardShadowHover': null,
    'menuCardIconColor': Estilo3Colores.marcaVerde,
    'menuCardIconSize': 40.0,
    'menuCardTitleStyle': Estilo3TextStyles.subtitulo,
    'transaccionesTotalValueTextColor': Estilo3Colores.amarilloCafe,
    'cajaBannerBackgroundColor': Estilo3Colores.marcaVerde,
    'cajaBannerTextStyle': const TextStyle(
      color: AppPaletaOficial.blanco,
      fontWeight: FontWeight.bold,
      fontSize: AppEscalaTipografica.subtitulo,
    ),
    'alertaObsolescenciaColor': Estilo3Colores.amarilloCafe,
  };
}

/// Widget de previsualización del tema Corporativo (uso en Configuraciones).
class Estilo3Preview extends StatelessWidget {
  final double samplePrice;
  final VoidCallback? onAction;

  const Estilo3Preview({super.key, this.samplePrice = 10000, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Estilo3Dimens.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tema Corporativo', style: theme.textTheme.headlineMedium),
          const SizedBox(height: Estilo3Dimens.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Estilo3Dimens.m),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Estilo3Colores.amarilloCafe.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      AppIconos.cajaRegistradora,
                      color: Estilo3Colores.amarilloCafe,
                    ),
                  ),
                  const SizedBox(width: Estilo3Dimens.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informe Corporativo',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Resumen ejecutivo y métricas clave',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatValue(samplePrice),
                    style: Estilo3TextStyles.precio,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Estilo3Dimens.m),
          TextField(
            decoration: InputDecoration(
              hintText: CurrencyFormatter.formatValue(0),
              prefixIcon: const Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyFormatter()],
          ),
          const SizedBox(height: Estilo3Dimens.m),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAction ?? () {},
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generar informe'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: Estilo3Dimens.s),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Notificaciones.exito(context, 'Exportado'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('Exportar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
