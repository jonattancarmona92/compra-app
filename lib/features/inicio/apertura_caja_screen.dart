// ==================== ARCHIVO: lib/features/inicio/apertura_caja_screen.dart ====================
// Apertura de Caja — Informe Global §2.2 (Barrera de Enrutamiento).
// "Es obligatorio abrir la Caja para acceder al Dashboard... El
// sistema propone como saldo inicial el saldo final del cierre
// anterior. En la primera ejecución (Día Cero), se permite el
// ingreso manual del saldo inicial. Bajo ninguna circunstancia se
// admiten valores negativos."
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/diseno.dart';
import '../configuraciones/actualizacion_en_curso_provider.dart';
import 'control_inicio_provider.dart';

class AperturaCajaScreen extends ConsumerStatefulWidget {
  /// Saldo final del cierre de caja anterior, que el sistema debe
  /// proponer automáticamente (§2.2). Es `null` únicamente en Día
  /// Cero, donde el informe autoriza el ingreso manual.
  ///
  /// NOTA DE INTEGRACIÓN PENDIENTE: este valor debe obtenerse del
  /// último registro de `cierres_caja` (§5.5.3) una vez conectemos el
  /// Módulo 5 (Drift). Por ahora se recibe como parámetro opcional
  /// para dejar el contrato listo; mientras no haya base de datos,
  /// dashboard_screen.dart lo invoca sin este argumento (Día Cero).
  final double? saldoPropuesto;

  const AperturaCajaScreen({super.key, this.saldoPropuesto});

  @override
  ConsumerState<AperturaCajaScreen> createState() => _AperturaCajaScreenState();
}

class _AperturaCajaScreenState extends ConsumerState<AperturaCajaScreen> {
  late final TextEditingController _saldoController;
  bool _guardando = false;

  bool get _esDiaCero => widget.saldoPropuesto == null;

  @override
  void initState() {
    super.initState();
    _saldoController = TextEditingController(
      text: _esDiaCero ? '' : _formatearParaEdicion(widget.saldoPropuesto!),
    );
  }

  @override
  void dispose() {
    _saldoController.dispose();
    super.dispose();
  }

  String _formatearParaEdicion(double valor) {
    return CurrencyFormatter.formatValue(valor);
  }

  Future<void> _abrirCaja() async {
    if (_guardando) return;

    // Regla de negocio: no se abre la Caja durante una actualización en curso.
    final actualizacion = ref.read(actualizacionEnCursoProvider);
    if (actualizacion.enCurso) {
      Notificaciones.error(
        context,
        'No se puede abrir la Caja mientras hay una actualización en proceso '
        '(${_porcentajeEtiqueta(actualizacion)}).',
      );
      return;
    }

    final texto = _saldoController.text.trim();
    final saldo = texto.isEmpty ? null : CurrencyFormatter.parseValue(texto);

    // §2.2: "Bajo ninguna circunstancia se admiten valores negativos."
    // Mínimo de $100 para valores positivos ($0 solo se acepta como
    // apertura sin dinero en efectivo).
    if (saldo == null ||
        saldo < 0 ||
        (saldo > 0 && saldo < CurrencyFormatter.minimo)) {
      Notificaciones.error(
        context,
        'Ingrese un saldo inicial válido (mínimo '
        '${CurrencyFormatter.formatValue(CurrencyFormatter.minimo)}).',
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await ref.read(controlInicioProvider.notifier).abrirCaja(saldo.toInt());

      if (!mounted) return;

      final estado = ref.read(controlInicioProvider);

      if (estado.isCajaAbierta) {
        Notificaciones.exito(context, 'Caja abierta correctamente.');
      } else {
        Notificaciones.error(context, 'No fue posible abrir la Caja.');
      }
    } catch (_) {
      if (!mounted) return;
      Notificaciones.error(context, 'No fue posible abrir la Caja.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _porcentajeEtiqueta(ActualizacionEnCurso actualizacion) {
    final mensaje = actualizacion.mensaje.trim();
    if (mensaje.isNotEmpty) return mensaje;
    return '${actualizacion.progreso.round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = ref.watch(controlInicioProvider);
    final actualizacion = ref.watch(actualizacionEnCursoProvider);
    final bloqueadaPorActualizacion = actualizacion.enCurso;
    final habilitado =
        !_guardando && estado.isPeriodoActivo && !bloqueadaPorActualizacion;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Apertura de Caja'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppEspaciado.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildIcono(),
                  const SizedBox(height: AppEspaciado.xl),
                  Text(
                    'Abrir Caja',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppPaletaOficial.cafe,
                      fontSize: AppEscalaTipografica.subtitulo + 2,
                    ),
                  ),
                  const SizedBox(height: AppEspaciado.s),
                  Text(
                    _esDiaCero
                        ? 'Ingrese el saldo disponible con el que inicia la '
                              'jornada operativa.'
                        : 'Confirme o ajuste el saldo propuesto, calculado a '
                              'partir del cierre anterior.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppEspaciado.xl),
                  _buildEstadoPeriodo(theme, estado),
                  if (bloqueadaPorActualizacion) ...[
                    const SizedBox(height: AppEspaciado.m),
                    _buildBloqueoActualizacion(theme, actualizacion),
                  ],
                  const SizedBox(height: AppEspaciado.l),
                  if (!_esDiaCero) ...[
                    _buildBadgeSaldoPropuesto(theme),
                    const SizedBox(height: AppEspaciado.m),
                  ],
                  TextField(
                    controller: _saldoController,
                    enabled: habilitado,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyFormatter()],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Saldo inicial',
                      prefixIcon: Icon(Icons.payments_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _abrirCaja(),
                  ),
                  const SizedBox(height: AppEspaciado.l),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
onPressed: _guardando || !estado.isPeriodoActivo ||
                            bloqueadaPorActualizacion
                        ? null
                        : _abrirCaja,
                      icon: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_open_outlined),
                      label: Text(_guardando ? 'ABRIENDO...' : 'ABRIR CAJA'),
                    ),
                  ),
                  const SizedBox(height: AppEspaciado.l),
                  _buildAviso(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcono() {
    return Center(
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: AppPaletaOficial.cafe.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          AppIconos.cajaRegistradora,
          size: 34,
          color: AppPaletaOficial.cafe,
        ),
      ),
    );
  }

  Widget _buildBadgeSaldoPropuesto(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspaciado.m,
        vertical: AppEspaciado.s,
      ),
      decoration: BoxDecoration(
        color: AppPaletaOficial.verde.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
        border: Border.all(
          color: AppPaletaOficial.verde.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 18, color: AppPaletaOficial.verde),
          const SizedBox(width: AppEspaciado.s),
          Flexible(
            child: Text(
              'Propuesto desde el cierre anterior: '
              '${CurrencyFormatter.formatValue(widget.saldoPropuesto!)}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppPaletaOficial.verde,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoPeriodo(ThemeData theme, ControlInicioEstado estado) {
    final activo = estado.isPeriodoActivo;

    return Container(
      padding: const EdgeInsets.all(AppEspaciado.l),
      decoration: BoxDecoration(
        color: activo
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Row(
        children: [
          Icon(
            activo ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            color: activo
                ? AppPaletaOficial.cafe
                : theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppEspaciado.m),
          Expanded(
            child: Text(
              activo
                  ? 'Período operativo activo.'
                  : 'El período operativo aún no está disponible.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: activo
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloqueoActualizacion(
    ThemeData theme,
    ActualizacionEnCurso actualizacion,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppEspaciado.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.system_update_alt,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: AppEspaciado.m),
              Expanded(
                child: Text(
                  'Actualización en proceso',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppEspaciado.m),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppEspaciado.radioEstandar),
            child: LinearProgressIndicator(
              value: (actualizacion.progreso / 100).clamp(0, 1),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppEspaciado.s),
          Text(
            actualizacion.mensaje,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAviso(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppEspaciado.l),
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
              'La Caja debe abrirse antes de iniciar las operaciones del día.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
