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
import 'package:shared_preferences/shared_preferences.dart';

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
    this.razonSocial = '',
    this.nit = '',
    this.direccion = '',
    this.telefono = '',
    this.ciudad = '',
    this.resolucionDian = '',
    this.vigenciaResolucion = '',
    this.mensajePie = '',
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
    this.cortarPapel = false,
    this.imprimirLogo = false,
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

  /// Complemento "Ventas POS": desactivación solicitada y diferida al
  /// Cierre del Ciclo Operativo porque el ciclo vigente ya tiene ventas
  /// POS (§3.6 — regla de negocio del complemento).
  final bool ventasPosPendienteDesactivacion;

  const ConfigComplementos({
    this.cotizaciones = true,
    this.ventasPos = true,
    this.redondeoMiles = false,
    this.ventasPosPendienteDesactivacion = false,
  });

  ConfigComplementos copyWith({
    bool? cotizaciones,
    bool? ventasPos,
    bool? redondeoMiles,
    bool? ventasPosPendienteDesactivacion,
  }) {
    return ConfigComplementos(
      cotizaciones: cotizaciones ?? this.cotizaciones,
      ventasPos: ventasPos ?? this.ventasPos,
      redondeoMiles: redondeoMiles ?? this.redondeoMiles,
      ventasPosPendienteDesactivacion:
          ventasPosPendienteDesactivacion ??
          this.ventasPosPendienteDesactivacion,
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
    _cargarComplementos();
  }

  // Persistencia de complementos (SharedPreferences). El resto de la
  // configuración sigue en memoria hasta la integración del Módulo 5.
  static const _keyCotizaciones = 'complemento_cotizaciones';
  static const _keyVentasPos = 'complemento_ventas_pos';
  static const _keyRedondeoMiles = 'complemento_redondeo_miles';
  static const _keyVentasPosPendiente = 'complemento_ventas_pos_pendiente';

  Future<void> _cargarComplementos() async {
    ConfigComplementos cargados = const ConfigComplementos();
    try {
      final prefs = await SharedPreferences.getInstance();
      cargados = ConfigComplementos(
        cotizaciones: prefs.getBool(_keyCotizaciones) ?? true,
        ventasPos: prefs.getBool(_keyVentasPos) ?? true,
        redondeoMiles: prefs.getBool(_keyRedondeoMiles) ?? false,
        ventasPosPendienteDesactivacion:
            prefs.getBool(_keyVentasPosPendiente) ?? false,
      );
    } catch (_) {
      // Entorno sin SharedPreferences (tests): valores por defecto.
    }
    _sincronizarRedondeo(cargados);
    state = state.copyWith(isCargando: false, complementos: cargados);
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
    _persistirComplementos(complementos);
    state = state.copyWith(complementos: complementos);
  }

  Future<void> _persistirComplementos(ConfigComplementos complementos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyCotizaciones, complementos.cotizaciones);
      await prefs.setBool(_keyVentasPos, complementos.ventasPos);
      await prefs.setBool(_keyRedondeoMiles, complementos.redondeoMiles);
      await prefs.setBool(
        _keyVentasPosPendiente,
        complementos.ventasPosPendienteDesactivacion,
      );
    } catch (_) {
      // Entorno sin SharedPreferences (tests): se omite la persistencia.
    }
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
