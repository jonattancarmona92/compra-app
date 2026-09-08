// ==================== ARCHIVO: lib/features/clientes/models/cliente_model.dart ====================
// ClienteModel — espejo de la tabla `clientes` §5.5.5 del Informe Global.
//
// El saldo de deuda actual del cliente (cartera) NO se persiste como
// columna; se calcula dinámicamente (§5.8 "Valores Dinámicos") sumando
// préstamos menos abonos y demás obligaciones. Este modelo agrega esos
// campos derivados que la capa de clientes (ClienteProvider) completa
// al consultar el estado financiero del tercero.
class ClienteModel {
  final String id;
  final String nombreCompleto;
  final String documento;
  final String? telefono;
  final String? direccion;
  final bool creditoAutorizado;
  final double cupoMaximo;
  final bool activo;

  // ---- Campos derivados (§5.8) ----
  /// Saldo neto de deuda del cliente (el cliente debe al negocio).
  final double saldoDeuda;

  /// Indica si el cliente tiene anticipos o ventas pendientes por
  /// amortizar (relevante para el flujo de Abonos §3.3.2).
  final bool tieneAnticipos;

  const ClienteModel({
    required this.id,
    required this.nombreCompleto,
    required this.documento,
    this.telefono,
    this.direccion,
    this.creditoAutorizado = false,
    this.cupoMaximo = 0,
    this.activo = true,
    this.saldoDeuda = 0,
    this.tieneAnticipos = false,
  });

  /// §3.3.2: cupo máximo por defecto que se aplica a un cliente con
  /// crédito autorizado al que no se le asignó un cupo máximo explícito.
  static const double cupoMaximoPorDefectoCredito = 1000000;

  /// §3.3.2: cupo máximo efectivo de crédito. Si al cliente no se le
  /// asignó cupo máximo (`cupoMaximo <= 0`) pero tiene crédito
  /// autorizado, se le asigna el cupo por defecto de $1'000.000.
  double get cupoMaximoEfectivo {
    if (cupoMaximo > 0) return cupoMaximo;
    return creditoAutorizado ? cupoMaximoPorDefectoCredito : 0;
  }

  /// §3.3.2: cupo disponible = cupo máximo efectivo - deuda acumulada.
  double get cupoDisponible {
    final disponible = cupoMaximoEfectivo - saldoDeuda;
    return disponible < 0 ? 0 : disponible;
  }

  ClienteModel copyWith({
    String? nombreCompleto,
    String? documento,
    String? telefono,
    String? direccion,
    bool? creditoAutorizado,
    double? cupoMaximo,
    bool? activo,
    double? saldoDeuda,
    bool? tieneAnticipos,
  }) {
    return ClienteModel(
      id: id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      documento: documento ?? this.documento,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      creditoAutorizado: creditoAutorizado ?? this.creditoAutorizado,
      cupoMaximo: cupoMaximo ?? this.cupoMaximo,
      activo: activo ?? this.activo,
      saldoDeuda: saldoDeuda ?? this.saldoDeuda,
      tieneAnticipos: tieneAnticipos ?? this.tieneAnticipos,
    );
  }
}
