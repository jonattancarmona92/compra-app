// ==================== ARCHIVO: lib/features/inicio/desbloqueo_screen.dart ====================
// Desbloqueo Cotidiano — Informe Global §1.1/§1.2.
// Patrón (matriz de 9 puntos) → PIN (4 dígitos) → Clave Maestra
// (recuperación con validación NTP + CC-MK-01).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/widgets/patron_lock_widget.dart';
import 'control_inicio_provider.dart';

class DesbloqueoScreen extends ConsumerStatefulWidget {
  const DesbloqueoScreen({super.key});

  @override
  ConsumerState<DesbloqueoScreen> createState() => _DesbloqueoScreenState();
}

class _DesbloqueoScreenState extends ConsumerState<DesbloqueoScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _claveMaestraController = TextEditingController();

  bool _procesando = false;
  bool _ocultarClaveMaestra = true;
  PatronLockEstado _estadoPatron = PatronLockEstado.normal;

  @override
  void dispose() {
    _pinController.dispose();
    _claveMaestraController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // PROCESAMIENTO DE INTENTOS
  // ==========================================================================

  Future<void> _procesarIntento(String valorIngresado) async {
    if (_procesando) return;
    setState(() => _procesando = true);

    final notifier = ref.read(controlInicioProvider.notifier);
    final correcto = await notifier.validarCredencial(valorIngresado);

    if (!mounted) return;

    final estado = ref.read(controlInicioProvider);

    if (correcto) {
      setState(() => _estadoPatron = PatronLockEstado.exito);

      if (estado.requiereReconfiguracionCredenciales) {
        Notificaciones.informacion(
          context,
          'Acceso recuperado. Configure un nuevo Patrón y PIN.',
        );
      } else if (estado.isAutenticado) {
        Notificaciones.exito(context, 'Acceso autorizado.');
      }
    } else {
      setState(() => _estadoPatron = PatronLockEstado.error);

      if (estado.errorHoraLegal != null) {
        Notificaciones.error(context, estado.errorHoraLegal!);
      } else if (estado.isBloqueado) {
        Notificaciones.error(context, 'Acceso bloqueado temporalmente.');
      } else if (estado.nivelAutenticacion == NivelAutenticacion.pin) {
        Notificaciones.error(
          context,
          'Patrón rechazado. Ahora puede utilizar su PIN.',
        );
      } else if (estado.nivelAutenticacion == NivelAutenticacion.claveMaestra) {
        Notificaciones.error(
          context,
          'PIN rechazado. Ingrese la Clave Maestra para recuperar el acceso.',
        );
      } else {
        Notificaciones.error(context, 'Credencial incorrecta.');
      }
    }

    _pinController.clear();
    _claveMaestraController.clear();

    setState(() => _procesando = false);

    // Vuelve el trazo del patrón a su estado normal tras el feedback.
    Future.delayed(AppAnimaciones.fade * 2, () {
      if (mounted) setState(() => _estadoPatron = PatronLockEstado.normal);
    });
  }

  // ==========================================================================
  // TEXTOS SEGÚN NIVEL (§1.2)
  // ==========================================================================

  String _tituloParaNivel(int nivel) {
    switch (nivel) {
      case NivelAutenticacion.pin:
        return 'Ingrese su PIN';
      case NivelAutenticacion.claveMaestra:
        return 'Recuperación administrativa';
      default:
        return 'Desbloquear sistema';
    }
  }

  String _descripcionParaNivel(int nivel) {
    switch (nivel) {
      case NivelAutenticacion.pin:
        return 'El patrón no pudo validarse. Ingrese su PIN de operación.';
      case NivelAutenticacion.claveMaestra:
        return 'Ingrese la Clave Maestra vigente para recuperar el acceso.';
      default:
        return 'Trace su patrón de desbloqueo para continuar.';
    }
  }

  IconData _iconoParaNivel(int nivel) {
    switch (nivel) {
      case NivelAutenticacion.pin:
        return Icons.dialpad;
      case NivelAutenticacion.claveMaestra:
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.pattern;
    }
  }

  // ==========================================================================
  // CONSTRUCCIÓN
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = ref.watch(controlInicioProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Desbloqueo'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppEspaciado.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  _buildEncabezado(theme, estado),
                  const SizedBox(height: AppEspaciado.xl),
                  AnimatedSwitcher(
                    duration: AppAnimaciones.fade,
                    switchInCurve: AppAnimaciones.curvaEstandar,
                    switchOutCurve: AppAnimaciones.curvaEstandar,
                    child: estado.isBloqueado
                        ? _BloqueoView(
                            key: const ValueKey('bloqueo'),
                            segundosRestantes: estado.segundosRestantesBloqueo,
                          )
                        : _buildFormularioPorNivel(theme, estado),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado(ThemeData theme, ControlInicioEstado estado) {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: AppPaletaOficial.cafe.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _iconoParaNivel(estado.nivelAutenticacion),
            size: 34,
            color: AppPaletaOficial.cafe,
          ),
        ),
        const SizedBox(height: AppEspaciado.l),
        Text(
          _tituloParaNivel(estado.nivelAutenticacion),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppPaletaOficial.cafe,
            fontSize: AppEscalaTipografica.subtitulo + 2,
          ),
        ),
        const SizedBox(height: AppEspaciado.s),
        Text(
          _descripcionParaNivel(estado.nivelAutenticacion),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (!estado.isBloqueado) ...[
          const SizedBox(height: AppEspaciado.s),
          Text(
            'Intentos restantes en este nivel: ${estado.intentosRestantes}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormularioPorNivel(ThemeData theme, ControlInicioEstado estado) {
    switch (estado.nivelAutenticacion) {
      case NivelAutenticacion.pin:
        return _PinEntryView(
          key: const ValueKey('pin'),
          controller: _pinController,
          procesando: _procesando,
          onCompletado: _procesarIntento,
        );
      case NivelAutenticacion.claveMaestra:
        return _ClaveMaestraEntryView(
          key: const ValueKey('clave_maestra'),
          controller: _claveMaestraController,
          procesando: _procesando || estado.validandoHoraLegal,
          ocultar: _ocultarClaveMaestra,
          onToggleOcultar: () {
            setState(() => _ocultarClaveMaestra = !_ocultarClaveMaestra);
          },
          onSubmit: () => _procesarIntento(_claveMaestraController.text),
          validandoHoraLegal: estado.validandoHoraLegal,
        );
      default:
        return _PatronEntryView(
          key: const ValueKey('patron'),
          estadoVisual: _estadoPatron,
          deshabilitado: _procesando,
          onPatronCompletado: _procesarIntento,
        );
    }
  }
}

// ============================================================================
// VISTA: PATRÓN (nivel 1)
// ============================================================================

class _PatronEntryView extends StatelessWidget {
  final PatronLockEstado estadoVisual;
  final bool deshabilitado;
  final void Function(String) onPatronCompletado;

  const _PatronEntryView({
    super.key,
    required this.estadoVisual,
    required this.deshabilitado,
    required this.onPatronCompletado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PatronLockWidget(
          tamano: 260,
          deshabilitado: deshabilitado,
          estadoExterno: estadoVisual,
          onPatronCompletado: onPatronCompletado,
        ),
        const SizedBox(height: AppEspaciado.l),
        Text(
          'Trace al menos 4 puntos sin levantar el dedo.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// VISTA: PIN (nivel 2) — §1.1 "Código de 4 dígitos numéricos"
// ============================================================================

class _PinEntryView extends StatelessWidget {
  final TextEditingController controller;
  final bool procesando;
  final void Function(String) onCompletado;

  const _PinEntryView({
    super.key,
    required this.controller,
    required this.procesando,
    required this.onCompletado,
  });

  void _onDigitoPresionado(String digito) {
    if (procesando || controller.text.length >= 4) return;
    controller.text += digito;
    if (controller.text.length == 4) {
      onCompletado(controller.text);
    }
  }

  void _onBorrar() {
    if (procesando || controller.text.isEmpty) return;
    controller.text = controller.text.substring(0, controller.text.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final lleno = i < value.text.length;
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppEspaciado.s,
                  ),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lleno ? AppPaletaOficial.cafe : Colors.transparent,
                    border: Border.all(color: AppPaletaOficial.cafe, width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppEspaciado.xl),
            _TecladoNumerico(
              deshabilitado: procesando,
              onDigito: _onDigitoPresionado,
              onBorrar: _onBorrar,
            ),
          ],
        );
      },
    );
  }
}

class _TecladoNumerico extends StatelessWidget {
  final bool deshabilitado;
  final void Function(String) onDigito;
  final VoidCallback onBorrar;

  const _TecladoNumerico({
    required this.deshabilitado,
    required this.onDigito,
    required this.onBorrar,
  });

  static const _filas = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'borrar'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _filas.map((fila) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppEspaciado.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: fila.map((tecla) {
              if (tecla.isEmpty) {
                return const SizedBox(width: 72, height: 56);
              }
              if (tecla == 'borrar') {
                return _TeclaNumerica(
                  icono: Icons.backspace_outlined,
                  deshabilitado: deshabilitado,
                  onTap: onBorrar,
                );
              }
              return _TeclaNumerica(
                texto: tecla,
                deshabilitado: deshabilitado,
                onTap: () => onDigito(tecla),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _TeclaNumerica extends StatelessWidget {
  final String? texto;
  final IconData? icono;
  final bool deshabilitado;
  final VoidCallback onTap;

  const _TeclaNumerica({
    this.texto,
    this.icono,
    required this.deshabilitado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppEspaciado.s),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: deshabilitado ? null : onTap,
          child: SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: texto != null
                  ? Text(
                      texto!,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: AppEscalaTipografica.titulo),
                    )
                  : Icon(
                      icono,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// VISTA: CLAVE MAESTRA (nivel 3) — recuperación con validación NTP
// ============================================================================

class _ClaveMaestraEntryView extends StatelessWidget {
  final TextEditingController controller;
  final bool procesando;
  final bool ocultar;
  final VoidCallback onToggleOcultar;
  final VoidCallback onSubmit;
  final bool validandoHoraLegal;

  const _ClaveMaestraEntryView({
    super.key,
    required this.controller,
    required this.procesando,
    required this.ocultar,
    required this.onToggleOcultar,
    required this.onSubmit,
    required this.validandoHoraLegal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          obscureText: ocultar,
          maxLength: 12,
          textCapitalization: TextCapitalization.characters,
          enabled: !procesando,
          autofocus: true,
          style: theme.textTheme.bodyLarge?.copyWith(
            letterSpacing: 2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            labelText: 'Clave Maestra (12 caracteres)',
            counterText: '',
            prefixIcon: const Icon(Icons.key_outlined),
            suffixIcon: IconButton(
              tooltip: ocultar ? 'Mostrar clave' : 'Ocultar clave',
              onPressed: procesando ? null : onToggleOcultar,
              icon: Icon(
                ocultar
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppEspaciado.l),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: procesando ? null : onSubmit,
            icon: procesando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open_outlined),
            label: Text(
              validandoHoraLegal
                  ? 'VALIDANDO HORA LEGAL...'
                  : (procesando ? 'VALIDANDO...' : 'RECUPERAR ACCESO'),
            ),
          ),
        ),
        const SizedBox(height: AppEspaciado.l),
        Container(
          padding: const EdgeInsets.all(AppEspaciado.m),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppPaletaOficial.cafe),
              const SizedBox(width: AppEspaciado.m),
              Expanded(
                child: Text(
                  'La validación requiere conexión para confirmar la Hora Legal '
                  'de Colombia. Al recuperar el acceso deberá configurar un '
                  'nuevo Patrón y PIN.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// VISTA: BLOQUEO TEMPORAL DE 30 SEGUNDOS (§1.2)
// ============================================================================

class _BloqueoView extends StatelessWidget {
  final int segundosRestantes;

  const _BloqueoView({super.key, required this.segundosRestantes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppEspaciado.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_clock_outlined,
            size: 40,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(height: AppEspaciado.m),
          Text(
            'Acceso temporalmente bloqueado',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppEspaciado.s),
          Text(
            'Se alcanzó el límite de intentos permitidos en los tres niveles.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: AppEspaciado.l),
          Text(
            '$segundosRestantes s',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
