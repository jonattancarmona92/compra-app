// ==================== ARCHIVO: lib/features/dashboard_screen.dart ====================

import 'package:compra/core/diseno.dart';
import 'package:compra/core/services/price_service.dart';

// ============================================================================
// CAJA
// ============================================================================
import 'package:compra/features/caja/entrada_y_salida_screen.dart';
import 'package:compra/features/caja/cierres_screen.dart';
import 'package:compra/features/caja/historial_de_movimientos_screen.dart';
import 'package:compra/features/caja/prestamos_y_abonos_screen.dart';
import 'package:compra/features/caja/caja_provider.dart';

// ============================================================================
// CLIENTES
// ============================================================================
import 'package:compra/features/clientes/nuevo_cliente_screen.dart';
import 'package:compra/features/clientes/clientes_screen.dart';

// ============================================================================
// INFORMES (§3.7 / §6.2 — únicamente dos pantallas oficiales)
// ============================================================================
import 'package:compra/features/informes/cierre_operativo_screen.dart';
import 'package:compra/features/informes/cierre_caja_screen.dart';

// ============================================================================
// POS
// ============================================================================
import 'package:compra/features/pos/pos_screen.dart';

// ============================================================================
// PROCESOS
// ============================================================================
import 'package:compra/features/procesos/transacciones_screen.dart';
import 'package:compra/features/procesos/cafe_a_secar_screen.dart';
import 'package:compra/features/procesos/bodega_screen.dart';
import 'package:compra/features/procesos/liquidaciones_screen.dart';

// ============================================================================
// CONFIGURACIONES
// ============================================================================
import 'package:compra/features/configuraciones/complementos_screen.dart';
import 'package:compra/features/configuraciones/copias_de_seguridad_screen.dart';
import 'package:compra/features/configuraciones/diseno_y_estilos_screen.dart';
import 'package:compra/features/configuraciones/seguridad_screen.dart';
import 'package:compra/features/configuraciones/factura_screen.dart';
import 'package:compra/features/configuraciones/impresora_screen.dart';
import 'package:compra/features/configuraciones/actualizaciones_screen.dart';
import 'package:compra/features/configuraciones/licencia_provider.dart';
import 'package:compra/features/configuraciones/licencia_screen.dart';
import 'package:compra/features/inicio/licencia_bloqueo_screen.dart';

// ============================================================================
// INICIO
// ============================================================================
import 'package:compra/features/inicio/configuracion_inicial_screen.dart';
import 'package:compra/features/inicio/desbloqueo_screen.dart';
import 'package:compra/features/inicio/apertura_caja_screen.dart';
import 'package:compra/features/inicio/control_inicio_provider.dart';
import 'package:compra/core/widgets/baner_licencia.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final PriceService _priceService;
  late Future<PriceData?> _priceFuture;

  String? _currentMenu;
  final String _appTitle = 'Coffee Control';

  Widget? _currentScreen;

  @override
  void initState() {
    super.initState();
    _priceService = PriceService();
    _priceFuture = _priceService.getPrice();
  }

  // ==========================================================================
  // ACTUALIZACIÓN DEL BANNER DE PRECIO
  // ==========================================================================

  void _refreshPrice() {
    setState(() {
      _priceFuture = _priceService.getPrice();
    });
  }

  // ==========================================================================
  // NAVEGACIÓN GENERAL DE PANTALLAS
  // ==========================================================================

  void _openScreen(Widget Function() screenBuilder) {
    setState(() {
      _currentScreen = screenBuilder();
    });
  }

  void _closeCurrentScreen() {
    setState(() {
      _currentScreen = null;
      _currentMenu = null;
    });
  }

  void _backToMainMenu() {
    setState(() {
      _currentMenu = null;
    });
  }

  // ==========================================================================
  // SELECTOR DE MENÚ
  // ==========================================================================

  void _selectMenu(String menuName) {
    switch (menuName) {
      // ----------------------------------------------------------------------
      // PROCESOS (§3.4 — Transacciones, Café a Secar, Bodega, Liquidaciones)
      // ----------------------------------------------------------------------

      case 'Transacciones':
        _openScreen(() => TransaccionesScreen(onBack: _closeCurrentScreen));
        break;

      case 'Café a Secar':
        _openScreen(() => CafeASecarScreen(onBack: _closeCurrentScreen));
        break;

      case 'Bodega':
        _openScreen(() => BodegaScreen(onBack: _closeCurrentScreen));
        break;

      case 'Liquidaciones':
        _openScreen(() => LiquidacionesScreen(onBack: _closeCurrentScreen));
        break;

      // ----------------------------------------------------------------------
      // CAJA (§3.3 — Entradas y Salidas, Préstamos y Abonos [§3.3.2],
      // Historial de Movimientos, Cierres)
      // ----------------------------------------------------------------------

      case 'Entradas y Salidas':
        _openScreen(() => EntradaYSalidaScreen(onBack: _closeCurrentScreen));
        break;

      case 'Préstamos y Abonos':
        _openScreen(() => PrestamosYAbonosScreen(onBack: _closeCurrentScreen));
        break;

      case 'Historial de Movimientos':
        _openScreen(
          () => HistorialDeMovimientosScreen(onBack: _closeCurrentScreen),
        );
        break;

      case 'Cierres':
        _openScreen(() => CierresScreen(onBack: _closeCurrentScreen));
        break;

      // ----------------------------------------------------------------------
      // POS (§3.6 — ventana única con pestañas: Vender, Catálogo, Historial)
      // ----------------------------------------------------------------------

      case 'Punto de Venta':
        _openScreen(() => PosScreen(onBack: _closeCurrentScreen));
        break;

      // ----------------------------------------------------------------------
      // CLIENTES
      // ----------------------------------------------------------------------

      case 'Nuevo Cliente':
        _openScreen(() => NuevoClienteScreen(onBack: _closeCurrentScreen));
        break;

      case 'Clientes (Visión 360°)':
        _openScreen(() => ClientesScreen(onBack: _closeCurrentScreen));
        break;

      // ----------------------------------------------------------------------
      // INFORMES (§3.7 — solo dos pantallas oficiales)
      // ----------------------------------------------------------------------

      case 'Cierre Operativo':
        _openScreen(() => CierreOperativoScreen(onBack: _closeCurrentScreen));
        break;

      case 'Cierre de Caja':
        _openScreen(() => CierreCajaScreen(onBack: _closeCurrentScreen));
        break;

      // ----------------------------------------------------------------------
      // CONFIGURACIONES
      // ----------------------------------------------------------------------

      case 'Diseño y Estilos':
        _openScreen(() => DisenoYEstilosScreen(onBack: _closeCurrentScreen));
        break;

      case 'Copias de Seguridad':
        _openScreen(() => CopiasDeSeguridadScreen(onBack: _closeCurrentScreen));
        break;

      case 'Complementos':
        _openScreen(() => ComplementosScreen(onBack: _closeCurrentScreen));
        break;

      case 'Seguridad':
        _openScreen(() => SeguridadScreen(onBack: _closeCurrentScreen));
        break;

      case 'Factura':
        _openScreen(() => FacturaScreen(onBack: _closeCurrentScreen));
        break;

      case 'Impresora':
        _openScreen(() => ImpresoraScreen(onBack: _closeCurrentScreen));
        break;

      case 'Licencia':
        _openScreen(() => LicenciaScreen(onBack: _closeCurrentScreen));
        break;

      case 'Actualizaciones':
        _openScreen(() => ActualizacionesScreen(onBack: _closeCurrentScreen));
        break;

      // ----------------------------------------------------------------------
      // MÓDULOS PRINCIPALES (abren submenú, no pantalla)
      // ----------------------------------------------------------------------

      default:
        setState(() {
          _currentMenu = menuName;
        });
    }
  }

  // ==========================================================================
  // CAPA DE INICIO Y ARRANQUE DEL SISTEMA (§2.2)
  // ==========================================================================

  Widget? _buildInicioOverlay(
    ControlInicioEstado estado,
    bool cajaAbierta,
    bool licenciaVencida,
  ) {
    if (!estado.isConfigurado || estado.requiereReconfiguracionCredenciales) {
      return const ConfiguracionInicialScreen();
    }

    if (estado.isCargando) {
      return const _InicioLoadingOverlay();
    }

    if (!estado.isConfigurado) {
      return const ConfiguracionInicialScreen();
    }

    if (!estado.isAutenticado) {
      return const DesbloqueoScreen();
    }

    // Licencia vencida: el sistema queda bloqueado hasta recargar con un
    // PIN (Documento "Pin de recarga").
    if (licenciaVencida) {
      return const LicenciaBloqueoScreen();
    }

    if (!estado.isPeriodoActivo) {
      return const _PeriodoOperativoOverlay();
    }

    if (!cajaAbierta) {
      return const AperturaCajaScreen();
    }

    return null;
  }

  // ==========================================================================
  // CONSTRUCCIÓN PRINCIPAL
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final dashboard = Theme.of(context).extension<CoffeeCustomTheme>()!;

    final estadoInicio = ref.watch(controlInicioProvider);
    final estadoCaja = ref.watch(cajaProvider);
    final estadoLicencia = ref.watch(licenciaProvider);
    final inicioOverlay = _buildInicioOverlay(
      estadoInicio,
      estadoCaja.isCajaAbierta,
      estadoLicencia.esVencida,
    );

    final dashboardContent = Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: dashboard.dashboardPagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CoffeeAppTitle(title: _appTitle),

                    const SizedBox(height: AppEspaciado.l),

                    BanerLicenciaWidget(
                      onRenovar: () => _openScreen(
                        () => LicenciaScreen(onBack: _closeCurrentScreen),
                      ),
                    ),

                    _CoffeePriceBanner(
                      priceFuture: _priceFuture,
                      onRefresh: _refreshPrice,
                    ),

                    SizedBox(height: dashboard.dashboardSectionSpacing),

                    // ------------------------------------------------------
                    // Menú Principal / Submenú con transición Slide
                    // horizontal (§4.13 — exclusiva para submenús)
                    // ------------------------------------------------------
                    AnimatedSwitcher(
                      duration: AppAnimaciones.slideHorizontal,
                      switchInCurve: AppAnimaciones.curvaEstandar,
                      switchOutCurve: AppAnimaciones.curvaEstandar,
                      transitionBuilder: (child, animation) {
                        final inSlide = Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return ClipRect(
                          child: SlideTransition(
                            position: inSlide,
                            child: child,
                          ),
                        );
                      },
                      child: _currentMenu == null
                          ? Column(
                              key: const ValueKey('menu_principal'),
                              children: [
                                Text(
                                  'Menú Principal',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: AppEspaciado.l),
                                _DashboardMenu(onMenuSelected: _selectMenu),
                              ],
                            )
                          : Column(
                              key: ValueKey('submenu_$_currentMenu'),
                              children: [
                                Text(
                                  _currentMenu!,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: AppEspaciado.l),
                                _SubmenuView(
                                  menuName: _currentMenu!,
                                  onBack: _backToMainMenu,
                                  onMenuSelected: _selectMenu,
                                ),
                              ],
                            ),
                    ),

                    SizedBox(height: dashboard.dashboardSectionSpacing),

                    const _DashboardFooter(),
                  ],
                ),
              ),
            ),

            // Pantallas abiertas desde Dashboard
            if (_currentScreen != null)
              Positioned.fill(
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(child: _currentScreen!),
                ),
              ),

            // Pantallas obligatorias de inicio, con Fade in/out (§4.13)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: inicioOverlay == null,
                child: AnimatedSwitcher(
                  duration: AppAnimaciones.fade,
                  switchInCurve: AppAnimaciones.curvaEstandar,
                  switchOutCurve: AppAnimaciones.curvaEstandar,
                  child: inicioOverlay == null
                      ? const SizedBox.shrink(key: ValueKey('sin_overlay'))
                      : Material(
                          key: ValueKey(inicioOverlay.runtimeType),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: SafeArea(child: inicioOverlay),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return dashboardContent;
  }
}

// ============================================================================
// PANTALLA DE CARGA INICIAL
// ============================================================================

class _InicioLoadingOverlay extends StatelessWidget {
  const _InicioLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ============================================================================
// CREACIÓN AUTOMÁTICA DEL PERÍODO OPERATIVO (§2.2 — Determinación del
// Ciclo Operativo, apertura silenciosa y automática)
// ============================================================================

class _PeriodoOperativoOverlay extends ConsumerStatefulWidget {
  const _PeriodoOperativoOverlay();

  @override
  ConsumerState<_PeriodoOperativoOverlay> createState() =>
      _PeriodoOperativoOverlayState();
}

class _PeriodoOperativoOverlayState
    extends ConsumerState<_PeriodoOperativoOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(controlInicioProvider.notifier)
          .crearPeriodoOperativoSilencioso();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppEspaciado.l),
            Text(
              'Preparando período operativo...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BANNER PRECIO DEL CAFÉ (§3.2 — Banner de Inteligencia de Mercado)
// ============================================================================

class _CoffeePriceBanner extends StatelessWidget {
  final Future<PriceData?> priceFuture;
  final VoidCallback onRefresh;

  const _CoffeePriceBanner({
    required this.priceFuture,
    required this.onRefresh,
  });

  /// §3.2: alerta visual de obsolescencia si supera 24 horas sin
  /// actualización.
  bool _esObsoleto(DateTime? ultimaActualizacion) {
    if (ultimaActualizacion == null) return false;
    final diferencia = DateTime.now().difference(ultimaActualizacion);
    return diferencia.inHours >= 24;
  }

  String _formatearFecha(DateTime dt) {
    String dos(int v) => v.toString().padLeft(2, '0');
    return '${dos(dt.day)}/${dos(dt.month)}/${dt.year} '
        '${dos(dt.hour)}:${dos(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final banner = Theme.of(context).extension<CoffeeCustomTheme>()!;

    return Container(
      decoration: BoxDecoration(
        gradient: banner.priceBannerGradient,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppEspaciado.radioEstandar),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspaciado.xl,
        vertical: AppEspaciado.xl,
      ),
      child: FutureBuilder<PriceData?>(
        future: priceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final priceData = snapshot.data;
          final esObsoleto = _esObsoleto(priceData?.lastUpdated);

          return Row(
            children: [
              Icon(
                AppIconos.granoDeCafe,
                color: banner.priceBannerIconColor,
                size: 48,
              ),

              const SizedBox(width: AppEspaciado.xl),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'PRECIO CAFÉ PERGAMINO SECO',
                            style: banner.priceBannerTitleStyle,
                          ),
                        ),
                        if (esObsoleto) ...[
                          const SizedBox(width: AppEspaciado.s),
                          Tooltip(
                            message:
                                'Precio desactualizado hace más de 24 horas',
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: banner.alertaObsolescenciaColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppEspaciado.m),

                    Text(
                      priceData != null
                          ? '\$ ${priceData.price.replaceAll(RegExp(r'[.,]\d+$'), '')}'
                          : '--',
                      style: banner.priceBannerPriceStyle.copyWith(
                        color: esObsoleto
                            ? banner.alertaObsolescenciaColor
                            : banner.priceBannerPriceStyle.color,
                      ),
                    ),

                    const SizedBox(height: AppEspaciado.m),

                    Text(
                      priceData != null
                          ? 'Actualizado: ${_formatearFecha(priceData.lastUpdated)}'
                          : '--',
                      style: banner.priceBannerUpdateStyle,
                    ),

                    const SizedBox(height: AppEspaciado.m),

                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: onRefresh,
                        icon: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(Icons.refresh, size: 18),
                        ),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Actualizar'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSecondary,
                          minimumSize: const Size(80, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// MENÚ PRINCIPAL
// ============================================================================

class _DashboardMenu extends StatelessWidget {
  final Function(String) onMenuSelected;

  const _DashboardMenu({required this.onMenuSelected});

  static const List<(String, IconData)> menuItems = [
    ('Caja', Icons.attach_money),
    ('Procesos', Icons.settings),
    ('POS', Icons.shopping_cart),
    ('Clientes', Icons.people),
    ('Informes', Icons.bar_chart),
    ('Configuraciones', Icons.tune),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppEspaciado.l,
        mainAxisSpacing: AppEspaciado.l,
        childAspectRatio: 0.95,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _MenuCard(
          title: item.$1,
          icon: item.$2,
          onTap: () => onMenuSelected(item.$1),
        );
      },
    );
  }
}

// ============================================================================
// TARJETA DE MENÚ
// ============================================================================

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuCard({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final menu = Theme.of(context).extension<CoffeeCustomTheme>()!;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () {
              Notificaciones.informacion(context, '$title - Próximamente');
            },
        child: Container(
          decoration: BoxDecoration(
            color: menu.menuCardBackgroundColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppEspaciado.radioEstandar),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppEspaciado.s,
              vertical: AppEspaciado.m,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: menu.menuCardIconColor,
                  size: menu.menuCardIconSize,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: menu.menuCardTitleStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SUBMENÚS
// ============================================================================

class _SubmenuView extends StatelessWidget {
  final String menuName;
  final VoidCallback onBack;
  final Function(String) onMenuSelected;

  const _SubmenuView({
    required this.menuName,
    required this.onBack,
    required this.onMenuSelected,
  });

  /// §3.3, §3.4, §3.5, §3.6, §3.7, §3.8 — composición exacta de cada
  /// submódulo según el Informe Global.
  static const Map<String, List<(String, IconData)>> submenus = {
    // §3.3 — Módulo de Caja: Entradas y Salidas (3.3.1), Préstamos y
    // Abonos (3.3.2 — pertenece oficialmente a Caja), Historial (3.3.3),
    // Cierres (3.3.4).
    'Caja': [
      ('Entradas y Salidas', Icons.compare_arrows),
      ('Préstamos y Abonos', Icons.account_balance),
      ('Historial de Movimientos', Icons.history),
      ('Cierres', Icons.lock),
    ],
    // §3.4 — Módulo de Procesos (Núcleo Cafetero): Transacciones (3.4.1),
    // Café a Secar (3.4.2), Bodega (3.4.3), Liquidaciones (3.4.4).
    'Procesos': [
      ('Transacciones', Icons.sync_alt),
      ('Café a Secar', Icons.local_cafe),
      ('Bodega', Icons.inventory),
      ('Liquidaciones', Icons.payments),
    ],
    // §3.6 — Módulo POS: ventana única "Punto de Venta" con pestañas
    // Vender (3.6.1), Catálogo de Productos (3.6.2) e Historial (3.6.3).
    'POS': [
      ('Punto de Venta', Icons.shopping_cart),
    ],
    // §3.5 — Módulo de Clientes: Cliente Nuevo (3.5.1), Visión 360 (3.5.2).
    'Clientes': [
      ('Nuevo Cliente', Icons.person_add),
      ('Clientes (Visión 360°)', Icons.people),
    ],
    // §3.7 — Módulo de Informes: únicamente dos pantallas oficiales.
    'Informes': [
      ('Cierre Operativo', Icons.public),
      ('Cierre de Caja', Icons.receipt_long),
    ],
    // §3.8 — Módulo de Configuraciones. La Licencia se gestiona aquí
    // (estado/plan/vencimiento y recarga por PIN); el ID de dispositivo
    // no se muestra en esa pantalla (Documento "Pin de recarga").
    'Configuraciones': [
      ('Diseño y Estilos', Icons.palette),
      ('Seguridad', Icons.security),
      ('Factura', Icons.receipt),
      ('Impresora', Icons.print),
      ('Licencia', Icons.verified_user),
      ('Actualizaciones', Icons.system_update),
      ('Copias de Seguridad', Icons.backup),
      ('Complementos', Icons.extension),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final items = submenus[menuName] ?? [];
    final opciones = <(String, IconData)>[
      ...items,
      ('Volver al menú principal', Icons.arrow_back),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppEspaciado.l,
        mainAxisSpacing: AppEspaciado.l,
        childAspectRatio: 0.95,
      ),
      itemCount: opciones.length,
      itemBuilder: (context, index) {
        final item = opciones[index];
        return _MenuCard(
          title: item.$1,
          icon: item.$2,
          onTap: () {
            if (index == opciones.length - 1) {
              onBack();
            } else {
              onMenuSelected(item.$1);
            }
          },
        );
      },
    );
  }
}

// ============================================================================
// PIE DEL DASHBOARD
// ============================================================================

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppEspaciado.l),
        child: Text(
          'Coffee Control v3.0',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
