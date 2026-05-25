import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ocr_service_interface.dart';

class OcrServiceImpl implements OcrService {
  @override
  Future<DatosTicketDetectados?> procesarTicket(String imagePath, {Uint8List? imageBytes}) async {
    if (imageBytes == null) {
      debugPrint('Se necesitan los bytes de la imagen para procesar en Web.');
      return null;
    }

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

  @override
  void dispose() {}
}

OcrService getOcrService() => OcrServiceImpl();
