// ==================== ARCHIVO: lib/core/utilitarios/calculos_operaciones.dart ====================
// Cálculos Operacionales — Informe Global §7.8.
// Fuente ÚNICA de toda lógica, ecuación y regla de redondeo de la
// aplicación. Ningún otro archivo debe implementar fórmulas de negocio.
// ============================================================================
// §7.6.2 — REDONDEO DE RESULTADOS MONETARIOS
//   * Por defecto: al múltiplo de 100 (centena) más cercano.
//     Ej: $150.230 -> $150.200 | $150.260 -> $150.300.
//   * Opcional (Configuración > Complementos "Redondear a la Unidad de
//     Mil"): al múltiplo de 1000 (milésima) más cercano.
//     Ej: $150.230 -> $150.000 | $150.600 -> $151.000.
// ============================================================================
class CalculosOperaciones {
  CalculosOperaciones._();

  /// Escala de redondeo por defecto: centena (§7.6.2).
  static const int redondeoCentena = 100;

  /// Escala de redondeo opcional: unidad de mil (§7.6.2).
  static const int redondeoMil = 1000;

  /// Redondea un valor monetario al múltiplo de [escala] más cercano.
  ///
  /// Si [escala] es cero o negativa el valor se devuelve sin cambios
  /// (equivalente a redondeo desactivado). El resultado siempre es un
  /// múltiplo exacto de la escala.
  static double redondearMoneda(double valor, {int escala = redondeoCentena}) {
    if (escala <= 0) return valor;
    return ((valor / escala).round() * escala).toDouble();
  }

  /// Normaliza una escala de redondeo configurada: valores inválidos o
  /// desactivados devuelven la centena por defecto (§7.6.2).
  static int normalizarEscala(int escala) {
    if (escala == redondeoMil) return redondeoMil;
    return redondeoCentena;
  }
}