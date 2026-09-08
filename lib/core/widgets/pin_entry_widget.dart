// ==================== ARCHIVO: lib/core/widgets/pin_entry_widget.dart ====================
// Único componente de PIN de la aplicación — Informe Global §1.1 "PIN:
// código de 4 dígitos numéricos" y §8.4.
//
// 1) `PinEntryWidget`: entrada de PIN por teclado numérico. Widget
//    reutilizable (Día Cero y Desbloqueo): muestra la cantidad de
//    dígitos como círculos y captura el PIN con un teclado numérico en
//    pantalla, invocando [onCompletado] al alcanzar la longitud exacta.
// 2) `showPinValidationDialog`: diálogo que usa el mismo PinEntryWidget
//    para las operaciones sensibles que exigen confirmación con PIN.
//
// El PIN es único: se configura una sola vez en el primer inicio y sirve
// para entrar a la aplicación y para validar operaciones, igual que el
// patrón usa un solo PatronLockWidget.
import 'package:flutter/material.dart';

import '../diseno.dart';

/// Teclado numérico con indicador visual de dígitos (PIN).
class PinEntryWidget extends StatefulWidget {
  final bool deshabilitado;

  /// Cantidad exacta de dígitos del PIN (predeterminado: 4).
  final int longitud;

  /// Se invoca al alcanzar la longitud completa del PIN.
  final void Function(String pin) onCompletado;

  /// Se invoca con cada dígito introducido o borrado (útil para
  /// limpiar mensajes de error en pantalla mientras el usuario tipea).
  final VoidCallback? onCambio;

  const PinEntryWidget({
    super.key,
    required this.onCompletado,
    this.deshabilitado = false,
    this.longitud = 4,
    this.onCambio,
  });

  @override
  State<PinEntryWidget> createState() => _PinEntryWidgetState();
}

class _PinEntryWidgetState extends State<PinEntryWidget> {
  String _digitos = '';

  void _onDigito(String digito) {
    if (widget.deshabilitado || _digitos.length >= widget.longitud) return;
    setState(() => _digitos += digito);
    widget.onCambio?.call();
    if (_digitos.length == widget.longitud) {
      final pin = _digitos;
      _digitos = '';
      widget.onCompletado(pin);
    }
  }

  void _onBorrar() {
    if (widget.deshabilitado || _digitos.isEmpty) return;
    setState(() {
      _digitos = _digitos.substring(0, _digitos.length - 1);
    });
    widget.onCambio?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.longitud, (i) {
            final lleno = i < _digitos.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppEspaciado.s),
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
          deshabilitado: widget.deshabilitado,
          onDigito: _onDigito,
          onBorrar: _onBorrar,
        ),
      ],
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

// ==================== DIÁLOGO DE VALIDACIÓN DE PIN ====================
// Operaciones sensibles (anular/editar movimientos, cerrar caja, cartera,
// etc.) exigen confirmación con el PIN único. La validación real se delega
// a un callback ([Future<bool> Function(String pin)]) que normalmente
// apunta al método `validarPinOperativo` del ControlInicioNotifier. Se
// devuelve `true` únicamente si el callback confirmó el PIN.

/// Muestra el diálogo de PIN y resuelve `true` solo si la validación
/// fue exitosa. Retorna `false` si el usuario cancela o si el PIN es
/// incorrecto (/concedido).
Future<bool> showPinValidationDialog(
  BuildContext context, {
  required Future<bool> Function(String pin) onValidate,
  String titulo = 'Confirmar con PIN',
  String mensaje = 'Ingrese su PIN de seguridad de 4 dígitos',
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PinValidationDialog(
      onValidate: onValidate,
      titulo: titulo,
      mensaje: mensaje,
    ),
  );
  return resultado ?? false;
}

class _PinValidationDialog extends StatefulWidget {
  final Future<bool> Function(String pin) onValidate;
  final String titulo;
  final String mensaje;

  const _PinValidationDialog({
    required this.onValidate,
    required this.titulo,
    required this.mensaje,
  });

  @override
  State<_PinValidationDialog> createState() => _PinValidationDialogState();
}

class _PinValidationDialogState extends State<_PinValidationDialog> {
  bool _validando = false;
  bool _mostrarError = false;

  Future<void> _validar(String pin) async {
    if (_validando) return;
    setState(() => _validando = true);

    final correcto = await widget.onValidate(pin);

    if (!mounted) return;

    if (correcto) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _validando = false;
        _mostrarError = true;
      });
    }
  }

  void _limpiarError() {
    if (!_mostrarError) return;
    setState(() => _mostrarError = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEspaciado.radioEstandar),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppEspaciado.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 40,
              color: AppPaletaOficial.cafe,
            ),
            const SizedBox(height: AppEspaciado.m),
            Text(
              widget.titulo,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppEspaciado.s),
            Text(
              widget.mensaje,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppEspaciado.l),
            PinEntryWidget(
              deshabilitado: _validando,
              onCambio: _limpiarError,
              onCompletado: _validar,
            ),
            if (_mostrarError) ...[
              const SizedBox(height: AppEspaciado.m),
              Text(
                'PIN incorrecto. Intente nuevamente.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppPaletaOficial.rojo,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}