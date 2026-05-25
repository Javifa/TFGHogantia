import '../../../core/errors/app_exception.dart';
import '../models/estancia.dart';
import '../repositories/estancias_repository.dart';

/// Servicio de estancias.
/// Lógica de negocio — validaciones y reglas.
class EstanciasService {
  final EstanciasRepository _repository;

  EstanciasService({EstanciasRepository? repository})
    : _repository = repository ?? EstanciasRepository();

  /// Obtiene todas las estancias del usuario.
  Future<List<Estancia>> obtenerTodas(String usuarioId) async {
    return await _repository.obtenerTodas(usuarioId);
  }

  /// Obtiene una estancia por ID.
  Future<Estancia> obtenerPorId(String id) async {
    return await _repository.obtenerPorId(id);
  }

  /// Crea una nueva estancia con validación.
  Future<Estancia> crear(Estancia estancia) async {
    _validar(estancia);
    return await _repository.crear(estancia);
  }

  /// Actualiza una estancia con validación.
  Future<Estancia> actualizar(Estancia estancia) async {
    _validar(estancia);
    return await _repository.actualizar(estancia);
  }

  /// Elimina una estancia.
  /// Los productos asociados se eliminan en cascada (DB).
  Future<void> eliminar(String id) async {
    await _repository.eliminar(id);
  }

  /// Validaciones de negocio para estancias.
  void _validar(Estancia estancia) {
    if (estancia.nombre.trim().isEmpty) {
      throw const AppException('El nombre de la estancia es obligatorio');
    }
    if (estancia.nombre.length > 50) {
      throw const AppException('El nombre no puede exceder 50 caracteres');
    }
  }
}
