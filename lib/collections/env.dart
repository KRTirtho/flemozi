import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static final String tenor = dotenv.get('TENOR_API_KEY');
  static final String giphy = dotenv.get('GIPHY_API_KEY');

  static configure() async {
    await dotenv.load(fileName: ".env");
  }
}
