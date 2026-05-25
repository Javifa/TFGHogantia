import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

/// Datos extraídos del ticket por la IA.
class DatosTicketDetectados {
  final String? tienda;
  final double? total;
  final DateTime? fecha;

  DatosTicketDetectados({this.tienda, this.total, this.fecha});
}

/// Servicio encargado de procesar imágenes y extraer texto usando ML Kit o Gemini.
class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extrae los datos relevantes de un ticket a partir de la ruta de una imagen o sus bytes (necesario en Web).
  Future<DatosTicketDetectados?> procesarTicket(String imagePath, {Uint8List? imageBytes}) async {
    // Si estamos en la web, el ML Kit no funciona nativamente. Usaremos Gemini.
    if (kIsWeb) {
      if (imageBytes == null) {
        debugPrint('Se necesitan los bytes de la imagen para procesar en Web.');
        return null;
      }
      return _procesarConGemini(imageBytes);
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String textoCompleto = recognizedText.text;
      debugPrint('Texto reconocido:\n$textoCompleto');

      final lineas = textoCompleto.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      if (lineas.isEmpty) return null;

      String? tiendaDetectada;
      double? totalDetectado;
      DateTime? fechaDetectada;

      // 1. Detección de la tienda (Heurística simple: suele estar en las 3 primeras líneas)
      // Omitimos números o fechas de las primeras líneas.
      for (int i = 0; i < (lineas.length < 3 ? lineas.length : 3); i++) {
        final linea = lineas[i];
        if (!RegExp(r'\d').hasMatch(linea) && linea.length > 3) {
          tiendaDetectada = linea.toUpperCase();
          break;
        }
      }

      // 2. Detección de Fecha (Regex buscando dd/mm/yyyy o dd-mm-yyyy)
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

      // 3. Detección del Total (Buscando "TOTAL", "IMPORTE" y el número que le sigue o está en esa línea)
      // Buscamos patrones como "TOTAL 34,50", "TOTAL € 34.50", "34.50" cerca del final.
      final RegExp precioRegex = RegExp(r'(\d+[.,]\d{2})');
      bool buscandoTotal = false;

      for (var linea in lineas.reversed) {
        final lineaUpper = linea.toUpperCase();
        
        if (lineaUpper.contains('TOTAL') || lineaUpper.contains('IMPORTE') || lineaUpper.contains('PAGAR')) {
          buscandoTotal = true;
          // Si el total está en la misma línea (Ej: "TOTAL 15,20")
          final match = precioRegex.firstMatch(linea);
          if (match != null) {
            totalDetectado = _parsearPrecio(match.group(1)!);
            break;
          }
        } else if (buscandoTotal) {
          // A veces la palabra TOTAL está arriba y el precio debajo
          final match = precioRegex.firstMatch(linea);
          if (match != null) {
            totalDetectado = _parsearPrecio(match.group(1)!);
            break;
          }
        }
      }

      // Fallback: si no encontramos la palabra TOTAL, pillamos el precio más alto del final del ticket
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
          totalDetectado = preciosPosibles.last; // El más grande suele ser el total
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

  Future<DatosTicketDetectados?> _procesarConGemini(Uint8List imageBytes) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        debugPrint('Falta la API Key de Gemini en el archivo .env');
        return null;
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      
      final prompt = TextPart(
        'Analiza esta imagen de un ticket de compra. '
        'Extrae únicamente un JSON válido con la siguiente estructura exacta y sin formato markdown: '
        '{"tienda": "Nombre del supermercado o tienda", "total": 12.34, "fecha": "YYYY-MM-DD"}. '
        'Si no encuentras algún dato, pon null. El total debe ser numérico. Ejemplo: {"tienda": "MERCADONA", "total": 34.50, "fecha": "2026-05-24"}'
      );
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      if (response.text == null) return null;

      String jsonString = response.text!.trim();
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      }

      final data = jsonDecode(jsonString);

      return DatosTicketDetectados(
        tienda: data['tienda']?.toString(),
        total: data['total'] != null ? double.tryParse(data['total'].toString()) : null,
        fecha: data['fecha'] != null ? DateTime.tryParse(data['fecha'].toString()) : null,
      );
    } catch (e) {
      debugPrint('Error en Gemini OCR: $e');
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
