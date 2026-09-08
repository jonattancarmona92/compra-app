import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:shared_preferences/shared_preferences.dart';

class PriceData {
  final String price;
  final DateTime lastUpdated;

  PriceData({required this.price, required this.lastUpdated});
}

class PriceService {
  static const String _url =
      'https://www.larepublica.co/indicadores-economicos/commodities/cafe';

  static const String _priceKey = 'last_coffee_price';
  static const String _dateKey = 'last_coffee_price_date';

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

      final List<dom.Element> elements = document.querySelectorAll(
        '.basic-card',
      );

      for (final element in elements) {
        final text = element.text.toUpperCase();

        if (text.contains('PRECIO INTERNO BASE') &&
            text.contains('PERGAMINO')) {
          final priceMatch = RegExp(
            r'\$?\s*([0-9.,]+)',
          ).firstMatch(element.text);

          if (priceMatch != null) {
            final price = priceMatch.group(1)?.trim() ?? '';

            if (price.isNotEmpty) {
              return PriceData(price: price, lastUpdated: DateTime.now());
            }
          }
        }
      }

      final List<dom.Element> priceElements = document.querySelectorAll(
        'span.value',
      );

      for (final element in priceElements) {
        final parent = element.parent;

        if (parent != null &&
            parent.text.toUpperCase().contains('PRECIO INTERNO BASE')) {
          final price = element.text.replaceAll(RegExp(r'[^\d.,]'), '').trim();

          if (price.isNotEmpty) {
            return PriceData(price: price, lastUpdated: DateTime.now());
          }
        }
      }

      final allText = document.body?.text ?? '';

      if (allText.contains('PRECIO INTERNO BASE')) {
        final priceMatch = RegExp(
          r'PRECIO INTERNO BASE[^0-9]*([0-9.,]+)',
        ).firstMatch(allText);

        if (priceMatch != null) {
          final price = priceMatch.group(1)?.trim() ?? '';

          if (price.isNotEmpty) {
            return PriceData(price: price, lastUpdated: DateTime.now());
          }
        }
      }

      throw Exception(
        'No se pudo encontrar el elemento del precio en la página.',
      );
    } else {
      throw Exception('Fallo al cargar la página: ${response.statusCode}');
    }
  }

  Future<void> _savePriceLocally(PriceData data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_priceKey, data.price);

    await prefs.setString(_dateKey, data.lastUpdated.toIso8601String());
  }

  Future<PriceData?> _loadPriceFromLocal() async {
    final prefs = await SharedPreferences.getInstance();

    final price = prefs.getString(_priceKey);
    final dateString = prefs.getString(_dateKey);

    if (price != null && dateString != null) {
      final lastUpdated = DateTime.tryParse(dateString);

      if (lastUpdated != null) {
        return PriceData(price: price, lastUpdated: lastUpdated);
      }
    }

    return null;
  }
}
