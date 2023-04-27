import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(obfuscate: true, requireEnvFile: true, path: ".env")
abstract class Env {
  @EnviedField(varName: 'TENOR_API_KEY')
  static final String tenor = _Env.tenor;
  @EnviedField(varName: 'GIPHY_API_KEY')
  static final String giphy = _Env.giphy;
}
