// ==================== ARCHIVO: lib/features/configuraciones/configuraciones_provider.dart ====================
// Módulo de Configuraciones — Informe Global §3.6.
// Administra la configuración general de la aplicación: datos de factura,
// impresora, seguridad, copias de seguridad y complementos.
//
// NOTA DE INTEGRACIÓN PENDIENTE: este provider usa un repositorio en
// memoria. En el Módulo 5 (Drift) y en la persistencia real
// (SharedPreferences) se reemplaza sin cambiar la interfaz pública del
// Notifier.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/services/comprobante_servicio.dart';
import '../../core/utilitarios/calculos_operaciones.dart';

// ============================================================================
// MODELOS
// ============================================================================

class DatosFactura {
  final String razonSocial;
  final String nit;
  final String direccion;
  final String telefono;
  final String ciudad;
  final String resolucionDian;
  final String vigenciaResolucion;
  final String mensajePie;

  const DatosFactura({
    this.razonSocial = 'Cooperativa de Caficultores',
    this.nit = '890.000.000-0',
    this.direccion = 'Calle 1 # 2-3',
    this.telefono = '000 000 0000',
    this.ciudad = 'Ciudad',
    this.resolucionDian = '',
    this.vigenciaResolucion = '',
    this.mensajePie = 'Gracias por su compra',
  });

  DatosFactura copyWith({
    String? razonSocial,
    String? nit,
    String? direccion,
    String? telefono,
    String? ciudad,
    String? resolucionDian,
    String? vigenciaResolucion,
    String? mensajePie,
  }) {
    return DatosFactura(
      razonSocial: razonSocial ?? this.razonSocial,
      nit: nit ?? this.nit,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      ciudad: ciudad ?? this.ciudad,
      resolucionDian: resolucionDian ?? this.resolucionDian,
      vigenciaResolucion: vigenciaResolucion ?? this.vigenciaResolucion,
      mensajePie: mensajePie ?? this.mensajePie,
    );
  }
}

enum FormatoImpresion { pos, tsl }

/// Conveniencia para comprobantes (§8.3): convierte los datos de la
/// factura configurados en el encabezado genérico del servicio.
extension DatosFacturaComprobante on DatosFactura {
  EncabezadoComprobante get aEncabezadoComprobante => EncabezadoComprobante(
        empresa: razonSocial,
        nit: nit,
        direccion: direccion,
        telefono: telefono,
        ciudad: ciudad,
        pie: mensajePie,
      );
}

class ConfigImpresora {
  final String nombre;
  final String direccionBluetooth;
  final FormatoImpresion formato;
  final bool enlinea;
  final int copias;
  final bool cortarPapel;
  final bool imprimirLogo;

  const ConfigImpresora({
    this.nombre = 'Impresora Térmica (Bluetooth)',
    this.direccionBluetooth = '',
    this.formato = FormatoImpresion.pos,
    this.enlinea = false,
    this.copias = 1,
    this.cortarPapel = true,
    this.imprimirLogo = true,
  });

  ConfigImpresora copyWith({
    String? nombre,
    String? direccionBluetooth,
    FormatoImpresion? formato,
    bool? enlinea,
    int? copias,
    bool? cortarPapel,
    bool? imprimirLogo,
  }) {
    return ConfigImpresora(
      nombre: nombre ?? this.nombre,
      direccionBluetooth: direccionBluetooth ?? this.direccionBluetooth,
      formato: formato ?? this.formato,
      enlinea: enlinea ?? this.enlinea,
      copias: copias ?? this.copias,
      cortarPapel: cortarPapel ?? this.cortarPapel,
      imprimirLogo: imprimirLogo ?? this.imprimirLogo,
    );
  }
}

class ConfigSeguridad {
  final bool pinRequerido;
  final bool notificacionesCriticas;
  final bool confirmarCierres;

  const ConfigSeguridad({
    this.pinRequerido = true,
    this.notificacionesCriticas = true,
    this.confirmarCierres = true,
  });

  ConfigSeguridad copyWith({
    bool? pinRequerido,
    bool? notificacionesCriticas,
    bool? confirmarCierres,
  }) {
    return ConfigSeguridad(
      pinRequerido: pinRequerido ?? this.pinRequerido,
      notificacionesCriticas:
          notificacionesCriticas ?? this.notificacionesCriticas,
      confirmarCierres: confirmarCierres ?? this.confirmarCierres,
    );
  }
}

class ConfigComplementos {
  final bool cotizaciones;
  final bool ventasPos;

  /// Redondea los resultados monetarios a la unidad de mil más cercana.
  final bool redondeoMiles;

  const ConfigComplementos({
    this.cotizaciones = true,
    this.ventasPos = true,
    this.redondeoMiles = false,
  });

  ConfigComplementos copyWith({
    bool? cotizaciones,
    bool? ventasPos,
    bool? redondeoMiles,
  }) {
    return ConfigComplementos(
      cotizaciones: cotizaciones ?? this.cotizaciones,
      ventasPos: ventasPos ?? this.ventasPos,
      redondeoMiles: redondeoMiles ?? this.redondeoMiles,
    );
  }
}

// ============================================================================
// ESTADO
// ============================================================================

class ConfiguracionesEstado {
  final bool isCargando;
  final DatosFactura factura;
  final ConfigImpresora impresora;
  final ConfigSeguridad seguridad;
  final ConfigComplementos complementos;
  final DateTime? ultimaCopia;

  const ConfiguracionesEstado({
    this.isCargando = true,
    this.factura = const DatosFactura(),
    this.impresora = const ConfigImpresora(),
    this.seguridad = const ConfigSeguridad(),
    this.complementos = const ConfigComplementos(),
    this.ultimaCopia,
  });

  ConfiguracionesEstado copyWith({
    bool? isCargando,
    DatosFactura? factura,
    ConfigImpresora? impresora,
    ConfigSeguridad? seguridad,
    ConfigComplementos? complementos,
    DateTime? ultimaCopia,
  }) {
    return ConfiguracionesEstado(
      isCargando: isCargando ?? this.isCargando,
      factura: factura ?? this.factura,
      impresora: impresora ?? this.impresora,
      seguridad: seguridad ?? this.seguridad,
      complementos: complementos ?? this.complementos,
      ultimaCopia: ultimaCopia ?? this.ultimaCopia,
    );
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

class ConfiguracionesNotifier extends StateNotifier<ConfiguracionesEstado> {
  ConfiguracionesNotifier() : super(const ConfiguracionesEstado()) {
    _sincronizarRedondeo(const ConfigComplementos());
    state = state.copyWith(isCargando: false);
  }

  void _sincronizarRedondeo(ConfigComplementos complementos) {
    CurrencyFormatter.configurarRedondeo(
      complementos.redondeoMiles
          ? CalculosOperaciones.redondeoMil
          : CalculosOperaciones.redondeoCentena,
    );
  }

  void guardarFactura(DatosFactura factura) {
    state = state.copyWith(factura: factura);
  }

  void guardarImpresora(ConfigImpresora impresora) {
    state = state.copyWith(impresora: impresora);
  }

  void guardarSeguridad(ConfigSeguridad seguridad) {
    state = state.copyWith(seguridad: seguridad);
  }

  void guardarComplementos(ConfigComplementos complementos) {
    _sincronizarRedondeo(complementos);
    state = state.copyWith(complementos: complementos);
  }

  /// Realiza una copia de seguridad (simulada) y registra la fecha.
  Future<void> realizarCopia() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(ultimaCopia: DateTime.now());
  }

  /// Restaura una copia (simulada) registrando la fecha.
  Future<void> restaurarCopia() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(ultimaCopia: DateTime.now());
  }
}

final configuracionesProvider =
    StateNotifierProvider<ConfiguracionesNotifier, ConfiguracionesEstado>(
  (ref) => ConfiguracionesNotifier(),
);
