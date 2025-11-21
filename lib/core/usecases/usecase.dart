/// Clase base abstracta para casos de uso
///
/// [Type] es el tipo de dato que retorna el caso de uso
/// [Params] es el tipo de parámetros que recibe el caso de uso
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Clase para casos de uso que no requieren parámetros
class NoParams {
  const NoParams();
}
