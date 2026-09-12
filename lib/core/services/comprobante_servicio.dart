// ==================== ARCHIVO: lib/core/services/comprobante_servicio.dart ====================
// Comprobantes — Informe Global §8.3, §10.2.
// Genera comprobantes en PDF (para compartir) y tiquetes ESC/POS (para
// impresión térmica Bluetooth). Toda la lógica numérica de los
// comprobantes vive en [CalculosOperaciones] (§7.8).
import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Una línea del comprobante: texto fijo o par Etiqueta/Valor.
class LineaComprobante {
  final String etiqueta;
  final String? valor;
  final bool enNegrita;
  final bool separador;

  const LineaComprobante.texto(
    this.etiqueta, {
    this.enNegrita = false,
    this.separador = false,
  }) : valor = null;

  const LineaComprobante.campo(
    this.etiqueta,
    this.valor, {
    this.enNegrita = false,
    this.separador = false,
  });

  const LineaComprobante.separador()
      : etiqueta = '',
        valor = null,
        enNegrita = false,
        separador = true;
}

/// Encabezado del comprobante (datos de factura §3.6).
class EncabezadoComprobante {
  final String empresa;
  final String? nit;
  final String? direccion;
  final String? telefono;
  final String? ciudad;
  final String? pie;

  const EncabezadoComprobante({
    required this.empresa,
    this.nit,
    this.direccion,
    this.telefono,
    this.ciudad,
    this.pie,
  });
}

class ComprobanteServicio {
  ComprobanteServicio._();

  static final ComprobanteServicio instancia = ComprobanteServicio._();

  /// Genera el PDF del comprobante (§8.3) con el encabezado de factura,
  /// las líneas y el pie configurado. Retorna los bytes del PDF.
  Future<Uint8List> generarPdf({
    required EncabezadoComprobante encabezado,
    required String titulo,
    required List<LineaComprobante> lineas,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        // No se usa PdfPageFormat.roll80: su altura es infinita y
        // MultiPage (pdf 3.x) exige altura finita (assert en
        // multi_page.dart), lo que rompe todas las generaciones.
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          297 * PdfPageFormat.mm,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              encabezado.empresa,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          if ((encabezado.nit ?? '').isNotEmpty)
            pw.Center(
              child: pw.Text(
                'NIT: ${encabezado.nit}',
                style: pw.TextStyle(fontSize: 9),
              ),
            ),
          if ((encabezado.direccion ?? '').isNotEmpty ||
              (encabezado.ciudad ?? '').isNotEmpty)
            pw.Center(
              child: pw.Text(
                [
                  if ((encabezado.direccion ?? '').isNotEmpty)
                    encabezado.direccion,
                  if ((encabezado.ciudad ?? '').isNotEmpty) encabezado.ciudad,
                ].join(' · '),
                style: pw.TextStyle(fontSize: 9),
              ),
            ),
          if ((encabezado.telefono ?? '').isNotEmpty)
            pw.Center(
              child: pw.Text(
                'Tel: ${encabezado.telefono}',
                style: pw.TextStyle(fontSize: 9),
              ),
            ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
              titulo,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
          pw.Divider(),
          for (final linea in lineas) ...[
            if (linea.separador)
              pw.Divider()
            else if (linea.valor == null)
              pw.Text(
                linea.etiqueta,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              )
            else
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      linea.etiqueta,
                      style: pw.TextStyle(
                        fontWeight: linea.enNegrita
                            ? pw.FontWeight.bold
                            : pw.FontWeight.normal,
                      ),
                    ),
                  ),
                  pw.Text(
                    linea.valor!,
                    style: pw.TextStyle(
                      fontWeight: linea.enNegrita
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),
          ],
          pw.SizedBox(height: 8),
          if ((encabezado.pie ?? '').isNotEmpty)
            pw.Center(
              child: pw.Text(
                encabezado.pie!,
                style: pw.TextStyle(fontSize: 9),
              ),
            ),
        ],
      ),
    );
    return doc.save();
  }

  /// Comparte el comprobante en PDF mediante la hoja de compartir del
  /// sistema (§8.3). Retorna `true` si la operación pudo iniciarse.
  Future<bool> compartirPdf({
    required EncabezadoComprobante encabezado,
    required String titulo,
    required List<LineaComprobante> lineas,
  }) async {
    try {
      final bytes = await generarPdf(
        encabezado: encabezado,
        titulo: titulo,
        lineas: lineas,
      );
      await Printing.sharePdf(bytes: bytes, filename: '$titulo.pdf');
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Construye un tiquete ESC/POS (papel 58 mm) a partir de líneas
/// genéricas. Respeta copias y corte de papel; codifica en Latin-1.
class TicketEscPosBuilder {
  TicketEscPosBuilder._();

  /// Igual que el ticket de prueba, pero con contenido arbitrario.
  static Uint8List construir({
    required String titulo,
    required List<String> lineas,
    required EncabezadoComprobante encabezado,
    required int copias,
    required bool cortarPapel,
  }) {
    final buffer = BytesBuilder();

    void linea(String texto) {
      buffer.add(latin1.encode(texto.contains(RegExp(r'[^\x00-\xFF]'))
          ? texto.replaceAll(RegExp(r'[^\x00-\xFF]'), '_')
          : texto));
      buffer.add(const [0x0A]);
    }

    // Inicializa la impresora (ESC @).
    buffer.add(const [0x1B, 0x40]);
    for (int c = 0; c < copias; c++) {
      if (c > 0) {
        // Avance entre copias (ESC d 3).
        buffer.add(const [0x1B, 0x64, 0x03]);
      }
      // Centrar (ESC a 1).
      buffer.add(const [0x1B, 0x61, 0x01]);
      // Doble tamaño para el título (GS ! 0x11).
      buffer.add(const [0x1D, 0x21, 0x11]);
      linea(titulo);
      buffer.add(const [0x1D, 0x21, 0x00]);
      linea('');
      linea(
        encabezado.empresa,
      );
      if ((encabezado.nit ?? '').isNotEmpty) {
        linea('NIT: ${encabezado.nit}');
      }
      linea('');
      for (final textoLinea in lineas) {
        buffer.add(const [0x1B, 0x61, 0x00]);
        linea(textoLinea);
      }
      final ahora = DateTime.now();
      final hh = ahora.hour.toString().padLeft(2, '0');
      final mm = ahora.minute.toString().padLeft(2, '0');
      final dd = ahora.day.toString().padLeft(2, '0');
      final mes = ahora.month.toString().padLeft(2, '0');
      buffer.add(const [0x1B, 0x61, 0x00]);
      linea('');
      linea('$hh:$mm  $dd/$mes/${ahora.year}');
      if ((encabezado.pie ?? '').trim().isNotEmpty) {
        linea('');
        buffer.add(const [0x1B, 0x61, 0x00]);
        linea(encabezado.pie!.trim());
      }
      // Avance final (ESC d 5).
      buffer.add(const [0x1B, 0x64, 0x05]);
    }
    if (cortarPapel) {
      // Corte parcial (GS V 66 0).
      buffer.add(const [0x1D, 0x56, 0x42, 0x00]);
    }
    return buffer.toBytes();
  }
}