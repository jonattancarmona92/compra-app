// ==================== ARCHIVO: test/currency_formato_test.dart ====================
// Protocolo del formato de moneda colombiana (§4.2.1):
//   - Símbolo $ al INICIO, nunca al final.
//   - Sin decimales; separadores de miles.
//   - Valor mínimo de $100 en TODO campo monetario.
//   - Redondeo configurable a la unidad de mil (Complementos).
import 'package:flutter_test/flutter_test.dart';

import 'package:compra/core/diseno.dart';

void main() {
  setUp(() => CurrencyFormatter.configurarRedondeo(0));

  group('CurrencyFormatter.formato', () {
    test('símbolo \$ al inicio y sin decimales', () {
      expect(CurrencyFormatter.formatValue(1500), r'$1.500');
      expect(CurrencyFormatter.formatValue(1800000), r'$1.800.000');
      expect(CurrencyFormatter.formatValue(0), r'$0');
    });

    test('parseValue descarta símbolo y separadores', () {
      expect(CurrencyFormatter.parseValue(r'$ 1.800.000'), 1800000.0);
      expect(CurrencyFormatter.parseValue('5000'), 5000.0);
      expect(CurrencyFormatter.parseValue(''), 0.0);
    });

    test('el texto no termina con el símbolo', () {
      expect(CurrencyFormatter.formatValue(2500).endsWith(r'$'), isFalse);
    });
  });

  group('CurrencyFormatter.minimo (\$100)', () {
    test('valores inferiores a \$100 se rechazan', () {
      expect(CurrencyFormatter.validar(''), isNotNull);
      expect(CurrencyFormatter.validar(r'$50'), isNotNull);
      expect(CurrencyFormatter.validar(r'$99'), isNotNull);
    });

    test('valores desde \$100 son válidos', () {
      expect(CurrencyFormatter.validar(r'$100'), isNull);
      expect(CurrencyFormatter.validar(r'$5.000'), isNull);
    });

    test('validarCeroPermitido acepta \$0 pero no \$1..\$99', () {
      expect(CurrencyFormatter.validarCeroPermitido('0'), isNull);
      expect(CurrencyFormatter.validarCeroPermitido(r'$75'), isNotNull);
      expect(CurrencyFormatter.validarCeroPermitido(r'$100'), isNull);
    });
  });

  group('CurrencyFormatter.redondeo a la unidad de mil', () {
    test('desactivado por defecto', () {
      expect(CurrencyFormatter.formatValue(1499), r'$1.499');
    });

    test('activado redondea al múltiplo de \$1.000 más cercano', () {
      CurrencyFormatter.configurarRedondeo(1000);
      expect(CurrencyFormatter.formatValue(1499), r'$1.000');
      expect(CurrencyFormatter.formatValue(1500), r'$2.000');
      expect(CurrencyFormatter.formatValue(25500), r'$26.000');
      CurrencyFormatter.configurarRedondeo(0);
    });

    test('la entrada en los campos NO se redondea', () {
      CurrencyFormatter.configurarRedondeo(1000);
      final resultado = CurrencyFormatter().formatEditUpdate(
            const TextEditingValue(text: ''),
            const TextEditingValue(text: '1499'),
          );
      expect(resultado.text, r'$1.499');
      CurrencyFormatter.configurarRedondeo(0);
    });
  });
}