import '../entities/impostor_type.dart';

abstract class ImpostorTypeRepository {
  Future<List<ImpostorType>> getImpostorTypes();
}
