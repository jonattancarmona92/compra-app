// ==================== ARCHIVO: lib/core/diseno.dart ====================
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'estilos/estilo_1.dart' as estilo1;
import 'estilos/estilo_2.dart' as estilo2;
import 'estilos/estilo_3.dart' as estilo3;
import 'utilitarios/calculos_operaciones.dart';

/// =====================================================================
/// PALETA EXACTA OFICIAL — Informe Global §4.4
/// Fuente única de verdad para los 6 colores principales de marca.
/// Los archivos de estilos/tema consumen estas constantes; no las repiten.
/// =====================================================================
class AppPaletaOficial {
  /// Uso: Fondos claros, textos secundarios.
  static const Color blanco = Color(0xFFFFFFFF);

  /// Uso: Fondos oscuros, tipografía en modo oscuro.
  static const Color negro = Color(0xFF000000);

  /// Uso: Color institucional, botones primarios.
  static const Color cafe = Color(0xFF6F4E37);

  /// Uso: Alertas, advertencias críticas.
  static const Color rojo = Color(0xFFC62828);

  /// Uso: Indicadores de obsolescencia, acentos.
  static const Color amarillo = Color(0xFFF9A825);

  /// Uso: Confirmaciones, estados positivos.
  static const Color verde = Color(0xFF2E7D32);
}

/// =====================================================================
/// ACCESORES DE SUPERFICIE/BORDE/TEXTO SEGÚN EL ESTILO ACTIVO — §4.4/§4.10
/// Las pantallas NO deben fijar colores de superficie con literales o
/// con AppPaletaOficial.blanco/negro (que no se adaptan). Para que la
/// UI se adapte a los estilos claro, oscuro y corporativo (definidos en
/// core/estilos/*), los widgets deben consultar estos accesores, que
/// leen el colorScheme establecido por cada estilo.
/// =====================================================================
class AppDiseno {
  /// Fondo estándar de tarjetas y paneles (blanco en claro/corporativo,
  /// #1B1B1B en oscuro, según el estilo activo).
  static Color superficie(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Borde sutil estándar de tarjetas y contenedores.
  static Color bordeTarjeta(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  /// Texto secundario (descripciones, direcciones, notas, campos).
  static Color textoSecundario(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
}

/// =====================================================================
/// ESCALA TIPOGRÁFICA — Informe Global §4.6
/// =====================================================================
class AppEscalaTipografica {
  /// Título principal: 24–26 pt (se usa 26 como valor de referencia).
  static const double titulo = 26.0;

  /// Subtítulo: 20 pt.
  static const double subtitulo = 20.0;

  /// Texto cuerpo: 16 pt.
  static const double cuerpo = 16.0;

  /// Texto secundario: 14 pt.
  static const double secundario = 14.0;

  /// Notas y etiquetas: 12 pt.
  static const double notas = 12.0;
}

/// =====================================================================
/// ESCALA DE ESPACIADO — Informe Global §4.7 (múltiplos de 8 px)
/// =====================================================================
class AppEspaciado {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;

  /// Radio de borde estándar (no forma parte de la escala oficial de
  /// espaciado, pero se centraliza aquí para evitar radios sueltos
  /// definidos localmente en pantallas, según §4.14).
  static const double radioEstandar = 12.0;

  /// Radio de borde ampliado para tarjetas y banners de mayor
  /// prominencia (misma filosofía de centralización que
  /// [radioEstandar], §4.14).
  static const double radioLg = 16.0;
}

/// =====================================================================
/// BREAKPOINTS — Informe Global §4.8
/// =====================================================================
class AppBreakpoints {
  static const double movilMax = 600.0;
  static const double tabletMin = 601.0;
  static const double tabletMax = 1024.0;
  static const double escritorioMin = 1025.0;

  static bool esMovil(double anchoPantalla) => anchoPantalla <= movilMax;

  static bool esTablet(double anchoPantalla) =>
      anchoPantalla > movilMax && anchoPantalla <= tabletMax;

  static bool esEscritorio(double anchoPantalla) => anchoPantalla > tabletMax;
}

/// =====================================================================
/// BIBLIOTECA DE ÍCONOS — Informe Global §4.12
/// Material Icons como base. Los cuatro íconos personalizados del
/// negocio cafetero se mapean aquí como marcador hasta que se incorpore
/// una fuente de íconos exclusiva; el resto de la app siempre debe
/// referenciar esta clase y no Icons.* directamente en las pantallas.
/// =====================================================================
class AppIconos {
  static const IconData granoDeCafe = Icons.coffee;
  static const IconData sacoDeCafe = Icons.inventory_2;
  static const IconData secadora = Icons.dry_cleaning;
  static const IconData cajaRegistradora = Icons.point_of_sale;
}

/// =====================================================================
/// ANIMACIONES Y TRANSICIONES — Informe Global §4.13
/// =====================================================================
class AppAnimaciones {
  /// Fade in/out: pantallas de arranque, cierres contables, cargas.
  static const Duration fade = Duration(milliseconds: 300);

  /// Slide horizontal: despliegue lateral de submenús en el Dashboard.
  static const Duration slideHorizontal = Duration(milliseconds: 250);

  /// Scale-up: feedback visual en botones principales al presionar.
  static const Duration scaleUp = Duration(milliseconds: 150);

  static const Curve curvaEstandar = Curves.easeInOut;
}

/// =====================================================================
/// FORMATEADOR DE MONEDA COLOMBIANA — Informe Global §4.2.1
/// Fuente ÚNICA de formateo COP; ningún otro archivo debe declarar un
/// formateador de moneda propio.
/// =====================================================================
class CurrencyFormatter extends TextInputFormatter {
  /// El patrón propio fija el símbolo del peso ($) como PREFIJO (símbolo
  /// al inicio, nunca al final) con separadores de miles y sin decimales.
  /// Informe Global §4.2.1.
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
    customPattern: '¤#,##0',
  );

  /// Valor mínimo (en pesos) que debe tener TODO campo monetario de la app.
  static const double minimo = 100;

  /// Escala de redondeo de los valores monetarios resultantes. Por
  /// defecto se redondea a la centena (§7.6.2); si está activo "Redondear
  /// a la Unidad de Mil" (Configuración > Complementos) se redondea a la
  /// milésima. Toda la lógica vive en [CalculosOperaciones] (§7.8).
  static int _escalaRedondeo = CalculosOperaciones.redondeoCentena;

  /// Activa o desactiva el redondeo de resultados al múltiplo de [escala].
  static void configurarRedondeo(int escala) =>
      _escalaRedondeo = CalculosOperaciones.normalizarEscala(escala);

  static double _aplicarRedondeo(double valor) =>
      CalculosOperaciones.redondearMoneda(valor, escala: _escalaRedondeo);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return const TextEditingValue(text: '');
    final number = double.parse(numericString);
    final formatted = _formatter.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Formatea un valor como moneda. Los RESULTADOS se redondean cuando está
  /// activo "Redondear a la Unidad de Mil"; la entrada en los campos se
  /// mantiene siempre exacta.
  static String formatValue(double value) =>
      _formatter.format(_aplicarRedondeo(value));

  /// Formatea un valor monetario SIN redondear el resultado. Se usa para
  /// precargar campos de entrada con el valor exacto ya registrado (p. ej.
  /// el precio de una transacción pendiente): al volver a parsearlo con
  /// [parseValue] se obtiene exactamente el mismo número.
  static String formatCifraExacta(double value) => _formatter.format(value);

  /// Validación estándar para campos monetarios: obligatorio y con valor
  /// mínimo de [minimo] pesos. Retorna `null` si es válido o el error.
  static String? validar(String? texto) {
    final t = texto?.trim() ?? '';
    if (t.isEmpty) return 'Ingrese un valor.';
    final valor = parseValue(t);
    if (valor < minimo) {
      return 'El valor mínimo es ${_formatter.format(minimo)}.';
    }
    return null;
  }

  /// Como [validar] pero permite el valor 0 (p. ej. anticipos o precios
  /// aún no definidos); cualquier valor entre 1 y 99 queda rechazado.
  static String? validarCeroPermitido(String? texto) {
    final t = texto?.trim() ?? '';
    if (t.isEmpty) return 'Ingrese un valor.';
    final valor = parseValue(t);
    if (valor > 0 && valor < minimo) {
      return 'El valor mínimo es ${_formatter.format(minimo)}.';
    }
    return null;
  }

  /// Convierte cualquier texto monetario (ya formateado o crudo) a un
  /// valor numérico, descartando símbolos y separadores. Fuente única de
  /// parsing COP junto con `formatValue`.
  static double parseValue(String text) {
    final numericString = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }
}

/// =====================================================================
/// NOTIFICACIONES CENTRALIZADAS — Informe Global §4.2.1
/// =====================================================================
class Notificaciones {
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppPaletaOficial.blanco),
            const SizedBox(width: AppEspaciado.s),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: AppAnimaciones.fade * 6,
      ),
    );
  }

  static void exito(BuildContext context, String message) {
    _showSnackBar(context, message, AppPaletaOficial.verde, Icons.check_circle);
  }

  static void error(BuildContext context, String message) {
    _showSnackBar(context, message, AppPaletaOficial.rojo, Icons.error);
  }

  static void advertencia(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppPaletaOficial.amarillo,
      Icons.warning_amber,
    );
  }

  static void informacion(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue.shade700, Icons.info);
  }
}

/// =====================================================================
/// TÍTULO INSTITUCIONAL REUTILIZABLE — Informe Global §4.2.1
/// =====================================================================
class CoffeeAppTitle extends StatelessWidget {
  final String title;
  const CoffeeAppTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppPaletaOficial.cafe,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// =====================================================================
/// EXTENSIÓN DE TEMA PERSONALIZADA — Informe Global §4.2.1
/// =====================================================================
@immutable
class CoffeeCustomTheme extends ThemeExtension<CoffeeCustomTheme> {
  final EdgeInsets dashboardPagePadding;
  final double dashboardSectionSpacing;
  final Gradient priceBannerGradient;
  final Color priceBannerIconColor;
  final TextStyle priceBannerTitleStyle;
  final TextStyle priceBannerPriceStyle;
  final TextStyle priceBannerUpdateStyle;
  final Color menuCardBackgroundColor;
  final Color menuCardHoverBackgroundColor;
  final BoxShadow? menuCardShadowHover;
  final Color menuCardIconColor;
  final double menuCardIconSize;
  final TextStyle menuCardTitleStyle;
  final Color transaccionesTotalValueTextColor;
  final Color cajaBannerBackgroundColor;
  final TextStyle cajaBannerTextStyle;
  final Color alertaObsolescenciaColor;
  final Color precioTendenciaSubeColor;
  final Color precioTendenciaBajaColor;
  final Color precioTendenciaEstableColor;
  final TextStyle precioTendenciaEtiquetaStyle;

  const CoffeeCustomTheme({
    this.dashboardPagePadding = const EdgeInsets.all(AppEspaciado.l),
    this.dashboardSectionSpacing = AppEspaciado.xl,
    this.priceBannerGradient = const LinearGradient(
      colors: [Color(0xFF8D6E63), AppPaletaOficial.cafe],
    ),
    this.priceBannerIconColor = AppPaletaOficial.blanco,
    this.priceBannerTitleStyle = const TextStyle(
      color: AppPaletaOficial.blanco,
      fontSize: AppEscalaTipografica.secundario,
    ),
    this.priceBannerPriceStyle = const TextStyle(
      color: AppPaletaOficial.blanco,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    this.priceBannerUpdateStyle = const TextStyle(
      color: Colors.white70,
      fontSize: AppEscalaTipografica.notas,
    ),
    this.menuCardBackgroundColor = AppPaletaOficial.blanco,
    this.menuCardHoverBackgroundColor = const Color(0xFFF5F5F5),
    this.menuCardShadowHover,
    this.menuCardIconColor = AppPaletaOficial.cafe,
    this.menuCardIconSize = 40,
    this.menuCardTitleStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.transaccionesTotalValueTextColor = AppPaletaOficial.cafe,
    this.cajaBannerBackgroundColor = AppPaletaOficial.cafe,
    this.cajaBannerTextStyle = const TextStyle(
      color: AppPaletaOficial.blanco,
      fontWeight: FontWeight.bold,
      fontSize: AppEscalaTipografica.subtitulo,
    ),
    this.alertaObsolescenciaColor = AppPaletaOficial.amarillo,
    this.precioTendenciaSubeColor = AppPaletaOficial.verde,
    this.precioTendenciaBajaColor = AppPaletaOficial.rojo,
    this.precioTendenciaEstableColor = AppPaletaOficial.amarillo,
    this.precioTendenciaEtiquetaStyle = const TextStyle(
      color: Colors.white70,
      fontSize: AppEscalaTipografica.notas,
    ),
  });

  @override
  CoffeeCustomTheme copyWith({
    EdgeInsets? dashboardPagePadding,
    double? dashboardSectionSpacing,
    Gradient? priceBannerGradient,
    Color? priceBannerIconColor,
    TextStyle? priceBannerTitleStyle,
    TextStyle? priceBannerPriceStyle,
    TextStyle? priceBannerUpdateStyle,
    Color? menuCardBackgroundColor,
    Color? menuCardHoverBackgroundColor,
    BoxShadow? menuCardShadowHover,
    Color? menuCardIconColor,
    double? menuCardIconSize,
    TextStyle? menuCardTitleStyle,
    Color? transaccionesTotalValueTextColor,
    Color? cajaBannerBackgroundColor,
    TextStyle? cajaBannerTextStyle,
    Color? alertaObsolescenciaColor,
    Color? precioTendenciaSubeColor,
    Color? precioTendenciaBajaColor,
    Color? precioTendenciaEstableColor,
    TextStyle? precioTendenciaEtiquetaStyle,
  }) {
    return CoffeeCustomTheme(
      dashboardPagePadding: dashboardPagePadding ?? this.dashboardPagePadding,
      dashboardSectionSpacing:
          dashboardSectionSpacing ?? this.dashboardSectionSpacing,
      priceBannerGradient: priceBannerGradient ?? this.priceBannerGradient,
      priceBannerIconColor: priceBannerIconColor ?? this.priceBannerIconColor,
      priceBannerTitleStyle:
          priceBannerTitleStyle ?? this.priceBannerTitleStyle,
      priceBannerPriceStyle:
          priceBannerPriceStyle ?? this.priceBannerPriceStyle,
      priceBannerUpdateStyle:
          priceBannerUpdateStyle ?? this.priceBannerUpdateStyle,
      menuCardBackgroundColor:
          menuCardBackgroundColor ?? this.menuCardBackgroundColor,
      menuCardHoverBackgroundColor:
          menuCardHoverBackgroundColor ?? this.menuCardHoverBackgroundColor,
      menuCardShadowHover: menuCardShadowHover ?? this.menuCardShadowHover,
      menuCardIconColor: menuCardIconColor ?? this.menuCardIconColor,
      menuCardIconSize: menuCardIconSize ?? this.menuCardIconSize,
      menuCardTitleStyle: menuCardTitleStyle ?? this.menuCardTitleStyle,
      transaccionesTotalValueTextColor:
          transaccionesTotalValueTextColor ??
          this.transaccionesTotalValueTextColor,
      cajaBannerBackgroundColor:
          cajaBannerBackgroundColor ?? this.cajaBannerBackgroundColor,
      cajaBannerTextStyle: cajaBannerTextStyle ?? this.cajaBannerTextStyle,
      alertaObsolescenciaColor:
          alertaObsolescenciaColor ?? this.alertaObsolescenciaColor,
      precioTendenciaSubeColor:
          precioTendenciaSubeColor ?? this.precioTendenciaSubeColor,
      precioTendenciaBajaColor:
          precioTendenciaBajaColor ?? this.precioTendenciaBajaColor,
      precioTendenciaEstableColor:
          precioTendenciaEstableColor ?? this.precioTendenciaEstableColor,
      precioTendenciaEtiquetaStyle:
          precioTendenciaEtiquetaStyle ?? this.precioTendenciaEtiquetaStyle,
    );
  }

  @override
  CoffeeCustomTheme lerp(ThemeExtension<CoffeeCustomTheme>? other, double t) {
    if (other is! CoffeeCustomTheme) return this;
    return CoffeeCustomTheme(
      dashboardPagePadding:
          EdgeInsets.lerp(
            dashboardPagePadding,
            other.dashboardPagePadding,
            t,
          ) ??
          dashboardPagePadding,
      dashboardSectionSpacing:
          ui.lerpDouble(
            dashboardSectionSpacing,
            other.dashboardSectionSpacing,
            t,
          ) ??
          dashboardSectionSpacing,
      priceBannerGradient: t < 0.5
          ? priceBannerGradient
          : other.priceBannerGradient,
      priceBannerIconColor:
          Color.lerp(priceBannerIconColor, other.priceBannerIconColor, t) ??
          priceBannerIconColor,
      priceBannerTitleStyle:
          TextStyle.lerp(
            priceBannerTitleStyle,
            other.priceBannerTitleStyle,
            t,
          ) ??
          priceBannerTitleStyle,
      priceBannerPriceStyle:
          TextStyle.lerp(
            priceBannerPriceStyle,
            other.priceBannerPriceStyle,
            t,
          ) ??
          priceBannerPriceStyle,
      priceBannerUpdateStyle:
          TextStyle.lerp(
            priceBannerUpdateStyle,
            other.priceBannerUpdateStyle,
            t,
          ) ??
          priceBannerUpdateStyle,
      menuCardBackgroundColor:
          Color.lerp(
            menuCardBackgroundColor,
            other.menuCardBackgroundColor,
            t,
          ) ??
          menuCardBackgroundColor,
      menuCardHoverBackgroundColor:
          Color.lerp(
            menuCardHoverBackgroundColor,
            other.menuCardHoverBackgroundColor,
            t,
          ) ??
          menuCardHoverBackgroundColor,
      menuCardShadowHover: t < 0.5
          ? menuCardShadowHover
          : other.menuCardShadowHover,
      menuCardIconColor:
          Color.lerp(menuCardIconColor, other.menuCardIconColor, t) ??
          menuCardIconColor,
      menuCardIconSize:
          ui.lerpDouble(menuCardIconSize, other.menuCardIconSize, t) ??
          menuCardIconSize,
      menuCardTitleStyle:
          TextStyle.lerp(menuCardTitleStyle, other.menuCardTitleStyle, t) ??
          menuCardTitleStyle,
      transaccionesTotalValueTextColor:
          Color.lerp(
            transaccionesTotalValueTextColor,
            other.transaccionesTotalValueTextColor,
            t,
          ) ??
          transaccionesTotalValueTextColor,
      cajaBannerBackgroundColor:
          Color.lerp(
            cajaBannerBackgroundColor,
            other.cajaBannerBackgroundColor,
            t,
          ) ??
          cajaBannerBackgroundColor,
      cajaBannerTextStyle:
          TextStyle.lerp(cajaBannerTextStyle, other.cajaBannerTextStyle, t) ??
          cajaBannerTextStyle,
      alertaObsolescenciaColor:
          Color.lerp(
            alertaObsolescenciaColor,
            other.alertaObsolescenciaColor,
            t,
          ) ??
          alertaObsolescenciaColor,
      precioTendenciaSubeColor:
          Color.lerp(
            precioTendenciaSubeColor,
            other.precioTendenciaSubeColor,
            t,
          ) ??
          precioTendenciaSubeColor,
      precioTendenciaBajaColor:
          Color.lerp(
            precioTendenciaBajaColor,
            other.precioTendenciaBajaColor,
            t,
          ) ??
          precioTendenciaBajaColor,
      precioTendenciaEstableColor:
          Color.lerp(
            precioTendenciaEstableColor,
            other.precioTendenciaEstableColor,
            t,
          ) ??
          precioTendenciaEstableColor,
      precioTendenciaEtiquetaStyle:
          TextStyle.lerp(
            precioTendenciaEtiquetaStyle,
            other.precioTendenciaEtiquetaStyle,
            t,
          ) ??
          precioTendenciaEtiquetaStyle,
    );
  }
}

/// =====================================================================
/// ENUM DE TEMAS OFICIALES — Informe Global §4.10
/// =====================================================================
enum CoffeeStyle { claro, oscuro, corporativo }

/// =====================================================================
/// MOTOR INTERNO DE TEMA (ChangeNotifier con persistencia local)
/// Es el motor que usa AppThemeSelector; no se expone directamente
/// a las pantallas, que deben consumir AppThemeSelector.of(context).
/// =====================================================================
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'coffee_selected_style';

  CoffeeStyle _current = CoffeeStyle.claro;
  ThemeData _currentTheme = estilo1.estilo1Theme();
  CoffeeCustomTheme _currentExtension = _coffeeCustomFromEstilo(
    CoffeeStyle.claro,
  );

  ThemeController() {
    _loadFromPrefs();
  }

  CoffeeStyle get currentStyle => _current;
  ThemeData get themeData => _currentTheme;
  CoffeeCustomTheme get extensionData => _currentExtension;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idx = prefs.getInt(_prefsKey);
      if (idx != null && idx >= 0 && idx < CoffeeStyle.values.length) {
        await setStyle(CoffeeStyle.values[idx], persist: false);
      } else {
        notifyListeners();
      }
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> setStyle(CoffeeStyle style, {bool persist = true}) async {
    _current = style;
    _currentTheme = _themeFromStyle(style);
    _currentExtension = _coffeeCustomFromEstilo(style);
    notifyListeners();
    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, style.index);
    }
  }

  static ThemeData _themeFromStyle(CoffeeStyle style) {
    switch (style) {
      case CoffeeStyle.claro:
        return estilo1.estilo1Theme();
      case CoffeeStyle.oscuro:
        return estilo2.estilo2Theme();
      case CoffeeStyle.corporativo:
        return estilo3.estilo3Theme();
    }
  }

  /// Expone el [ThemeData] de un estilo concreto, para previsualización
  /// en pantallas (p. ej. Diseño y Estilos, §3.6) sin alterar el tema
  /// activo (Informe Global §4.10).
  static ThemeData themeFromStyle(CoffeeStyle style) =>
      _themeFromStyle(style);

  /// Expone el [CoffeeCustomTheme] de un estilo concreto, para
  /// previsualización en pantallas sin alterar el tema activo.
  static CoffeeCustomTheme coffeeCustomFromEstilo(CoffeeStyle style) =>
      _coffeeCustomFromEstilo(style);

  static CoffeeCustomTheme _coffeeCustomFromEstilo(CoffeeStyle style) {
    switch (style) {
      case CoffeeStyle.claro:
        return _coffeeCustomFromMap(estilo1.coffeeCustomValuesFromEstilo1());
      case CoffeeStyle.oscuro:
        return _coffeeCustomFromMap(estilo2.coffeeCustomValuesFromEstilo2());
      case CoffeeStyle.corporativo:
        return _coffeeCustomFromMap(estilo3.coffeeCustomValuesFromEstilo3());
    }
  }

  static CoffeeCustomTheme _coffeeCustomFromMap(Map<String, dynamic> map) {
    const defecto = CoffeeCustomTheme();
    return CoffeeCustomTheme(
      dashboardPagePadding:
          map['dashboardPagePadding'] as EdgeInsets? ??
          defecto.dashboardPagePadding,
      dashboardSectionSpacing:
          map['dashboardSectionSpacing'] as double? ??
          defecto.dashboardSectionSpacing,
      priceBannerGradient:
          map['priceBannerGradient'] as Gradient? ??
          defecto.priceBannerGradient,
      priceBannerIconColor:
          map['priceBannerIconColor'] as Color? ?? defecto.priceBannerIconColor,
      priceBannerTitleStyle:
          map['priceBannerTitleStyle'] as TextStyle? ??
          defecto.priceBannerTitleStyle,
      priceBannerPriceStyle:
          map['priceBannerPriceStyle'] as TextStyle? ??
          defecto.priceBannerPriceStyle,
      priceBannerUpdateStyle:
          map['priceBannerUpdateStyle'] as TextStyle? ??
          defecto.priceBannerUpdateStyle,
      menuCardBackgroundColor:
          map['menuCardBackgroundColor'] as Color? ??
          defecto.menuCardBackgroundColor,
      menuCardHoverBackgroundColor:
          map['menuCardHoverBackgroundColor'] as Color? ??
          defecto.menuCardHoverBackgroundColor,
      menuCardShadowHover: map['menuCardShadowHover'] as BoxShadow?,
      menuCardIconColor:
          map['menuCardIconColor'] as Color? ?? defecto.menuCardIconColor,
      menuCardIconSize:
          map['menuCardIconSize'] as double? ?? defecto.menuCardIconSize,
      menuCardTitleStyle:
          map['menuCardTitleStyle'] as TextStyle? ?? defecto.menuCardTitleStyle,
      transaccionesTotalValueTextColor:
          map['transaccionesTotalValueTextColor'] as Color? ??
          defecto.transaccionesTotalValueTextColor,
      cajaBannerBackgroundColor:
          map['cajaBannerBackgroundColor'] as Color? ??
          defecto.cajaBannerBackgroundColor,
      cajaBannerTextStyle:
          map['cajaBannerTextStyle'] as TextStyle? ??
          defecto.cajaBannerTextStyle,
      alertaObsolescenciaColor:
          map['alertaObsolescenciaColor'] as Color? ??
          defecto.alertaObsolescenciaColor,
    );
  }
}

/// =====================================================================
/// SELECTOR DINÁMICO DE TEMAS — Informe Global §4.2.1 (AppThemeSelector)
/// Widget público que evalúa la configuración persistida y determina
/// cuál de los tres temas oficiales debe aplicarse. Envuelve el motor
/// interno ThemeController y lo expone de forma reactiva a toda la app.
/// =====================================================================
class AppThemeSelector extends InheritedNotifier<ThemeController> {
  const AppThemeSelector({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Acceso reactivo: el widget que llama a este método se reconstruye
  /// automáticamente cuando el tema cambia.
  static ThemeController of(BuildContext context) {
    final selector = context
        .dependOnInheritedWidgetOfExactType<AppThemeSelector>();
    assert(
      selector != null,
      'AppThemeSelector.of() fue llamado sin un AppThemeSelector ancestro. '
      'Envuelve tu MaterialApp con AppThemeSelector(controller: ..., child: ...).',
    );
    return selector!.notifier!;
  }
}
