import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:shared_preferences/shared_preferences.dart';

class PriceData {
  final String price;
  final String? variantionPesos;
  final String? variantionPorcentaje;
  final String? fechaCotizacion;
  final DateTime lastUpdated;

  PriceData({
    required this.price,
    this.variantionPesos,
    this.variantionPorcentaje,
    this.fechaCotizacion,
    required this.lastUpdated,
  });
}

/// Una cotización registrada en un día concreto del historial de precios.
class PrecioHistorico {
  final DateTime fecha; // normalizada a medianoche (solo día)
  final String price;

  PrecioHistorico({required this.fecha, required this.price});
}

class PriceService {
  static const String _url =
      'https://www.larepublica.co/indicadores-economicos/commodities/cafe';

  static const String _priceKey = 'last_coffee_price';
  static const String _dateKey = 'last_coffee_price_date';
  static const String _historyKey = 'coffee_price_history';
  static const String _variationPesosKey = 'last_coffee_variation_pesos';
  static const String _variationPorKey = 'last_coffee_variation_por';
  static const String _quoteDateKey = 'last_coffee_quote_date';

  Future<PriceData?> getPrice() async {
    try {
      final priceData = await _fetchPriceFromNetwork();
      await _savePriceLocally(priceData);
      return priceData;
    } catch (e) {
      return _loadPriceFromLocal();
    }
  }

  Future<PriceData> _fetchPriceFromNetwork() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final document = html.parse(response.body);

      // Busca la tarjeta del "PRECIO INTERNO BASE - CAFÉ PERGAMINO SECO",
      // que contiene el precio, la variación absoluta en pesos, la variación
      // porcentual y la fecha de la cotización.
      dom.Element? tarjeta;
      for (final element in document.querySelectorAll('.cardI')) {
        final texto = element.text.toUpperCase();
        if (texto.contains('PRECIO INTERNO BASE') &&
            texto.contains('PERGAMINO')) {
          tarjeta = element;
          break;
        }
      }

      if (tarjeta != null) {
        final precio = _extraerCantidad(
          tarjeta.querySelector('.price')?.text,
        );
        final variacionPesos = tarjeta.querySelector('.varAbs')?.text.trim();
        final variacionPorcentaje =
            tarjeta.querySelector('.varPor')?.text.trim();
        final fechaCotizacion =
            tarjeta.querySelector('.date')?.text.trim();

        if (precio != null && precio.isNotEmpty) {
          return PriceData(
            price: precio,
            variantionPesos: variacionPesos,
            variantionPorcentaje: variacionPorcentaje,
            fechaCotizacion: fechaCotizacion,
            lastUpdated: DateTime.now(),
          );
        }
      }

      throw Exception(
        'No se pudo encontrar el precio del café pergamino seco en la página.',
      );
    } else {
      throw Exception('Fallo al cargar la página: ${response.statusCode}');
    }
  }

  /// Extrae el número de un texto de precio ("$ 2.043.000,00" -> "2.043.000,00").
  String? _extraerCantidad(String? texto) {
    if (texto == null) return null;
    final match = RegExp(r'[\d.,]+').firstMatch(texto);
    return match?.group(0)?.trim();
  }

  Future<void> _savePriceLocally(PriceData data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_priceKey, data.price);

    await prefs.setString(_dateKey, data.lastUpdated.toIso8601String());

    if (data.variantionPesos != null) {
      await prefs.setString(_variationPesosKey, data.variantionPesos!);
    }
    if (data.variantionPorcentaje != null) {
      await prefs.setString(_variationPorKey, data.variantionPorcentaje!);
    }
    if (data.fechaCotizacion != null) {
      await prefs.setString(_quoteDateKey, data.fechaCotizacion!);
    }

    // Registra esta cotización en el historial diario (una entrada por día)
    // usando la fecha de cotización que publica la página cuando está
    // disponible; si no, se usa la fecha de la consulta.
    final historial = await _loadHistoryFromLocal();
    final dia = _parsearFechaCotizacion(data.fechaCotizacion) ??
        _normalizarDia(data.lastUpdated);
    final historialActualizado = {
      for (final entry in historial) entry.fecha.toIso8601String(): entry.price,
      dia.toIso8601String(): data.price,
    };
    await prefs.setString(
      _historyKey,
      historialActualizado.entries
          .map((e) => '${e.key}|${e.value}')
          .join('\n'),
    );
  }

  /// Convierte "08/09/2026" a una fecha normalizada a medianoche.
  DateTime? _parsearFechaCotizacion(String? texto) {
    if (texto == null) return null;
    final match = RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(texto.trim());
    if (match == null) return null;
    return DateTime(int.parse(match.group(3)!),
        int.parse(match.group(2)!), int.parse(match.group(1)!));
  }

  Future<List<PrecioHistorico>> _loadHistoryFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];

    final resultado = <PrecioHistorico>[];
    for (final line in raw.split('\n')) {
      final parts = line.split('|');
      if (parts.length != 2) continue;
      final fecha = DateTime.tryParse(parts[0]);
      if (fecha == null || parts[1].isEmpty) continue;
      resultado.add(
        PrecioHistorico(fecha: _normalizarDia(fecha), price: parts[1]),
      );
    }
    resultado.sort((a, b) => a.fecha.compareTo(b.fecha));
    return resultado;
  }

  DateTime _normalizarDia(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Devuelve el historial diario ordenado de más reciente a más antiguo.
  Future<List<PrecioHistorico>> obtenerHistorial() async {
    final historial = await _loadHistoryFromLocal();
    historial.sort((a, b) => b.fecha.compareTo(a.fecha));
    return historial;
  }

  Future<PriceData?> _loadPriceFromLocal() async {
    final prefs = await SharedPreferences.getInstance();

    final price = prefs.getString(_priceKey);
    final dateString = prefs.getString(_dateKey);

    if (price != null && dateString != null) {
      final lastUpdated = DateTime.tryParse(dateString);

      if (lastUpdated != null) {
        return PriceData(
          price: price,
          variantionPesos: prefs.getString(_variationPesosKey),
          variantionPorcentaje: prefs.getString(_variationPorKey),
          fechaCotizacion: prefs.getString(_quoteDateKey),
          lastUpdated: lastUpdated,
        );
      }
    }

    return null;
  }

  /// Persiste un [PriceData] (último precio + variación + historial diario).
  /// Exposición pública para pruebas y para re-guardar datos cacheados.
  Future<void> guardarDatos(PriceData data) => _savePriceLocally(data);
}
