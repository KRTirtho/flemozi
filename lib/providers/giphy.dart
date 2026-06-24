import 'package:flemozi/collections/env.dart';
import 'package:flemozi/services/giphy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final giphyProvider = Provider((ref) => GiphyClient(apiKey: Env.giphy));
