import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ocr_service_interface.dart';

class OcrServiceImpl implements OcrService {
  @override
  Future<DatosTicketDetectados?> procesarTicket(
    String imagePath, {
    Uint8List? imageBytes,
  }) async {
    if (imageBytes == null) {
      debugPrint('Se necesitan los bytes de la imagen para procesar en Web.');
      return null;
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Falta la API Key de Gemini en el archivo .env');
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final prompt = TextPart(
      'Analiza esta imagen de un ticket de compra. '
      'Extrae únicamente un JSON válido con la siguiente estructura exacta y sin formato markdown: '
      '{"tienda": "Nombre del supermercado o tienda", "total": 12.34, "fecha": "YYYY-MM-DD"}. '
      'Si no encuentras algún dato, pon null. El total debe ser numérico. Ejemplo: {"tienda": "MERCADONA", "total": 34.50, "fecha": "2026-05-24"}',
    );

    // Intentar adivinar el mime type por los magic bytes, por defecto jpeg
    String mimeType = 'image/jpeg';
    if (imageBytes.length > 3) {
      if (imageBytes[0] == 0x89 &&
          imageBytes[1] == 0x50 &&
          imageBytes[2] == 0x4E &&
          imageBytes[3] == 0x47)
        mimeType = 'image/png';
      else if (imageBytes[0] == 0x52 &&
          imageBytes[1] == 0x49 &&
          imageBytes[2] == 0x46 &&
          imageBytes[3] == 0x46)
        mimeType = 'image/webp';
    }
    final imagePart = DataPart(mimeType, imageBytes);

    final response = await model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    if (response.text == null || response.text!.isEmpty) {
      throw Exception('Gemini devolvió una respuesta vacía');
    }

    String text = response.text!.trim();
    // Extraer JSON usando Regex por si Gemini añade texto extra
    final RegExp jsonRegExp = RegExp(r'\{[\s\S]*\}');
    final match = jsonRegExp.firstMatch(text);
    if (match == null) {
      throw Exception('No se encontró JSON en la respuesta de Gemini: $text');
    }

    final data = jsonDecode(match.group(0)!);

    return DatosTicketDetectados(
      tienda: data['tienda']?.toString(),
      total: data['total'] != null
          ? double.tryParse(data['total'].toString())
          : null,
      fecha: data['fecha'] != null
          ? DateTime.tryParse(data['fecha'].toString())
          : null,
    );
  }

  @override
  void dispose() {}
}

OcrService getOcrService() => OcrServiceImpl();
