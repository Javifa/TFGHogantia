import 'dart:typed_data';
import 'ocr_service.dart';

/// Datos extraídos del ticket por la IA.
class DatosTicketDetectados {
  final String? tienda;
  final double? total;
  final DateTime? fecha;

  DatosTicketDetectados({this.tienda, this.total, this.fecha});
}

abstract class OcrService {
  factory OcrService() => getOcrService();

  
  Future<DatosTicketDetectados?> procesarTicket(String imagePath, {Uint8List? imageBytes});
  void dispose();
}
