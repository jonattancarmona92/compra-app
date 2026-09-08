// ==================== ARCHIVO: lib/features/inicio/configuracion_inicial_screen.dart ====================
// Día Cero — Informe Global §1.5 / §2.2.
// Paso 1: ID de Dispositivo (mostrado, generado automáticamente) +
//         Clave Maestra CC-MK-01 (validación NTP).
// Paso 2: Registro de Patrón (9 puntos) + PIN (4 dígitos).
// Los campos de Negocio/NIT/Propietario/Impresora NO pertenecen a Día
// Cero (pertenecen a Configuraciones → Factura/Impresora, §3.8) y se
// excluyen deliberadamente de esta pantalla.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../../core/widgets/patron_lock_widget.dart';
import '../../core/widgets/pin_entry_widget.dart';
import '../configuraciones/licencia_provider.dart';
import 'control_inicio_provider.dart';

enum _PasoDiaCero { activacion, credenciales }

/// Sub-pasos secuenciales del registro de credenciales (§2.2):
/// Patrón → Confirmar Patrón → PIN → Confirmar PIN.
enum _PasoCredencial {
  patron,
  confirmarPatron,
  pin,
  confirmarPin,
}

class ConfiguracionInicialScreen extends ConsumerStatefulWidget {
  const ConfiguracionInicialScreen({super.key});

  @override
  ConsumerState<ConfiguracionInicialScreen> createState() =>
      _ConfiguracionInicialScreenState();
}

class _ConfiguracionInicialScreenState
    extends ConsumerState<ConfiguracionInicialScreen> {
  _PasoDiaCero _paso = _PasoDiaCero.activacion;

  // Paso 1
  final _formActivacionKey = GlobalKey<FormState>();
  final _claveMaestraController = TextEditingController();
  bool _ocultarClaveMaestra = true;
  bool _validandoActivacion = false;

  // Paso 2 — registro secuencial de credenciales
  _PasoCredencial _pasoCredencial = _PasoCredencial.patron;
  String? _patronIngresado;
  String? _patronConfirmado;
  String? _pinIngresado;
  bool _guardandoCredenciales = false;
  PatronLockEstado _estadoPatron = PatronLockEstado.normal;
  bool _credencialesCompletas = false;

  @override
  void dispose() {
    _claveMaestraController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // PASO 1 — ACTIVACIÓN (§1.5 / §1.4)
  // ==========================================================================

  Future<void> _validarActivacion() async {
    if (!_formActivacionKey.currentState!.validate() || _validandoActivacion) {
      return;
    }

    setState(() => _validandoActivacion = true);

    final notifier = ref.read(controlInicioProvider.notifier);
    final exito = await notifier.validarActivacion(
      claveMaestraIngresada: _claveMaestraController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _validandoActivacion = false);

    if (exito) {
      Notificaciones.exito(context, 'Activación validada correctamente.');
      setState(() => _paso = _PasoDiaCero.credenciales);
    } else {
      final estado = ref.read(controlInicioProvider);
      Notificaciones.error(
        context,
        estado.errorHoraLegal ?? 'No fue posible validar la activación.',
      );
    }
  }

  // ==========================================================================
  // PASO 2 — PATRÓN + PIN (§2.2)
  // ==========================================================================

  void _onPrimerPatron(String patronSerializado) {
    setState(() {
      _patronIngresado = patronSerializado;
      _estadoPatron = PatronLockEstado.exito;
      _pasoCredencial = _PasoCredencial.confirmarPatron;
      _patronConfirmado = null;
    });
    Notificaciones.informacion(
      context,
      'Patrón registrado. Confírmelo trazando el mismo patrón.',
    );
  }

  void _onConfirmacionPatron(String patronSerializado) {
    if (patronSerializado == _patronIngresado) {
      setState(() {
        _patronConfirmado = patronSerializado;
        _estadoPatron = PatronLockEstado.exito;
        _pasoCredencial = _PasoCredencial.pin;
      });
      Notificaciones.informacion(
        context,
        'Patrón confirmado. Ahora defina su PIN de 4 dígitos.',
      );
    } else {
      setState(() => _estadoPatron = PatronLockEstado.error);
      Notificaciones.error(
        context,
        'Los patrones no coinciden. Vuelva a trazar el patrón inicial.',
      );
      Future.delayed(AppAnimaciones.fade * 2, () {
        if (mounted && _pasoCredencial == _PasoCredencial.confirmarPatron) {
          setState(() => _estadoPatron = PatronLockEstado.normal);
        }
      });
    }
  }

  void _reiniciarPatron() {
    setState(() {
      _patronIngresado = null;
      _patronConfirmado = null;
      _pasoCredencial = _PasoCredencial.patron;
      _estadoPatron = PatronLockEstado.normal;
    });
  }

  void _onPinIngresado(String pin) {
    setState(() {
      _pinIngresado = pin;
      _pasoCredencial = _PasoCredencial.confirmarPin;
    });
    Notificaciones.informacion(
      context,
      'PIN registrado. Confírmelo ingresándolo nuevamente.',
    );
  }

  void _onConfirmacionPin(String pin) {
    if (pin == _pinIngresado) {
      setState(() {
        _credencialesCompletas = true;
      });
      Notificaciones.exito(
        context,
        'Credenciales confirmadas. Puede activar el sistema.',
      );
    } else {
      setState(() {
        _pinIngresado = null;
        _pasoCredencial = _PasoCredencial.pin;
      });
      Notificaciones.error(
        context,
        'Los PIN no coinciden. Ingrese su PIN nuevamente.',
      );
    }
  }

  Future<void> _guardarCredenciales() async {
    if (_guardandoCredenciales) return;

    if (!_credencialesCompletas ||
        _patronConfirmado == null ||
        _pinIngresado == null) {
      Notificaciones.error(
        context,
        'Complete la confirmación del Patrón y el PIN.',
      );
      return;
    }

    setState(() => _guardandoCredenciales = true);

    try {
      final exito = await ref
          .read(controlInicioProvider.notifier)
          .registrarCredencialesIniciales(
            patronSerializado: _patronConfirmado!,
            pin: _pinIngresado!,
          );

      if (!mounted) return;

      if (exito) {
        Notificaciones.exito(context, 'Coffee Control activado correctamente.');
      } else {
        Notificaciones.error(
          context,
          'No fue posible registrar las credenciales.',
        );
      }
    } finally {
      if (mounted) setState(() => _guardandoCredenciales = false);
    }
  }

  // ==========================================================================
  // CONSTRUCCIÓN
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = ref.watch(controlInicioProvider);
    final estadoLicencia = ref.watch(licenciaProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          estado.requiereReconfiguracionCredenciales
              ? 'Nuevas Credenciales'
              : 'Configuración Día Cero',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppEspaciado.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AnimatedSwitcher(
                duration: AppAnimaciones.fade,
                switchInCurve: AppAnimaciones.curvaEstandar,
                switchOutCurve: AppAnimaciones.curvaEstandar,
                child: estado.requiereReconfiguracionCredenciales
                    ? _buildPasoCredenciales(
                        theme,
                        estadoLicencia,
                        key: const ValueKey('reconfiguracion'),
                      )
                    : (_paso == _PasoDiaCero.activacion
                          ? _buildPasoActivacion(theme, estado)
                          : _buildPasoCredenciales(theme, estadoLicencia)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // PASO 1 — UI
  // --------------------------------------------------------------------------

  Widget _buildPasoActivacion(
    ThemeData theme,
    ControlInicioEstado estado,
  ) {
    return Form(
      key: _formActivacionKey,
      child: Column(
        key: const ValueKey('paso_activacion'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEncabezado(
            theme,
            icono: Icons.rocket_launch_outlined,
            titulo: 'Activación del sistema',
            descripcion:
                'Ingrese la Clave Maestra vigente para habilitar Coffee '
                'Control en este dispositivo.',
          ),
          const SizedBox(height: AppEspaciado.xl),
          _StepIndicator(pasoActual: 1),
          const SizedBox(height: AppEspaciado.xl),
          TextFormField(
            controller: _claveMaestraController,
            enabled: !_validandoActivacion,
            obscureText: _ocultarClaveMaestra,
            maxLength: 12,
            textCapitalization: TextCapitalization.characters,
            style: theme.textTheme.bodyLarge?.copyWith(letterSpacing: 2),
            decoration: InputDecoration(
              labelText: 'Clave Maestra (12 caracteres)',
              counterText: '',
              prefixIcon: const Icon(Icons.key_outlined),
              suffixIcon: IconButton(
                tooltip: _ocultarClaveMaestra
                    ? 'Mostrar clave'
                    : 'Ocultar clave',
                onPressed: () {
                  setState(() => _ocultarClaveMaestra = !_ocultarClaveMaestra);
                },
                icon: Icon(
                  _ocultarClaveMaestra
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              border: const OutlineInputBorder(),
              helperText: 'Vigente por 60 minutos desde su generación.',
            ),
            validator: (value) {
              final texto = value?.trim() ?? '';
              if (texto.isEmpty) return 'Campo obligatorio';
              if (texto.length != 12) {
                return 'Debe tener exactamente 12 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: AppEspaciado.xl),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _validandoActivacion ? null : _validarActivacion,
              icon: _validandoActivacion
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                estado.validandoHoraLegal
                    ? 'VALIDANDO HORA LEGAL...'
                    : (_validandoActivacion
                          ? 'VALIDANDO...'
                          : 'VALIDAR ACTIVACIÓN'),
              ),
            ),
          ),
          const SizedBox(height: AppEspaciado.l),
          _buildAviso(
            theme,
            'La validación requiere conexión a internet para confirmar la '
            'Hora Legal de Colombia. Sin ella, la activación no puede '
            'completarse.',
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // PASO 2 — UI
  // --------------------------------------------------------------------------

  Widget _buildPasoCredenciales(
    ThemeData theme,
    LicenciaEstado estadoLicencia, {
    Key? key,
  }) {
    return Column(
      key: key ?? const ValueKey('paso_credenciales'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEncabezado(
          theme,
          icono: Icons.pattern,
          titulo: 'Credenciales de uso diario',
          descripcion:
              'Registre el Patrón y el PIN que usará para desbloquear '
              'el sistema cada día.',
        ),
        const SizedBox(height: AppEspaciado.xl),
        _BannerSecuencial(pasoActual: _pasoCredencial.index + 1),
        const SizedBox(height: AppEspaciado.l),
        _buildTarjetaDispositivo(theme, estadoLicencia),
        const SizedBox(height: AppEspaciado.l),
        AnimatedSwitcher(
          duration: AppAnimaciones.fade,
          switchInCurve: AppAnimaciones.curvaEstandar,
          switchOutCurve: AppAnimaciones.curvaEstandar,
          child: _credencialesCompletas
              ? _buildCredencialesCompletas(theme)
              : _buildSubPasoActual(theme),
        ),
        const SizedBox(height: AppEspaciado.l),
        if (_credencialesCompletas) ...[
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _guardandoCredenciales ? null : _guardarCredenciales,
              icon: _guardandoCredenciales
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_outline),
              label: Text(
                _guardandoCredenciales ? 'GUARDANDO...' : 'ACTIVAR SISTEMA',
              ),
            ),
          ),
          const SizedBox(height: AppEspaciado.l),
          _buildAviso(
            theme,
            'Estas credenciales se guardan cifradas con hash y salt. '
            'La Clave Maestra solo debe usarse para recuperación.',
          ),
        ],
      ],
    );
  }

  // --------------------------------------------------------------------------
  // SUB-PASO ACTUAL (Patrón / Confirma Patrón / PIN / Confirma PIN)
  // --------------------------------------------------------------------------

  Widget _buildSubPasoActual(ThemeData theme) {
    switch (_pasoCredencial) {
      case _PasoCredencial.patron:
        return _buildPasoPatron(theme);
      case _PasoCredencial.confirmarPatron:
        return _buildPasoConfirmarPatron(theme);
      case _PasoCredencial.pin:
        return _buildPasoPin(theme, confirmando: false);
      case _PasoCredencial.confirmarPin:
        return _buildPasoPin(theme, confirmando: true);
    }
  }

  Widget _buildPasoPatron(ThemeData theme) {
    return Column(
      key: const ValueKey('credencial_patron'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Paso A — Dibuje su Patrón',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppEspaciado.m),
        Center(
          child: PatronLockWidget(
            tamano: 250,
            estadoExterno: _estadoPatron,
            onPatronCompletado: _onPrimerPatron,
          ),
        ),
        const SizedBox(height: AppEspaciado.s),
        Center(
          child: Text(
            'Trace al menos 4 puntos sin levantar el dedo.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasoConfirmarPatron(ThemeData theme) {
    return Column(
      key: const ValueKey('credencial_confirmar_patron'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Paso B — Confirme su Patrón',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppEspaciado.s),
        Center(
          child: Text(
            'Repita el mismo patrón para confirmarlo.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        Center(
          child: PatronLockWidget(
            tamano: 250,
            estadoExterno: _estadoPatron,
            minimoPuntos: 1,
            onPatronCompletado: _onConfirmacionPatron,
          ),
        ),
        const SizedBox(height: AppEspaciado.s),
        Center(
          child: TextButton.icon(
            onPressed: _reiniciarPatron,
            icon: const Icon(Icons.refresh),
            label: const Text('Volver a trazar el Patrón'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasoPin(ThemeData theme, {required bool confirmando}) {
    return Column(
      key: ValueKey(confirmando ? 'credencial_confirmar_pin' : 'credencial_pin'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          confirmando ? 'Paso D — Confirme su PIN' : 'Paso C — Defina su PIN',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppEspaciado.s),
        Center(
          child: Text(
            confirmando
                ? 'Ingrese nuevamente su PIN de 4 dígitos.'
                : 'Ingrese un PIN de 4 dígitos numéricos.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppEspaciado.m),
        PinEntryWidget(
          deshabilitado: _guardandoCredenciales,
          onCompletado: confirmando ? _onConfirmacionPin : _onPinIngresado,
        ),
        if (confirmando) ...[
          const SizedBox(height: AppEspaciado.s),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _pinIngresado = null;
                  _pasoCredencial = _PasoCredencial.pin;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Volver a ingresar el PIN'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCredencialesCompletas(ThemeData theme) {
    return Column(
      key: const ValueKey('credenciales_completas'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppEspaciado.l),
          decoration: BoxDecoration(
            color: AppPaletaOficial.verde.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
            border: Border.all(color: AppPaletaOficial.verde),
          ),
          child: Column(
            children: [
              Icon(
                Icons.lock_open_outlined,
                size: 40,
                color: AppPaletaOficial.verde,
              ),
              const SizedBox(height: AppEspaciado.m),
              Text(
                'Credenciales confirmadas',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppPaletaOficial.verde,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppEspaciado.s),
              Text(
                'Patrón y PIN registrados correctamente. Puede activar '
                'Coffee Control.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // COMPONENTES COMPARTIDOS
  // --------------------------------------------------------------------------

  Widget _buildTarjetaDispositivo(
    ThemeData theme,
    LicenciaEstado estadoLicencia,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppEspaciado.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.devices_other,
                size: 20,
                color: AppPaletaOficial.cafe,
              ),
              const SizedBox(width: AppEspaciado.s),
              Text('ID de Dispositivo', style: theme.textTheme.bodySmall),
              const Spacer(),
              IconButton(
                tooltip: 'Copiar ID',
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    _copiarDispositivo(estadoLicencia.dispositivoId),
                icon: const Icon(Icons.copy, size: 18),
              ),
            ],
          ),
          const SizedBox(height: AppEspaciado.xs),
          Text(
            estadoLicencia.dispositivoId.isEmpty
                ? '----'
                : estadoLicencia.dispositivoId,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: AppEspaciado.s),
          Text(
            'Guarde este ID: es único de este equipo y se usa para generar '
            'los PIN de recarga de su licencia.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copiarDispositivo(String id) async {
    if (id.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: id));
    if (!mounted) return;
    Notificaciones.exito(context, 'ID de dispositivo copiado');
  }

  Widget _buildEncabezado(
    ThemeData theme, {
    required IconData icono,
    required String titulo,
    required String descripcion,
  }) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppPaletaOficial.cafe.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
child: Icon(icono, size: 30, color: AppPaletaOficial.cafe),
        ),
        const SizedBox(height: AppEspaciado.m),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppPaletaOficial.cafe,
            fontSize: AppEscalaTipografica.subtitulo + 2,
          ),
        ),
        const SizedBox(height: AppEspaciado.s),
        Text(
          descripcion,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAviso(ThemeData theme, String texto) {
    return Container(
      width: double.infinity,
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
          Expanded(child: Text(texto, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

// ============================================================================
// INDICADOR DE PASOS (1/2) — puramente visual, sin lógica de negocio
// ============================================================================

class _StepIndicator extends StatelessWidget {
  final int pasoActual;

  const _StepIndicator({required this.pasoActual});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPunto(context, 1, 'Activación'),
        _buildLinea(context, activa: pasoActual >= 2),
        _buildPunto(context, 2, 'Credenciales'),
      ],
    );
  }

  Widget _buildPunto(BuildContext context, int numero, String etiqueta) {
    final activo = pasoActual >= numero;
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: activo
              ? AppPaletaOficial.cafe
              : Theme.of(context).colorScheme.outlineVariant,
          child: Text(
            '$numero',
            style: const TextStyle(
              color: AppPaletaOficial.blanco,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildLinea(BuildContext context, {required bool activa}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        height: 2,
        color: activa
            ? AppPaletaOficial.cafe
            : Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

// ============================================================================
// BANNER SECUENCIAL DE CREDENCIALES — informa en qué sub-paso va el
// registro (Patrón → Confirmar Patrón → PIN → Confirmar PIN).
// Puramente visual, sin lógica de negocio.
// ============================================================================

class _BannerSecuencial extends StatelessWidget {
  final int pasoActual;

  const _BannerSecuencial({required this.pasoActual});

  static const _etiquetas = ['Patrón', 'Confir.', 'PIN', 'Confir.'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _etiquetas.length; i++) ...[
          _buildPunto(context, i + 1, _etiquetas[i]),
          if (i < _etiquetas.length - 1)
            _buildLinea(context, activa: pasoActual > i + 1),
        ],
      ],
    );
  }

  Widget _buildPunto(BuildContext context, int numero, String etiqueta) {
    final activo = pasoActual >= numero;
    final completado = pasoActual > numero;
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: completado
              ? AppPaletaOficial.verde
              : (activo
                    ? AppPaletaOficial.cafe
                    : Theme.of(context).colorScheme.outlineVariant),
          child: completado
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: AppPaletaOficial.blanco,
                )
              : Text(
                  '$numero',
                  style: const TextStyle(
                    color: AppPaletaOficial.blanco,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildLinea(BuildContext context, {required bool activa}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        height: 2,
        color: activa
            ? AppPaletaOficial.verde
            : Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
