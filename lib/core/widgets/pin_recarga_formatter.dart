// ==================== CAMPO DE PIN DE RECARGA ====================
// Entrada protegida por formato (Documento "Pin de recarga"):
//  - Mayúsculas automáticas.
//  - Formato visual XXXXX-XXXX (guion al escribir el sexto carácter).
//  - Filtro estricto: bloquea 0, 1, I y O (alfabeto seguro).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../diseno.dart';
import '../seguridad/licencia_pin.dart';

class PinRecargaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = newValue.text.toUpperCase();
    final buffer = StringBuffer();
    for (final c in texto.split('')) {
      if (c == '-' || c == ' ') continue;
      if (!AlfabetoSeguro.esPermitido(c)) continue;
      if (buffer.length >= 10) break;
      if (buffer.length == 5) buffer.write('-');
      buffer.write(c);
    }
    final limpio = buffer.toString();
    return TextEditingValue(
      text: limpio,
      selection: TextSelection.collapsed(offset: limpio.length),
    );
  }
}

class CampoPinRecarga extends StatelessWidget {
  const CampoPinRecarga({
    super.key,
    required this.controller,
    this.habilitado = true,
  });

  final TextEditingController controller;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: habilitado,
      inputFormatters: [PinRecargaFormatter()],
      textCapitalization: TextCapitalization.characters,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      style: TextStyle(
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
        fontSize: AppEscalaTipografica.secundario,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'PIN de recarga',
        hintText: 'XXXXX-XXXX',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
        ),
      ),
    );
  }
}