import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_service_interface.dart';

class OcrServiceImpl implements OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<DatosTicketDetectados?> procesarTicket(String imagePath, {Uint8List? imageBytes}) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String textoCompleto = recognizedText.text;
      debugPrint('Texto reconocido:\\n$textoCompleto');

      final lineas = textoCompleto.split('\\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      if (lineas.isEmpty) return null;

      String? tiendaDetectada;
      double? totalDetectado;
      DateTime? fechaDetectada;

      for (int i = 0; i < (lineas.length < 3 ? lineas.length : 3); i++) {
        final linea = lineas[i];
        if (!RegExp(r'\d').hasMatch(linea) && linea.length > 3) {
          tiendaDetectada = linea.toUpperCase();
          break;
        }
      }

      final RegExp fechaRegex = RegExp(r'\b(\d{2})[/-](\d{2})[/-](\d{4})\b');
      for (var linea in lineas) {
        final match = fechaRegex.firstMatch(linea);
        if (match != null) {
          final dia = int.tryParse(match.group(1)!);
          final mes = int.tryParse(match.group(2)!);
          final anio = int.tryParse(match.group(3)!);
          if (dia != null && mes != null && anio != null) {
            fechaDetectada = DateTime(anio, mes, dia);
            break;
          }
        }
      }

      final RegExp precioRegex = RegExp(r'(\d+[.,]\d{2})');
      bool buscandoTotal = false;

      for (var linea in lineas.reversed) {
        final lineaUpper = linea.toUpperCase();
        
        if (lineaUpper.contains('TOTAL') || lineaUpper.contains('IMPORTE') || lineaUpper.contains('PAGAR')) {
          buscandoTotal = true;
          final match = precioRegex.firstMatch(linea);
          if (match != null) {
            totalDetectado = _parsearPrecio(match.group(1)!);
            break;
          }
        } else if (buscandoTotal) {
          final match = precioRegex.firstMatch(linea);
          if (match != null) {
            totalDetectado = _parsearPrecio(match.group(1)!);
            break;
          }
        }
      }

      if (totalDetectado == null) {
        List<double> preciosPosibles = [];
        for (var linea in lineas.reversed.take(10)) {
          final matches = precioRegex.allMatches(linea);
          for (var match in matches) {
            final val = _parsearPrecio(match.group(1)!);
            if (val != null) preciosPosibles.add(val);
          }
        }
        if (preciosPosibles.isNotEmpty) {
          preciosPosibles.sort();
          totalDetectado = preciosPosibles.last;
        }
      }

      return DatosTicketDetectados(
        tienda: tiendaDetectada,
        fecha: fechaDetectada,
        total: totalDetectado,
      );

    } catch (e) {
      debugPrint('Error en OCR: $e');
      return null;
    }
  }

  double? _parsearPrecio(String texto) {
    try {
      final limpio = texto.replaceAll(',', '.');
      return double.parse(limpio);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}

OcrService getOcrService() => OcrServiceImpl();
