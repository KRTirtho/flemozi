import 'package:flemozi/collections/env.dart';
import 'package:giphy_api_client/giphy_api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final giphyProvider = Provider((ref) => GiphyClient(apiKey: Env.giphy));
