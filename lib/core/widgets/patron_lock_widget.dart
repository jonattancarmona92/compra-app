// ==================== ARCHIVO: lib/core/widgets/patron_lock_widget.dart ====================
// Widget de Patrón de Desbloqueo — Informe Global §1.1
// "Patrón: Matriz de 9 puntos. Es el mecanismo de desbloqueo cotidiano
// rápido." Implementa una cuadrícula táctil 3x3 con trazo por arrastre,
// tal como exige la definición del §1.1 (no un campo de texto).
//
// Ubicación: se coloca en lib/core/widgets/ porque es un componente
// visual reutilizable (Día Cero y Desbloqueo lo usan ambos), en el
// mismo espíritu de centralización de lib/core/diseno.dart (§4.14).
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../diseno.dart';

/// Estado visual externo del patrón, controlado por la pantalla que
/// lo usa (por ejemplo, para mostrar rojo tras una validación fallida
/// o verde tras una confirmación exitosa).
enum PatronLockEstado { normal, exito, error }

/// Convierte y valida la representación serializada de un patrón.
/// Formato: índices de punto (0–8) separados por guiones, ej. "0-1-4-7-8".
class PatronSerializador {
  const PatronSerializador._();

  static String serializar(List<int> puntos) => puntos.join('-');

  static List<int>? deserializar(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    try {
      final partes = valor.split('-').map(int.parse).toList();
      if (partes.any((p) => p < 0 || p > 8)) return null;
      return partes;
    } catch (_) {
      return null;
    }
  }
}

/// Matriz de 9 puntos para capturar o confirmar el Patrón de
/// Desbloqueo — Informe Global §1.1.
class PatronLockWidget extends StatefulWidget {
  /// Lado del widget cuadrado, en píxeles lógicos.
  final double tamano;

  /// Se invoca cuando el usuario levanta el dedo tras trazar un
  /// patrón que cumple el mínimo de puntos exigido.
  final void Function(String patronSerializado) onPatronCompletado;

  /// Cantidad mínima de puntos para considerar el trazo válido.
  /// El Informe Global no fija un mínimo explícito para el Patrón;
  /// se adopta 4 como práctica de seguridad estándar (equivalente al
  /// mínimo de Android Pattern Lock), documentado aquí como supuesto
  /// de diseño, no como regla del §1.1.
  final int minimoPuntos;

  final bool deshabilitado;

  /// Estado visual controlado externamente (para pintar de rojo tras
  /// un fallo de validación, o verde tras confirmar correctamente).
  final PatronLockEstado estadoExterno;

  const PatronLockWidget({
    super.key,
    required this.onPatronCompletado,
    this.tamano = 280,
    this.minimoPuntos = 4,
    this.deshabilitado = false,
    this.estadoExterno = PatronLockEstado.normal,
  });

  @override
  State<PatronLockWidget> createState() => _PatronLockWidgetState();
}

class _PatronLockWidgetState extends State<PatronLockWidget> {
  final List<int> _puntosSeleccionados = [];
  Offset? _posicionDedoActual;

  final GlobalKey _areaKey = GlobalKey();

  List<Offset> _posicionesPuntos(Size tamanoArea) {
    final margen = tamanoArea.width * 0.15;
    final disponible = tamanoArea.width - margen * 2;
    final paso = disponible / 2;

    return List.generate(9, (index) {
      final fila = index ~/ 3;
      final columna = index % 3;
      return Offset(margen + columna * paso, margen + fila * paso);
    });
  }

  double get _radioDeteccion => widget.tamano * 0.09;

  RenderBox? get _renderBox =>
      _areaKey.currentContext?.findRenderObject() as RenderBox?;

  int? _puntoEnPosicion(Offset posicionLocal, Size tamanoArea) {
    final posiciones = _posicionesPuntos(tamanoArea);
    for (var i = 0; i < posiciones.length; i++) {
      if ((posiciones[i] - posicionLocal).distance <= _radioDeteccion) {
        return i;
      }
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.deshabilitado) return;
    final box = _renderBox;
    if (box == null) return;

    setState(() {
      _puntosSeleccionados.clear();
      _posicionDedoActual = box.globalToLocal(details.globalPosition);
    });

    _evaluarToque(box.globalToLocal(details.globalPosition), box.size);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.deshabilitado) return;
    final box = _renderBox;
    if (box == null) return;

    final local = box.globalToLocal(details.globalPosition);
    setState(() => _posicionDedoActual = local);
    _evaluarToque(local, box.size);
  }

  void _evaluarToque(Offset local, Size tamanoArea) {
    final punto = _puntoEnPosicion(local, tamanoArea);
    if (punto != null && !_puntosSeleccionados.contains(punto)) {
      setState(() => _puntosSeleccionados.add(punto));
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.deshabilitado) return;

    if (_puntosSeleccionados.length >= widget.minimoPuntos) {
      widget.onPatronCompletado(
        PatronSerializador.serializar(_puntosSeleccionados),
      );
    }

    setState(() {
      _posicionDedoActual = null;
      _puntosSeleccionados.clear();
    });
  }

  Color get _colorActivo {
    switch (widget.estadoExterno) {
      case PatronLockEstado.exito:
        return AppPaletaOficial.verde;
      case PatronLockEstado.error:
        return AppPaletaOficial.rojo;
      case PatronLockEstado.normal:
        return AppPaletaOficial.cafe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimaciones.scaleUp,
      key: _areaKey,
      width: widget.tamano,
      height: widget.tamano,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          size: Size(widget.tamano, widget.tamano),
          painter: _PatronPainter(
            puntosSeleccionados: _puntosSeleccionados,
            posicionDedoActual: _posicionDedoActual,
            colorActivo: _colorActivo,
            colorInactivo: Theme.of(context).colorScheme.outlineVariant,
            posicionesPuntos: _posicionesPuntos(
              Size(widget.tamano, widget.tamano),
            ),
            radioDeteccion: _radioDeteccion,
          ),
        ),
      ),
    );
  }
}

class _PatronPainter extends CustomPainter {
  final List<int> puntosSeleccionados;
  final Offset? posicionDedoActual;
  final Color colorActivo;
  final Color colorInactivo;
  final List<Offset> posicionesPuntos;
  final double radioDeteccion;

  _PatronPainter({
    required this.puntosSeleccionados,
    required this.posicionDedoActual,
    required this.colorActivo,
    required this.colorInactivo,
    required this.posicionesPuntos,
    required this.radioDeteccion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pincelPuntoInactivo = Paint()
      ..color = colorInactivo
      ..style = PaintingStyle.fill;

    final pincelPuntoActivo = Paint()
      ..color = colorActivo
      ..style = PaintingStyle.fill;

    final pincelAnilloInactivo = Paint()
      ..color = colorInactivo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final pincelLinea = Paint()
      ..color = colorActivo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = ui.StrokeCap.round;

    // Líneas entre puntos ya seleccionados.
    for (var i = 0; i < puntosSeleccionados.length - 1; i++) {
      final desde = posicionesPuntos[puntosSeleccionados[i]];
      final hasta = posicionesPuntos[puntosSeleccionados[i + 1]];
      canvas.drawLine(desde, hasta, pincelLinea);
    }

    // Línea desde el último punto hasta la posición actual del dedo.
    if (puntosSeleccionados.isNotEmpty && posicionDedoActual != null) {
      final desde = posicionesPuntos[puntosSeleccionados.last];
      canvas.drawLine(desde, posicionDedoActual!, pincelLinea);
    }

    // Puntos (con feedback de escala al ser seleccionados — §4.13).
    for (var i = 0; i < posicionesPuntos.length; i++) {
      final seleccionado = puntosSeleccionados.contains(i);
      final centro = posicionesPuntos[i];
      final radioBase = radioDeteccion * 0.42;
      final radio = seleccionado ? radioBase * 1.25 : radioBase;

      if (seleccionado) {
        canvas.drawCircle(centro, radio, pincelPuntoActivo);
        canvas.drawCircle(
          centro,
          radio + 6,
          Paint()
            ..color = colorActivo.withValues(alpha: 0.18)
            ..style = PaintingStyle.fill,
        );
      } else {
        canvas.drawCircle(centro, radioBase * 0.55, pincelPuntoInactivo);
        canvas.drawCircle(centro, radio, pincelAnilloInactivo);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatronPainter oldDelegate) {
    return oldDelegate.puntosSeleccionados != puntosSeleccionados ||
        oldDelegate.posicionDedoActual != posicionDedoActual ||
        oldDelegate.colorActivo != colorActivo;
  }
}

/// Distancia euclidiana auxiliar (uso interno reservado para
/// extensiones futuras de sensibilidad de trazo).
double distanciaEntrePuntos(Offset a, Offset b) =>
    sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
