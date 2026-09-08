// ==================== ARCHIVO: lib/features/caja/widgets/banner_caja_widget.dart ====================
// Banner de saldo de Caja — Informe Global §3.3.1:
// "Banner obligatorio en todas las pantallas del módulo de Caja:
// 'Caja Actual: $[Valor]'".
import 'package:flutter/material.dart';

import '../../../core/diseno.dart';

class BannerCajaWidget extends StatelessWidget {
  final double saldoActual;
  final String? etiquetaExtra;

  const BannerCajaWidget({
    super.key,
    required this.saldoActual,
    this.etiquetaExtra,
  });

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CoffeeCustomTheme>()!;

    return Container(
      width: double.infinity,
      color: custom.cajaBannerBackgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspaciado.l,
        vertical: AppEspaciado.m,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppPaletaOficial.blanco,
          ),
          const SizedBox(width: AppEspaciado.s),
          Expanded(
            child: Text(
              'Caja Actual: ${CurrencyFormatter.formatValue(saldoActual)}',
              style: custom.cajaBannerTextStyle,
            ),
          ),
          if (etiquetaExtra != null)
            Text(etiquetaExtra!, style: custom.cajaBannerTextStyle),
        ],
      ),
    );
  }
}
